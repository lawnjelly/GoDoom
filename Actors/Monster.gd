extends Actor_Base

#var m_Rep



func Create():
	Base_Create()
	Base_CreatePhyRep()
	
	#Base_GetGOB().m_Friction = 0.997
	
	var r = Scene.m_Scene_Rep_Monster.instance()
	Scene.m_Node_Reps.add_child(r)
	
	# link
	r.set_target(self.get_path())
	
	m_Rep = r
	
	# register as a dob with lportal
	m_DOB_ID = Scene.m_RoomManager.dob_register(r, Vector3(0, 0, 0), 1.0)
	
	pass # Replace with function body.

func TickUpdate():
	
	# get heading to player
	var gob : Graph_Objects.GObject = Base_GetGOB()
	var pgob : Graph_Objects.GObject = Scene.Player().Base_GetGOB()
	
	var offset = pgob.m_ptPos - gob.m_ptPos
	var ang = Math.OffsetToAngle(offset.x, offset.z)
	m_Yaw = Math.SmoothBetweenAngles(m_Yaw, ang, 0.009)
	
	# move
	var move = Math.AngleToOffset3(m_Yaw, 0.003)

	if Game.m_bMonstersMove:
		Base_Push(move)
	
	Base_TickUpdate()
	Scene.m_RoomManager.dob_update(m_DOB_ID, m_Pos)
	pass
