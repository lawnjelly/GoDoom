extends Node



enum eType {
T_NONE,
T_PLAYER,
T_ROCK,
T_SPINNER,
T_BOUNCER,
T_PLATFORM,
T_BASE,
T_PLAYERBASE,
T_MONSTER,
T_CARRY,
T_NUM_TYPES,
}

enum eWeapon {
W_LASER,
W_BOMB,
}

enum eDamage {
D_SPAWNER,	
}




#const m_PLAYER_X_RANGE = 6000
#const m_PLAYER_Y_RANGE = 4000

const m_TERRAIN_SCALE = 5
const m_INVERSE_TERRAIN_SCALE = 0.2
const m_TERRAIN_HEIGHT_SCALE = 0.05

# positioning to close the cave
const m_START_PLAYER = 25
# start of DOBs
const m_START_GAP = 30
# num segs to close off
const m_START_TERRAIN_SEGS = 4

# add this to subtype to signify DOB is dead
# e.g. destroyed base
const m_DEAD_SUBTYPE = 1000
#const m_DELETED_SUBTYPE = 2000
const m_SPAWNERS_OFF = false
const m_SECTIONS_VERBOSE = false

var m_Actors : Actors = Actors.new()
var m_Level : Level = Level.new()
var m_ParticleSystems : ParticleSystems = ParticleSystems.new()

# player stuff
var m_Fuel : int = 0
var m_Lives : int = 0
var m_Score : int = 0

var m_Health : int = 0
var m_Health_prev : int = 0
var m_Health_TimeLeft : float = 0.0

# determined at new game
var m_Difficulty_Overall : float = 1.0
var m_Difficulty_Int : int = 3

# input flags
var m_bUseTouchscreen : bool = true
var m_bDebugBuild : bool = false

const m_INPUT_LEFT = 1
const m_INPUT_RIGHT = 2
const m_INPUT_UP = 4
const m_INPUT_DOWN = 8
const m_INPUT_FIRE = 16
const m_INPUT_BOMB = 32
const m_INPUT_TRACTOR = 64

var m_InputFlags : int = 0
var m_ptInputAnalog : Vector2 = Vector2(0.0, 0.0)
var m_bAnalogInput : bool = false


func Hardware_Detect():
	m_bUseTouchscreen = OS.has_touchscreen_ui_hint()
	m_bDebugBuild = OS.is_debug_build()
	

func App_Start():
	m_Level.App_Start()
	m_ParticleSystems.App_Start()
	m_Actors.App_Start()

func Game_Start():
	m_Level.Game_Start()
	m_Actors.Game_Start()	
	m_Fuel = 5000 # 5000
	m_Lives = 3
	m_Score = 0
	
	#set_process_unhandled_input(true)
	#Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	
	# difficulty
	if m_Difficulty_Overall < 0.9:
		m_Lives += 1

	UI_UpdateScore()
	UI_UpdateLives()
	UI_UpdateFuel()
	Player_InstantHealth(100)
	
	
	
func Level_Start():
	m_Level.Level_Start()
	m_Actors.Level_Start()
	#Scene.m_Rep_Player.Level_Start()
	#Scene.m_Node_Camera.TeleportToPlayer()
	Scene.Level_Start()
	m_Level.GenerateLevel()
	
	# now replace the DOBs height
	Game.m_Level.GenerateLevel_Finalize()


func FrameUpdate():
	if Input.is_action_just_pressed("ui_cancel"):
		Framework.ShowMenu(Framework.eMenu.MENU_PAUSE)
	
	m_Actors.FrameUpdate()
	#Scene.m_Node_Light.FrameUpdate()
	#Scene.m_Node_Camera.FrameUpdate()

	if m_Health_TimeLeft > 0.0:
		Scene.m_TextureProgress_Health.value = lerp(m_Health_prev, m_Health, 1.0 - m_Health_TimeLeft)
		m_Health_TimeLeft -= Timing.m_FrameDelta
		
#	var health_diff = m_Health - Scene.m_TextureProgress_Health.value
#	var max_change = Timing.m_FrameDelta * 30
#	health_diff = clamp(health_diff, -max_change, max_change)
#	if health_diff != 0:
#		Scene.m_TextureProgress_Health.value += health_diff
	pass
	
func LoTickUpdate():
	Player_IncrementFuel()
	UI_FlashFuel()

func TickUpdate():
	
	m_Actors.TickUpdate()
	
	if m_bDebugBuild:
		Scene.UI_TickUpdate_Debug()
	pass


