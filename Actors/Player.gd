extends Actor_Base

#var m_Particles_Sparks
#var m_Particles_Tractor
var m_bLPortalActive = true
var m_MouseSensitivity = 0.003  # radians/pixel

var m_Node_Laser

var m_iTick_NextBomb = 0
var m_iTick_NextLaser = 0


var m_iTick_FinishLaser = 0
const m_LASER_TICKS = 6

func Create():
#	Physics_Create(Scene.m_Phy_Player)
#	m_Type = Game.eType.T_PLAYER
	#m_Particles_Sparks = Base_GetRep().get_node("Particles_Sparks")
	#m_Particles_Tractor = Base_GetRep().get_node("Particles_Tractor")
	m_Node_Laser = Base_GetRep().get_node("Laser")
	
#	m_Breadcrumbs.Create()
	
	pass # Replace with function body.

func Level_Start():
	Base_Create()
	
	var ptStart = Vector3(Game.m_START_PLAYER, 5, 0)
#	Physics_Teleport(ptStart, Quat(0, 0, 0, 1))
#	m_Breadcrumbs.Fill(ptStart)
	
	Base_CreatePhyRep()
	
	m_iTick_NextBomb = 0
	m_iTick_NextLaser = 0
	m_iTick_FinishLaser = 0
	
#	var pr = Physics_GetRep()
#	assert (pr)
#	pr.translation = Vector3(5, 5, 0)
	
	FrameUpdate()
	pass

func FrameUpdate():
	#.Base_FrameUpdate()
	
	# adjust spaceship yaw
	#var yaw = Math.InterpolateBetweenAngles(m_Yaw_prev, m_Yaw, Timing.m_fFraction)
	
	#$Rep.rotation = Vector3(0, yaw, 0)
	pass

func DisplayMessage(var sz):
	print(sz)
	
func TickUpdate():
	# input
	if Input.is_action_just_pressed("ui_focus_next"):
		if m_bLPortalActive == true:
			m_bLPortalActive = false
			DisplayMessage("LPortal OFF")
		else:
			m_bLPortalActive = true
			DisplayMessage("LPortal ON")
			
		Scene.m_RoomManager.rooms_set_active(m_bLPortalActive)
	
	
	if Input.is_action_just_pressed("ui_end"):
		Scene.m_RoomManager.rooms_log_frame()
		if Game.m_bMonstersMove:
			Game.m_bMonstersMove = false
		else:
			Game.m_bMonstersMove = true
			
	
	
	DoInput()
	Move_FirstPerson()
	
	Base_TickUpdate()
	
	TickUpdate_TractorBeam()
	TickUpdate_Weapons()
	#Physics_TickUpdate()
	#BasePlayer_TickUpdate()
	# debug
	#var h = Scene.m_Node_Terrain.Debug_GetHeightInt(m_ptPos.x)
	#Scene.UI_DebugText(1, "height " + str(h))
	
	
	pass
	
func CanThrust():
	if Game.m_Fuel <= 0:
		# sound?
		return false
		
	Game.m_Fuel -= 1
	if (Game.m_Fuel % 10) == 0:
		Scene.m_Label_Fuel.text = str(Game.m_Fuel / 10)
		
	return true
	
	
func DoInput():
	Game.m_InputFlags = 0
	if Input.is_action_pressed("ui_left"):
		Game.m_InputFlags |= Game.m_INPUT_LEFT
	if Input.is_action_pressed("ui_right"):
		Game.m_InputFlags |= Game.m_INPUT_RIGHT
	if Input.is_action_pressed("ui_up"):
		Game.m_InputFlags |= Game.m_INPUT_UP
	if Input.is_action_pressed("ui_down"):
		Game.m_InputFlags |= Game.m_INPUT_DOWN
#	if Input.is_action_pressed("ui_select"):
#		Game.m_InputFlags |= Game.m_INPUT_TRACTOR
	if Input.is_action_just_pressed("fire"):
		Game.m_InputFlags |= Game.m_INPUT_FIRE
#	if Input.is_action_pressed("ui_accept"):
#		Game.m_InputFlags |= Game.m_INPUT_BOMB
	if Input.is_action_just_pressed("jump"):
		Game.m_InputFlags |= Game.m_INPUT_JUMP
	pass
	

func DoInput_Old():
	
	#var pr = Physics_GetRep()
	#if pr == null:
#		return
	
	var move = Vector3(0, 0, 0)
	var bMoving = false
	var bThrust = false
	
