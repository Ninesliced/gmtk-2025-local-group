extends Camera2D
	
func _physics_process(delta: float) -> void:
	if !GameGlobal.player:
		return 
	position.x += (GameGlobal.player.position.x - position.x)*delta*3
