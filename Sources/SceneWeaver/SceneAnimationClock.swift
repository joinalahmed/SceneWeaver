import Foundation

/// Owned by one Canvas. No observable mutations occur during rendering.
final class SceneAnimationClock {
    private var seconds=0.0
    private var previous:Date?
    private var wasPlaying=false
    func time(at date:Date,playing:Bool,reduced:Bool)->Double {
        if reduced {seconds=0}
        else if playing,wasPlaying,let previous {seconds += max(0,date.timeIntervalSince(previous))}
        previous=date;wasPlaying=playing && !reduced
        return seconds
    }
}
