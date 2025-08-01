@tool
extends Node2D

class_name Map

@export var tiles : Array[PackedScene] = []

@export var grid_size : Vector2i = Vector2i(5, 25):
	set(value):
		grid_size = value
		_update_grid()
		generate_grid()
	

@export var tile_size : Vector2i = Vector2i(32, 32)

var grid : Array[Array] = []

func _ready() -> void:
	GameGlobal.map = $"."
	_update_grid()
	print("Generate grid")
	generate_grid()
	# print(GameGlobal)	

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
	GameGlobal.rng.seed = randi()
	for x in range(grid_size.x):
		for y in range(grid_size.y):
			if grid[x][y] == null:
				var selected_tile: Resource = tiles[GameGlobal.rng.randi() % tiles.size()]
				var tile_scene = load(selected_tile.resource_path)
				var tile = tile_scene.instantiate()
				tile.tile_rotation = GameGlobal.rng.randi() % 4
				tile.position = Vector2i(x, y) * tile_size
				tile.grid_position = (Vector2i(x, y))
				add_child(tile)
				grid[x][y] = tile

func clear_grid() -> void:
	for x in range(grid_size.x):
		for y in range(grid_size.y):
			if grid[x][y] != null:
				grid[x][y].queue_free()
				grid[x][y] = null

func swap_tiles(tile1_co : Vector2i,tile2_co : Vector2i,) -> void:
	var tile1 : Tile = grid[tile1_co.x][tile1_co.y]
	var tile2 : Tile = grid[tile2_co.x][tile2_co.y]
	grid[tile1_co.x][tile1_co.y] = tile2
	grid[tile2_co.x][tile2_co.y] = tile1
	
	tile1.grid_position = tile2_co
	tile2.grid_position = tile1_co

func regenerate_grid() -> void:
	clear_grid()
	generate_grid()
