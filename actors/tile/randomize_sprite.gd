extends Node

var sprite: AnimatedSprite2D

func _ready() -> void:
	await get_parent().ready
	var parent = get_parent()
	if !(parent is AnimatedSprite2D):
		return
	sprite = parent
	play_random_sprite()

func play_random_sprite():
	if !sprite:
		return
	var frame_count = sprite.sprite_frames.get_frame_count(sprite.animation)
	sprite.frame = randi_range(0, frame_count)
