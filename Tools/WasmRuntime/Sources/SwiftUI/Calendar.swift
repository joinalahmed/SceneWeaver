import WASILibc
/// Runtime inputs express the selected local wall-clock hour on a UTC epoch day.
/// These are the calendar components used by the canonical clock recipes.
public struct SceneCalendar {
 public enum Component:Hashable{case hour,minute}
 public struct Components{public let hour:Int?;public let minute:Int?}
 public static let current=SceneCalendar()
 public func dateComponents(_ components:Set<Component>,from date:Date)->Components{
  let minute=((Int(floor(date.timeIntervalSince1970/60))%1440)+1440)%1440
  return Components(hour:minute/60,minute:minute%60)
 }
}
