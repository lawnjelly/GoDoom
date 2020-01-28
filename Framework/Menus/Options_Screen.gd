extends Control

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	_on_SoundSlider_value_changed(1.5)
	pass

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass


func _on_Back_pressed():
	Framework.Menu_Resume()
	pass # replace with function body


func _on_CheckBox_toggled(button_pressed):
	OS.window_fullscreen = button_pressed
	pass # replace with function body


func _on_MusicSlider2_value_changed(value):
	Framework.m_Node_Music.ChangeVolume(value)
	pass # replace with function body


# 0 to 2 with 1 default (0db)
func _on_SoundSlider_value_changed(value):
	Framework.m_Node_SoundManager.ChangeVolume(value)

	var bus_index = AudioServer.get_bus_index("Master")

	if value == 0.0:
		AudioServer.set_bus_mute(bus_index, true)
	else:
		AudioServer.set_bus_mute(bus_index, false)
	
	value -= 1.0
	if value >= 0.0:
		value *= 8.0
	else:
		value *= 32.0
	
	print("sound volume " + str(value) + "dB")
	
	AudioServer.set_bus_volume_db(bus_index, value)
	
	pass # replace with function body
