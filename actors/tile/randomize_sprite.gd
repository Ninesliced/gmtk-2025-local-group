extends Node

@export var textures: Dictionary[Texture2D, float] = {}

@export var selectedSprite: Sprite2D

func _ready() -> void:
	var sum = 0.0
	for texture in textures.keys():
		sum += textures[texture]

	
	var random_value = randf() * sum
	var cumulative_sum = 0.0
	var random_index = 0
	for i in range(textures.size()):
		cumulative_sum += textures.values()[i]
		if random_value < cumulative_sum:
			random_index = i
			break
	selectedSprite.texture = textures.keys()[random_index]
