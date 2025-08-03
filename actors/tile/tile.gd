@tool
extends Node2D

class_name Tile

enum Rotation {
	UP = 0,
	RIGHT = 1,
	DOWN = 2,
	LEFT = 3
}

# Never used
# signal on_tile_full


@onready var tile_bigger: AnimationPlayer = %TileBigger
@onready var outline: Node2D = %Outline
@onready var sprite: AnimatedSprite2D = %Sprite
@onready var action_holder: Node2D = %ActionHolder

@onready var seasons = ["spring","summer","fall","winter"]
var outline_color: Color = Color(1, 1, 1, 1)
var outline_tween: Tween = null

@export var outline_min = 0.1
@export var outline_max = 0.5

@export var rotation_speed: float = 0.2
@export var rotation_sound_effect: AudioStreamPlayer
@export var idle_rotation_sound_effect: AudioStreamPlayer

@export var is_changeable := true
@export var tile_rotation : Rotation = Rotation.UP : 
	set(new_rotation):
		if lock_rotation:
			return

		# var clockwise = x > tile_rotation
		# var new_rotation = x
		# if not is_inside_tree():
		# 	return
		if is_inside_tree() && get_tree():
			rotate_animated(new_rotation)
		else:
			%Sprite.rotation = PI / 2 * new_rotation
		
		tile_rotation = new_rotation % 4

@export var is_action_spawnable: bool = true
@export_range(0,1,0.01) var chance_action_spawn: float = 0.025
@export var lock_rotation: bool = false
@export var tileName: String = ""

var force_transform_to_scene: PackedScene = null

var _transform_to_full: bool = false

var is_hover : bool = false
# DO NOT USE THIS VARIABLE AS EXPORT, Its a hack to solve tools issues
@export var grid_position : Vector2i = Vector2i.ZERO
var is_player_inside: bool = false
### PUBLIC

func is_transform_to_full() -> bool:
	return _transform_to_full

func set_grid_position(new_grid_position: Vector2i) -> void:
	grid_position = new_grid_position

func rotate_clock() -> void:
	tile_clicked(1)

func rotate_counter_clock() -> void:
	tile_clicked(-1)

func swap(map: Map,vector : Vector2i) -> void:
	var tile_size = map.tile_size
	
	var neighbor = map.grid[(grid_position.x+vector.x)%map.grid_size.x][(grid_position.y+vector.y)%map.grid_size.y]
	
	var pos_neigh = neighbor.position
	var pos = position
	
	translation_animated(pos_neigh)
	neighbor.translation_animated(pos)
	
	map.swap_tiles(grid_position,(grid_position+vector)%map.grid_size)

func horizontal_swap(map: Map) -> void:
	swap(map,Vector2i(1,0))
	

func vertical_swap(map: Map) -> void:
	swap(map,Vector2i(0,1))


func _play_rotation_sound() -> void:
	rotation_sound_effect.pitch_scale = randf_range(0.6, 1.0)
	# FIXME: Godot is broken
	rotation_sound_effect.volume_db = -5.0
	rotation_sound_effect.play()


func _play_idle_rotation_sound() -> void:
	idle_rotation_sound_effect.pitch_scale = randf_range(0.6, 1.0)
	# FIXME: Godot is broken
	idle_rotation_sound_effect.volume_db = -5.0
	idle_rotation_sound_effect.play()

func _ready() -> void:
	# Generation de l'action
	sprite.speed_scale = 0
	
	if is_action_spawnable:
		if GameGlobal.rng.randf() < chance_action_spawn:
			var action_load: PackedScene = load("res://actors/action/action.tscn")
			var action = action_load.instantiate()
			action.choose_an_random_action()
			action.position = Vector2i(8,8)
			%ActionHolder.add_child(action)
	pass
	
	var season_len : int = 25 / 4 #horrible valeur 25 = GameGlobal.map.grid_size.x hardcode
	var i : int = grid_position.x / season_len % 4
	var season = seasons[i]
	sprite.play(season)


func _on_area_2d_mouse_entered() -> void:
	tile_hovered()
	is_hover = true


func _on_area_2d_mouse_exited() -> void:
	tile_unhovered()
	is_hover = false


func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if !event.pressed and event.button_index < 3:
			# print("name: ", name, " grid_position: ", grid_position, " event: ", event)
			# print("tile name:", tileName)
			GameGlobal.act_tile(self, event)


func tile_clicked(way: int) -> void:
	if lock_rotation:
		tile_bigger.play("rotate_lock")
		return
		
	tile_rotation = (tile_rotation + way) % 4
	
	if tile_rotation < 0:
		tile_rotation += 4


func tile_hovered() -> void:
	if len(GameGlobal.action_stacks) == 0: return
	var action = GameGlobal.action_stacks[0]
	spawn_outline(action)


