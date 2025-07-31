extends Node

var parent : Player

var is_moving : bool = false

signal on_move(direction: Vector2)

var grid_position : Vector2i = Vector2i(0, 2) :
	set(value):
		if is_moving:
			return
		
		var map = GameGlobal.map
		grid_position.x = value.x % map.grid_size.x
		grid_position.y = value.y % map.grid_size.y
		
		if grid_position.x < 0:
			grid_position.x = map.grid_size.x - 1
		if grid_position.y < 0:
			grid_position.y = map.grid_size.y - 1
		
		update_position()

func _ready():
	if parent == null:
		var new_parent = get_parent()
		if new_parent is Player:
			parent = new_parent
		else:
			assert(false, "MovementComponent must be a child of a CharacterBody2D node.")


func _process(delta):
	var x_direction: float = Input.get_axis("left", "right")
	var y_direction: float = Input.get_axis("up", "down")
	if x_direction **2 + y_direction **2 > 0.4:
		GameGlobal.is_game_have_start = true
	else:
		return
	
	var move_direction: Vector2i = Vector2i.ZERO
	
	if x_direction > 0.4:
		move_direction = Vector2i(1, 0)
	elif x_direction < -0.4:
		move_direction = Vector2i(-1, 0)

	if y_direction > 0.4:
		move_direction = Vector2i(0, 1)
	elif y_direction < -0.4:
		move_direction = Vector2i(0, -1)

	on_move.emit(move_direction)
	grid_position += move_direction


func update_position():
	var map = GameGlobal.map

	var target_position = map.grid[grid_position.x][grid_position.y].global_position + Vector2(map.tile_size) / 2
	
	var distance = (parent.position - target_position).length()
	if get_tree() and distance < 64:
		translation_animation(target_position)
	else:
		parent.position = target_position

func translation_animation(target_position: Vector2) -> void:
	var tween: Tween = create_tween()
	tween.tween_property(parent, "position", target_position, 0.3)
	tween.tween_callback(stop_movement)
	tween.set_ease(Tween.EASE_IN_OUT)
	is_moving = true

func stop_movement() -> void:
	is_moving = false
	
