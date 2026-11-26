import SwiftUI

/// Animated water highlights clipped to a normalized region of an artwork plate.
public struct SceneWater {
    public var bounds: CGRect
    public var opacity: Double
    public init(x: CGFloat = 0, y: CGFloat = 0.73, width: CGFloat = 1, height: CGFloat = 0.27, opacity: Double = 0.28) {
        bounds = CGRect(x:x,y:y,width:width,height:height); self.opacity=opacity
    }
    public func draw(in context: inout GraphicsContext, rect: CGRect, frame: SceneFrame) {
        let area=CGRect(x:rect.minX+bounds.minX*rect.width,y:rect.minY+bounds.minY*rect.height,width:bounds.width*rect.width,height:bounds.height*rect.height)
        var surface=context;surface.clip(to:Path(area))
        for i in 0..<32 {
            let phase=frame.time*1.3+Double(i)*0.9
            let x=area.minX+CGFloat(ScenePen.noise(i,91))*area.width+CGFloat(sin(phase*0.6))*rect.width*0.012
            let y=area.minY+CGFloat(ScenePen.noise(i,92))*area.height
            let length=rect.width*CGFloat((0.012+ScenePen.noise(i,93)*0.032)*(1+sin(phase)*0.25))
            let alpha=opacity*(0.35+0.65*(0.5+0.5*sin(phase)))*(1-frame.darkness*0.45)
            var path=Path();path.move(to:CGPoint(x:x-length/2,y:y));path.addLine(to:CGPoint(x:x+length/2,y:y))
            surface.stroke(path,with:.color(Color(red:0.75,green:0.86,blue:0.88).opacity(alpha)),style:StrokeStyle(lineWidth:max(0.5,rect.width*0.001),lineCap:.round))
        }
    }
}

/// A small drifting boat, drawn between plates so foreground artwork occludes it.
public struct SceneBoat {
    public var x: CGFloat; public var y: CGFloat
    public var amplitude: CGFloat; public var frequency: Double
    public var width: CGFloat; public var height: CGFloat
    public var color: Color
    public init(x: CGFloat = 0.5,y: CGFloat = 0.83,amplitude: CGFloat = 0.08,frequency: Double = 0.15,width: CGFloat = 40,height: CGFloat = 0.02,color: Color = .orange) {
        self.x=x;self.y=y;self.amplitude=amplitude;self.frequency=frequency;self.width=width;self.height=height;self.color=color
    }
    public func draw(in context: inout GraphicsContext,rect: CGRect,frame: SceneFrame) {
        let cx=rect.minX+rect.width*(x+CGFloat(sin(frame.time*frequency))*amplitude)
        let top=rect.minY+rect.height*y, bottom=top+rect.height*height
        var path=Path();path.move(to:CGPoint(x:cx-width/2,y:top));path.addLine(to:CGPoint(x:cx+width/2,y:top));path.addLine(to:CGPoint(x:cx+width*0.3,y:bottom));path.addLine(to:CGPoint(x:cx-width*0.3,y:bottom));path.closeSubpath()
        context.fill(path,with:.color(color))
    }
}

/// An analog clock anchored to a normalized point on an artwork plate.
public struct SceneClock {
    public var x: CGFloat; public var y: CGFloat; public var radius: CGFloat
    public init(x:CGFloat,y:CGFloat,radius:CGFloat=0.0134){self.x=x;self.y=y;self.radius=radius}
    public func draw(in context:inout GraphicsContext,rect:CGRect,frame:SceneFrame){
        let c=CGPoint(x:rect.minX+rect.width*x,y:rect.minY+rect.height*y),r=rect.width*radius
        context.fill(Path(ellipseIn:CGRect(x:c.x-r,y:c.y-r,width:r*2,height:r*2)),with:.color(Color(red:0.98,green:0.94,blue:0.79).opacity(1-frame.darkness*0.3)))
        let parts=Calendar.current.dateComponents([.hour,.minute],from:frame.date),minutes=Double(parts.minute ?? 0),hours=Double((parts.hour ?? 0)%12)+minutes/60
        var hands=Path()
        for(angle,length) in [(hours/12*Double.pi*2,0.50),(minutes/60*Double.pi*2,0.78)]{hands.move(to:c);hands.addLine(to:CGPoint(x:c.x+CGFloat(sin(angle)*length)*r,y:c.y-CGFloat(cos(angle)*length)*r))}
        context.stroke(hands,with:.color(Color(red:0.19,green:0.17,blue:0.11)),style:StrokeStyle(lineWidth:max(0.4,rect.width*0.0011),lineCap:.round))
    }
}

