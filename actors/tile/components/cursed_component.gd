extends Node

var tile: Tile

@export var area: Area2D

func _ready():
	tile = get_parent()
	if not (tile is Tile):
		print("CursedComponent: Parent is not a Tile")
		return
	area.body_exited.connect(_on_exit)
	tile.force_transform_to_scene = load("res://actors/tile/full.tscn")

func _on_exit(body: Node) -> void:
	pass
	


func _on_area_mouse_entered():
	print("CURSED")
	pass # Replace with function body.
