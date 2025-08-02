extends Node2D

func _ready():
	#init the game
	GameGlobal.canvas_layer.show()
	GameGlobal.reset_game()
	GameGlobal.map.generate_grid_from_numbers([
		[0 ,0 ,0 ,0 ,0 ,21,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0],
		[0 ,0 ,0 ,0 ,0 ,21,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0],
		[0 ,0 ,2 ,2 ,2 ,11,0 ,13,2 ,2 ,2 ,2 ,2 ,2 ,21,2 ,2 ,2 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0],
		[0 ,0 ,0 ,0 ,0 ,0 ,0 ,21,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0],
		[0 ,0 ,0 ,0 ,0 ,13,2 ,11,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0],
	])
	
	var action_load: PackedScene = load("res://actors/action/action.tscn")
	var action = action_load.instantiate()
	action.choose_an_random_action()
	action.position = Vector2i(8,8)
	GameGlobal.map.add_child(action)
