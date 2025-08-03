extends Control
class_name MainMenu

@onready var play: Control = %Play
@export var main_menu_scene: PackedScene
@onready var play_button: Button = %PlayCustomSeed
@onready var request: Node2D = $Request
@onready var play_seed_of_the_day: Button = %PlaySeedOfTheDay

var seed_of_the_day: String = ""
@export var tutorial_scene: PackedScene = preload("res://scenes/tuto.tscn")
@onready var leaderboards: Array[HBoxContainer] = [%Leaderboard, %Leaderboard2, %Leaderboard3, %Leaderboard4, %Leaderboard5]

@onready var hbox_container: VBoxContainer = %HBoxContainer
func _ready():
	GameGlobal.is_game_have_start = false
	UIManager.first_unclosable = true
	UIManager._stack.clear() # HACK
	UIManager.set_ui(hbox_container, play_button)
	%Username.text = GameGlobal.username
	if GameGlobal.username != "":
		play_seed_of_the_day.is_username_valid = true
	if !GameGlobal.is_seed_of_the_day and GameGlobal.is_user_seed:
		%SeedInput.text = GameGlobal.rng_seed
		
func _on_play_pressed():
	UIManager.set_ui(play)
	#print("Play button pressed")
	#TransitionManager.change_scene(main_menu_scene, "circle_gradient", null, 1.0)
	request.get_seed()
	request.get_leaderboard()
	# request.get_rank(pseudo="Pseudo")
	
func _on_quit_pressed():
	get_tree().quit()
	
func get_random_seed() -> String:
	var out = ""
	var possible_char = "azertyuiopqsdfghjklmwxcvbn1234567890"
	for i in range(12):
		out += possible_char[randi()%len(possible_char)]
	return out
	
func _on_play_button_pressed():
	var inputed_seed = $Play/Container/HBoxContainer/right/panel/VBoxContainer/NinePatchRect/SeedInput.text
	if inputed_seed == "":
		inputed_seed = get_random_seed()
	GameGlobal.is_user_seed = (%SeedInput.text != "")
	GameGlobal.rng_seed = inputed_seed
	GameGlobal.is_seed_of_the_day = false
	GameGlobal.music_manager.calfed = false
	GameGlobal.score = 0
	GameGlobal.is_in_game = true
	TransitionManager.change_scene(main_menu_scene, "circle_gradient", null, 1.0)


func _on_play_seed_of_the_day_pressed() -> void:
	GameGlobal.is_seed_of_the_day = true
	GameGlobal.username = $Play/Container/HBoxContainer/right/SeedOfTheDay/VBoxContainer/NinePatchRect2/Username.text
	if GameGlobal.username == "":
		GameGlobal.username = "Noob"
	GameGlobal.music_manager.calfed = false
	GameGlobal.score = 0
	GameGlobal.is_in_game = true
	TransitionManager.change_scene(main_menu_scene, "circle_gradient", null, 1.0)


func _on_tutorial_button_pressed():
	GameGlobal.music_manager.calfed = false
	GameGlobal.is_seed_of_the_day = false
	GameGlobal.is_in_game = true
	TransitionManager.change_scene(tutorial_scene, "circle_gradient", null, 1.0)
