extends Reference

class_name Actors

func App_Start():
	pass

func Game_Start():
	pass

func Level_Start():
	Scene.m_Phy_Player.Level_Start()
	pass

func FrameUpdate():
	pass


func TickUpdate():
	Scene.m_Phy_Player.TickUpdate()
	Graph_Objects.iterate_all()
	pass

