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

var is_hover : bool = false
var grid_position : Vector2i = Vector2i.ZERO

### PUBLIC

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

func _on_area_2d_mouse_entered() -> void:
	tile_hovered()
	is_hover = true


func _on_area_2d_mouse_exited() -> void:
	tile_unhovered()
	is_hover = false


func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			GameGlobal.act_tile(self)
		# elif event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
		# 	tile_clicked(1)

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
	
	transform_to_another_type(load("res://actors/tile/full.tscn"))

func rotate_animated(new_rotation: int) -> void:
	var tween = get_tree().create_tween()
	if abs(%Sprite.rotation) - abs(PI / 2 * new_rotation) > 0.01:
		if %Sprite.rotation > 2*PI:
			%Sprite.rotation -= 2 * PI
		elif %Sprite.rotation < -2*PI:
			%Sprite.rotation += 2 * PI
	tween.tween_property(%Sprite, "rotation", PI / 2 * new_rotation, 0.2)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_LINEAR)

	await tween.finished
	%StaticBody2D.rotation = PI / 2 * new_rotation
	
func translation_animated(new_translation: Vector2) -> void:
	print("Translation tile to: ", new_translation)
	var tween = get_tree().create_tween()
	tween.tween_property(self, "position", position + new_translation, 0.2)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_LINEAR)

	await tween.finished

func transform_to_another_type(new_tile: PackedScene) -> void:
	var tile_instance: Tile = new_tile.instantiate()
	tile_instance.position = position
	tile_instance.grid_position = grid_position
	tile_instance.tile_rotation = tile_rotation
	get_parent().add_child(tile_instance)
	tile_instance.tile_bigger.play_full()
	GameGlobal.map.grid[grid_position.x][grid_position.y] = tile_instance
	queue_free()
