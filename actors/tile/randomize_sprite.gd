extends Node

@export var textures: Array[Texture2D] = []

@export var selectedSprite: Sprite2D

func _ready() -> void:    
	var random_index = randi() % textures.size()
	selectedSprite.texture = textures[random_index]
