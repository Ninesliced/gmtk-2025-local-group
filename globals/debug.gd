extends Control

func _process(_delta: float) -> void:
	if DebugGlobal.is_debug:
		show()
	else:
		hide()
