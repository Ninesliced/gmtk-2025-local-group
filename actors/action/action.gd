extends Node2D

@export var action: GameGlobal.ActionType = 0

func _ready() -> void:
	%Sprite2D.texture = GameGlobal.action_textures[action]
	

"""
func _on_area_2d_area_entered(area: Area2D) -> void:
	var player = area.get_parent()
	if !(player && player is Player):
		return
	var action_ui_load: PackedScene = load("res://scenes/ui/action_ui.tscn")
	var action_ui = action_ui_load.instantiate()
	action_ui.texture_rect = %Sprite2D.texture
	# TODO: action_ui.animation_player: A
	GameGlobal.add_action(action, action_ui)
	queue_free()
"""

func _on_area_2d_body_entered(player: Node2D) -> void:
	print("Entered", player)
	if !(player is Player):
		return
	
	var action_ui = GameGlobal.new_action_ui(action)
	
	# TODO: action_ui.animation_player: A
	GameGlobal.add_action(action, action_ui)
	queue_free()
