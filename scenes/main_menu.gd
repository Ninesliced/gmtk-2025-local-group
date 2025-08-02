extends Control

@export var main_menu_scene: PackedScene

func _on_play_pressed():
    TransitionManager.change_scene(main_menu_scene, "circle_gradient", null, 1.0)
    pass # Replace with function body.

func _on_quit_pressed():
    get_tree().quit()