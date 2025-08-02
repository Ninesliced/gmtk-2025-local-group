extends CharacterBody2D
class_name Player


var randomTileCount: int = 0
@export var randomTileMax: int = -1
@export var grid_position: Vector2i = Vector2i(2,2)
@onready var movement_component: MovementComponent = %MovementComponent

func _ready() -> void:
	GameGlobal.player = $"."
	movement_component.grid_position = Vector2i(grid_position)

func _on_hitbox_component_area_entered(area:Area2D):
	kill_player()

func kill_player() -> void:
	GameGlobal.is_game_have_start = false
	TransitionManager.reload_scene("square_gradient")
