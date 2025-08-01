extends Node2D
var target_move : Vector2i
var is_moving : bool = false
@onready var grid := GameGlobal.map.grid
@export var target : Player 
var grid_position : Vector2i = Vector2i(3, 2) :
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

func _ready() -> void:
	GameGlobal.on_action.connect(on_action_performed)
	grid_position = Vector2(0,0)
	
func get_new_target_tile():
	var next_pos = target.movementComponent.grid_position - grid_position
	var move_direction := Vector2i.ZERO
	
	if abs(next_pos.x) >= 1:
		move_direction.x = next_pos.x/abs(next_pos.x)
		
	if abs(next_pos.y) >= 1:
		move_direction.y = next_pos.y/abs(next_pos.y)

	var can_move := Vector2i((int)(is_move_possible(Vector2(move_direction.x,0))),(int)(is_move_possible(Vector2(0,move_direction.y))))

	if can_move.x and can_move.y:
		match randi_range(0,1):
			0:
				move_direction = Vector2(move_direction.x,0)
				grid_position += move_direction
			1:
				move_direction = Vector2(0,move_direction.y)
				grid_position += move_direction
	elif can_move.x:
		move_direction = Vector2(move_direction.x,0)
		grid_position += move_direction
	elif can_move.y:
		move_direction = Vector2(0,move_direction.y)
		grid_position += move_direction
	elif abs(move_direction.y) >= 1 and abs(move_direction.x) >= 1:
		match randi_range(0,1):
			0:
				target_move = Vector2(move_direction.x,0)
			1:
				target_move = Vector2(0,move_direction.y)
	elif abs(move_direction.x) >= 1:
		target_move = Vector2(move_direction.x,0)
	elif abs(move_direction.y) >= 1:
		target_move = Vector2(0,move_direction.y)
	else:
		return
	
func is_move_possible(move_direction: Vector2i) -> bool:
	var current_tile : Tile = GameGlobal.map.grid[grid_position.x][grid_position.y]
	var next_pos = Vector2i(grid_position + move_direction) % GameGlobal.map.grid_size
	var next_tile : Tile = GameGlobal.map.grid[next_pos.x][next_pos.y]
	var inside_direction : Tile.Rotation
	var outside_direction : Tile.Rotation
	
	match move_direction:
		Vector2i(1, 0):
			inside_direction = Tile.Rotation.RIGHT
			outside_direction = Tile.Rotation.LEFT
		Vector2i(-1, 0):
			inside_direction = Tile.Rotation.LEFT
			outside_direction = Tile.Rotation.RIGHT
		Vector2i(0, 1):
			inside_direction = Tile.Rotation.DOWN
			outside_direction = Tile.Rotation.UP
		Vector2i(0, -1):
			inside_direction = Tile.Rotation.UP
			outside_direction = Tile.Rotation.DOWN
		_:
			return false
	
	return !(current_tile == null or next_tile == null or not current_tile.can_pass(inside_direction) or not next_tile.can_pass(outside_direction))
		
func update_position():
	var map = GameGlobal.map

	var target_position = map.grid[grid_position.x][grid_position.y].global_position + Vector2(map.tile_size) / 2
	
	var distance = (position - target_position).length()
	if get_tree() and distance < 64:
		translation_animation(target_position)
	else:
		position = target_position

func translation_animation(target_position: Vector2) -> void:
	var tween: Tween = create_tween()
	tween.tween_property(self, "position", target_position, 0.3)
	tween.tween_callback(stop_movement)
	tween.set_ease(Tween.EASE_IN_OUT)
	is_moving = true
	
func on_action_performed():
	if target_move:
		grid_position += target_move
		target_move = Vector2i.ZERO
	else:
		get_new_target_tile()

func stop_movement() -> void:
	is_moving = false
