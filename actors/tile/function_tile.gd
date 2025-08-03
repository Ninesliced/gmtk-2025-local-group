extends Tile


var main_menu = load("res://scenes/main_menu.tscn")

enum Function {
		RETURN_TO_MAIN_MENU
	}
	
@export var function : Function = Function.RETURN_TO_MAIN_MENU
	
var dict: Dictionary[Function,Callable] = {
	Function.RETURN_TO_MAIN_MENU: return_to_main_menu
}

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Player:
		dict[function].call()

func return_to_main_menu():
	TransitionManager.change_scene(main_menu,"circle_gradient")
	GameGlobal.canvas_layer.hide()
