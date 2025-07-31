extends Node2D

class_name Tile

enum Rotation {
	UP = 0,
	RIGHT = 1,
	DOWN = 2,
	LEFT = 3
}

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


### PUBLIC

func rotate_clock() -> void:
	print("rotating clockwise")
	tile_clicked(1)

func rotate_counter_clock() -> void:
	tile_clicked(-1)

func _on_area_2d_mouse_entered() -> void:
	is_hover = true


func _on_area_2d_mouse_exited() -> void:
	is_hover = false


func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			GameGlobal.act_tile(self)
		# elif event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
		# 	tile_clicked(1)
	elif event is InputEventMouseMotion:
		if is_hover:
			tile_hovered()
		else:
			tile_unhovered()

func tile_clicked(way: int) -> void:
	tile_rotation = tile_rotation + way

func tile_hovered() -> void:	
	pass

func tile_unhovered() -> void:
	pass


func rotate_animated(new_rotation: int) -> void:
	print("Rotating tile to: ", new_rotation)
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
