extends Node

signal on_action_stack_changed
signal on_action
var in_menu: bool = false
const ENEMY = preload("res://actors/enemy/enemy.tscn")
@onready var canvas_layer: CanvasLayer = %CanvasLayer
@export var action_stacks : Array[ActionType] = [
	ActionType.ROTATE_CLOCK,
	ActionType.ROTATE_COUNTER_CLOCK,
	ActionType.ROTATE_COUNTER_CLOCK,
	ActionType.TRANSFORM_EMPTY,
	ActionType.TRANSFORM_EMPTY_CURSED,
	ActionType.HORIZONTAL_SWAP,
	ActionType.HORIZONTAL_SWAP,
	ActionType.VERTICAL_SWAP,
	ActionType.TRANSFORM_CROSS,
	ActionType.ENEMY,
	ActionType.DELETE_CURRENT_ACTION,
	ActionType.DELETE_CURRENT_ACTION,
	ActionType.VERTICAL_SPIKE
] : 
	set(value):
		action_stacks = value
		action_stack_backup = action_stacks.duplicate()
		on_action_stack_changed.emit()

var action_stack_backup = action_stacks.duplicate()
var action_ui_stacks : Array[ActionUI] = []

var hovered_tile: Tile = null

## include movement of player
signal on_player_action
var number_of_actions: int = 0:
	set(value):
		number_of_actions = value
		on_player_action.emit()

var score : int = 0:
	set(value):
		score = max(score, value)
		%Score.text = "Score: " + str(score)


@export var action_textures : Dictionary[ActionType, Texture2D] = {}
enum ActionType {
	ROTATE_CLOCK,
	ROTATE_COUNTER_CLOCK,
	TRANSFORM_EMPTY,
	HORIZONTAL_SWAP,
	VERTICAL_SWAP,
	TRANSFORM_CROSS,
	BOMB_SQUARE,
	ENEMY,
	DELETE_CURRENT_ACTION,
	VERTICAL_SPIKE,
	TRANSFORM_EMPTY_CURSED,
}

