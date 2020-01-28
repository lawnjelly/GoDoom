extends Control


func _on_Exit_pressed():
	print ("pressed exit")
	Framework.Menu_Exit()
	pass # replace with function body


func _on_NewGame_pressed():
	Framework.ShowMenu(Framework.eMenu.MENU_NEW)
	pass # replace with function body


func _on_Credits_pressed():
	Framework.Menu_Credits()
	pass # replace with function body