/// A steady architectural lamp with atmospheric shimmer and an optional floor reflection.
public struct SceneFixtureLight {
    public var x:CGFloat;public var y:CGFloat;public var radius:CGFloat;public var near:Bool
    public var reflection:CGFloat;public var phase:Double;public var color:Color
    public init(x:CGFloat,y:CGFloat,radius:CGFloat=0.012,near:Bool=false,reflection:CGFloat=0,phase:Double=0,color:Color=Color(red:1,green:0.73,blue:0.24)){
        self.x=x;self.y=y;self.radius=radius;self.near=near;self.reflection=reflection;self.phase=phase;self.color=color
    }
    public func draw(in context:inout GraphicsContext,rect:CGRect,frame:SceneFrame){
        let on=min(1,max(0,(frame.darkness-0.12)/0.53));guard on>0.001 else{return}
        let p=CGPoint(x:rect.minX+rect.width*x,y:rect.minY+rect.height*y),r=rect.width*radius
        let shimmer=0.97+0.03*sin(frame.time*0.45+phase)
        context.fill(Path(CGRect(x:p.x-r,y:p.y-r,width:r*2,height:r*2)),with:.radialGradient(Gradient(colors:[color.opacity(on*0.65*shimmer),color.opacity(on*0.18),.clear]),center:p,startRadius:0,endRadius:r))
        let core=rect.width*(near ? 0.0017:0.0010)
        context.fill(Path(ellipseIn:CGRect(x:p.x-core,y:p.y-core,width:core*2,height:core*2)),with:.color(Color(red:1,green:0.96,blue:0.72).opacity(on)))
    }
    public func drawReflection(in context:inout GraphicsContext,rect:CGRect,frame:SceneFrame,floor:CGFloat=0.88){
        let on=min(1,max(0,(frame.darkness-0.12)/0.58));guard reflection>0,on>0.001 else{return}
        let px=rect.minX+rect.width*x,py=rect.minY+rect.height*floor,w=rect.width*(near ? 0.022:0.013),h=rect.height*reflection
        var reflected=context;reflected.addFilter(.blur(radius:rect.width*0.002))
        reflected.fill(Path(ellipseIn:CGRect(x:px-w/2,y:py,width:w,height:h)),with:.linearGradient(Gradient(colors:[Color(red:1,green:0.78,blue:0.36).opacity(on*0.24),.clear]),startPoint:CGPoint(x:px,y:py),endPoint:CGPoint(x:px,y:py+h)))
    }
}

/// People moving on an elliptical circuit or crossing a plaza, between artwork plates.
public struct SceneCrowd {
    public enum Pattern {case orbit,crossing}
    public var pattern:Pattern
    public var exclusions:[CGRect]
    public init(pattern:Pattern,exclusions:[CGRect]=[]){self.pattern=pattern;self.exclusions=exclusions}
    public func draw(in context:inout GraphicsContext,rect:CGRect,frame:SceneFrame){
        let orbit=pattern == .orbit,count=orbit ? 420:38
        var white=Path(),dark=Path(),heads=Path(),shadows=Path()
        for index in 0..<count {
            let nx:CGFloat,ny:CGFloat
            if orbit {
                let angle=Double(index)*2.399963-frame.time*0.014,radius=0.22+Double(index%6)*0.025+ScenePen.noise(index,845)*0.02
                nx=0.49+CGFloat(cos(angle)*radius);ny=0.83+CGFloat(sin(angle)*radius*0.36)
            }else{
                let fraction=(ScenePen.noise(index,403)+frame.time*(index%2 == 0 ? 0.0006:-0.0005)).truncatingRemainder(dividingBy:1)
                nx=CGFloat(0.12+(fraction<0 ? fraction+1:fraction)*0.76);ny=CGFloat(0.82+ScenePen.noise(index,807)*0.15)
            }
            if exclusions.contains(where:{$0.contains(CGPoint(x:nx,y:ny))}){continue}
            let x=rect.minX+nx*rect.width,y=rect.minY+ny*rect.height,h=rect.width*(orbit ? 0.0046:0.010)*(0.65+(ny-0.7)*2.5)
            var body=Path();body.move(to:CGPoint(x:x-h*0.2,y:y));body.addLine(to:CGPoint(x:x+h*0.2,y:y));body.addLine(to:CGPoint(x:x+h*0.12,y:y-h*0.75));body.addQuadCurve(to:CGPoint(x:x-h*0.12,y:y-h*0.75),control:CGPoint(x:x,y:y-h*0.94));body.closeSubpath()
            if index%4 == 0{dark.addPath(body)}else{white.addPath(body)}
            heads.addEllipse(in:CGRect(x:x-h*0.09,y:y-h*1.02,width:h*0.18,height:h*0.18));shadows.addEllipse(in:CGRect(x:x-h*0.1,y:y-h*0.05,width:h*0.6,height:h*0.18))
        }
        context.fill(shadows,with:.color(.black.opacity(0.13)));context.fill(white,with:.color(Color(white:0.96-frame.darkness*0.30)));context.fill(dark,with:.color(Color(red:0.20,green:0.23,blue:0.22)));context.fill(heads,with:.color(Color(red:0.48,green:0.39,blue:0.27).opacity(0.8)))
    }
}
