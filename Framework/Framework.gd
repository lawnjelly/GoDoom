extends Node

enum eGameMode {
GM_NORMAL,
GM_RANDOM}


enum eSoundType {
ST_CLICK,
ST_BONK,
ST_THRUST,
#ST_SINE,
ST_TRACTOR,
ST_EXPLOSION_0,
ST_LASER,
ST_DROP,
ST_MONSTER_0,
ST_MONSTER_1,
ST_MONSTER_2,
ST_PLAYER_HIT_0,
ST_LASER_HIT,
ST_BIGZAP,
ST_DROPPIANO,
ST_RESPAWN,
ST_BEEP,
ST_FUEL,
ST_ELECTROCHING,
}

enum eGameState {
GS_RUNNING,
GS_MENU,
GS_INFO,
}

enum eMenu {
MENU_NONE,
MENU_TITLE,
MENU_PAUSE,
MENU_CREDITS,
MENU_NEW,
MENU_OPTIONS,
}

#enum eInfo {
#INFO_NONE,
#INFO_REACHED_HOME,
#INFO_LEVEL_COMPLETE,
#INFO_GAME_OVER,
#INFO_DIED,
#INFO_INSTRUCTIONS,
#INFO_WON_GAME,
#}


# framework needs a tick
var m_iCurrentTick = 0
var m_iTicksPerSecond = 0

# global player stuff
var m_eGameMode = eGameMode.GM_NORMAL
#var m_iDifficulty = 5

var m_eGameState = eGameState.GS_MENU

# repeatable randoms
var m_RandList_Music


var m_Node_Framework
var m_Node_Menus
var m_Node_Menu_Title
var m_Node_Menu_Pause
var m_Node_Menu_Credits
var m_Node_Menu_New
var m_Node_Menu_Options
var m_Node_Info
var m_Node_SoundManager
var m_Node_Music

func IsRunning():
	return m_eGameState == eGameState.GS_RUNNING


func _physics_process(_delta):
	m_iCurrentTick += 1

func _Interface_PauseGame(var bPause):
	Helper.Physics_SetActive(bPause == false)
	pass

# override these for the game
func _Interface_ShowGame(var bShow):
	Scene.m_Node_Game.visible = bShow
	Scene.m_Node_UI.visible = bShow
	#Helper.Demo_SetActive(bShow == false)
	pass

func _Interface_StartGame():
	print("StartGame")
	Manager.Game_Start()
	pass

func _Interface_EndGame():
	print("EndGame")
	Manager.Game_End()
	pass
	
func _Interface_StartLevel():
	print("StartLevel")
	#m_Info.ShowInfo(INFO_INSTRUCTIONS)
	pass
	
func _Interface_EndLevel():
	pass

func _Interface_ChangeDifficulty(var _difficulty):
	print ("Changed difficulty to " + str(_difficulty))
	
	# 0 to 2
	var d = _difficulty / 3.0
	
	# -1 to 1
	d -= 1.0
	
	d *= 0.5
	d += 1.0

	# 0.5 to 1.5	
	Game.m_Difficulty_Overall = d
	Game.m_Difficulty_Int = int (_difficulty)
	print ("Difficulty overall " + str(Game.m_Difficulty_Overall))
	pass

func _Interface_HideMouse(var bHide):
	#return
	if bHide:
		#Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		#Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	pass

func App_Start():
	m_iTicksPerSecond = Engine.get_iterations_per_second()
	
	var classRandList = load("res://Framework/RandList.gd")
	m_RandList_Music = classRandList.new()
	# repeatable randoms
	#seed(0)
	randomize()
	for _i in range(64):
		var r = randi()
		m_RandList_Music.Add(r)
	
	
	
	m_Node_Framework = Scene.m_Node_Root.get_node("Framework")
	m_Node_Menus = m_Node_Framework.get_node("Menus")
	m_Node_Menu_Title = m_Node_Menus.get_node("Title_Screen")
	m_Node_Menu_Pause = m_Node_Menus.get_node("Pause_Screen")
	m_Node_Menu_Credits = m_Node_Menus.get_node("Credits_Screen")
	m_Node_Menu_New = m_Node_Menus.get_node("New_Screen")
	m_Node_Menu_Options = m_Node_Menus.get_node("Options_Screen")
	m_Node_Info = m_Node_Framework.get_node("Info")
	m_Node_SoundManager = m_Node_Framework.get_node("SoundManager")
	m_Node_Music = m_Node_Framework.get_node("Music")

