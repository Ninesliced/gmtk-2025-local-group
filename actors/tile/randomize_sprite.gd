extends Node

@onready var sprite: AnimatedSprite2D = %Sprite

func _ready() -> void:
	play_random_animation()

func play_random_animation():
	var animation_names := sprite.sprite_frames.get_animation_names()

	if(!len(animation_names)):
		return
	var random_ani_name = animation_names[randi() % animation_names.size()]
	sprite.play(random_ani_name)
