import SwiftUI
import SceneWeaver

struct CourtyardRenderer {
    let now: Date
    let animated: Bool
    // Detailed architecture is decoded once; sky, weather, lighting and people
    // continue to render on the same live Canvas timeline.
    static let haramArtwork = SceneCatalog.artwork(named: "HaramCourtyard")
    static let nabawiArtwork = SceneCatalog.artwork(named: "NabawiCourtyard")
    static let haramBackground = SceneCatalog.artwork(named: "HaramBackground")
    static let haramForeground = SceneCatalog.artwork(named: "HaramForeground")
    static let nabawiBackground = SceneCatalog.artwork(named: "NabawiBackgroundV2")
    static let nabawiForeground = SceneCatalog.artwork(named: "NabawiForeground")

    private static func ramp(_ value: Double, _ low: Double, _ high: Double) -> Double {
        min(1, max(0, (value - low) / (high - low)))
    }
    private static func unit(_ index: Int, _ salt: Int) -> Double {
        let value = sin(Double(index) * 12.9898 + Double(salt) * 78.233) * 43758.5453
        return value - floor(value)
    }
    /// Transparent architectural layers preserve the reference's fine detail.
    /// The sky is still visible through minarets and parasols; all motion is live.
    func illustratedCourtyard(_ context: inout GraphicsContext, _ size: CGSize, horizon: CGFloat,
                                      artwork: Image, haram: Bool, darkness: Double, glow: Double, time: Double) {
        let motion = animated ? CGFloat(sin(time * 0.06)) : 0
        let backRect = HolyCourtyardLayout.artworkRect(width: size.width, horizon: horizon, motion: motion)
        let frontRect = HolyCourtyardLayout.artworkRect(width: size.width, horizon: horizon, motion: motion, foreground: true)
        let background = haram ? Self.haramBackground : Self.nabawiBackground
        let foreground = haram ? Self.haramForeground : Self.nabawiForeground
        var stage = context
        stage.clip(to: Path(CGRect(x: 0, y: backRect.minY, width: size.width, height: backRect.height + 1)))
        // 1. The distant plate receives cool ambient light and warm facade floods.
        litCourtyardPlate(&stage, artwork: background ?? artwork, rect: backRect,
                          darkness: darkness, glow: glow, foreground: false, time: time)
        if haram { courtyardClock(&stage, rect: backRect, darkness: darkness) }
        // 2. Live people occupy the actual depth between architectural plates.
        courtyardPeople(&stage, rect: backRect, haram: haram, darkness: darkness, time: time)
        courtyardReflections(&stage, rect: backRect, haram: haram, darkness: darkness)
        courtyardLamps(&stage, backRect: backRect, frontRect: frontRect, haram: haram, near: false, darkness: darkness, time: time)
        // 3. The focal architecture / nearest parasols occlude people naturally.
        if let foreground, background != nil {
            litCourtyardPlate(&stage, artwork: foreground, rect: frontRect,
                              darkness: darkness, glow: glow, foreground: true, time: time)
        }
        courtyardLamps(&stage, backRect: backRect, frontRect: frontRect, haram: haram, near: true, darkness: darkness, time: time)
        // The artwork fills beyond both sides; only its bottom merges to black.
        let fade = CGRect(x: 0, y: horizon - 13, width: size.width, height: 14)
        stage.fill(Path(fade), with: .linearGradient(Gradient(colors: [.clear, .black.opacity(0.9)]),
                   startPoint: CGPoint(x: size.width / 2, y: fade.minY), endPoint: CGPoint(x: size.width / 2, y: fade.maxY)))
    }

    private func litCourtyardPlate(_ context: inout GraphicsContext, artwork: Image, rect: CGRect,
                                   darkness: Double, glow: Double, foreground: Bool, time: Double) {
        let positions: [(CGFloat, CGFloat)] = foreground
            ? [(0.44, 0.76), (0.63, 0.79), (0.15, 0.64), (0.87, 0.64)]
            : [(0.12, 0.61), (0.30, 0.58), (0.51, 0.57), (0.72, 0.59), (0.90, 0.65)]
        let layer = ArtworkLayer(image: artwork, depth: foreground ? 2 : 1,
            ambientDimming: foreground ? 0.25 : 0.46,
            floodlights: positions.map { ArtworkLight(x: $0.0, y: $0.1,
                radius: foreground ? 0.19 : 0.17, intensity: foreground ? 0.10 : 0.34) })
        layer.draw(in: &context, rect: rect,
            frame: SceneFrame(size: rect.size, horizon: rect.maxY, time: time, date: now,
                              darkness: darkness, glow: glow, motionEnabled: animated))
    }

