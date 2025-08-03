extends Control

var start_touch_pos := Vector2.ZERO
var is_dragging := false
const DRAG_THRESHOLD := 20.0

func _input(event): 
	if GameGlobal.in_menu:
		return
	if event is InputEventMouseButton and event.position[1] < 21.:
		return
	if event is InputEventMouseButton and event.pressed:
		accept_event()
	if event is InputEventMouseButton:
		if event.pressed:
			start_touch_pos = event.position
			is_dragging = false
		else:
			if not is_dragging:
				var distance = start_touch_pos.distance_to(event.position)
				if distance > DRAG_THRESHOLD:
					accept_event()
					
					var direction = start_touch_pos - event.position
					var move_direction = Vector2i.ZERO
					if abs(direction.x) > abs(direction.y):
						move_direction = Vector2i(-1 if direction.x > 0 else 1, 0)
					else:
						move_direction = Vector2i(0, -1 if direction.y > 0 else 1)
					GameGlobal.player.get_movement_component().move_player(move_direction)
			start_touch_pos = Vector2.ZERO


"""
var start_touch_pos := Vector2.ZERO
var is_dragging := false
const DRAG_THRESHOLD := 20.0

func _ready():
	# Active la réception des événements globaux
	set_process_input(true)

func _input(event):
	print(event)
	if event is InputEventMouseButton:
		if event.pressed:
			start_touch_pos = event.position
			is_dragging = false
		else:
			if not is_dragging:
				var distance = start_touch_pos.distance_to(event.position)
				if distance < DRAG_THRESHOLD:
					var world_pos = GameGlobal.camera.screen_to_world(event.position)
					GameGlobal.map.detect_area_at(world_pos)
			start_touch_pos = Vector2.ZERO

	elif event is InputEventScreenDrag:
		if start_touch_pos:
			var drag_distance = start_touch_pos.distance_to(event.position)
			if drag_distance > DRAG_THRESHOLD:
				is_dragging = true
"""
