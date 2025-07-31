extends Node2D

var grid := GameGlobal.map.grid

func _ready() -> void:
	GameGlobal.on_action.connect(on_action_performed)
	
func update():
	pass
	
func on_action_performed():
	update()
