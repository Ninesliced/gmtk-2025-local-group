extends Control

func _process(_delta: float) -> void:
	if DebugGlobal.is_debug:
		GameGlobal.in_menu = true
		show()
	else:
		GameGlobal.in_menu = false
		hide()
