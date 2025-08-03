extends Control

class_name ActionUI

@onready var texture_rect: TextureRect = %TextureRect
@onready var animation_player: AnimationPlayer = %AnimationPlayer

func animation_pop() -> void:
	if animation_player:
		animation_player.play("pop")

func set_texture_rect(texture: Texture2D) -> void:
	# print("set_texture_rect", texture)
	%TextureRect.texture = texture