func tile_unhovered() -> void:
	if len(GameGlobal.action_stacks) == 0: return
	var action = GameGlobal.action_stacks[0]
	clear_outline(action)


func on_action(action) -> void:
	clear_outline(action)
	var new_action = GameGlobal.action_stacks[0] if len(GameGlobal.action_stacks) > 0 else action
	spawn_outline(new_action)


func clear_outline(action) -> void:
	var action_property = GameGlobal.dict[action]
	var action_zone = action_property["action_zone"]
	
	for pos in action_zone:
		var grid_pos = (grid_position + pos) % GameGlobal.map.grid_size
		if grid_pos.x < 0:
			grid_pos.x += GameGlobal.map.grid_size.x
		if grid_pos.y < 0:
			grid_pos.y += GameGlobal.map.grid_size.y
		
		var tile: Tile = GameGlobal.map.grid[grid_pos.x][grid_pos.y]
		if tile and tile.outline:
			tile.hide_outline()


func spawn_outline(action) -> void:
	var action_property = GameGlobal.dict[action]
	var action_zone = action_property["action_zone"]

	var is_action_valid: bool = true
	var tiles := []
	
	for pos in action_zone:
		var grid_pos = (grid_position + pos) % GameGlobal.map.grid_size
		if grid_pos.x < 0:
			grid_pos.x += GameGlobal.map.grid_size.x
		if grid_pos.y < 0:
			grid_pos.y += GameGlobal.map.grid_size.y

		var tile: Tile = GameGlobal.map.grid[grid_pos.x][grid_pos.y]
		if tile and tile.outline:
			tiles.append(tile)
		
		if tile.grid_position == GameGlobal.player.get_movement_component().grid_position:
			is_action_valid = false
	
	for tile in tiles:
		if is_action_valid:
			tile.outline.modulate = Color(1, 1, 1, 0.5)
		else:
			tile.outline.modulate = Color(1, 50./255., 50./255., 1)
		tile.show_outline()


func show_outline() -> void:
	outline.visible = true
	low_visibility_outline()


func hide_outline() -> void:
	outline.visible = false
	if outline_tween:
		outline_tween.stop()


func low_visibility_outline() -> void:
	if not outline.visible:
		return
	
	var color := outline.modulate
	outline_tween = create_tween()
	outline_tween.tween_property(outline, "modulate", Color(color.r, color.g, color.b, 0.2), 0.6)
	outline_tween.set_ease(Tween.EASE_IN_OUT)
	outline_tween.tween_callback(high_visibility_outline)


func high_visibility_outline() -> void:
	if not outline.visible:
		return
	
	var color := outline.modulate
	outline_tween = create_tween()
	outline_tween.tween_property(outline, "modulate", Color(color.r, color.g, color.b, 0.5), 0.6)
	outline_tween.set_ease(Tween.EASE_IN_OUT)
	outline_tween.tween_callback(low_visibility_outline)


func _process(delta: float) -> void:
	# label.text = str(grid_position)
	pass


func _on_area_body_exited(body: Node2D) -> void:
	if not body is Player:
		return
		
	if not is_changeable:
		return
#	is_player_inside = false
#	if !_transform_to_full:
#		return
#	_transform_to_full = false
#	transform_to_another_type(load("res://actors/tile/full.tscn"))
	# var tile: Tile = transform_to_another_type(tiles[GameGlobal.rng.randi() % tiles.size()])
	# tile.tile_rotation = randi() % 4
	var direction = GameGlobal.player.movement_component.last_inside_direction
	var tile: Tile = transform_with_1ddl_less(direction, true)
	if !tile:
		return
	tile.tile_bigger.play_full()
	tile._play_idle_rotation_sound()
	
	
func rotate_animated(new_rotation: int) -> void:
	# print(new_rotation)
	# print(%Sprite.rotation, " vs ", PI / 2 * new_rotation)
	if abs(%Sprite.rotation - PI / 2 * new_rotation) > PI:
		if %Sprite.rotation < PI / 2 * new_rotation:
			%Sprite.rotation += PI * 2
		else:
			%Sprite.rotation -= PI * 2

	var tween = get_tree().create_tween()
	tween.tween_property(%Sprite, "rotation", PI / 2 * new_rotation, rotation_speed)
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_ELASTIC)
	
	_play_rotation_sound()
	
func translation_animated(target: Vector2) -> void:
	var pos = position
	%Sprite.position -= target - pos
	position = target
	var tween = get_tree().create_tween()
	tween.tween_property(%Sprite, "position", Vector2(0,0), 0.2)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_LINEAR)


