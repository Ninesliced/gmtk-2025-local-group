extends Node

var tile: Tile

@export var area: Area2D

func _ready():
    tile = get_parent() as Tile
    area.body_exited.connect(_on_exit)
    if tile == null:
        print("CursedComponent: Parent is not a Tile")
        return

func _on_exit():
    tile.transform_to_another_type(load("res://actors/tile/full.tscn"), false)
    
