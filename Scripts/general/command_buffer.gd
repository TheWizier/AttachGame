extends RefCounted
class_name CommandBuffer

# TODO We could change this buffer to only one action to avoid chains of queued actions (prioritize first)
# TODO Or we could change it to empty the whole buffer when an action is consumed (prioritize by chosen order)
# TODO This could also be implemented as a buffer of one where we replace according to that order
var _buffered: Dictionary = {} # action_name -> tick issued

func buffer(action: String, tick: int) -> void:
	_buffered[action] = tick

# TODO Might want to be able to say seconds to match logic easier with durations of other things
# TODO or make everything use ticks (I think maybe under hood ticks but practically seconds is nicest)
func try_consume(action: String, current_tick: int, buffer_window_ticks: int) -> bool:
	if not _buffered.has(action):
		return false
	var fresh = current_tick - _buffered[action] <= buffer_window_ticks
	_buffered.erase(action)
	return fresh
