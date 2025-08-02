extends Control
class_name MainMenu

@onready var play: Control = %Play
@export var main_menu_scene: PackedScene
@onready var play_button: Button = %PlayButton
@onready var request: Node2D = $Request
@onready var seed_of_the_day: Label = %Seed_of_the_day

@onready var leaderboards: Array[HBoxContainer] = [%Leaderboard, %Leaderboard2, %Leaderboard3, %Leaderboard4, %Leaderboard5]

@onready var hbox_container: VBoxContainer = $HBoxContainer
func _ready():
	UIManager.first_unclosable = true
	UIManager.set_ui(hbox_container, play_button)

func _on_play_pressed():
	UIManager.set_ui(play)
	#print("Play button pressed")
	#TransitionManager.change_scene(main_menu_scene, "circle_gradient", null, 1.0)
	request.get_seed()
	request.get_leaderboard()
	# request.get_rank(pseudo="Pseudo")
	
func _on_quit_pressed():
	get_tree().quit()
func _on_play_button_pressed():
	TransitionManager.change_scene(main_menu_scene, "circle_gradient", null, 1.0)
	pass # Replace with function body.
