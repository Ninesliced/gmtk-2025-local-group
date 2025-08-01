extends Node

@onready var sprite: AnimatedSprite2D = %Sprite

func _ready() -> void:
	await get_parent()._ready()
	play_random_sprite()

func play_random_sprite():
	var frame_count = sprite.sprite_frames.get_frame_count(sprite.animation)
	sprite.frame = randi_range(0, frame_count)