    private struct CourtyardLamp {
        let x: CGFloat
        let y: CGFloat
        var near = false
        var reflection: CGFloat = 0
    }

    private func sceneLamps(haram: Bool) -> [CourtyardLamp] {
        if haram {
            // Lamp glass along the two curved galleries, not arbitrary sky dots.
            let front: [(CGFloat, CGFloat)] = [(0.012,0.790),(0.035,0.773),(0.064,0.751),(0.094,0.732),
                (0.126,0.711),(0.161,0.694),(0.198,0.676),(0.237,0.660),(0.278,0.647),
                (0.322,0.636),(0.367,0.628),(0.413,0.621),(0.460,0.617),(0.506,0.616),
                (0.554,0.617),(0.601,0.622),(0.647,0.628),(0.692,0.637),(0.735,0.650),
                (0.777,0.664),(0.817,0.680),(0.855,0.700),(0.891,0.721),(0.923,0.744),(0.953,0.768),(0.982,0.793)]
            return front.map { CourtyardLamp(x: $0.0, y: $0.1, reflection: 0.015) } + [
                CourtyardLamp(x: 0.213, y: 0.911, near: true, reflection: 0.028),
                CourtyardLamp(x: 0.765, y: 0.907, near: true, reflection: 0.028),
                CourtyardLamp(x: 0.637, y: 0.791, near: true, reflection: 0.018)]
        }
        return [CourtyardLamp(x:0.400,y:0.631,near:true,reflection:0.10),
                CourtyardLamp(x:0.587,y:0.660,near:true,reflection:0.07),
                CourtyardLamp(x:0.745,y:0.631,near:true,reflection:0.085),
                CourtyardLamp(x:0.654,y:0.697,reflection:0.055),
                CourtyardLamp(x:0.092,y:0.630,near:true,reflection:0.065),
                CourtyardLamp(x:0.359,y:0.681,reflection:0.05),
                CourtyardLamp(x:0.868,y:0.685,reflection:0.05),
                CourtyardLamp(x:0.945,y:0.730,reflection:0.045),
                CourtyardLamp(x:0.103,y:0.724,reflection:0.045)]
    }

    private func courtyardLamps(_ context: inout GraphicsContext, backRect: CGRect, frontRect: CGRect,
                                haram: Bool, near: Bool, darkness: Double, time: Double) {
        let on = Self.ramp(darkness, 0.12, 0.65)
        guard on > 0.001 else { return }
        for (i, lamp) in sceneLamps(haram: haram).enumerated() where lamp.near == near {
            let rect = lamp.near ? frontRect : backRect
            let p = CGPoint(x: rect.minX + rect.width * lamp.x, y: rect.minY + rect.height * lamp.y)
            let r = rect.width * (lamp.near ? 0.022 : 0.012)
            // Most of the output is steady electric light; motion is a tiny
            // atmospheric shimmer, never lamps randomly switching off.
            let shimmer = 0.97 + 0.03 * sin(time * 0.45 + Double(i) * 1.3)
            let tint = Color(red: 1, green: 0.73, blue: 0.24)
            context.fill(Path(CGRect(x:p.x-r,y:p.y-r,width:r*2,height:r*2)),
                         with: .radialGradient(Gradient(colors:[tint.opacity(on * 0.65 * shimmer), tint.opacity(on * 0.18), .clear]),
                                               center:p,startRadius:0,endRadius:r))
            let core = rect.width * (lamp.near ? 0.0017 : 0.0010)
            context.fill(Path(ellipseIn:CGRect(x:p.x-core,y:p.y-core,width:core*2,height:core*2)),
                         with:.color(Color(red:1,green:0.96,blue:0.72).opacity(on)))
        }
    }

    private func courtyardReflections(_ context: inout GraphicsContext, rect: CGRect, haram: Bool, darkness: Double) {
        let on = Self.ramp(darkness, 0.12, 0.7)
        guard on > 0.001 else { return }
        // Elongated pools sit only on the marble, below the nearest galleries.
        for lamp in sceneLamps(haram: haram) where lamp.reflection > 0 {
            let x = rect.minX + rect.width * lamp.x
            let floorY: CGFloat = haram ? max(0.82, lamp.y + 0.10) : 0.88
            let y = rect.minY + rect.height * floorY
            let width = rect.width * (lamp.near ? 0.022 : 0.013)
            let height = rect.height * lamp.reflection
            var reflection = context
            reflection.addFilter(.blur(radius: rect.width * 0.002))
            reflection.fill(Path(ellipseIn: CGRect(x:x-width/2,y:y,width:width,height:height)),
                            with:.linearGradient(Gradient(colors:[Color(red:1,green:0.78,blue:0.36).opacity(on * 0.24),.clear]),
                                                 startPoint:CGPoint(x:x,y:y),endPoint:CGPoint(x:x,y:y+height)))
        }
    }

