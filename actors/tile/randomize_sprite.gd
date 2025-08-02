extends Node

@export var sprite: AnimatedSprite2D
@export var root_parent: Node
func _ready() -> void:
	if root_parent:
		await root_parent.ready
	play_random_sprite()

func play_random_sprite():
	var frame_count = sprite.sprite_frames.get_frame_count(sprite.animation)
	
	sprite.frame = randi_range(0, frame_count)
