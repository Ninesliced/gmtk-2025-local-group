extends Tile

@onready var collision_shape_2d: CollisionShape2D = $AreaSpike/CollisionShape2D

func _ready() -> void:
	GameGlobal.on_action.connect(on_action_performed)
	collision_shape_2d.disabled = true
	sprite.play("spike_in")
	

func on_action_performed():
	if collision_shape_2d.disabled:
		collision_shape_2d.disabled = false
		sprite.play("spike_out")
	else:
		collision_shape_2d.disabled = true
		sprite.play("spike_in")
