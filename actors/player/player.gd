extends CharacterBody2D
class_name Player


var randomTileCount: int = 0
@export var randomTileMax: int = 2

func _ready() -> void:
	GameGlobal.player = $"."

func _on_hitbox_component_area_entered(area:Area2D):
	GameGlobal.is_game_have_start = false
	get_tree().reload_current_scene()
