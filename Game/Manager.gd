extends Node

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	App_Start()
	pass

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass

# Android _______________________________
func Android_Start():
	get_tree().set_quit_on_go_back(false)

func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_GO_BACK_REQUEST:
		_on_Back_pressed()
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		_on_Back_pressed()
		
func _on_Back_pressed():
	#Do what you want to do here
	if Framework.m_eGameState == Framework.eGameState.GS_RUNNING:
		Framework.ShowMenu(Framework.eMenu.MENU_PAUSE)
	pass
# _________________________________________

func App_Start():
	Game.Hardware_Detect()
	Helper.Rand_Init()
	Scene.App_Start()
	Helper.Physics_SetActive(false)
	Framework.App_Start()
	Game.App_Start()
	Android_Start()
	#Helper.App_Start()

	# auto choose new game	
	#Framework.Menu_NewGame()
	pass

func Game_Start():
	Game.Game_Start()
	Helper.Physics_SetActive(true)
	print("Game_Start")
	Level_Start()
	pass

func Game_End():
	print("Game_End")
	Helper.Physics_SetActive(false)
	pass

	
func Delayed_Finish():
	Game_End()
	Framework.ShowMenu(Framework.eMenu.MENU_TITLE)
	pass
	
	
func Level_Start():
	Framework._Interface_ShowGame(false)
	Game.Level_Start()
	
	var delay = 2
	if Game.m_bDebugBuild:
		delay = 0.1
	
	Framework.ShowMessage("Level " + str(Game.m_Level.m_iLevel), delay, Manager, "Level_Start_SecondMessage")
	pass
	
func Level_Start_SecondMessage():
	Framework.m_Node_SoundManager.PlaySound(Framework.eSoundType.ST_MONSTER_2)
	var msg = ""
#	if Game.m_Level.m_Needed_Bases:
#		msg += "Destroy " + str(Game.m_Level.m_Needed_Bases) + " alien bases\n\n"
	
		
	var delay = 2
	if Game.m_bDebugBuild:
		delay = 0.1
	Framework.ShowMessage(msg, delay, Manager, "Level_Start_Finish")

func Level_Start_Finish():
	Framework.m_Node_SoundManager.PlaySound(Framework.eSoundType.ST_RESPAWN)
	Timing.ResetTimer()
	
	
	#Helper.Physics_SetActive(true)
	Framework._Interface_ShowGame(true)
	
func Level_Complete():
	print ("Level complete")
	Framework.ShowMessage("Level Complete!", 4, Manager, "Level_Complete_Finish", false)
	Framework.m_Node_SoundManager.PlaySound(Framework.eSoundType.ST_BIGZAP)
	#Helper.Physics_SetActive(false)
	pass
	
func Level_Complete_Finish():
	Level_Start()
	pass
	
func Player_Respawn():
	Framework.m_Node_SoundManager.PlaySound(Framework.eSoundType.ST_RESPAWN)
	Game.m_Spawners.Respawn_All()
	print("Respawning!")
	pass
