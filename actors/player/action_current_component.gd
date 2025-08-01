extends Node
class_name ActionCurrentComponent

var action_ui: ActionUI = null


func _ready() -> void:
	var parent_node = get_parent()
	if parent_node is ActionUI:
		action_ui = parent_node
	else:
		assert(false, "ActionCurrentComponent must be a child of ActionUI node.")
	GameGlobal.on_action_stack_changed.connect(set_current_action)
	set_current_action()

func _process(_delta: float) -> void:
	pass
func set_current_action():
	if GameGlobal.action_stacks.size() == 0:
		return
	action_ui.animation_pop()
	var texture = GameGlobal.action_textures[GameGlobal.action_stacks[0]]
	print("Current action texture: ",action_ui.texture_rect)
	action_ui.set_texture_rect(texture)
