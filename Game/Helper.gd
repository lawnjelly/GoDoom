extends Node

var m_szPrintLine = ""

const m_cWorldScale = 1.0 / 1024.0

var m_RandList_Int = LaRandList.new()
var m_RandList_Float = LaRandList.new()

var m_bPaused : bool = true

# generate repeatable random lists
func Rand_Init():
	for i in range (1024):
		m_RandList_Int.Add(randi())
	for i in range (1024):
		m_RandList_Float.Add(randf())
	

func Rand_Seed(var s):
	# just some random prime number
	# 467 for version 0.12
	#s *= 467
	s *= 1021
	m_RandList_Int.Reset(s)
	m_RandList_Float.Reset(s)
	
func Rand_Int()->int:
	return m_RandList_Int.GetValue()

func Rand_Float()->float:
	return m_RandList_Float.GetValue()
	
func Rand_Range(var lo : float, var hi : float)->float:
	var f : float = Rand_Float()
	f *= (hi - lo)
	f += lo
	return f

func Rand_IntRange(var lo : int, var hi : int)->int:
	var v : int = Rand_Int() % (hi - lo + 1)
	return v + lo


func Log_(var sz):
	m_szPrintLine += sz

func Log(var sz):
	Log_(sz)
	print(m_szPrintLine)
	m_szPrintLine = ""

func GetTimeMS() -> int:	
	return OS.get_ticks_msec()
	
func VecToWorld(var pos : Vec2I):
	return Vector3(pos.x * m_cWorldScale, pos.y * m_cWorldScale, 0)
	
	
func Physics_SetActive(var bOn):
	# store the paused state because we may want to turn on and off the demo
	m_bPaused = bOn
	get_tree().paused = bOn == false
	
func Demo_SetActive(var bOn):

	if bOn:
		if Scene.m_Node_Demo == null:
			var r = Scene.m_Scene_Demo.instance()
			Scene.m_Node_Root.add_child(r)
			Scene.m_Node_Demo = r
	else:
		if Scene.m_Node_Demo:
			Scene.m_Node_Demo.queue_free()
			Scene.m_Node_Demo = null
	
	#Scene.m_Node_Demo = Scene.m_Node_Root.get_node("Demo")
	#Scene.m_Node_Demo.visible = bOn
#	if bOn:
#		Scene.m_Node_Demo.pause_mode = PAUSE_MODE_PROCESS
#	else:
#		Scene.m_Node_Demo.pause_mode = PAUSE_MODE_PROCESS
	
func StringFromType(var type):
	match type:
		Game.eType.T_NONE:
			return "None"
		Game.eType.T_PLAYER:
			return "Play"
		Game.eType.T_ROCK:
			return "Rock"
		Game.eType.T_SPINNER:
			return "Spin"
		Game.eType.T_BOUNCER:
			return "Boun"
		Game.eType.T_PLATFORM:
			return "Plat"
		Game.eType.T_MONSTER:
			return "Mons"
		Game.eType.T_BASE:
			return "Base"
		Game.eType.T_PLAYERBASE:
			return "PBas"
		Game.eType.T_CARRY:
			return "Carr"
	return "Unkn"
	
# this does not determine culling (see DOBs typesizes)
# but does determine how close DOBs are on the map, and the area size to flatten
func GetTypeLength(var type, var subtype = 0):
	match type:
		Game.eType.T_PLATFORM:
			match subtype:
				0:
					return 8
				4:
					return 2
				5:
					return 1
				_:
					return 4
		Game.eType.T_ROCK:
			return 2
		Game.eType.T_PLAYERBASE:
			return 8 # 12
		#Game.eType.T_NONE:
		#	return Helper.Rand_IntRange(4, 32)
	return 1
	pass

# we are only interested in flattening for certain types	
func GetTerrainFlattenLength(var type, var subtype = 0):
	match type:
		Game.eType.T_PLAYERBASE:
			return GetTypeLength(type, subtype)
	
	# default
	return 0

func GetTypeHeightClearance(var type, var subtype = 0):
	match type:
		Game.eType.T_PLATFORM:
			return 20
		Game.eType.T_SPINNER:
			return 120
		Game.eType.T_MONSTER:
			match subtype:
				1:
					return 160
				3:
					return 160
		Game.eType.T_PLAYERBASE:
			return 120
		Game.eType.T_BASE:
			return 120
			
	return 120
	
func GetFrequencyFromType(var type, var subtype = 0):
	
	pass
	
func GetRandomNormalizedVector()->Vector3:
	var v : Vector3
	
	var bInvalid = true
	var l : float
	
	while bInvalid:
		v = Vector3(rand_range(-1.0, 1.0), rand_range(-1.0, 1.0), rand_range(-1.0, 1.0))
		l = v.length()
		if l > 0.001:
			bInvalid = false
		
	v *= 1.0 / l
	return v