func transform_to_another_type(new_tile: PackedScene, play_animation: bool = true, new_tile_rotation: Rotation = tile_rotation) -> Tile:
	# print(new_tile.resource_name)
	if not is_changeable:
		return self
	if is_player_inside:
		print("Player is still inside the tile, cannot transform")
		return null
	var tile_instance: Tile = new_tile.instantiate()
	tile_instance.position = position
	tile_instance.grid_position = grid_position
	tile_instance.tile_rotation = new_tile_rotation
	if get_parent():
		get_parent().add_child(tile_instance)
	else:
		push_error("why does this tile have no parent?")
	if tile_instance.tile_bigger and play_animation:
		tile_instance.tile_bigger.play_full()
	GameGlobal.map.grid[grid_position.x][grid_position.y] = tile_instance
	queue_free()

	return tile_instance
	
var equivalance_pos_tile_classique: Dictionary = {
	"1111": load("res://actors/tile/full.tscn"),
	"1000": load("res://actors/tile/t.tscn"),
	"1010": load("res://actors/tile/line.tscn"),
	"1100": load("res://actors/tile/corner.tscn"),
	"0000": load("res://actors/tile/four.tscn")
}
var equivalance_pos_tile_spike: Dictionary = {
	"1111": load("res://actors/tile/spike/full_spike.tscn"),
	"1000": load("res://actors/tile/spike/t_spike.tscn"),
	"1010": load("res://actors/tile/spike/line_spike.tscn"),
	"1100": load("res://actors/tile/spike/corner_spike.tscn"),
	"0000": load("res://actors/tile/spike/four_spike.tscn")
}
var equivalance_tile_pos: Dictionary = {
	# 1 c'est un mur
	"FullTile": "1111",
	"TTile": "1000",
	"LineTile": "1010",
	"CornerTile": "1100",
	"FourTile": "0000",
	"FullSpikeTile": "1111",
	"TSpikeTile": "1000",
	"LineSpikeTile": "1010",
	"CornerSpikeTile": "1100",
	"FourSpikeTile": "0000"
}


func rotate_right_by_one(text: String) -> String:
	if text.length() == 0:
		return text
	return text[-1] + text.substr(0, text.length() - 1)


func transform_with_1ddl_less(direction: Rotation, play_animation: bool = true) -> Tile:
	if not is_changeable:
		return self
	if is_player_inside:
		print("Player is still inside the tile, cannot transform")
		return null
	 
	var is_spike = "Spike" in tileName
	var equivalance_pos_tile = equivalance_pos_tile_spike if is_spike else equivalance_pos_tile_classique

	if force_transform_to_scene:
		var tile: Tile = transform_to_another_type(force_transform_to_scene, play_animation)
		# tile.tile_rotation = (tile.tile_rotation - direction + 8) % 4 # FIXME: if later update :3
		return tile
	
	if tileName not in equivalance_tile_pos.keys():
		var tile: Tile = transform_to_another_type(GameGlobal.map.tiles[GameGlobal.rng.randi() % GameGlobal.map.tiles.size()])
		tile.tile_rotation = randi() % 4
		return tile

	var encodage = equivalance_tile_pos[tileName]
	var direction_to_depop = (direction - tile_rotation + 8) % 4

	if direction_to_depop == Rotation.UP:
		encodage[0] = "1"
	elif direction_to_depop == Rotation.RIGHT:
		encodage[1] = "1"
	elif direction_to_depop == Rotation.DOWN:
		encodage[2] = "1"
	elif direction_to_depop == Rotation.LEFT:
		encodage[3] = "1"
	if encodage.count("1") >= 3:
		var tile = transform_to_another_type(equivalance_pos_tile["1111"], true) 
		return tile
		
	for rot in range(4):
		if encodage in equivalance_pos_tile.keys():
			var to_load_tile: PackedScene = equivalance_pos_tile[encodage]
			var tile = transform_to_another_type(to_load_tile, false, (tile_rotation - rot + 8) % 4)
			# ation = rot
			# tile.tile_rotation = (0 - rot) % 4
			return tile

		encodage = rotate_right_by_one(encodage)

	print("Error: Not found rotation")
	"""var tile_instance: Tile = new_tile.instantiate()
	tile_instance.position = position
	tile_instance.grid_position = grid_position
	tile_instance.tile_rotation = tile_rotation
	if get_parent():
		get_parent().add_child(tile_instance)
	else:
		push_error("why does this tile have no parent?")
	if tile_instance.tile_bigger and play_animation:
		tile_instance.tile_bigger.play_full()
	GameGlobal.map.grid[grid_position.x][grid_position.y] = tile_instance
	queue_free()
	return tile_instance"""
	return self


func can_pass(direction: Rotation) -> bool:
	return true


#func _on_area_body_entered(body):
#	if not body is Player:
#		return
#	var player: Player = body
#	is_player_inside = true
#	if player.randomTileCount < player.randomTileMax and player.randomTileMax > 0:
#		player.randomTileCount += 1
#		if player.randomTileCount >= player.randomTileMax:
#			_transform_to_full = true
#			player.randomTileCount = 0
