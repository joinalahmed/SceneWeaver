import SwiftUI
import SceneWeaver

private var result:UnsafeMutablePointer<UInt8>?
private var resultLength:Int32=0
private let entries=CatalogRecipes.scenes
private let byID=Dictionary(uniqueKeysWithValues:entries.enumerated().map{($0.element.id,$0.offset)})

@_cdecl("scene_alloc") public func sceneAlloc(_ count:Int32)->UnsafeMutablePointer<UInt8>?{guard count>0,count<100000000 else{return nil};return .allocate(capacity:Int(count))}
@_cdecl("scene_free") public func sceneFree(_ pointer:UnsafeMutablePointer<UInt8>?){pointer?.deallocate()}
@_cdecl("scene_index") public func sceneIndex(_ pointer:UnsafePointer<UInt8>?,_ count:Int32)->Int32{
 guard let pointer,count>0,count<1000 else{return -1};return Int32(byID[String(decoding:UnsafeBufferPointer(start:pointer,count:Int(count)),as:UTF8.self)] ?? -1)
}
@_cdecl("scene_result_length") public func sceneResultLength()->Int32{resultLength}
private indirect enum JSON {
 case string(String),number(Double),bool(Bool),array([JSON]),object([(String,JSON)])
 static func numbers(_ values:[Double])->JSON{.array(values.map{.number($0.isFinite ? $0:0)})}
 func append(to output:inout[UInt8]){
  switch self {
  case .string(let value):output.append(34);for byte in value.utf8{switch byte{case 34:output += [92,34];case 92:output += [92,92];case 10:output += [92,110];case 13:output += [92,114];case 9:output += [92,116];default:output.append(byte)}};output.append(34)
  case .number(let value):output += String(value.isFinite ? value:0).utf8
  case .bool(let value):output += (value ? "true":"false").utf8
  case .array(let values):output.append(91);for(i,value)in values.enumerated(){if i>0{output.append(44)};value.append(to:&output)};output.append(93)
  case .object(let values):output.append(123);for(i,pair)in values.enumerated(){if i>0{output.append(44)};JSON.string(pair.0).append(to:&output);output.append(58);pair.1.append(to:&output)};output.append(125)
  }
 }
}
func number(_ n:CGFloat)->String{String((Double(n)*1000).rounded()/1000)}
private func pathObject(_ path:Path)->JSON {
 func data(_ part:Path.Part,_ flatten:Bool)->String{
  part.commands.map{command in
   var values:[String]=[]
   for i in stride(from:0,to:command.values.count,by:2){let p=CGPoint(x:command.values[i],y:command.values[i+1]);let point=flatten ? p.applying(part.transform):p;values += [number(point.x),number(point.y)]}
   return command.op+(values.isEmpty ? "":" "+values.joined(separator:" "))
  }.joined(separator:" ")
 }
 if path.parts.count==1,path.parts[0].stroke==nil{return .string(data(path.parts[0],true))}
 let box=path.boundingRect
 return .object([("parts",.array(path.parts.map{part in
  var value:[(String,JSON)]=[("d",.string(data(part,false))),("transform",.numbers(part.transform.values))]
  if let s=part.stroke{value.append(("stroke",.object([("width",.number(Double(s.lineWidth))),("cap",.string(s.lineCap.rawValue)),("join",.string(s.lineJoin.rawValue))])))}
  return .object(value)
 })),("bounds",.numbers([Double(box.minX),Double(box.minY),Double(box.width),Double(box.height)]))])
}
@_cdecl("scene_render") public func sceneRender(_ index:Int32,_ width:Double,_ horizon:Double,_ time:Double,_ night:Double,_ hour:Double,_ rtl:Int32)->UnsafePointer<UInt8>?{
 guard index>=0,Int(index)<entries.count,width.isFinite,horizon.isFinite,time.isFinite,night.isFinite,hour.isFinite else{return nil}
 let item=entries[Int(index)],city=item.city
 var pen=ScenePen(width:width,horizon:horizon,time:time,night:night,clockDate:Date(timeIntervalSince1970:hour*3600),illustrated:city.quranScene)
 city.draw(&pen);if rtl != 0 && city.rtlPlacement == .leftMargin {pen.moveToLeftMargin()}
 var paths:[JSON]=[]
 func intern(_ path:Path)->JSON{let id=paths.count;paths.append(pathObject(path));return .number(Double(id))}
 let frame=JSON.object([("solids",.array(pen.solids.map(intern))),("holes",.array(pen.holes.map(intern))),("lights",.array(pen.lights.map(intern))),("tints",.array(pen.tints.map{t in
  let b=t.path.boundingRect
  var value:[(String,JSON)]=[("path",intern(t.path)),("color",.numbers(t.color.rgba)),("nightOnly",.bool(t.nightOnly)),("bounds",.numbers([Double(b.minX),Double(b.minY),Double(b.width),Double(b.height)]))]
  if let lower=t.lowerColor{value.append(("lower",.numbers(lower.rgba)))};return .object(value)
 })),("beacons",.array(pen.beacons.map{.numbers([Double($0.x),Double($0.y)])}))])
 let value=JSON.object([("version",.number(1)),("width",.number(width)),("horizon",.number(horizon)),("paths",.array(paths)),("day",frame),("night",frame),("backdrop",.string(String(describing:city.backdrop))),("wild",.bool(city.wild)),("ownMoon",.bool(city.ownMoon)),("illustrated",.bool(city.quranScene)),("movesForRTL",.bool(false))])
 var bytes:[UInt8]=[];bytes.reserveCapacity(32768);value.append(to:&bytes)
 result?.deallocate();let output=UnsafeMutablePointer<UInt8>.allocate(capacity:bytes.count)
 bytes.withUnsafeBufferPointer{output.initialize(from:$0.baseAddress!,count:$0.count)};result=output;resultLength=Int32(bytes.count);return UnsafePointer(output)
}
