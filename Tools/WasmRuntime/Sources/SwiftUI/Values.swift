import WASILibc
public typealias CGFloat=Double
public struct CGPoint:Equatable {
 public var x:CGFloat;public var y:CGFloat
 public init(x:CGFloat,y:CGFloat){self.x=x;self.y=y}
 public static let zero=CGPoint(x:0,y:0)
}
public struct CGSize:Equatable {
 public var width:CGFloat;public var height:CGFloat
 public init(width:CGFloat,height:CGFloat){self.width=width;self.height=height}
 public static let zero=CGSize(width:0,height:0)
}
public struct CGRect:Equatable {
 public var origin:CGPoint;public var size:CGSize
 public init(x:CGFloat,y:CGFloat,width:CGFloat,height:CGFloat){origin=CGPoint(x:x,y:y);size=CGSize(width:width,height:height)}
 public init(origin:CGPoint,size:CGSize){self.origin=origin;self.size=size}
 public static let zero=CGRect(x:0,y:0,width:0,height:0)
 public static let null=CGRect(x:.infinity,y:.infinity,width:0,height:0)
 public var minX:CGFloat{min(origin.x,origin.x+size.width)}
 public var minY:CGFloat{min(origin.y,origin.y+size.height)}
 public var maxX:CGFloat{max(origin.x,origin.x+size.width)}
 public var maxY:CGFloat{max(origin.y,origin.y+size.height)}
 public var midX:CGFloat{origin.x+size.width/2}
 public var midY:CGFloat{origin.y+size.height/2}
 public var width:CGFloat{size.width}
 public var height:CGFloat{size.height}
 public var isNull:Bool{origin.x.isInfinite || origin.y.isInfinite}
 public var isEmpty:Bool{isNull || width<=0 || height<=0}
 public func union(_ b:CGRect)->CGRect{if isNull{return b};if b.isNull{return self};let x=min(minX,b.minX),y=min(minY,b.minY);return CGRect(x:x,y:y,width:max(maxX,b.maxX)-x,height:max(maxY,b.maxY)-y)}
 public func insetBy(dx:CGFloat,dy:CGFloat)->CGRect{CGRect(x:origin.x+dx,y:origin.y+dy,width:width-2*dx,height:height-2*dy)}
 public func intersects(_ b:CGRect)->Bool{!isNull && !b.isNull && minX<b.maxX && maxX>b.minX && minY<b.maxY && maxY>b.minY}
 public func contains(_ p:CGPoint)->Bool{!isNull && p.x>=minX && p.x<maxX && p.y>=minY && p.y<maxY}
}
public struct Date:Equatable {
 public let timeIntervalSince1970:Double
 public init(timeIntervalSince1970:Double){self.timeIntervalSince1970=timeIntervalSince1970}
 public init(){timeIntervalSince1970=Double(WASILibc.time(nil))}
}
public enum CharacterSet {case whitespacesAndNewlines}
extension String {
 public func trimmingCharacters(in set:CharacterSet)->String{
  var a=startIndex,b=endIndex;while a<b && self[a].isWhitespace{formIndex(after:&a)};while b>a{let previous=index(before:b);if !self[previous].isWhitespace{break};b=previous};return String(self[a..<b])
 }
 public func replacingOccurrences(of target:String,with replacement:String)->String {
  guard !target.isEmpty else{return self};var result="",cursor=startIndex
  while cursor<endIndex {if self[cursor...].hasPrefix(target){result+=replacement;cursor=index(cursor,offsetBy:target.count)}else{result.append(self[cursor]);formIndex(after:&cursor)}};return result
 }
}