func Player_InstantHealth(var health : int):
	m_Health = health
	m_Health_prev = health
	m_Health_TimeLeft = 1.0
	

func Player_IncreaseHealth(var amount : int = 10):
	#print ("increase health")
	m_Health_prev = Scene.m_TextureProgress_Health.value
	
	var max_health = 100
	
	if m_Health < max_health:
		Framework.m_Node_SoundManager.PlaySound(Framework.eSoundType.ST_BEEP, Scene.m_Rep_Player)
	
	m_Health += amount
	if m_Health > max_health:
		m_Health = max_health
		
	m_Health_TimeLeft = 1.0
	pass


func Player_IncrementFuel():
	var max_fuel = 200

	if (Game.m_Fuel < max_fuel):
		Game.m_Fuel += 4
	else:
		return
	
	if Game.m_Fuel > max_fuel:
		Game.m_Fuel = max_fuel

	if (Game.m_Fuel % 10) == 0:
		UI_UpdateFuel()
	pass

func Player_IncreaseFuel(var amount = 300):
	#print ("increase fuel")
	var max_fuel = 5000
	
	if (Game.m_Fuel < max_fuel):
		Framework.m_Node_SoundManager.PlaySound(Framework.eSoundType.ST_FUEL, Scene.m_Rep_Player, 2.0)

	Game.m_Fuel += amount
	
	if Game.m_Fuel > max_fuel:
		Game.m_Fuel = max_fuel
	
	UI_UpdateFuel()
	pass

func Player_Scored(var score):
	m_Score += score
	UI_UpdateScore()
	

func Player_Damaged(var edamage):
	#return
	var d = 10
	
	match edamage:
		Game.eDamage.D_SPAWNER:
			d = 10
	
	Framework.m_Node_SoundManager.PlaySound(Framework.eSoundType.ST_PLAYER_HIT_0, Scene.m_Rep_Player)
	#Scene.m_Node_Camera.Shake(d / 5.0)
	Scene.m_Node_Camera.Shake(1.0)
	
	
	m_Health_prev = Scene.m_TextureProgress_Health.value
	
	# difficulty modifier
	var health_loss = d
	health_loss = int (health_loss * Game.m_Difficulty_Overall)
	m_Health -= health_loss
	
	m_Health_TimeLeft = 1.0
	Player_Scored(-d)
	
	# update UI
	if m_Health <= 0:
		m_Lives -= 1
		if m_Lives <= 0:
			UI_UpdateLives()
			Framework.ShowMessage("Game Over", 8, Manager, "Delayed_Finish")
			Framework.m_Node_SoundManager.PlaySound(Framework.eSoundType.ST_BIGZAP)
			return
		else:
			Framework.ShowMessage("You died!", 4, Manager, "Player_Respawn")
			Framework.m_Node_SoundManager.PlaySound(Framework.eSoundType.ST_BIGZAP)
			m_Health = 100
			m_Health_prev = 100
			UI_UpdateLives()
		
	#Scene.m_TextureProgress_Health.value = m_Health
		


func UI_UpdateFuel():
	Scene.m_Label_Fuel.text = str(Game.m_Fuel / 10)

func UI_FlashFuel():
	if Game.m_Fuel < 500:
		Scene.m_Label_Fuel.visible = Scene.m_Label_Fuel.visible == false
	else:
		if Scene.m_Label_Fuel.visible == false:
			Scene.m_Label_Fuel.visible = true

func UI_UpdateLives():
	Scene.m_Label_Lives.text = str(m_Lives)

func UI_UpdateScore():
	Scene.m_Label_Score.text = str(m_Score)	

#func _ready():
#	Scene.App_Start()
#	Framework.App_Start()
#	pass
#

#func _process(delta):
#	if Framework.m_eGameState == Framework.eGameState.GS_MENU:
#		return
#
#	if Input.is_action_just_pressed("ui_cancel") && (MAI.GetThreadState() == MAI.eThreadState.T_INACTIVE):
#		Framework.ShowMenu(Framework.eMenu.MENU_PAUSE)
#	pass

#func _input(event):
#	if Framework.IsRunning() == false:
#		return
	
#	if event is InputEventMouseButton and event.pressed and event.button_index == 1:
#		var pos = Helper.PickBoard(event.position)
			
		#Framework.m_Node_SoundManager.PlaySound(Framework.eSoundType.ST_CLICK)
			
	

	#Framework.ShowMessage(szMessage, 10, self, "Delayed_Finish")


