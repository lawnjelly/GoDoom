extends Spatial

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var m_Yaw : float = 0.0

# Called when the node enters the scene tree for the first time.
func _ready():
	#$Camera_Demo.translation = Vector3(0, 0, 10)
	$Camera_Demo.make_current()
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	m_Yaw += delta * 0.1
	if m_Yaw > PI:
		m_Yaw -= 2 * PI
		
	#print ("yaw " + str(m_Yaw))
		
	$Stage.rotation = Vector3(0, -m_Yaw, 0)
	pass