var dict: Dictionary[ActionType, Dictionary] = {
	ActionType.ROTATE_CLOCK: {
		"name": "Rotate Clockwise",
		"function": rotate_clock,
		"action_zone": [
			Vector2i(0, 0)
		]
	},
	ActionType.ROTATE_COUNTER_CLOCK: {
		"name": "Rotate Counter Clockwise",
		"function": rotate_counter_clock,
		"action_zone": [
			Vector2i(0, 0)
		]
	},
	ActionType.TRANSFORM_EMPTY: {
		"name": "Transform Empty",
		"function": transform_empty,
		"action_zone": [
			Vector2i(0, 0)
		]
	},
	ActionType.TRANSFORM_EMPTY_CURSED: {
		"name": "Transform  in a row",
		"function": transform_empty_cursed,
		"action_zone": [
			Vector2i(0, 0),
			Vector2i(1, 0),
			Vector2i(2, 0),
			Vector2i(3, 0)
		],
		"temporary": true,
	},
	ActionType.HORIZONTAL_SWAP: {
		"name": "SWAP HORIZONTAL TILES",
		"function": horizontal_swap,
		"action_zone": [
			Vector2i(0, 0),
			Vector2i(1, 0)
		]
	},
	ActionType.VERTICAL_SWAP: {
		"name": "SWAP VERTICAL TILES",
		"function": vertical_swap,
		"action_zone": [
			Vector2i(0, 0),
			Vector2i(0, 1)
		]
	},
	ActionType.TRANSFORM_CROSS: {
		"name": "Transform Empty",
		"function": transform_cross,
		# "probability": 0,
		"action_zone": [
			Vector2i(0, 0),
			Vector2i(-1, 0),
			Vector2i(1, 0),
			Vector2i(0, -1),
			Vector2i(0, 1),
			Vector2i(1, 1),
			Vector2i(-1, 1),
			Vector2i(1, -1),
			Vector2i(-1, -1),
		]
	},
	ActionType.BOMB_SQUARE: {
		"name": "BOMB SQUARE",
		"function": transform_empty_bomb,
		"temporary": true,
		# "probability": 0.1,
		"action_zone": [
			Vector2i(0, 0),
			Vector2i(-1, 0),
			Vector2i(1, 0),
			Vector2i(0, -1),
			Vector2i(0, 1),
			Vector2i(1, 1),
			Vector2i(-1, 1),
			Vector2i(1, -1),
			Vector2i(-1, -1),
		]
	},
	ActionType.ENEMY: {
		"name": "ENEMY SPAWNER",
		"function": spawn_enemy,
		"action_zone": [
			Vector2i(0, 1),
			Vector2i(0, 0),
			Vector2i(0, -1),
			Vector2i(1, 0),
			Vector2i(-1, 0),
		]
	},
	ActionType.DELETE_CURRENT_ACTION: {
		"name": "DELETE CURRENT ACTION",
		"function": nop,
		"on_get_function": delete_current_action,
		"temporary": true,
		"action_zone": [],
		"probability": 0.01
	},
	ActionType.VERTICAL_SPIKE: {
		"name": "VERTICAL SPIKE",
		"function": spawn_vertical_spikes,
		"probability": 0.1,
		"action_zone": [
			Vector2i(0, 1),
			Vector2i(0, 0),
			Vector2i(0, -1),
			Vector2i(1, 0),
			Vector2i(-1, 0),
		]
	},
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
	if action_stacks.size() == 0:
		_update_size()
	var next_action: ActionType = action_stacks[0]
	var action_property = dict[next_action]
	var action_zone = action_property["action_zone"]
	
	for pos in action_zone:
		var target_pos = (tile.grid_position + pos) % map.grid_size
		if target_pos.x < 0:
			target_pos.x += map.grid_size.x
		if target_pos.y < 0:
			target_pos.y += map.grid_size.y
		
		if target_pos == player.movement_component.grid_position:
			return
	
	var action = action_stacks.pop_front()
	var action_ui = action_ui_stacks.pop_front()
	if action in dict:
		tile.on_action(next_action)
		on_action.emit()
		dict[action]["function"].call(tile, event)
	else:
		print("Action not found: ", action)
	if !("temporary" in dict[action] && dict[action]["temporary"]):
		action_stacks.append(action)
		action_ui_stacks.append(action_ui)
	else:
		action_ui.queue_free()

	on_action_stack_changed.emit()
	GameGlobal.is_game_have_start = true
	number_of_actions += 1

func rotate_clock(tile: Tile, event: InputEvent) -> void:
	if event.button_index == MOUSE_BUTTON_RIGHT:
		tile.rotate_counter_clock()
	else:
		tile.rotate_clock()
	pass

func rotate_counter_clock(tile: Tile, event: InputEvent) -> void:
	tile.rotate_counter_clock()
	pass

func transform_empty(tile: Tile, event: InputEvent) -> Tile:
	return tile.transform_to_another_type(load("res://actors/tile/cursed_four.tscn"))

## ultimate carrot
func transform_empty_cursed(tile: Tile, event: InputEvent) -> void:
	var grid_pos = tile.grid_position
	for i in range(0, 4):
		var current_tile: Tile = map.grid[(grid_pos.x + i) % map.grid_size.x][grid_pos.y]
		current_tile.is_changeable = true
		transform_empty(current_tile, event)
		await get_tree().create_timer(0.1).timeout


func transform_cross(tile: Tile, event: InputEvent) -> void:
	var list_random = [0,0,0,0,1,1,1,2,2]
	list_random.shuffle()

	for i in range(-1,2):
		for j in range(-1,2):
			var current_tile = map.grid[(tile.grid_position.x+i)%map.grid_size.x][(tile.grid_position.y+j)%map.grid_size.y]
			var pop = list_random.pop_front()
			var new_tile: Tile = null
			match pop:
				1:
					new_tile = current_tile.transform_to_another_type(load("res://actors/tile/cursed_four.tscn"), false)
				0:
					new_tile = current_tile.transform_to_another_type(load("res://actors/tile/four.tscn"), false)
				2:
					new_tile = current_tile.transform_to_another_type(load("res://actors/tile/full.tscn"), false)
			if new_tile && new_tile.tile_bigger:
				new_tile.tile_bigger.play_full(abs((-i) * 0.1 + (-j) * 0.1))

func transform_empty_bomb(tile: Tile, event: InputEvent) -> void:
	for i in range(-1,2):
		for j in range(-1,2):
			var current_tile = map.grid[(tile.grid_position.x+i)%map.grid_size.x][(tile.grid_position.y+j)%map.grid_size.y]
			var new_tile: Tile = current_tile.transform_to_another_type(load("res://actors/tile/four.tscn"), false)
			if new_tile && new_tile.tile_bigger:
				new_tile.tile_bigger.play_full((i+1) * 0.1 + (j+1) * 0.1)

func horizontal_swap(tile: Tile, event: InputEvent) -> void:
	tile.horizontal_swap(map)

func vertical_swap(tile: Tile, event: InputEvent) -> void:
	tile.vertical_swap(map)
	
func spawn_enemy(tile: Tile, event: InputEvent) -> void:
	
	for i in range(-1,2):
		var current_tile = map.grid[(tile.grid_position.x + i)%map.grid_size.x][(tile.grid_position.y)%map.grid_size.y]
		var new_tile = null
		new_tile = current_tile.transform_to_another_type(load("res://actors/tile/four.tscn"), false)
		if new_tile && new_tile.tile_bigger:
			new_tile.tile_bigger.play_full(0.1*(i+1))
			
	for i in range(-1,3,2):
		var current_tile = map.grid[(tile.grid_position.x)%map.grid_size.x][(tile.grid_position.y+i)%map.grid_size.y]
		var new_tile = null
		new_tile = current_tile.transform_to_another_type(load("res://actors/tile/four.tscn"), false)
		if new_tile && new_tile.tile_bigger:
			new_tile.tile_bigger.play_full(0.1*(i+1))
	
	var enemy := ENEMY.instantiate()
	enemy.target = player
	player.get_parent().add_child(enemy)
	enemy.grid_position = tile.grid_position

func spawn_vertical_spikes(tile: Tile, event: InputEvent) -> void:
	var spike := load("res://actors/tile/spike/four_spike.tscn")
	var full := load("res://actors/tile/full.tscn")
	
	for i in range(-1,2,2):
		var current_tile = map.grid[(tile.grid_position.x + i)%map.grid_size.x][(tile.grid_position.y)%map.grid_size.y]
		var new_tile = null
		new_tile = current_tile.transform_to_another_type(spike, false)
		if new_tile && new_tile.tile_bigger:
			new_tile.tile_bigger.play_full(0.1*(i+1))
	
	for j in range(-1,2,2):
		var current_tile = map.grid[(tile.grid_position.x)%map.grid_size.x][(tile.grid_position.y + j)%map.grid_size.y]
		var new_tile = null
		new_tile = current_tile.transform_to_another_type(spike, false)
		if new_tile && new_tile.tile_bigger:
			new_tile.tile_bigger.play_full(0.1*(j+1))

	var current_tile = map.grid[(tile.grid_position.x)%map.grid_size.x][(tile.grid_position.y)%map.grid_size.y]
	var new_tile = null
	new_tile = current_tile.transform_to_another_type(full, false)
	if new_tile && new_tile.tile_bigger:
		new_tile.tile_bigger.play_full(0.1)

func delete_current_action() -> void:
	var to_remove_action = GameGlobal.action_stacks.pop_front()
	var action_ui = GameGlobal.action_ui_stacks.pop_front()
	action_ui.queue_free()
	# if action_stacks.size() == 0:
	_update_size()
	on_action_stack_changed.emit()
	if !hovered_tile:
		return
	hovered_tile.on_action(to_remove_action)
	

# No operation
func nop(_tile: Tile, _event: InputEvent):
	return

@export var player: Player = null
@export var map: Map = null
@export var camera: Camera2D = null
var is_game_have_start: bool = false
var rng = RandomNumberGenerator.new()
var rng_seed = str(randi())
var leaderboard = null

@export var action_ui_scene: PackedScene = preload("res://scenes/ui/action_ui.tscn")
@export var gap: int = 2

var actions_ui: Array[ActionUI] = []



func _update_size() -> void:
	if actions_ui.size() == 0:
		add_action(ActionType.ROTATE_CLOCK, new_action_ui(ActionType.ROTATE_CLOCK))
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
	# _update_size()
	
	return action_ui
	
func pick_weighted_random_action() -> ActionType:
	var all_actions = dict.keys()
	var defined_weight := 0.0
	var undefined_actions := []

	# 1. Calcul du poids défini et collecte des actions sans proba
	for action in all_actions:
		if dict[action].has("probability"):
			defined_weight += dict[action]["probability"]
		else:
			undefined_actions.append(action)

	# 2. Répartition uniforme pour les actions restantes
	var remaining_weight = 1.0 - defined_weight
	var default_weight =  remaining_weight / undefined_actions.size() if undefined_actions.size() > 0  else 0.0

	# 3. Liste cumulative
	var cumulative := []
	var acc := 0.0
	for action in all_actions:
		var weight = dict[action].get("probability", default_weight)
		acc += weight
		cumulative.append({ "action": action, "threshold": acc })

	# 4. Tirage
	var r = rng.randf()
	for entry in cumulative:
		if r <= entry.threshold:
			return entry.action

	return all_actions[0]  # Fallback


func reset_game() -> void:

	score = 0
	number_of_actions = 0

	GameGlobal.action_stacks = GameGlobal.action_stack_backup.duplicate()
	for action_ui in GameGlobal.action_ui_stacks:
		action_ui.queue_free()
	GameGlobal.action_ui_stacks.clear()
	for action in GameGlobal.action_stacks:
		var action_ui: ActionUI = action_ui_scene.instantiate()
		%ActionsContainer.add_child(action_ui)
		action_ui.texture_rect.texture = GameGlobal.action_textures[action]
		actions_ui.append(action_ui)
		_update_size()
	GameGlobal.action_ui_stacks = actions_ui
