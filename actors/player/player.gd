extends CharacterBody2D
class_name Player


var randomTileCount: int = 0
@export var randomTileMax: int = -1
@export var grid_position: Vector2i = Vector2i(2,2)
@onready var movement_component: MovementComponent = %MovementComponent


func _play_item_take_sound_effect() -> void:
	%ItemTakeSoundEffect.play()


func _ready() -> void:
	GameGlobal.player = $"."
	movement_component.grid_position = Vector2i(grid_position)
	var spawn_tile : Tile = GameGlobal.map.grid[grid_position.x][grid_position.y]
	spawn_tile.transform_to_another_type(load("res://actors/tile/spawn_tile.tscn"), false, 2)


func _on_hitbox_component_area_entered(area:Area2D):
	kill_player()


func kill_player() -> void:
	await get_tree().create_timer(0.2).timeout
	GameGlobal.is_game_have_start = false
	GameGlobal.end_game()
	# TransitionManager.reload_scene("square_gradient")


func get_movement_component() -> MovementComponent:
	return movement_component
