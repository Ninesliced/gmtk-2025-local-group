extends Control
@onready var play: Control = %Play
@export var main_menu_scene: PackedScene
@onready var play_button: Button = %PlayButton

@onready var hbox_container: VBoxContainer = $HBoxContainer
func _ready():
	UIManager.first_unclosable = true
	UIManager.set_ui(hbox_container, play_button)

func _on_play_pressed():
	UIManager.set_ui(play)
	#print("Play button pressed")
	#TransitionManager.change_scene(main_menu_scene, "circle_gradient", null, 1.0)
	pass # Replace with function body.

func _on_quit_pressed():
	get_tree().quit()
func _on_play_button_pressed():
	TransitionManager.change_scene(main_menu_scene, "circle_gradient", null, 1.0)
	pass # Replace with function body.
