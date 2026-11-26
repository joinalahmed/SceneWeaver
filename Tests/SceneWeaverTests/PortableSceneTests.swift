import XCTest
import SwiftUI
@testable import SceneWeaver

final class PortableSceneTests:XCTestCase {
    func testPauseRetainsFrameAndResumeExcludesPausedTime(){
        let clock=SceneAnimationClock()
        func sample(_ second:Double,_ playing:Bool,_ reduced:Bool=false)->Double{clock.time(at:Date(timeIntervalSince1970:second),playing:playing,reduced:reduced)}
        XCTAssertEqual(sample(1,true),0);XCTAssertEqual(sample(3,true),2)
        XCTAssertEqual(sample(4,false),2);XCTAssertEqual(sample(60,false),2)
        XCTAssertEqual(sample(61,true),2);XCTAssertEqual(sample(62,true),3)
        XCTAssertEqual(sample(63,true,true),0)
    }
    func testPortableProjectLoadsAllActorTypesAndRejectsInvalidBounds()throws {
        let json="""
        {"version":1,"name":"Actors","settings":{"hour":18,"weather":"clear","ground":36,"aspectRatio":1.5,"overscan":1.12,"viewport":1.5,"motion":true,"schedule":[5,6,12,15,18,19.5]},"layers":[{"id":"plate","name":"Plate","visible":true,"depth":1,"dim":0.46,"asset":{"name":"Plate"},"lights":[{"id":"lamp","type":"lamp","x":0.5,"y":0.5,"radius":0.012,"intensity":1,"color":"#ffc76b","fixture":true,"near":true,"reflection":0.05}],"water":{"x":0,"y":0.73,"width":1,"height":0.27,"opacity":0.28},"boat":{"x":0.5,"y":0.83,"amplitude":0.08,"frequency":0.15,"width":40,"height":0.02,"color":"#ff9500"},"clock":{"x":0.8,"y":0.15,"radius":0.0134},"crowd":"orbit"}]}
        """
        let project=try SceneProject(data:Data(json.utf8))
        XCTAssertNotNil(try project.definition(image:{_ in Image(systemName:"circle")}).render)
        XCTAssertThrowsError(try SceneProject(data:Data(json.replacingOccurrences(of:"\"width\":1,\"height\":0.27",with:"\"width\":2,\"height\":0.27").utf8)))
        XCTAssertThrowsError(try project.definition(image:{_ in nil}))
    }
}
