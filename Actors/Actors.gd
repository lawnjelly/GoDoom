extends Reference

class_name Actors

func App_Start():
	pass

func Game_Start():
	pass

func Level_Start():
	Scene.m_Phy_Player.Level_Start()
	
	# create monsters
	for i in range (8):
		var m = Scene.m_Scene_Monster.instance()
		Scene.m_Node_Physics.add_child(m)
		m.Create()
	pass

func FrameUpdate():
	pass


func TickUpdate():
	
	for i in range (Scene.m_Node_Physics.get_child_count()):
		var ch = Scene.m_Node_Physics.get_child(i)
		ch.TickUpdate()
	
	#Scene.m_Phy_Player.TickUpdate()
	
	Graph_Objects.iterate_all()
	pass


