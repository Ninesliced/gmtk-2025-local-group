extends Node2D

enum Rotation {
	UP = 0,
	RIGHT = 1,
	DOWN = 2,
	LEFT = 3
}

@onready var sprite : Sprite2D = $Sprite

@export var tile_rotation : Rotation = Rotation.UP : 
	set(x):
		tile_rotation = x % 4
		sprite.rotate(PI / 2 * x)

var is_hover : bool = false

func _on_area_2d_mouse_entered() -> void:
	is_hover = true


func _on_area_2d_mouse_exited() -> void:
	is_hover = false


func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			tile_clicked(-1)
		elif event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			tile_clicked(1)
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
