extends Spatial

class_name Actor_Base

var m_Yaw : float
var m_Pos : Vector3 = Vector3()
var m_Graph_ID : int
var m_DOB_ID : int = -1


# render rep is separate to the physics tick moved actor
var m_Rep : Spatial

func Base_GetRep()->Spatial:
	return m_Rep

func Base_Create():
	m_Yaw = 0.0
	m_Pos = Vector3()
	m_Graph_ID = -1
	
func Base_CreatePhyRep():
	m_Graph_ID = Graph_Objects.create_obj()
	
	
func Base_TickUpdate():
	var gob : Graph_Objects.GObject = Graph_Objects.get_obj(m_Graph_ID)
	m_Pos = gob.m_ptPos
	translation = m_Pos
	rotation = Vector3(0, -m_Yaw, 0)
	

func Base_GetGOB()->Graph_Objects.GObject:
	var gob : Graph_Objects.GObject = Graph_Objects.get_obj(m_Graph_ID)
	return gob
	

func Base_Push(var ptPush : Vector3):
	Graph_Objects.push(m_Graph_ID, ptPush)
	
	
