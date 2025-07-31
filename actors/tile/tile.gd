@tool
extends Node2D

class_name Tile

enum Rotation {
	UP = 0,
	RIGHT = 1,
	DOWN = 2,
	LEFT = 3
}

signal on_tile_full


@onready var tile_bigger: AnimationPlayer = %TileBigger
@export var rotation_speed: float = 0.2
@export var tile_rotation : Rotation = Rotation.UP : 
	set(x):
		var clockwise = x > tile_rotation
		var new_rotation = x
		if get_tree():
			rotate_animated(new_rotation)
		else:
			%Sprite.rotation = PI / 2 * new_rotation
			%StaticBody2D.rotation = PI / 2 * new_rotation

		tile_rotation = new_rotation % 4
@export var is_action_spawnable: bool = true
@export_range(0,1,0.01) var chance_action_spawn: float = 0.1

var _transform_to_full: bool = false

var is_hover : bool = false
var grid_position : Vector2i = Vector2i.ZERO

### PUBLIC

func set_grid_position(new_grid_position: Vector2i) -> void:
	grid_position = new_grid_position

func rotate_clock() -> void:
	print("rotating clockwise")
	tile_clicked(1)

func rotate_counter_clock() -> void:
	tile_clicked(-1)

func swap(map: Map,vector : Vector2i) -> void:
	var til_size = map.tile_size
	translation_animated(vector * til_size)
	
	var neighbor = map.grid[(grid_position.x+vector.x)%map.grid_size.x][(grid_position.y+vector.y)%map.grid_size.y]
	neighbor.translation_animated(-vector * til_size)
	
	map.swap_tiles(grid_position,(grid_position+vector)%map.grid_size)

func horizontal_swap(map: Map) -> void:
	swap(map,Vector2i(1,0))
	
func vertical_swap(map: Map) -> void:
	swap(map,Vector2i(0,1))



func _ready():
	# Generation de l'action
	if is_action_spawnable:
		if randf() < chance_action_spawn:
			var action_load: PackedScene = load("res://actors/action/action.tscn")
			var action = action_load.instantiate()
			action.choose_an_random_action()
			action.position = Vector2i(8,8)
			%ActionHolder.add_child(action)
	pass

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
	tile_rotation = tile_rotation + way

func tile_hovered() -> void:	
	pass

func tile_unhovered() -> void:
	pass

func _process(delta: float) -> void:
	# label.text = str(grid_position)
	pass

func _on_area_body_exited(body: Node2D) -> void:
	if not body is Player:
		return
	if !_transform_to_full:
		return
	transform_to_another_type(load("res://actors/tile/full.tscn"))
	_transform_to_full = false

func rotate_animated(new_rotation: int) -> void:
	%StaticBody2D.rotation = PI / 2 * new_rotation
	var tween = get_tree().create_tween()
	if abs(%Sprite.rotation) - abs(PI / 2 * new_rotation) > 0.01:
		if %Sprite.rotation > 2*PI:
			%Sprite.rotation -= 2 * PI
		elif %Sprite.rotation < -2*PI:
			%Sprite.rotation += 2 * PI
	tween.tween_property(%Sprite, "rotation", PI / 2 * new_rotation, rotation_speed)
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_ELASTIC)
	
func translation_animated(new_translation: Vector2) -> void:
	print("Translation tile to: ", new_translation)
	var tween = get_tree().create_tween()
	var target = position + new_translation
	tween.tween_property(self, "position", target, 0.2)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_LINEAR)

	await tween.finished
	position = target

func transform_to_another_type(new_tile: PackedScene) -> void:
	var tile_instance: Tile = new_tile.instantiate()
	tile_instance.position = position
	tile_instance.grid_position = grid_position
	tile_instance.tile_rotation = tile_rotation
	get_parent().add_child(tile_instance)
	if tile_instance.tile_bigger:
		tile_instance.tile_bigger.play_full()
	GameGlobal.map.grid[grid_position.x][grid_position.y] = tile_instance
	queue_free()

func can_pass(direction: Rotation) -> bool:
	return true


func _on_area_body_entered(body):
	if not body is Player:
		return
	var player: Player = body
	if player.randomTileCount < player.randomTileMax:
		player.randomTileCount += 1
		if player.randomTileCount >= player.randomTileMax:
			_transform_to_full = true
			player.randomTileCount = 0

	pass # Replace with function body.
