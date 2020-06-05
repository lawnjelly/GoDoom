extends Node

var m_RoomManager : LRoomManager

var m_Node_Root
var m_Node_Game
var m_Node_Demo
var m_Node_UI
var m_Node_Camera : Spatial
var m_Node_Light
var m_Node_ParticleSystems

var m_Smooth_Camera
var m_Node_Controller

var m_Node_Level


var m_Node_Actors
var m_Node_Reps
var m_Node_Physics

var m_Node_Explosions
var m_Node_Melts
#var m_Node_Lasers

var m_Rep_Player
var m_Phy_Player

var m_Rep_Pools

var m_Scene_Sound
var m_Scene_Player
var m_Scene_Bomb
var m_Scene_Explosion
var m_Scene_Melt
var m_Scene_RepPool
var m_Scene_Demo

var m_Scene_Monster
var m_Scene_Rep_Monster

var m_Scene_Levels = []

var m_Label_Fuel
var m_Label_Lives
var m_Label_Score
var m_TextureProgress_Health

var m_Label_Needed0
var m_Label_Needed1
var m_Label_Debug0
var m_Label_Debug1
var m_Label_Debug0_Timeout : int = 0
var m_Label_Debug1_Timeout : int = 0
const DEBUG_TIMEOUT_TICKS = 120

var m_Debug_Sphere0

var m_Mat_Laser

func Player():
	return m_Phy_Player

func Level_Start():
	m_Label_Debug0_Timeout = 0
	m_Label_Debug1_Timeout = 1

func App_Start():

#	m_Mat_Black = load("res://Misc/Black_Mat.tres")
	
	m_Mat_Laser = load("res://Game/Shader_Laser.tres")

#	m_Class_Piece = load("res://Game/Piece.gd")

	m_Node_Root = get_node("/root/Root")
	m_Node_Game = m_Node_Root.get_node("Game")
	m_RoomManager = m_Node_Game.get_node("LRoomManager")
	m_Node_UI = m_Node_Game.get_node("UI")
	m_Smooth_Camera = m_Node_Game.get_node("SmCamera")
	m_Node_Controller = m_Smooth_Camera.get_node("Controller")
	m_Node_Camera = m_Node_Controller.get_node("Camera")
	m_Node_Light = m_Node_Game.get_node("Light")
	m_Node_ParticleSystems = m_Node_Game.get_node("ParticleSystems")

	m_Node_Level = m_Node_Game.get_node("Level")

	m_Scene_Sound = load("res://Framework/Sound/Sound.tscn")
	m_Scene_Player = load("res://Scenes/Player/Player.tscn")
	m_Scene_Bomb = load("res://Scenes/Bomb.tscn")
	m_Scene_Explosion = load("res://Particles/Particles_Explosion.tscn")
	m_Scene_Melt = load("res://Particles/Particles_Melt.tscn")
	m_Scene_RepPool = load("res://Scenes/RepPool.tscn")
	m_Scene_Demo = load("res://Scenes/Demo.tscn")

	m_Scene_Monster = load("res://Scenes/Enemy/Monster.tscn")
	m_Scene_Rep_Monster = load("res://Scenes/Enemy/Monster_Rep.tscn")

	var scene_lev = load("res://Levels/0/rooms.tscn")
	m_Scene_Levels.push_back(scene_lev)

	m_Node_Actors = m_Node_Game.get_node("Actors")
	m_Debug_Sphere0 = m_Node_Game.get_node("DebugSphere0")

	m_Node_Physics = m_Node_Actors.get_node("Phys")
	m_Node_Reps = m_Node_Actors.get_node("Reps")
	
	m_Node_Explosions = m_Node_ParticleSystems.get_node("Explosions")
	m_Node_Melts = m_Node_ParticleSystems.get_node("Melts")
#	m_Node_Lasers = m_Node_Actors.get_node("Lasers")
	
	
#	Scene.m_Node_Reps.add_child(Scene.m_Scene_Player.instance())
	
	# actor reps
#	m_Rep_Player = m_Node_Reps.get_node("Player")
#	m_Rep_Rocks = m_Node_Reps.get_node("Rocks")
#	m_Rep_Pools = m_Node_Reps.get_node("Pools")
#	m_Rep_Spawners = m_Node_Reps.get_node("Spawners")
	

	# physics reps
	m_Phy_Player = m_Node_Physics.get_node("Player")
	

	m_Label_Fuel = m_Node_UI.find_node("Label_Fuel", true, false)
	m_Label_Lives = m_Node_UI.find_node("Label_Lives", true, false)
	m_Label_Score = m_Node_UI.find_node("Label_Score", true, false)
	m_TextureProgress_Health = m_Node_UI.find_node("TextureProgress_Health", true, false)
	
	m_Label_Needed0 = m_Node_UI.find_node("Label_Needed0", true, false)
	m_Label_Needed1 = m_Node_UI.find_node("Label_Needed1", true, false)
	m_Label_Debug0 = m_Node_UI.find_node("Label_Debug0", true, false)
	m_Label_Debug1 = m_Node_UI.find_node("Label_Debug1", true, false)


	# link smoothing nodes
	m_Smooth_Camera.set_target(m_Phy_Player.get_path())

	UI_Start()
	

#	m_Rep_Player.Create()


func Test():
	print("test")
	
func UI_Start():
	# for touchscreens, scale the UI
	var size = OS.window_size
	var wpad = m_Node_UI.find_node("WeaponPad", true, false)
	var touchs = m_Node_UI.find_node("Touchstick", true, false)
	
	assert (wpad)
	assert (touchs)
	
	print("Window Size " + str(size))
	
	if Game.m_bUseTouchscreen == false:
		wpad.visible = false
		touchs.visible = false
		return
	
	
	var scale = size.x / 1500.0
	wpad.scale = Vector2(scale, scale)

	#scale *= 3.0
	#touchs.SetScale(scale)
	
	pass

func UI_NeededText(var which, var sz):	
	match which:
		0:
			m_Label_Needed0.text = sz
		1:
			m_Label_Needed1.text = sz			

func UI_DebugText(var which, var sz):
	if Game.m_bDebugBuild:
		match which:
			0:
				m_Label_Debug0.text = sz
				m_Label_Debug0_Timeout = Timing.m_iCurrentTick + DEBUG_TIMEOUT_TICKS
			1:
				m_Label_Debug1.text = sz			
				m_Label_Debug1_Timeout = Timing.m_iCurrentTick + DEBUG_TIMEOUT_TICKS
	
func UI_TickUpdate_Debug():
	var t : int = Timing.m_iCurrentTick
	
	if (t >= m_Label_Debug0_Timeout) && m_Label_Debug0_Timeout:
		UI_DebugText(0, "")
		m_Label_Debug0_Timeout = 0
	if (t >= m_Label_Debug1_Timeout) && m_Label_Debug1_Timeout:
		UI_DebugText(1, "")
		m_Label_Debug1_Timeout = 0
	pass		
			
func Debug_PlaceSphere(var which, var ptPos):
	match which:
		0:
			m_Debug_Sphere0.translation = ptPos
