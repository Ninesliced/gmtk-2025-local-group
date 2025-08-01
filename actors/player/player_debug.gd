extends Node2D

@export var mc: MovementComponent

@onready var label: Label = $Label

func _process(_delta: float) -> void:
	if DebugGlobal.is_debug:
		show()
	else:
		hide()

	label.text = "grid " + str(mc.grid_position) + "\n" \
	 + "pos: " + str(mc.get_parent().global_position) + "\n"
