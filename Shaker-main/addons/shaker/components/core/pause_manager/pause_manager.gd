extends Node

var _pause_priority : int = 0

func pause(pause_priority: int = 0) -> void:
	if pause_priority < _pause_priority:
		return
	if not get_tree().paused:
		get_tree().paused = true
		_pause_priority = pause_priority
		
func unpause(priority: int = 0) -> void:
	if priority < _pause_priority:
		return
	if get_tree().paused:
		get_tree().paused = false
		_pause_priority = 0