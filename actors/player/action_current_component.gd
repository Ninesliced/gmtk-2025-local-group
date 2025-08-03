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
	var pos_viewport: Vector2 = get_viewport().get_mouse_position()
	var cam := get_parent().get_parent().get_node("Camera2D") as Camera2D
	var world_pos: Vector2 = get_viewport().get_canvas_transform().affine_inverse() * pos_viewport
	action_ui.global_position = world_pos - Vector2(8, 8)
	

func set_current_action():
	if GameGlobal.action_stacks.size() == 0:
		action_ui.set_texture_rect(null)
		return
	action_ui.animation_pop()
	var texture = GameGlobal.action_textures[GameGlobal.action_stacks[0]]
	# print("Current action texture: ",action_ui.texture_rect)
	action_ui.set_texture_rect(texture)