    private func courtyardClock(_ context: inout GraphicsContext, rect: CGRect, darkness: Double) {
        let c = CGPoint(x: rect.minX + rect.width * 0.812, y: rect.minY + rect.height * 0.146)
        let radius = rect.width * 0.0134
        context.fill(Path(ellipseIn: CGRect(x: c.x - radius, y: c.y - radius, width: radius * 2, height: radius * 2)),
                     with: .color(Color(red: 0.98, green: 0.94, blue: 0.79).opacity(1 - darkness * 0.3)))
        let parts = Calendar.current.dateComponents([.hour, .minute], from: now)
        let minutes = Double(parts.minute ?? 0), hours = Double((parts.hour ?? 0) % 12) + minutes / 60
        var hands = Path()
        for (angle, length) in [(hours / 12 * Double.pi * 2, 0.50), (minutes / 60 * Double.pi * 2, 0.78)] {
            hands.move(to: c)
            hands.addLine(to: CGPoint(x: c.x + CGFloat(sin(angle) * length) * radius,
                                      y: c.y - CGFloat(cos(angle) * length) * radius))
        }
        context.stroke(hands, with: .color(Color(red: 0.19, green: 0.17, blue: 0.11)),
                       style: StrokeStyle(lineWidth: max(0.4, rect.width * 0.0011), lineCap: .round))
    }

    private func courtyardPeople(_ context: inout GraphicsContext, rect: CGRect, haram: Bool, darkness: Double, time: Double) {
        var white = Path(), dark = Path(), heads = Path(), shadows = Path()
        let count = haram ? 420 : 38
        for index in 0..<count {
            var nx: CGFloat, ny: CGFloat
            if haram {
                let angle = Double(index) * 2.399963 - time * 0.014
                let radius = 0.22 + Double(index % 6) * 0.025 + Self.unit(index, 845) * 0.02
                nx = 0.49 + CGFloat(cos(angle) * radius)
                ny = 0.83 + CGFloat(sin(angle) * radius * 0.36)
                // Keep the Kaaba, Hijr and the small enclosures unpainted.
                if Self.haramForeground == nil && nx > 0.36 && nx < 0.605 && ny < 0.925 { continue }
                if nx > 0.60 && nx < 0.73 && ny > 0.75 && ny < 0.84 { continue }
                if nx > 0.59 && nx < 0.67 && ny > 0.86 && ny < 0.94 { continue }
            } else {
                let fraction = (Self.unit(index, 403) + time * (index % 2 == 0 ? 0.0006 : -0.0005)).truncatingRemainder(dividingBy: 1)
                nx = CGFloat(0.12 + (fraction < 0 ? fraction + 1 : fraction) * 0.76)
                ny = CGFloat(0.82 + Self.unit(index, 807) * 0.15)
            }
            let x = rect.minX + nx * rect.width, y = rect.minY + ny * rect.height
            let h = rect.width * (haram ? 0.0046 : 0.010) * (0.65 + (ny - 0.7) * 2.5)
            let body = Path { path in
                path.move(to: CGPoint(x: x - h * 0.2, y: y))
                path.addLine(to: CGPoint(x: x + h * 0.2, y: y))
                path.addLine(to: CGPoint(x: x + h * 0.12, y: y - h * 0.75))
                path.addQuadCurve(to: CGPoint(x: x - h * 0.12, y: y - h * 0.75), control: CGPoint(x: x, y: y - h * 0.94))
                path.closeSubpath()
            }
            if index % 4 == 0 { dark.addPath(body) } else { white.addPath(body) }
            heads.addEllipse(in: CGRect(x: x - h * 0.09, y: y - h * 1.02, width: h * 0.18, height: h * 0.18))
            shadows.addEllipse(in: CGRect(x: x - h * 0.1, y: y - h * 0.05, width: h * 0.6, height: h * 0.18))
        }
        context.fill(shadows, with: .color(.black.opacity(0.13)))
        context.fill(white, with: .color(Color(white: 0.96 - darkness * 0.30)))
        context.fill(dark, with: .color(Color(red: 0.20, green: 0.23, blue: 0.22)))
        context.fill(heads, with: .color(Color(red: 0.48, green: 0.39, blue: 0.27).opacity(0.8)))
    }

}
