@tool
extends EditorPlugin


func _enter_tree() -> void:
	add_autoload_singleton("TransitionManager", "res://addons/shaker/components/ui/transition_manager/transition_manager.tscn")
	add_autoload_singleton("UIManager", "res://addons/shaker/components/ui/ui_manager/ui_manager.tscn")
	add_autoload_singleton("PauseManager", "res://addons/shaker/components/core/pause_manager/pause_manager.tscn")
	
	# Initialization of the plugin goes here.
	pass


func _exit_tree() -> void:
	remove_autoload_singleton("TransitionManager")
	remove_autoload_singleton("UIManager")
	remove_autoload_singleton("PauseManager")
	# Clean-up of the plugin goes here.
	pass
