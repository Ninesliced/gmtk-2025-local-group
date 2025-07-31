extends Node

signal on_action_stack_changed
signal on_action


@export var action_stacks : Array[ActionType] = [
	ActionType.ROTATE_CLOCK,
	ActionType.ROTATE_COUNTER_CLOCK,
	ActionType.ROTATE_COUNTER_CLOCK,
	ActionType.TRANSFORM_EMPTY,
	ActionType.HORIZONTAL_SWAP,
	ActionType.HORIZONTAL_SWAP,
	ActionType.VERTICAL_SWAP,
	ActionType.TRANSFORM_CROSS
]
var action_ui_stacks : Array[ActionUI] = []

@export var action_textures : Dictionary[ActionType, Texture2D] = {}
enum ActionType {
	ROTATE_CLOCK,
	ROTATE_COUNTER_CLOCK,
	TRANSFORM_EMPTY,
	HORIZONTAL_SWAP,
	VERTICAL_SWAP,
	TRANSFORM_CROSS
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
	},
	ActionType.VERTICAL_SWAP: {
		"name": "SWAP VERTICAL TILES",
		"function": vertical_swap,
	},
	ActionType.TRANSFORM_CROSS: {
		"name": "Transform Empty",
		"function": transform_cross,
	},
	# ActionType.DELETE_CURRENT_ACTION: {
	# 	"name": "DELETE CURRENT ACTION",
	# 	"function": delete_current_action,
	# },

}

func _ready():
	print("test: ", action_stacks)

	# Action UI
	for action in GameGlobal.action_stacks:
		var action_ui: ActionUI = action_ui_scene.instantiate()
		%ActionsContainer.add_child(action_ui)
		action_ui.texture_rect.texture = GameGlobal.action_textures[action]
		actions_ui.append(action_ui)
		_update_size()
	GameGlobal.action_ui_stacks = actions_ui
	GameGlobal.on_action_stack_changed.connect(_update_size)

func act_tile(tile: Tile, event: InputEvent) -> void:
	var action = action_stacks.pop_front()
	var action_ui = action_ui_stacks.pop_front()
	if action in dict:
		dict[action]["function"].call(tile, event)
		on_action.emit()
	else:
		print("Action not found: ", action)
	if !("temporary" in dict[action] && dict[action]["temporary"]):
		action_stacks.append(action)
		action_ui_stacks.append(action_ui)
	else:
		action_ui.queue_free()

	on_action_stack_changed.emit()
	GameGlobal.is_game_have_start = true

func rotate_clock(tile: Tile, event: InputEvent) -> void:
	if event.button_index == MOUSE_BUTTON_RIGHT:
		tile.rotate_counter_clock()
	else:
		tile.rotate_clock()
	pass

func rotate_counter_clock(tile: Tile, event: InputEvent) -> void:
	tile.rotate_counter_clock()
	pass

func transform_empty(tile: Tile, event: InputEvent) -> void:
	tile.transform_to_another_type(load("res://actors/tile/four.tscn"))
	
func transform_cross(tile: Tile, event: InputEvent) -> void:
	for i in range(-1,2):
		for j in range(-1,2):
			var current_tile = map.grid[tile.grid_position.x+i][tile.grid_position.y+j]
			var rnd = randi_range(0,1)
			match rnd:
				0:
					current_tile.transform_to_another_type(load("res://actors/tile/four.tscn"))
				1:
					current_tile.transform_to_another_type(load("res://actors/tile/full.tscn"))

func horizontal_swap(tile: Tile, event: InputEvent) -> void:
	tile.horizontal_swap(map)

func vertical_swap(tile: Tile, event: InputEvent) -> void:
	tile.vertical_swap(map)

# func delete_current_action(tile: Tile) -> void:
	
	

	
@export var player: Player = null
@export var map: Map = null
@export var camera: Camera2D = null
var is_game_have_start: bool = false



@export var action_ui_scene: PackedScene = preload("res://scenes/ui/action_ui.tscn")
@export var gap: int = 2

var actions_ui: Array[ActionUI] = []



func _update_size() -> void:
	var last_ui: ActionUI = actions_ui[actions_ui.size() - 1]
	last_ui.animation_player.play("pop")
	last_ui.position.x = (actions_ui.size() + 1) * (16 + gap)

	for i in range(0,actions_ui.size()):
		var action_ui = actions_ui[i]
		var tween = get_tree().create_tween()
		tween.tween_property(action_ui, "position:x", i * (16 + gap), 0.2)

func add_action(action: ActionType, action_ui: ActionUI) -> void:
	action_stacks.append(action)
	action_ui_stacks.append(action_ui)
	on_action_stack_changed.emit()

func new_action_ui(action: ActionType) -> ActionUI:
	var action_ui: ActionUI = load("res://scenes/ui/action_ui.tscn").instantiate()
	%ActionsContainer.add_child(action_ui)
	action_ui.texture_rect.texture = GameGlobal.action_textures[action]
	actions_ui.append(action_ui)
	_update_size()
	
	return action_ui
