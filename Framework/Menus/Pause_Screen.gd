extends Control



func _on_Resume_pressed():
	Framework.Menu_Resume()
	pass # replace with function body


func _on_EndGame_pressed():
	Framework.Menu_EndGame()
	pass # replace with function body


func _on_Options_pressed():
	Framework.ShowMenu(Framework.eMenu.MENU_OPTIONS)
	pass # replace with function body
