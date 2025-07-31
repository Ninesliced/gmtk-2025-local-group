extends Control

class_name ActionsContainer

@export var action_ui_scene: PackedScene = preload("res://scenes/ui/action_ui.tscn")
@export var gap: int = 2

var actions_ui: Array[ActionUI] = []

func _ready():
	for action in GameGlobal.action_stacks:
		var action_ui: ActionUI = action_ui_scene.instantiate()
		add_child(action_ui)
		action_ui.texture_rect.texture = GameGlobal.action_textures[action]
		actions_ui.append(action_ui)
		_update_size()
	GameGlobal.action_ui_stacks = actions_ui
	GameGlobal.on_action_stack_changed.connect(_update_size)

func _process(delta: float) -> void:
	# print(GameGlobal.action_stacks)
	pass

func _update_size() -> void:
	var last_ui: ActionUI = actions_ui[actions_ui.size() - 1]
	last_ui.animation_player.play("pop")
	last_ui.position.x = (actions_ui.size() + 1) * (16 + gap)

	for i in range(0,actions_ui.size()):
		var action_ui = actions_ui[i]
		var tween = get_tree().create_tween()
		tween.tween_property(action_ui, "position:x", i * (16 + gap), 0.2)
