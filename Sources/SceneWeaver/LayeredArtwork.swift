import SwiftUI

/// Width-filling composition anchored to the horizon. All layers share the same
/// aspect ratio and overscan so independently cut plates remain registered.
public enum ArtworkLayout {
    public static func rect(width: CGFloat, horizon: CGFloat, aspectRatio: CGFloat = 1.5,
                            overscan: CGFloat = 1.12, motion: CGFloat = 0, depth: CGFloat = 1) -> CGRect {
        let safeWidth = max(0, width)
        let plateWidth = safeWidth * max(1, overscan)
        let height = plateWidth / max(0.01, aspectRatio)
        return CGRect(x: (safeWidth - plateWidth) / 2 + motion * safeWidth * 0.0015 * depth,
                      y: horizon - height, width: plateWidth, height: height)
    }
}

/// A normalized point on an image. Coordinates are measured from its top left.
public struct ArtworkLight {
    public var position: CGPoint
    public var radius: CGFloat
    public var intensity: Double
    public var color: Color
    public init(x: CGFloat, y: CGFloat, radius: CGFloat = 0.17, intensity: Double = 0.34,
                color: Color = Color(red: 1, green: 0.78, blue: 0.42)) {
        position = CGPoint(x: x, y: y); self.radius = radius
        self.intensity = intensity; self.color = color
    }
}

/// One transparent image plate. Floodlights are clipped to its alpha channel.
public struct ArtworkLayer {
    public var image: Image
    public var depth: CGFloat
    public var ambientDimming: Double
    public var floodlights: [ArtworkLight]
    public init(image: Image, depth: CGFloat = 1, ambientDimming: Double = 0.46,
                floodlights: [ArtworkLight] = []) {
        self.image = image; self.depth = depth; self.ambientDimming = ambientDimming
        self.floodlights = floodlights
    }

    public func draw(in context: inout GraphicsContext, rect: CGRect, frame: SceneFrame) {
        context.drawLayer { layer in
            var material = layer
            let dark = frame.darkness, glow = frame.glow, dim = ambientDimming
            material.addFilter(.colorMultiply(Color(red: 1 - dark * dim,
                green: 1 - dark * (dim - 0.025) - glow * 0.025,
                blue: 1 - dark * (dim - 0.12) - glow * 0.065)))
            material.draw(image, in: rect)
            var illumination = layer
            illumination.blendMode = .sourceAtop
            let dusk = min(1, max(0, (dark - 0.15) / 0.65))
            for light in floodlights {
                let p = CGPoint(x: rect.minX + rect.width * light.position.x,
                                y: rect.minY + rect.height * light.position.y)
                let radius = max(0.1, rect.width * light.radius)
                illumination.fill(Path(CGRect(x: p.x - radius, y: p.y - radius, width: radius * 2, height: radius * 2)),
                    with: .radialGradient(Gradient(colors: [light.color.opacity(dusk * light.intensity), .clear]),
                                          center: p, startRadius: 0, endRadius: radius))
            }
            let sun = CGPoint(x: rect.minX + rect.width * 0.22, y: rect.minY + rect.height * 0.35)
            illumination.fill(Path(rect), with: .radialGradient(
                Gradient(colors: [Color(red: 1, green: 0.74, blue: 0.36).opacity(glow * 0.18), .clear]),
                center: sun, startRadius: 0, endRadius: max(0.1, rect.width * 0.8)))
        }
    }
}

/// A point light authored on a plate. Draw it after the plate it belongs to;
/// draw a foreground plate afterwards to naturally occlude a distant lamp.
public struct SceneLamp {
    public var position: CGPoint
    public var color: Color
    public var radius: CGFloat
    public init(x: CGFloat, y: CGFloat, radius: CGFloat = 0.012,
                color: Color = Color(red: 1, green: 0.84, blue: 0.51)) {
        position = CGPoint(x: x, y: y); self.radius = radius; self.color = color
    }
    public func draw(in context: inout GraphicsContext, rect: CGRect, frame: SceneFrame) {
        let on = min(1, max(0, (frame.darkness - 0.12) / 0.53))
        guard on > 0.001 else { return }
        let point = CGPoint(x: rect.minX + rect.width * position.x, y: rect.minY + rect.height * position.y)
        let r = max(0.5, rect.width * radius)
        context.fill(Path(ellipseIn: CGRect(x: point.x-r, y: point.y-r, width: r*2, height: r*2)),
                     with: .radialGradient(Gradient(colors: [color.opacity(on * 0.65), .clear]),
                                           center: point, startRadius: 0, endRadius: r))
        let core = max(0.45, rect.width * 0.0012)
        context.fill(Path(ellipseIn: CGRect(x: point.x-core, y: point.y-core, width: core*2, height: core*2)),
                     with: .color(Color(red: 1, green: 0.97, blue: 0.80).opacity(on)))
    }
}

/// Ordered image and Canvas layers, allowing actors or lights between plates.
public struct LayeredArtwork {
    public enum Layer {
        case image(ArtworkLayer)
        case canvas(depth: CGFloat, (inout GraphicsContext, CGRect, SceneFrame) -> Void)
    }
    public var layers: [Layer]
    public var aspectRatio: CGFloat
    public var overscan: CGFloat
    public init(layers: [Layer], aspectRatio: CGFloat = 1.5, overscan: CGFloat = 1.12) {
        self.layers = layers; self.aspectRatio = aspectRatio; self.overscan = overscan
    }
    public func draw(in context: inout GraphicsContext, frame: SceneFrame) {
        let motion = frame.motionEnabled ? CGFloat(sin(frame.time * 0.06)) : 0
        for layer in layers {
            let depth: CGFloat
            switch layer {
            case .image(let plate): depth = plate.depth
            case .canvas(let value, _): depth = value
            }
            let rect = ArtworkLayout.rect(width: frame.size.width, horizon: frame.horizon,
                aspectRatio: aspectRatio, overscan: overscan, motion: motion, depth: depth)
            switch layer {
            case .image(let plate): plate.draw(in: &context, rect: rect, frame: frame)
            case .canvas(_, let render): render(&context, rect, frame)
            }
        }
    }
}
