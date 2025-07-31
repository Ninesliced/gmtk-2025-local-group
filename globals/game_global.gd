extends Node

signal on_action_stack_changed

@export var action_stacks : Array[ActionType] = [
	ActionType.ROTATE_CLOCK,
	ActionType.ROTATE_COUNTER_CLOCK,
	ActionType.ROTATE_COUNTER_CLOCK,
]
@export var action_ui_stacks : Array[ActionUI] = []

@export var action_textures : Dictionary[ActionType, Texture2D] = {}
enum ActionType {
	ROTATE_CLOCK,
	ROTATE_COUNTER_CLOCK,
	TRANSFORM_EMPTY
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

	}
}

func _ready():
	print("test: ", action_stacks)
	pass

func act_tile(tile: Tile) -> void:
	var action = action_stacks.pop_front()
	var action_ui = action_ui_stacks.pop_front()
	if action in dict:
		print(tile)
		# print("Executing action: ", dict[action]["name"])
		rotate_clock(tile)
		# call(dict[action]["function"], tile)
	else:
		print("Action not found: ", action)
	action_stacks.append(action)
	action_ui_stacks.append(action_ui)
	on_action_stack_changed.emit()

func rotate_clock(tile: Tile) -> void:
	tile.rotate_clock()
	pass

func rotate_counter_clock(tile: Tile) -> void:
	tile.rotate_counter_clock()
	pass

func transform_empty(tile: Tile) -> void:
	pass
