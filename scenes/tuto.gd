extends Node2D

func _ready():
	#init the game
	GameGlobal.canvas_layer.show()
	GameGlobal.reset_game()
	GameGlobal.map.generate_grid_from_numbers([
		[0 ,0 ,0 ,0 ,0 ,21,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ],
		[0 ,0 ,0 ,0 ,0 ,21,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ],
		[0 ,0 ,2 ,2 ,2 ,11,0 ,13,2 ,2 ,21,2 ,2 ,5 ,5 ,5 ,2 ,1 ,0 ,13,3 ,2 ,21,21,21,21,2 ,2 ,2 ,0 ,21,2 ,6 ],
		[0 ,0 ,0 ,0 ,0 ,0 ,0 ,21,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,12,2 ,32,11,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,21,0 ,0 ,0 ],
		[0 ,0 ,0 ,0 ,0 ,13,2 ,11,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ],
	])
	
	print(len(GameGlobal.action_stacks))
	for i in range(len(GameGlobal.actions_ui)):
		GameGlobal.actions_ui[i].queue_free()
		
	GameGlobal.action_stacks.clear()
	GameGlobal.actions_ui.clear()

	GameGlobal.on_action_stack_changed.emit()
	
	var action_load: PackedScene = load("res://actors/action/action.tscn")
	var action = action_load.instantiate()
	action.action = GameGlobal.ActionType.ROTATE_CLOCK
	action.position = Vector2i(8,8)
	GameGlobal.map.grid[8][2].action_holder.add_child(action)
	
	action_load = load("res://actors/action/action.tscn")
	action = action_load.instantiate()
	action.action = GameGlobal.ActionType.VERTICAL_SWAP
	action.position = Vector2i(8,8)
	GameGlobal.map.grid[27][2].action_holder.add_child(action)
	
	GameGlobal.spawn_enemy_on_tile(GameGlobal.map.grid[19][2])
