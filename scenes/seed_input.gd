extends LineEdit



func _on_text_changed():
	if text.length() > 8:
		text = text.substr(0, 8)
	pass # Replace with function body.
