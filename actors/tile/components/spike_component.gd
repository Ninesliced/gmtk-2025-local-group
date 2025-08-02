extends Node

var parent : Tile
@onready var collision_shape_2d: CollisionShape2D = %SpikeCollision

func _ready() -> void:
	GameGlobal.on_action.connect(on_action_performed)
	collision_shape_2d.disabled = true
	var tile := get_parent()
	if not (tile is Tile):
		print("CursedComponent: Parent is not a Tile")
		return
	parent = tile
#	parent.sprite.play("spike_in")


func on_action_performed():
	if collision_shape_2d.disabled:
		collision_shape_2d.disabled = false
		parent.sprite.play("spike_out")
	else:
		collision_shape_2d.disabled = true
		parent.sprite.play("spike_in")
