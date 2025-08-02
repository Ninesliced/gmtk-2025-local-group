extends Node2D

func _ready():
	#init the game
	GameGlobal.map.generate_grid()
	GameGlobal.canvas_layer.show()
	GameGlobal.reset_game()
	pass
