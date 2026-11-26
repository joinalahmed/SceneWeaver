import SwiftUI
import Foundation

/// The same portable version-1 document consumed by Studio and React.
/// Hosts resolve image names; the engine does not fetch network resources.
public struct SceneProject: Decodable {
    public struct Settings: Decodable {
        public let hour:Double;public let weather:String;public let ground:Double
        public let aspectRatio:Double;public let overscan:Double;public let viewport:Double
        public let motion:Bool;public let schedule:[Double]
        public let reservedHeight:ReservedHeight?;public let showsSunPath:Bool?
        public struct ReservedHeight:Decodable {public let widthFactor:Double;public let offset:Double}
    }
    public struct Asset:Decodable {public let name:String;public let src:String?;public let data:String?}
    public struct Water:Decodable {let x:Double;let y:Double;let width:Double;let height:Double;let opacity:Double}
    public struct Boat:Decodable {let x:Double;let y:Double;let amplitude:Double;let frequency:Double;let width:Double;let height:Double;let color:String}
    public struct Clock:Decodable {let x:Double;let y:Double;let radius:Double}
    public struct Light:Decodable {
        let id:String;let type:String;let x:Double;let y:Double;let radius:Double;let intensity:Double;let color:String
        let fixture:Bool?;let near:Bool?;let reflection:Double?;let phaseIndex:Double?
        var fixtureLight:SceneFixtureLight { SceneFixtureLight(x:x,y:y,radius:radius,near:near ?? false,reflection:reflection ?? 0,phase:(phaseIndex ?? 0)*1.3,color:Self.color(color)) }
        static func color(_ hex:String)->Color {let n=UInt32(hex.dropFirst(),radix:16) ?? 0;return Color(red:Double((n>>16)&255)/255,green:Double((n>>8)&255)/255,blue:Double(n&255)/255)}
    }
    public struct Layer:Decodable {
        public let id:String;public let name:String;public let visible:Bool;public let depth:Double;public let dim:Double;public let asset:Asset
        let lights:[Light];let water:Water?;let boat:Boat?;let crowd:String?;let clock:Clock?
    }
    public struct NativeReference:Decodable {public let id:String}
    public let version:Int;public let name:String;public let settings:Settings;public let layers:[Layer]
    public let nativeScene:NativeReference?
    public init(data:Data)throws {
        self=try JSONDecoder().decode(Self.self,from:data)
        try validate()
    }
    public enum ProjectError:Error {case invalidDocument,missingImage(String),missingNativeScene(String)}
    public func definition(image:(String)->Image?,nativeScene resolve:((String)->SceneDefinition?)?=nil)throws->SceneDefinition {
        try validate()
        var content:[LayeredArtwork.Layer]=[]
        for layer in layers where layer.visible {
            guard let artwork=image(layer.asset.name)else{throw ProjectError.missingImage(layer.asset.name)}
            let floods=layer.lights.filter{$0.type=="flood"}.map{ArtworkLight(x:$0.x,y:$0.y,radius:$0.radius,intensity:$0.intensity,color:Light.color($0.color))}
            content.append(.image(ArtworkLayer(image:artwork,depth:layer.depth,ambientDimming:layer.dim,floodlights:floods)))
            content.append(.canvas(depth:layer.depth){context,rect,frame in
                if let clock=layer.clock{SceneClock(x:clock.x,y:clock.y,radius:clock.radius).draw(in:&context,rect:rect,frame:frame)}
                if let crowd=layer.crowd {
                    SceneCrowd(pattern:crowd=="orbit" ? .orbit:.crossing,exclusions:crowd=="orbit" ? [CGRect(x:0.60,y:0.75,width:0.13,height:0.09),CGRect(x:0.59,y:0.86,width:0.08,height:0.08)]:[]).draw(in:&context,rect:rect,frame:frame)
                    for light in layers.flatMap(\.lights) where light.fixture==true {
                        light.fixtureLight.drawReflection(in:&context,rect:rect,frame:frame,floor:crowd=="orbit" ? max(0.82,light.y+0.1):0.88)
                    }
                }
                if let water=layer.water{SceneWater(x:water.x,y:water.y,width:water.width,height:water.height,opacity:water.opacity).draw(in:&context,rect:rect,frame:frame)}
                if let boat=layer.boat{SceneBoat(x:boat.x,y:boat.y,amplitude:boat.amplitude,frequency:boat.frequency,width:boat.width,height:boat.height,color:Light.color(boat.color)).draw(in:&context,rect:rect,frame:frame)}
                for light in layer.lights where light.type=="lamp" {
                    if light.fixture==true{light.fixtureLight.draw(in:&context,rect:rect,frame:frame)}
                    else{SceneLamp(x:light.x,y:light.y,radius:light.radius,color:Light.color(light.color)).draw(in:&context,rect:rect,frame:frame)}
                }
            })
        }
        if layers.contains(where:{$0.crowd != nil}) {
            content.append(.canvas(depth:0){context,_,frame in
                context.fill(Path(CGRect(x:0,y:frame.horizon-13,width:frame.size.width,height:14)),with:.linearGradient(Gradient(colors:[.clear,.black.opacity(0.9)]),startPoint:CGPoint(x:0,y:frame.horizon-13),endPoint:CGPoint(x:0,y:frame.horizon+1)))
            })
        }
        let artwork=LayeredArtwork(layers:content,aspectRatio:settings.aspectRatio,overscan:settings.overscan)
        var result:SceneDefinition
        if let nativeScene {
            guard let original=resolve?(nativeScene.id)else{throw ProjectError.missingNativeScene(nativeScene.id)}
            result=original;let originalOverlay=result.overlay
            result.overlay={context,frame in originalOverlay?(&context,frame);artwork.draw(in:&context,frame:frame)}
        }else{result=SceneDefinition(render:{context,frame in artwork.draw(in:&context,frame:frame)})}
        if let height=settings.reservedHeight{result.reservedHeight={width in width*height.widthFactor+height.offset}}
        return result
    }
    private func validate()throws {
        func number(_ n:Double,_ lo:Double,_ hi:Double)->Bool{n.isFinite && n>=lo && n<=hi}
        guard version==1,!name.isEmpty,settings.schedule.count==6,settings.schedule.allSatisfy({number($0,0,24)}),zip(settings.schedule,settings.schedule.dropFirst()).allSatisfy({$0<$1}),number(settings.hour,0,23.99),number(settings.ground,0,160),number(settings.aspectRatio,0.25,4),number(settings.overscan,1,1.6),number(settings.viewport,0.5,2.5),SceneWeather(rawValue:settings.weather) != nil,layers.count<=24,Set(layers.map(\.id)).count==layers.count else{throw ProjectError.invalidDocument}
        for layer in layers {
            guard !layer.id.isEmpty,layer.asset.name.range(of:"^[A-Za-z][A-Za-z0-9_]*$",options:.regularExpression) != nil,number(layer.depth,0,8),number(layer.dim,0,0.9),layer.lights.count<=100,Set(layer.lights.map(\.id)).count==layer.lights.count else{throw ProjectError.invalidDocument}
            for light in layer.lights {
                guard ["lamp","flood"].contains(light.type),number(light.x,0,1),number(light.y,0,1),number(light.radius,0.001,1),number(light.intensity,0,1),light.color.range(of:"^#[a-fA-F0-9]{6}$",options:.regularExpression) != nil else{throw ProjectError.invalidDocument}
            }
            if let w=layer.water {guard number(w.x,0,1),number(w.y,0,1),number(w.width,0.001,1),number(w.height,0.001,1),w.x+w.width<=1.000001,w.y+w.height<=1.000001,number(w.opacity,0,1)else{throw ProjectError.invalidDocument}}
            if let c=layer.crowd,!(["orbit","crossing"].contains(c)){throw ProjectError.invalidDocument}
            if let c=layer.clock {guard number(c.x,0,1),number(c.y,0,1),number(c.radius,0.001,0.2)else{throw ProjectError.invalidDocument}}
            if let b=layer.boat {guard number(b.x,0,1),number(b.y,0,1),number(b.amplitude,0,0.5),number(b.frequency,0,10),number(b.width,1,200),number(b.height,0.001,0.2)else{throw ProjectError.invalidDocument}}
        }
    }
    public func schedule(for date:Date)->DaylightSchedule {
        let start=Calendar.current.startOfDay(for:date)
        return DaylightSchedule(orderedDates:settings.schedule.map{start.addingTimeInterval($0*3600)})
    }
}

/// SwiftUI counterpart of React's project-based SceneView, with the same saved hour and framing.
public struct SceneProjectView:View {
    private let project:SceneProject
    private let definition:SceneDefinition
    private let date:Date?
    private let paused:Bool
    public init(project:SceneProject,date:Date?=nil,paused:Bool?=nil,image:(String)->Image?,nativeScene:((String)->SceneDefinition?)?=nil)throws {
        self.project=project;self.definition=try project.definition(image:image,nativeScene:nativeScene);self.date=date;self.paused=paused ?? !project.settings.motion
    }
    public var body:some View {
        let now=date ?? Calendar.current.startOfDay(for:.now).addingTimeInterval(project.settings.hour*3600)
        SceneView(schedule:project.schedule(for:now),now:now,weather:SceneWeather(rawValue:project.settings.weather),scene:definition,showsSunPath:project.settings.showsSunPath ?? true,ground:project.settings.ground,paused:paused)
            .aspectRatio(project.settings.viewport,contentMode:.fit).clipped()
    }
}
