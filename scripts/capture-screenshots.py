#!/usr/bin/env python3
"""Build the example in a temporary iOS app and capture unmodified simulator PNGs.

Requires Xcode, an available iOS simulator runtime and an Apple Silicon Mac.
Uses a dedicated simulator named SceneWeaver Screenshots, leaving other apps alone.
"""
import json
from pathlib import Path
import plistlib
import subprocess
import tempfile
import time

ROOT = Path(__file__).resolve().parent.parent
DEVICE_NAME = 'SceneWeaver Screenshots'
BUNDLE = 'org.sceneweaver.screenshots'


def run(*args, **kwargs):
    return subprocess.run(args, check=True, **kwargs)


def output(*args):
    return subprocess.check_output(args, text=True).strip()


def main():
    inventory = json.loads(output('xcrun', 'simctl', 'list', 'devices', 'available', '--json'))
    devices = [d for group in inventory['devices'].values() for d in group if d['name'] == DEVICE_NAME]
    if len(devices) > 1:
        raise SystemExit(f'Expected one simulator named {DEVICE_NAME}; found {len(devices)}.')
    if devices:
        device = devices[0]
    else:
        runtimes = json.loads(output('xcrun', 'simctl', 'list', 'runtimes', '--json'))['runtimes']
        preferred_type = 'com.apple.CoreSimulator.SimDeviceType.iPhone-17'
        compatible = [(r, d) for r in runtimes if r['isAvailable'] and r['name'].startswith('iOS ')
                      for d in r.get('supportedDeviceTypes', []) if d['name'].startswith('iPhone ')]
        if not compatible:
            raise SystemExit('Install an iOS simulator runtime with an iPhone device type in Xcode.')
        runtime, device_type = max(compatible, key=lambda pair: (
            pair[1]['identifier'] == preferred_type,
            tuple(map(int, pair[0]['version'].split('.')))))
        udid = output('xcrun', 'simctl', 'create', DEVICE_NAME,
                      device_type['identifier'], runtime['identifier'])
        device = {'udid': udid, 'state': 'Shutdown'}
    udid = device['udid']
    if device['state'] != 'Booted':
        run('xcrun', 'simctl', 'boot', udid)
    run('xcrun', 'simctl', 'bootstatus', udid, '-b')
    run('xcrun', 'simctl', 'ui', udid, 'appearance', 'dark')
    run('xcrun', 'simctl', 'status_bar', udid, 'override', '--time', '9:41',
        '--dataNetwork', 'wifi', '--wifiMode', 'active', '--wifiBars', '3',
        '--batteryState', 'charged', '--batteryLevel', '100')
    sdk = output('xcrun', '--sdk', 'iphonesimulator', '--show-sdk-path')
    flags = ['-sdk', sdk, '-target', 'arm64-apple-ios17.0-simulator', '-parse-as-library']
    with tempfile.TemporaryDirectory(prefix='sceneweaver-screenshots-') as temporary:
        build = Path(temporary)
        obj = build / 'SceneWeaver.o'
        run('xcrun', 'swiftc', *flags, '-whole-module-optimization', '-emit-module', '-emit-object',
            '-module-name', 'SceneWeaver', '-emit-module-path', str(build / 'SceneWeaver.swiftmodule'),
            *map(str, sorted((ROOT / 'Sources/SceneWeaver').glob('*.swift'))), '-o', str(obj))
        app = build / 'SceneWeaver.app'
        app.mkdir()
        (app / 'Info.plist').write_bytes(plistlib.dumps({
            'CFBundleIdentifier': BUNDLE, 'CFBundleExecutable': 'SceneWeaver',
            'CFBundleName': 'SceneWeaver', 'CFBundlePackageType': 'APPL',
            'CFBundleShortVersionString': '1.0', 'CFBundleVersion': '1',
            'MinimumOSVersion': '17.0', 'LSRequiresIPhoneOS': True,
            'UIDeviceFamily': [1], 'UILaunchScreen': {},
            'UISupportedInterfaceOrientations': ['UIInterfaceOrientationLandscapeLeft'],
            'UIInterfaceOrientation': 'UIInterfaceOrientationLandscapeLeft',
        }))
        entry = build / 'ScreenshotApp.swift'
        entry.write_text('''import SwiftUI
import SceneWeaver

@main struct ScreenshotApp: App {
    private var mode: String { ProcessInfo.processInfo.arguments.last ?? "coast-day" }
    private var hour: Double {
        switch mode {
        case "coast-sunset": 18
        case "coast-night", "layers-night": 22
        default: 10
        }
    }
    var body: some Scene {
        WindowGroup {
            SceneWeaverScene(hour: hour, layered: mode == "layers-night")
                .ignoresSafeArea()
                .statusBarHidden()
            .preferredColorScheme(.dark)
        }
    }
}
''')
        run('xcrun', 'swiftc', *flags, '-module-name', 'SceneWeaverScreenshotApp', '-I', str(build), str(obj),
            str(ROOT / 'Examples/SceneWeaverGallery.swift'), str(entry), '-o', str(app / 'SceneWeaver'))
        run('codesign', '--force', '--sign', '-', str(app))
        run('xcrun', 'simctl', 'install', udid, str(app))
        destination = ROOT / 'docs/screenshots'
        destination.mkdir(parents=True, exist_ok=True)
        for mode in ['coast-day', 'coast-sunset', 'coast-night', 'layers-night']:
            run('xcrun', 'simctl', 'launch', '--terminate-running-process', udid, BUNDLE, mode)
            time.sleep(3)
            run('xcrun', 'simctl', 'io', udid, 'screenshot', str(destination / f'{mode}.png'))
    print(f'Screenshots saved to {destination}')


if __name__ == '__main__':
    main()
