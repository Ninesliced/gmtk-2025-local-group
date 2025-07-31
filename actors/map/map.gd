@tool
extends Node2D

class_name Map

@export var tiles : Array[PackedScene] = []

@export var grid_size : Vector2i = Vector2i(20,20):
	set(value):
		grid_size = value
		_update_grid()
		generate_grid()
	

@export var tile_size : Vector2i = Vector2i(32, 32)

var grid : Array[Array] = []

func _ready() -> void:
	_update_grid()
	generate_grid()

func _update_grid() -> void:
	for child in grid:
		for tile in child:
			if tile != null:
				print("Removing tile: ", tile)
				tile.queue_free()
	grid.clear()
	
	for x in range(grid_size.x):
		var column = []
		for y in range(grid_size.y):
			column.append(null)
		grid.append(column)

func generate_grid() -> void:
	for x in range(grid_size.x):
		for y in range(grid_size.y):
			if grid[x][y] == null:
				var selected_tile: Resource = tiles[randi() % tiles.size()]
				var tile_scene = load(selected_tile.resource_path)
				var tile = tile_scene.instantiate()
				tile.tile_rotation = randi() % 4
				tile.position = Vector2i(x, y) * tile_size
				add_child(tile)
				grid[x][y] = tile

func clear_grid() -> void:
	for x in range(grid_size.x):
		for y in range(grid_size.y):
			if grid[x][y] != null:
				grid[x][y].queue_free()
				grid[x][y] = null

func regenerate_grid() -> void:
	clear_grid()
	generate_grid()
