// Animation time advances only between playing frames. Pausing retains the
// exact pose; Reduce Motion deliberately renders the static rest pose.
export function createAnimationClock() {
  let seconds = 0,
    previous,
    wasPlaying = false;
  return (timestamp, playing, reduced = false) => {
    if (reduced) seconds = 0;
    else if (playing && wasPlaying && previous !== undefined)
      seconds += Math.max(0, timestamp - previous) / 1000;
    previous = timestamp;
    wasPlaying = playing && !reduced;
    return seconds;
  };
}