#	if Game.m_bUseTouchscreen == false:
	Game.m_InputFlags = 0
	if Input.is_action_pressed("ui_left"):
		Game.m_InputFlags |= Game.m_INPUT_LEFT
	if Input.is_action_pressed("ui_right"):
		Game.m_InputFlags |= Game.m_INPUT_RIGHT
	if Input.is_action_pressed("ui_up"):
		Game.m_InputFlags |= Game.m_INPUT_UP
	if Input.is_action_pressed("ui_down"):
		Game.m_InputFlags |= Game.m_INPUT_DOWN
	if Input.is_action_pressed("ui_select"):
		Game.m_InputFlags |= Game.m_INPUT_TRACTOR
	if Input.is_action_pressed("ui_focus_next"):
		Game.m_InputFlags |= Game.m_INPUT_FIRE
	if Input.is_action_pressed("ui_accept"):
		Game.m_InputFlags |= Game.m_INPUT_BOMB
	
	if Input.is_action_just_pressed("ui_end"):
		Game.m_DOBs.DebugPrint()
	
	
	if Game.m_InputFlags & Game.m_INPUT_LEFT:
		move.x -= 1
		bMoving = true
		#BasePlayer_PressedLeftRight(true)
	if Game.m_InputFlags & Game.m_INPUT_RIGHT:
		move.x += 1
		bMoving = true
		#BasePlayer_PressedLeftRight(false)
	if Game.m_InputFlags & Game.m_INPUT_UP:
		#if m_Row < Globals.Helper_GetLastRow():
		#if CanThrust():
			#Framework.m_Node_SoundManager.PlaySound(Framework.eSoundType.ST_THRUST, pr, 0.6)
		move.z += 1
		bMoving = true
		bThrust = true
	if Game.m_InputFlags & Game.m_INPUT_DOWN:
		#if m_Row > 0:
		move.z -= 1
		bMoving = true

	# analog
	if Game.m_bAnalogInput:
		move.x = Game.m_ptInputAnalog.x
		move.y = Game.m_ptInputAnalog.y

		#if abs(move.x) > 0.2:
			#BasePlayer_PressedLeftRight(move.x < 0.0)
					
		# can thrust?
		if move.y > 0.4:
			if CanThrust():
				#Framework.m_Node_SoundManager.PlaySound(Framework.eSoundType.ST_THRUST, pr, 0.6)
				bThrust = true
			else:
				# no fuel
				move.y = 0.0
		
		bMoving = true
		# add a boost to speed
		move.x *= 1.5
		move.y *= 1.5


#	if bThrust:
#		m_Particles_Sparks.visible = true
#		m_Particles_Sparks.emitting = true
#	else:
#		m_Particles_Sparks.emitting = false

		
	if bMoving == false:
		# allow the player to photosynthesize fuel as last resort
		#Game.Player_IncrementFuel()
		return
		
	# apply velocity in yaw direction
	move *= Timing.m_Sec_PerTick

	Base_Push(move)
	#pr.apply_impulse(Vector3(0, 0, 0), move)
			
#	print("vel : " + str(m_ptVel))


	pass

func TickUpdate_TractorBeam():
	# is anything below the player?
	#var pr = Physics_GetRep()
	#if pr == null:
	#	return
		
#	if Game.m_InputFlags & Game.m_INPUT_TRACTOR:
#		if pr.m_CollisionShape_Tractor.is_disabled() == true:
#			pr.m_CollisionShape_Tractor.set_disabled(false)
#			m_Particles_Tractor.visible = true
#			m_Particles_Tractor.emitting = true
#			Framework.m_Node_SoundManager.PlaySound(Framework.eSoundType.ST_TRACTOR, pr)
#	else:
#		if pr.m_CollisionShape_Tractor.is_disabled() == false:
#			pr.m_CollisionShape_Tractor.set_disabled(true)
#			m_Particles_Tractor.emitting = false
#			Framework.m_Node_SoundManager.StopSound(Framework.eSoundType.ST_TRACTOR, pr)
	pass

func TickUpdate_Weapons():
	if Game.m_InputFlags & Game.m_INPUT_FIRE:
		var sid : int = Graph_Objects.get_obj_sid(m_Graph_ID)
		print("fire from " + String(m_Pos) + " sid " + String(sid))
		
		var yaw = -Scene.m_Node_Controller.rotation.y + (PI / 2)
		var pitch = (Scene.m_Node_Camera.rotation.x)
		
#		var forward = -Vector2(cos(angle), sin(angle))
		var forward = Vector3(-cos(yaw), pitch, -sin(yaw))
		forward = forward.normalized()
		
		#var debug_pos = m_Pos + (forward * 10)
		#Scene.Debug_PlaceSphere(0, debug_pos)

		# do a trace
		
		var hit : Graph_Objects.GTraceResult = Graph_Objects.trace(sid, m_Pos, forward)
		if hit.m_bHit:
			print("hit at " + String(hit.m_ptHit))
			Scene.Debug_PlaceSphere(0, hit.m_ptHit)
	
