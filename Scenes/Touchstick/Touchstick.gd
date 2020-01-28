extends Node2D

const INACTIVE_IDX = -1;

var m_Node_BG
var m_Node_Ball

var m_ptCentre = Vector2(0,0)
var m_ptForce = Vector2(0,0)
var m_ptBall = Vector2()
var m_CurrentPointerIDX = INACTIVE_IDX;


var m_ptHalfSize = Vector2()
var m_SquaredHalfSizeLength = 0

var m_ptHalfSize_Scaled = Vector2()
var m_SquaredHalfSizeLength_Scaled = 0

var m_SquaredHalfSizeLength_Scaled_PLUSBUFFER = 0


# reading
#func Touchstick_IsActive():
#	return IsActive()
#
#func Touchstick_GetPos():
#	return m_ptForce


func _ready():
#	set_process_input(true)
	m_Node_BG = get_node("Touch_BG")
	m_Node_Ball = get_node("Touch_Ball")	

	# scale
	var size = OS.window_size
	var sc = size.x / 600.0

	# original background size
	m_ptHalfSize = m_Node_BG.texture.get_size()/2
	m_SquaredHalfSizeLength = m_ptHalfSize.x * m_ptHalfSize.y
	
	# scale
	m_ptHalfSize_Scaled = m_ptHalfSize * sc
	m_SquaredHalfSizeLength_Scaled = m_ptHalfSize_Scaled.x * m_ptHalfSize_Scaled.y
	
	# allow a buffer extra zone for initially selecting the touchstick,
	# because it is annoying to be difficult to click
	var hs = m_ptHalfSize_Scaled + (m_ptHalfSize_Scaled)
	m_SquaredHalfSizeLength_Scaled_PLUSBUFFER = hs.x * hs.y
	
	# scale graphics
	scale = Vector2(sc, sc)
	position = Vector2(32 + m_ptHalfSize_Scaled.x, -32 -m_ptHalfSize_Scaled.y)

# when scaling according to screen size, we also need to adjust these params
#func SetScale(var sc):
#	print ("Touchstick setscale " + str(sc))
#	m_ptHalfSize *= sc
#	m_SquaredHalfSizeLength = m_ptHalfSize.x * m_ptHalfSize.y
#	scale = Vector2(sc, sc)
	

func GetForce():
	return m_ptForce

func _input_OFF(event):
	
	var incomingPointer = ExtractPointerIdx(event)
	#print(incomingPointer)
	
	if incomingPointer == INACTIVE_IDX:
		return

	
	if Need2ChangeActivePointer(event):
		#if (m_CurrentPointerIDX != incomingPointer) and event.is_pressed():
		if (m_CurrentPointerIDX == INACTIVE_IDX) and event.is_pressed():
			m_CurrentPointerIDX = incomingPointer;
			#ShowAtPos(Vector2(event.position.x, event.position.y));

	var theSamePointer = m_CurrentPointerIDX == incomingPointer
	
	if IsActive() and theSamePointer:
		process_input(event)

func Need2ChangeActivePointer(event): #touch down inside analog	
	if event is InputEventMouseButton or event is InputEventScreenTouch:
		#if isDynamicallyShowing:
			#print(get_parent().get_global_rect())
		#	return get_parent().get_global_rect().has_point(Vector2(event.position.x, event.position.y))
		#else:
		var length = (global_position - Vector2(event.position.x, event.position.y)).length_squared();
		return length < m_SquaredHalfSizeLength_Scaled_PLUSBUFFER
	else:
		return false

func IsActive():
	return m_CurrentPointerIDX != INACTIVE_IDX

func ExtractPointerIdx(event):
	var touch = event is InputEventScreenTouch
	var drag = event is InputEventScreenDrag
	var mouseButton = event is InputEventMouseButton
	var mouseMove = event is InputEventMouseMotion
	
	#print(event)
	if touch or drag:
		return 1
	elif mouseButton or mouseMove:
		#plog("SOMETHING IS VERYWRONG??, I HAVE MOUSE ON TOUCH DEVICE")
		return 0
	else:
		return INACTIVE_IDX

func process_input(event):
	var isReleased = IsReleased(event)
	if isReleased:
		Reset()
		#print ("released")
		return

	#print ("input")

	CalculateForce(event.position.x - global_position.x, event.position.y - global_position.y)
	UpdateBallPos()



func Reset():
	m_CurrentPointerIDX = INACTIVE_IDX
	CalculateForce(0, 0)

#	if isDynamicallyShowing:
#		hide()
#	else:
	UpdateBallPos()

func ShowAtPos(pos):
#	if isDynamicallyShowing:
#	animation_player.play("alpha_in", 0.2)
	global_position = pos

func Hide():
	#animation_player.play("alpha_out", 0.2) 
	pass

func UpdateBallPos():
	m_ptBall.x = m_ptHalfSize.x * m_ptForce.x #+ halfSize.x
	m_ptBall.y = m_ptHalfSize.y * -m_ptForce.y #+ halfSize.y
	m_Node_Ball.position = Vector2(m_ptBall.x, m_ptBall.y)

func CalculateForce(var x, var y):
	#get direction
	m_ptForce.x = (x - m_ptCentre.x)/ m_ptHalfSize_Scaled.x
	m_ptForce.y = -(y - m_ptCentre.y)/ m_ptHalfSize_Scaled.y
	#print(currentForce.x, currentForce.y)
	#limit 
	#print(currentForce.length_squared())
	var sl = m_ptForce.length_squared()
	
	# normalize if outside zone
	if sl > 1.0:
		m_ptForce = m_ptForce / m_ptForce.length()
		
	if sl > 0.04:
		Game.m_bAnalogInput = true
		Game.m_ptInputAnalog = m_ptForce
		#print ("force " + str(m_ptForce))
	else:
		Game.m_bAnalogInput = false
		
	#sendSignal2Listener()

#func sendSignal2Listener():
#	if (listenerNodePath != null):
#		listenerNodePath.analog_force_change(currentForce, self)

func IsPressed(event):
	if event is InputEventMouseMotion:
		return (InputEventMouse.button_mask == 1)
	elif event is InputEventScreenTouch:
		return event.is_pressed()

func IsReleased(event):
	if event is InputEventScreenTouch:
		return !event.is_pressed()
	elif event is InputEventMouseButton:
		return !event.is_pressed()
