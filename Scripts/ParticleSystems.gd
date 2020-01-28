extends Reference

class_name ParticleSystems

func App_Start():
	for i in range (4):
		var p = Scene.m_Scene_Explosion.instance()
		Scene.m_Node_Explosions.add_child(p)
		#ex.visible = false

	for i in range (4):
		var p = Scene.m_Scene_Melt.instance()
		Scene.m_Node_Melts.add_child(p)

	pass
	
#func Game_Start():
#	pass
	
func Request_Explosion(var pos):
	for i in range (Scene.m_Node_Explosions.get_child_count()):
		var ex = Scene.m_Node_Explosions.get_child(i)
		if ex.IsFree():
			ex.Create(pos)
			return
	

func Request_Melt(var pos):
	for i in range (Scene.m_Node_Melts.get_child_count()):
		var ex = Scene.m_Node_Melts.get_child(i)
		if ex.IsFree():
			ex.Create(pos)
			#print("melt tick " + str(Timing.m_iCurrentTick))
			return
