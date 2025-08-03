extends Button

var has_seed_being_received := false :
	set(value):
		has_seed_being_received = value
		check_disabled()
var is_username_valid := false :
	set(value):
		is_username_valid = value
		check_disabled()

func _ready() -> void:
	check_disabled()
	
func check_disabled():
	
	if has_seed_being_received and is_username_valid:
		disabled = false
	else:
		disabled = true


func _on_username_text_changed(new_text: String) -> void:
	if new_text  == "":
		is_username_valid = false
	else:
		is_username_valid = true
