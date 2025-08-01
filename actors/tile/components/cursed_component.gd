extends Node

var tile: Tile

@export var area: Area2D

func _ready():
	tile = get_parent()
	if not (tile is Tile):
		print("CursedComponent: Parent is not a Tile")
		return
	area.body_exited.connect(_on_exit)

func _on_exit(body: Node) -> void:
	if not (body is Player):
		return
	if tile and tile.is_transform_to_full():
		return
	print("CursedComponent: Transforming tile to full")
	tile.transform_to_another_type(load("res://actors/tile/full.tscn"), true)
	
