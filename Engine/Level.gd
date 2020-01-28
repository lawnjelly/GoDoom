extends Reference

class_name Level





var m_iLevel : int = 0



func App_Start():
	pass

func Game_Start():
	m_iLevel = 0 # 3

	
	pass	

func Level_Start():
	if Framework.m_eGameMode == Framework.eGameMode.GM_RANDOM:
		Helper.Rand_Seed(randi())
	else:
		Helper.Rand_Seed(m_iLevel + 1)
	

	# requirements to complete level
	m_iLevel += 1
	
	# load level scene
	#var lev = Scene.m_Scene_Levels[0].instance()
	#Scene.m_Node_Level.add_child(lev)
	var lev = Scene.m_Node_Level.get_node("RoomList")
	
	Graph_Load.import("Levels/0/data.lev")

	Scene.m_RoomManager.set_rooms(lev)
	Scene.m_RoomManager.rooms_set_portal_plane_convention(true)
	#m_RoomManager.rooms_set_hide_method_detach(false)
	Scene.m_RoomManager.rooms_convert(false, true)
#	Scene.m_RoomManager.rooms_set_debug_planes(true)
#	Scene.m_RoomManager.rooms_set_debug_bounds(true)

	Scene.m_RoomManager.dob_register(Scene.m_Node_Camera, 0)
	print ("registering camfirst in room " + str(Scene.m_RoomManager.dob_get_room_id(Scene.m_Node_Camera)))
	
	#print("camfirst ID is " + str(Scene.m_node_Cam_First.get_instance_id()))
	
	#Scene.m_RoomManager.dob_register(Scene.m_node_Cam_Third, 0)

	#print ("registering camthird in room " + #str(Scene.m_RoomManager.dob_get_room_id(Scene.m_node_Cam_Third)))
	#print ("camfirst is still in room " + str(Scene.m_RoomManager.dob_get_room_id(Scene.m_node_Cam_First)))

	
	#Scene.m_RoomManager.rooms_set_camera(Scene.m_node_Cam_Third)
	Scene.m_RoomManager.rooms_set_camera(Scene.m_Node_Camera)



func GenerateLevel():

	# special case, no player bases to take parts to
		
	pass

func GenerateLevel_Finalize():
	
	#refressh UI	
	CheckForLevelCompleted()


func CheckForLevelCompleted():
#	Manager.Level_Complete()
#	return true
	return false
