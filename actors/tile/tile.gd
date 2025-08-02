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
@onready var outline : Node2D = %Outline
@onready var seasons = ["spring","summer","fall","winter"]
var outline_color: Color = Color(1, 1, 1, 1)
var outline_tween: Tween = null
@export var outline_min = 0.1
@export var outline_max = 0.5
@onready var sprite: AnimatedSprite2D = %Sprite

@export var sound_action: AudioStreamPlayer2D

@export var rotation_speed: float = 0.2
@export var tile_rotation : Rotation = Rotation.UP : 
	set(x):
		if lock_rotation:
			return
		# var clockwise = x > tile_rotation
		var new_rotation = x
		# if not is_inside_tree():
		# 	return
		if is_inside_tree() && get_tree():
			rotate_animated(new_rotation)
		else:
			%Sprite.rotation = PI / 2 * new_rotation
			%StaticBody2D.rotation = PI / 2 * new_rotation

		tile_rotation = new_rotation % 4
@export var is_action_spawnable: bool = true
@export_range(0,1,0.01) var chance_action_spawn: float = 0.1
@export var lock_rotation: bool = false
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
	
	# var real_co_vector = vector * tile_size
	var neighbor = map.grid[(grid_position.x+vector.x)%map.grid_size.x][(grid_position.y+vector.y)%map.grid_size.y]
	
	translation_animated((grid_position + vector)%map.grid_size * tile_size - grid_position* tile_size)
	neighbor.translation_animated(-((grid_position + vector)%map.grid_size * tile_size - grid_position* tile_size))
	
	map.swap_tiles(grid_position,(grid_position+vector)%map.grid_size)

func horizontal_swap(map: Map) -> void:
	swap(map,Vector2i(1,0))
	
func vertical_swap(map: Map) -> void:
	swap(map,Vector2i(0,1))



func _ready():
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
		if event.pressed:
			GameGlobal.act_tile(self, event)

func tile_clicked(way: int) -> void:
	if lock_rotation:
		tile_bigger.play("rotate_lock")
		return
	tile_rotation = (tile_rotation + way) % 4
	if tile_rotation < 0:
		tile_rotation += 4

func tile_hovered() -> void:
	var action = GameGlobal.action_stacks[0]
	spawn_outline(action)

func tile_unhovered() -> void:
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
		
		if tile.grid_position == GameGlobal.player.movementComponent.grid_position:
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
#	is_player_inside = false
#	if !_transform_to_full:
#		return
#	_transform_to_full = false
#	transform_to_another_type(load("res://actors/tile/full.tscn"))
	var tiles = GameGlobal.map.tiles
	transform_to_another_type(tiles[GameGlobal.rng.randi() % tiles.size()])

func rotate_animated(new_rotation: int) -> void:
	%StaticBody2D.rotation = PI / 2 * new_rotation
	print(new_rotation)
	print(%Sprite.rotation, " vs ", PI / 2 * new_rotation)
	if abs(%Sprite.rotation - PI / 2 * new_rotation) > PI:
		if %Sprite.rotation < PI / 2 * new_rotation:
			%Sprite.rotation += PI * 2
		else:
			%Sprite.rotation -= PI * 2

	var tween = get_tree().create_tween()
	tween.tween_property(%Sprite, "rotation", PI / 2 * new_rotation, rotation_speed)
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_ELASTIC)
	
func translation_animated(new_translation: Vector2) -> void:
	var target = position + new_translation
	%Sprite.position -= new_translation
	position = target
	print("Translation tile to: ", new_translation)
	var tween = get_tree().create_tween()
	tween.tween_property(%Sprite, "position", Vector2(0,0), 0.2)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_LINEAR)

	await tween.finished

func transform_to_another_type(new_tile: PackedScene, play_animation: bool = true) -> Tile:
	if is_player_inside:
		print("Player is still inside the tile, cannot transform")
		return null
	var tile_instance: Tile = new_tile.instantiate()
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
	return tile_instance

func play_sound() -> void:
	if not sound_action:
		print("no sound action set")
		return
	print("Playing sound")
	sound_action.play()

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