#	var pr = Physics_GetRep()
#	if pr == null:
#		return
#
#	var tick : int = Timing.m_iCurrentTick
#
#	if tick >= m_iTick_NextBomb:
#		if Game.m_InputFlags & Game.m_INPUT_BOMB:
#			Game.m_Weapons.RequestBomb(pr.translation, pr.linear_velocity)
#			m_iTick_NextBomb = Timing.m_iCurrentTick + (Timing.m_iTicksPerSec / 4)
#			Framework.m_Node_SoundManager.PlaySound(Framework.eSoundType.ST_DROP, pr)
#
#
#	if tick >= m_iTick_NextLaser:
#		if Game.m_InputFlags & Game.m_INPUT_FIRE:
#			#Game.m_Weapons.RequestLaser(pr.translation, true)
#			FireLaser(true)
#
#	if tick >= m_iTick_FinishLaser:
#		FireLaser(false)
#	else:
#		# laser shader
#		if Scene.m_Mat_Laser != null:
#			# ticks left
#			var f = m_LASER_TICKS - (m_iTick_FinishLaser - tick)
#			f += Timing.m_fFraction
#			f /= float (m_LASER_TICKS)
#			Scene.m_Mat_Laser.set_shader_param("shader_time", f)
#

		
	pass

func FireLaser(var bOn):
#	var pr : Physics_Player = Physics_GetRep()
#
#	if bOn:
#		m_iTick_NextLaser = Timing.m_iCurrentTick + m_LASER_TICKS + 4
#		m_iTick_FinishLaser = m_iTick_NextLaser-4
#		m_Node_Laser.visible = true
#		pr.m_CollisionShape_Laser.disabled = false
#
##var m_CollisionShape_Laser
##var m_Area_Laser
#
#		Framework.m_Node_SoundManager.PlaySound(Framework.eSoundType.ST_LASER, pr, 0.5)
#	else:
#		if m_Node_Laser.visible == true:
#			m_Node_Laser.visible = false
#			pr.m_CollisionShape_Laser.disabled = true
	pass

func LaserHit(body):
#	if body == Scene.m_Phy_Player:
#		return
#
#	if body is RigidBody:
#		Game.m_ParticleSystems.Request_Melt(body.translation)
#		var diff = body.translation - m_ptPos
#		var l = diff.length()
#		if l > 0.1:
#			body.linear_velocity += diff * (2.5 / l)
#		Framework.m_Node_SoundManager.PlaySound(Framework.eSoundType.ST_LASER_HIT, body)
#		#print ("Laser hit")
#		body.Hit(Game.eWeapon.W_LASER)
#	#print ("Laser hit")
#
#	if body is KinematicBody:
#		Game.m_ParticleSystems.Request_Explosion(body.translation)
#		Framework.m_Node_SoundManager.PlaySound(Framework.eSoundType.ST_LASER_HIT, body)
#		body.Hit(Game.eWeapon.W_LASER)
		
	pass
	
	
# mouse look
#func _unhandled_input(event):
func _input(event):
#	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
	if event is InputEventMouseMotion:
		Scene.m_Node_Controller.rotate_y(-event.relative.x * m_MouseSensitivity)
		Scene.m_Node_Camera.rotate_x(-event.relative.y * m_MouseSensitivity)
		Scene.m_Node_Camera.rotation.x = clamp(Scene.m_Node_Camera.rotation.x, -1.2, 1.2)

# 1st person shooter type control
func Move_FirstPerson():
	
	var delta = Timing.m_Sec_PerTick
	
	var angle = 0.0
	var move = Vector2(0, 0)
	var height = 0
	
	var gob : Graph_Objects.GObject = Base_GetGOB()
	
	if Game.m_InputFlags & Game.m_INPUT_LEFT:
		move.x -= 1
		#angle += delta
	if Game.m_InputFlags & Game.m_INPUT_RIGHT:
		move.x += 1
		#angle -= delta
	if Game.m_InputFlags & Game.m_INPUT_UP:
		move.y += 1
	if Game.m_InputFlags & Game.m_INPUT_DOWN:
		move.y -= 1
		
	if Input.is_action_pressed("ui_page_down"):
		height -= 1
	if Input.is_action_pressed("ui_page_up"):
		height += 1
	
	if (gob.m_bOnFloor) and (Game.m_InputFlags & Game.m_INPUT_JUMP):
		height += 10
		
	# get forward vector
	angle = -Scene.m_Node_Controller.rotation.y + (PI / 2)
	
	var forward = -Vector2(cos(angle), sin(angle))
	var right = Vector2(-forward.y, forward.x)
	
	move *= 0.4
	height *= 0.3

	var ptPush = Vector3()

	ptPush.x += forward.x * move.y
	ptPush.z += forward.y * move.y
	
	ptPush.x += right.x * move.x
	ptPush.z += right.y * move.x

	ptPush.y += height

	Base_Push(ptPush * delta * 1.0)
	#Graph_Objects.push(m_Player_GID, ptPush * delta * 1.0)

#	var tr = Scene.m_node_Controller.translation
#	tr = Graph_Objects.get_pos(m_Player_GID)
#	var gobj : Graph_Objects.GObject = Graph_Objects.get_obj(m_Player_GID)
#
#	m_bPlayer_OnFloor = gobj.m_bOnFloor
	
	#print ("pos " + str(tr))
#	Scene.m_node_Controller.translation = tr

#	if App.m_WhichCam == 0:
#		m_bPlayer_Flying = true
#	else:
#		m_bPlayer_Flying = false

	# friction
	#m_ptVel *= 0.9
