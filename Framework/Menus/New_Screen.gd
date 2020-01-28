extends Control

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

var m_ListBox_GameMode


func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	m_ListBox_GameMode = find_node("ItemList", true, false)
	m_ListBox_GameMode.add_item("Normal")
	m_ListBox_GameMode.add_item("Random")
	m_ListBox_GameMode.select(0)
	pass

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass


func _on_Start_pressed():
	var ItemNo = m_ListBox_GameMode.get_selected_items()
	Framework.m_eGameMode = Framework.eGameMode.GM_NORMAL
	#Helper.m_Random_Seed = 0
	if ItemNo.size():
		if ItemNo[0] == 1:
			Framework.m_eGameMode = Framework.eGameMode.GM_RANDOM
			#randomize()
			#Helper.m_Random_Seed = randi()
	
	Framework.Menu_NewGame()


func _on_HSlider_value_changed(value):
	print("difficulty value " + str(value))
	#Framework.m_iDifficulty = value
	Framework._Interface_ChangeDifficulty(value)
	pass # replace with function body
