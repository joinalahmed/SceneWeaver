import WASILibc
public struct Color:Hashable {
    public let red:Double,green:Double,blue:Double,alpha:Double
    public init(red:Double,green:Double,blue:Double){self.red=red;self.green=green;self.blue=blue;self.alpha=1}
    private init(_ r:Double,_ g:Double,_ b:Double,_ a:Double){red=r;green=g;blue=b;alpha=a}
    public init(white:Double){self.init(red:white,green:white,blue:white)}
    public init(hue:Double,saturation:Double,brightness:Double){
        let h=(hue-floor(hue))*6,c=brightness*saturation,x=c*(1-abs(h.truncatingRemainder(dividingBy:2)-1)),m=brightness-c
        let colors:[Double]
        switch h {case ..<1:colors=[c,x,0];case ..<2:colors=[x,c,0];case ..<3:colors=[0,c,x];case ..<4:colors=[0,x,c];case ..<5:colors=[x,0,c];default:colors=[c,0,x]}
        self.init(red:colors[0]+m,green:colors[1]+m,blue:colors[2]+m)
    }
    public func opacity(_ value:Double)->Color{Color(red,green,blue,alpha*value)}
    public static let black=Color(red:0,green:0,blue:0)
    public static let white=Color(red:1,green:1,blue:1)
    public static let clear=Color(0,0,0,0)
    public var rgba:[Double]{[red,green,blue,alpha].map{min(1,max(0,$0))}}
}
