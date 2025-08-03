extends Node2D

func _ready():
	#init the game
	GameGlobal.map.generate_grid()
	GameGlobal.canvas_layer.show()
	GameGlobal.reset_game()
	UIManager.close_all()
	pass
