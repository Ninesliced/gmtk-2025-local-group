## GLOBAL UI Manager
extends Node

@export var first_unclosable : bool = false

var _stack : Array = []
var _focus_stack : Array = []
var _current_ui : Node = null

var is_consummed : bool = false

func consume_input() -> void:
	is_consummed = true

func is_ui_open() -> bool:
	return _current_ui != null

func _input(event: InputEvent) -> void:
	if is_consummed:
		is_consummed = false
		return
	if event.is_action_pressed("ui_cancel"):
		close_ui()
		return

## display the UI and set focus to a specific node, if none is provided, focus on the current UI
func set_ui(ui: Node, focus_node: Node = null, hide_current: bool = true) -> void:
	if _current_ui != null and hide_current:
		_current_ui.hide()

	ui.show()
	_stack.append(ui)

	if focus_node != null:
		focus_node.grab_focus()
		_focus_stack.append(focus_node)
	else:
		ui.grab_focus()
		_focus_stack.append(ui)

	_current_ui = ui

## close the current UI if closable
func close_ui() -> void:
	if first_unclosable and _stack.size() == 1:
		return

	if _current_ui != null:
		_current_ui.hide()

	_current_ui = null

	if _stack.size() > 1:
		_stack.pop_back()
		_focus_stack.pop_back()
		if _stack.back() == null or !is_instance_valid(_stack.back()):
			print("UIManager: Closing UI, but no valid UI left in stack.")
			_stack.clear()
			_focus_stack.clear()
			return
		_current_ui = _stack.back()
		_current_ui.show()
		print(_current_ui.name, " is now the current UI")

		var current_focus = _focus_stack.back()
		current_focus.grab_focus()
	else:
		_focus_stack.clear()
		_stack.clear()

func close_all() -> void:
	var minimum_size = 1 if first_unclosable else 0

	while _stack.size() > minimum_size:
		close_ui()
