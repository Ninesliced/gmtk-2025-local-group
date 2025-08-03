extends Node2D

@export var tile_size := Vector2i(32, 32)
@onready var timer := %Timer

var tile_scene := preload("res://scenes/ui/tile_ui.tscn")

func _ready() -> void:
	var screen_size := get_viewport_rect().size
	
	var grid_size := Vector2i(
		ceil(screen_size.x / tile_size.x),
		ceil(screen_size.y / tile_size.y)
	)
	
	for x in range(grid_size.x):
		for y in range(-1, grid_size.y):
			var tile : TileUi = tile_scene.instantiate()
			tile.position = Vector2i(x, y) * tile_size
			%CanvasGroup.add_child(tile)

func _physics_process(delta: float) -> void:
	var screen_size := get_viewport_rect().size
	var time = timer.wait_time
	var _dist : float = tile_size.y * delta / time
	
	for tile in %CanvasGroup.get_children():
		if tile is TileUi:
			tile.position.y += _dist
			if tile.position.y >= screen_size.y + tile_size.y / 2 - 4:
				var new_tile : TileUi = tile_scene.instantiate()
				new_tile.position = Vector2(tile.position.x, -tile_size.y)
				%CanvasGroup.add_child(new_tile)
				tile.queue_free()
