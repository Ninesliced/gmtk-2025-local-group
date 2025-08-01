extends CharacterBody2D
class_name Player


var randomTileCount: int = 0
@export var randomTileMax: int = -1

@onready var movementComponent: MovementComponent = %MovementComponent

func _ready() -> void:
	GameGlobal.player = $"."

func _on_hitbox_component_area_entered(area:Area2D):
	GameGlobal.is_game_have_start = false
	TransitionManager.reload_scene("square_gradient")
