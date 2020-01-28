extends Actor_Base

#var m_Rep


func Create():
	Base_Create()
	Base_CreatePhyRep()
	
	Base_GetGOB().m_Friction = 0.997
	
	var r = Scene.m_Scene_Rep_Monster.instance()
	Scene.m_Node_Reps.add_child(r)
	
	# link
	r.set_target(self.get_path())
	
	m_Rep = r
	
	# register as a dob with lportal
	Scene.m_RoomManager.dob_register(r, 1.0)
	
	pass # Replace with function body.

func TickUpdate():
	Base_TickUpdate()
	Scene.m_RoomManager.dob_update(m_Rep)
	pass
