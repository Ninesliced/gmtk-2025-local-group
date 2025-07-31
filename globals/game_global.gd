extends Node

signal on_action_stack_changed

@export var action_stacks : Array[ActionType] = [
	ActionType.ROTATE_CLOCK,
	ActionType.ROTATE_COUNTER_CLOCK,
	ActionType.ROTATE_COUNTER_CLOCK,
	ActionType.TRANSFORM_EMPTY,
	ActionType.HORIZONTAL_SWAP
]
var action_ui_stacks : Array[ActionUI] = []

@export var action_textures : Dictionary[ActionType, Texture2D] = {}
enum ActionType {
	ROTATE_CLOCK,
	ROTATE_COUNTER_CLOCK,
	TRANSFORM_EMPTY,
	HORIZONTAL_SWAP
}

var dict: Dictionary[ActionType, Dictionary] = {
	ActionType.ROTATE_CLOCK: {
		"name": "Rotate Clockwise",
		"function": rotate_clock,
	},
	ActionType.ROTATE_COUNTER_CLOCK: {
		"name": "Rotate Counter Clockwise",
		"function": rotate_counter_clock,
	},
	ActionType.TRANSFORM_EMPTY: {
		"name": "Transform Empty",
		"function": transform_empty,
	},
	ActionType.HORIZONTAL_SWAP: {
		"name": "SWAP HORIZONTAL TILES",
		"function": horizontal_swap,
		"temporary": true
	}
}

func _ready():
	print("test: ", action_stacks)
	pass

func act_tile(tile: Tile) -> void:
	var action = action_stacks.pop_front()
	var action_ui = action_ui_stacks.pop_front()
	if action in dict:
		dict[action]["function"].call(tile)
	else:
		print("Action not found: ", action)
	if !("temporary" in dict[action] && dict[action]["temporary"]):
		action_stacks.append(action)
		action_ui_stacks.append(action_ui)
	else:
		action_ui.queue_free()

	on_action_stack_changed.emit()
	GameGlobal.is_game_have_start = true

func rotate_clock(tile: Tile) -> void:
	tile.rotate_clock()
	pass

func rotate_counter_clock(tile: Tile) -> void:
	tile.rotate_counter_clock()
	pass

func transform_empty(tile: Tile) -> void:
	tile.transform_to_another_type(load("res://actors/tile/four.tscn"))
	
func horizontal_swap(tile: Tile) -> void:
	tile.horizontal_swap(map.tile_size)
	


@export var player: Player = null
@export var map: Map = null
@export var camera: Camera2D = null
var is_game_have_start: bool = false
