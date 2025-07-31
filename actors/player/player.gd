extends CharacterBody2D
class_name Player

func _ready() -> void:
	GameGlobal.player = $"."

func _on_hitbox_component_area_entered(area:Area2D):
	get_tree().reload_current_scene()
	pass # Replace with function body.