#	m_Label_Lives = get_tree().get_root().find_node("Label_Lives", true, false)
#	m_Label_Score = get_tree().get_root().find_node("Label_Score", true, false)
#	m_Label_Flies = get_tree().get_root().find_node("Label_Flies", true, false)
	#_Interface_ShowGame(false)
	ShowMenu(Framework.eMenu.MENU_TITLE)
	#m_Node_Info.ShowMessage("This is a message!", 5)

func ShowMessage(var txt, var timeSeconds, var node = null, var szFunc = null, var bPause = true):
	m_Node_Info.ShowMessage(txt, timeSeconds, node, szFunc, bPause)
	

func _SetGameState(var gs : int):
	m_eGameState = gs
	if gs == eGameState.GS_RUNNING:
		_Interface_PauseGame(false)
	else:
		_Interface_PauseGame(true)

func ShowMenu(var m):
	
	#m_Node_SoundManager.PlaySound(Framework.eSoundType.ST_ALERT)
	
	var bHideMouse = false
	
	m_Node_Menu_Pause.visible = false
	m_Node_Menu_Title.visible = false
	m_Node_Menu_Credits.visible = false
	m_Node_Menu_New.visible = false
	m_Node_Menu_Options.visible = false
	
	var bShowDemo = false
	
	match m:
		Framework.eMenu.MENU_NONE:
			bHideMouse = true
			_Interface_ShowGame(true)
			m_Node_Menus.visible = false
			_SetGameState(eGameState.GS_RUNNING)
		Framework.eMenu.MENU_TITLE:
			_Interface_ShowGame(false)
			m_Node_Menus.visible = true
			_SetGameState(eGameState.GS_MENU)
			m_Node_Menu_Pause.visible = false
			m_Node_Menu_Title.visible = true
			m_Node_Menu_Title.get_node("Title_Menu/VBoxContainer/NewGame").grab_focus()
			bShowDemo = true
		Framework.eMenu.MENU_PAUSE:
			#m_Level.ShowGame(false)
			m_Node_Menus.visible = true
			_SetGameState(eGameState.GS_MENU)
			m_Node_Menu_Pause.visible = true
			m_Node_Menu_Pause.get_node("Pause_Menu/VBoxContainer/Resume").grab_focus()
		Framework.eMenu.MENU_CREDITS:
			m_Node_Menus.visible = true
			_SetGameState(eGameState.GS_MENU)
			m_Node_Menu_Credits.visible = true
			m_Node_Music._on_AudioStreamPlayer_finished()
			m_Node_Menu_Credits.get_node("Credits_Menu/VBoxContainer/Back").grab_focus()
		Framework.eMenu.MENU_NEW:
			m_Node_Menus.visible = true
			_SetGameState(eGameState.GS_MENU)
			m_Node_Menu_New.visible = true
			m_Node_Menu_New.get_node("New_Menu/VBoxContainer/Start").grab_focus()
		Framework.eMenu.MENU_OPTIONS:
			_Interface_ShowGame(false)
			m_Node_Menus.visible = true
			_SetGameState(eGameState.GS_MENU)
			m_Node_Menu_Options.visible = true
			m_Node_Menu_Options.get_node("Options_Menu/VBoxContainer/Back").grab_focus()
	
	_Interface_HideMouse(bHideMouse)
	
	Helper.Demo_SetActive(bShowDemo)
	pass
	
func Menu_Exit():
	get_tree().quit()
	pass
	
func Menu_NewGame():
	ShowMenu(eMenu.MENU_NONE)
	_Interface_StartGame()
	pass

func Menu_Credits():
	ShowMenu(eMenu.MENU_CREDITS)
	
func Menu_Resume():
	ShowMenu(eMenu.MENU_NONE)
	pass	

func Menu_EndGame():
	_Interface_EndGame()
	ShowMenu(eMenu.MENU_TITLE)
	pass	
	
	
	#UpdateUI()
	#m_Info.ShowInfo(INFO_DIED)
	#m_SoundManager.PlaySound(Globals.ST_SPLAT, m_Frog.m_Pos)
	
#func UpdateUI():
#	m_Label_Lives.text = str(m_Lives)
#	m_Label_Score.text = str(m_Score)
#
#	m_Icon_Armour.visible = m_Frog.m_bArmour
#
#	if m_Container_Flies.visible == true:
#		m_Label_Flies.text = str(m_nFliesNeeded)
#
#	pass
	
func Rand_Music():
	return m_RandList_Music.GetValue()
