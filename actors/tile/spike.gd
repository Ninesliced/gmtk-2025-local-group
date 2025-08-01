extends Tile

@onready var collision_shape_2d: CollisionShape2D = $AreaSpike/CollisionShape2D
@onready var sprite: AnimatedSprite2D = %Sprite

func _ready() -> void:
	GameGlobal.on_action.connect(on_action_performed)

func on_action_performed():
	if collision_shape_2d.disabled:
		sprite.play("spike_in")
		collision_shape_2d.disabled = false
	else:
		sprite.play("spike_out")
		collision_shape_2d.disabled = true
