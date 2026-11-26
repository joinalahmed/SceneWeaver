@_exported import WASILibc

public struct CGAffineTransform:Equatable {
    public var a:CGFloat,b:CGFloat,c:CGFloat,d:CGFloat,tx:CGFloat,ty:CGFloat
    public init(a:CGFloat,b:CGFloat,c:CGFloat,d:CGFloat,tx:CGFloat,ty:CGFloat){self.a=a;self.b=b;self.c=c;self.d=d;self.tx=tx;self.ty=ty}
    public init(translationX:CGFloat,y:CGFloat){self.init(a:1,b:0,c:0,d:1,tx:translationX,ty:y)}
    public static let identity=CGAffineTransform(a:1,b:0,c:0,d:1,tx:0,ty:0)
    public func concatenating(_ n:Self)->Self {Self(a:a*n.a+c*n.b,b:b*n.a+d*n.b,c:a*n.c+c*n.d,d:b*n.c+d*n.d,tx:a*n.tx+c*n.ty+tx,ty:b*n.tx+d*n.ty+ty)}
    public func translatedBy(x:CGFloat,y:CGFloat)->Self{concatenating(Self(translationX:x,y:y))}
    public func scaledBy(x:CGFloat,y:CGFloat)->Self{concatenating(Self(a:x,b:0,c:0,d:y,tx:0,ty:0))}
    public func rotated(by angle:CGFloat)->Self{concatenating(Self(a:cos(angle),b:sin(angle),c:-sin(angle),d:cos(angle),tx:0,ty:0))}
    public var values:[Double]{[a,b,c,d,tx,ty]}
}
extension CGPoint {public func applying(_ t:CGAffineTransform)->CGPoint{CGPoint(x:t.a*x+t.c*y+t.tx,y:t.b*x+t.d*y+t.ty)}}
public enum CGLineCap:String {case butt,round,square}
public enum CGLineJoin:String {case miter,round,bevel}
public struct StrokeStyle:Equatable {
    public var lineWidth:CGFloat;public var lineCap:CGLineCap;public var lineJoin:CGLineJoin
    public init(lineWidth:CGFloat=1,lineCap:CGLineCap = .butt,lineJoin:CGLineJoin = .miter){self.lineWidth=lineWidth;self.lineCap=lineCap;self.lineJoin=lineJoin}
}
public struct Path:Equatable {
    public struct Command:Equatable {public var op:String;public var values:[CGFloat]}
    public struct Part:Equatable {public var commands:[Command];public var stroke:StrokeStyle?;public var transform:CGAffineTransform}
    public private(set)var parts:[Part]=[]
    public init(){}
    public init(_ rect:CGRect){self.init();addRect(rect)}
    public init(ellipseIn rect:CGRect){self.init();addEllipse(in:rect)}
    public init(_ build:(inout Path)->Void){self.init();build(&self)}
    private mutating func append(_ op:String,_ values:[CGFloat]=[]){
        if parts.isEmpty || parts[parts.count-1].stroke != nil || parts[parts.count-1].transform != .identity {parts.append(Part(commands:[],stroke:nil,transform:.identity))}
        parts[parts.count-1].commands.append(Command(op:op,values:values))
    }
    public mutating func move(to p:CGPoint){append("M",[p.x,p.y])}
    public mutating func addLine(to p:CGPoint){append("L",[p.x,p.y])}
    public mutating func addQuadCurve(to p:CGPoint,control c:CGPoint){append("Q",[c.x,c.y,p.x,p.y])}
    public mutating func addCurve(to p:CGPoint,control1 a:CGPoint,control2 b:CGPoint){append("C",[a.x,a.y,b.x,b.y,p.x,p.y])}
    public mutating func closeSubpath(){append("Z")}
    public mutating func addRect(_ r:CGRect){move(to:CGPoint(x:r.minX,y:r.minY));addLine(to:CGPoint(x:r.maxX,y:r.minY));addLine(to:CGPoint(x:r.maxX,y:r.maxY));addLine(to:CGPoint(x:r.minX,y:r.maxY));closeSubpath()}
    public mutating func addEllipse(in r:CGRect){
        let x=r.midX,y=r.midY,rx=r.width/2,ry=r.height/2,k:CGFloat=0.5522847498307936
        move(to:CGPoint(x:x+rx,y:y));addCurve(to:CGPoint(x:x,y:y+ry),control1:CGPoint(x:x+rx,y:y+k*ry),control2:CGPoint(x:x+k*rx,y:y+ry));addCurve(to:CGPoint(x:x-rx,y:y),control1:CGPoint(x:x-k*rx,y:y+ry),control2:CGPoint(x:x-rx,y:y+k*ry));addCurve(to:CGPoint(x:x,y:y-ry),control1:CGPoint(x:x-rx,y:y-k*ry),control2:CGPoint(x:x-k*rx,y:y-ry));addCurve(to:CGPoint(x:x+rx,y:y),control1:CGPoint(x:x+k*rx,y:y-ry),control2:CGPoint(x:x+rx,y:y-k*ry));closeSubpath()
    }
    public mutating func addPath(_ path:Path){parts += path.parts}
    public func applying(_ t:CGAffineTransform)->Path {var p=self;p.parts=p.parts.map{var s=$0;s.transform=t.concatenating(s.transform);return s};return p}
    public func strokedPath(_ style:StrokeStyle)->Path {var p=self;p.parts=p.parts.map{var s=$0;s.stroke=style;return s};return p}
    public var isEmpty:Bool{parts.allSatisfy{$0.commands.isEmpty}}
    public var boundingRect:CGRect {
        var total=CGRect.null
        for part in parts {
            var box=CGRect.null,current=CGPoint.zero,start=CGPoint.zero
            func include(_ p:CGPoint){box=box.union(CGRect(x:p.x,y:p.y,width:0,height:0))}
            func point(_ v:[CGFloat],_ offset:Int)->CGPoint{CGPoint(x:v[offset],y:v[offset+1]).applying(part.transform)}
            func cubic(_ p0:CGFloat,_ p1:CGFloat,_ p2:CGFloat,_ p3:CGFloat,_ t:CGFloat)->CGFloat{let u=1-t;return u*u*u*p0+3*u*u*t*p1+3*u*t*t*p2+t*t*t*p3}
            for command in part.commands {
                let v=command.values
                switch command.op {
                case "M":current=point(v,0);start=current;include(current)
                case "L":current=point(v,0);include(current)
                case "Z":current=start;include(current)
                case "Q":
                    let c=point(v,0),end=point(v,2),a=current;include(end)
                    for (p0,p1,p2) in [(a.x,c.x,end.x),(a.y,c.y,end.y)] {let denominator=p0-2*p1+p2;if abs(denominator)>0.000000001 {let t=(p0-p1)/denominator;if t>0,t<1 {let u=1-t;include(CGPoint(x:u*u*a.x+2*u*t*c.x+t*t*end.x,y:u*u*a.y+2*u*t*c.y+t*t*end.y))}}};current=end
                case "C":
                    let a=current,b=point(v,0),c=point(v,2),end=point(v,4);include(end)
                    for (p0,p1,p2,p3) in [(a.x,b.x,c.x,end.x),(a.y,b.y,c.y,end.y)] {
                        let qa = -p0+3*p1-3*p2+p3,qb=2*(p0-2*p1+p2),qc=p1-p0
                        var roots:[CGFloat]=[]
                        if abs(qa)<0.000000001 {if abs(qb)>0.000000001{roots=[-qc/qb]}}
                        else {let d=qb*qb-4*qa*qc;if d>=0{roots=[(-qb+sqrt(d))/(2*qa),(-qb-sqrt(d))/(2*qa)]}}
                        for t in roots where t>0 && t<1 {include(CGPoint(x:cubic(a.x,b.x,c.x,end.x,t),y:cubic(a.y,b.y,c.y,end.y,t)))}
                    };current=end
                default:break
                }
            }
            if let stroke=part.stroke,!box.isNull {box=box.insetBy(dx:-stroke.lineWidth/2*sqrt(part.transform.a*part.transform.a+part.transform.c*part.transform.c),dy:-stroke.lineWidth/2*sqrt(part.transform.b*part.transform.b+part.transform.d*part.transform.d))}
            total=total.union(box)
        }
        return total
    }
}
