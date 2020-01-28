extends Spatial

var m_Smoke
var m_Sparks

#var m_iTickLastPlayed = 0

func IsFree()->bool:
	return m_Sparks.emitting == false

func Create(var pos):
	
	#print ("laser tick gap " + str(Timing.m_iCurrentTick - m_iTickLastPlayed))
	#m_iTickLastPlayed = Timing.m_iCurrentTick
	
	translation = pos
	visible = true
	
	if m_Smoke != null:
		m_Smoke.emitting = true
		m_Smoke.restart()
		#m_Smoke.emitting = false
		
	if m_Sparks != null:
		m_Sparks.emitting = true
		m_Sparks.restart()
		#m_Sparks.emitting = false
	pass

# Called when the node enters the scene tree for the first time.
func _ready():
	m_Smoke = get_node("Smoke")
	m_Sparks = get_node("Sparks")
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
