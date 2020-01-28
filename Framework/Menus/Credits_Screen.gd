extends Control

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

var m_T1 = ""
var m_T2 = ""

func Title(var txt):
	#m_T1 += "[color=red][b]" + txt + "[/b][/color]\n"
	m_T1 += "[b]" + txt + "[/b]\n"
	m_T2 += "\n"
	
func Line(var t1, var t2):
	#m_T1 += t1 + "\t" + t2 + "\n"
	m_T1 += t1 + "\n"
	m_T2 += t2 + "\n"

func Space():
	m_T1 += "\n"
	m_T2 += "\n"

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	var rt = find_node("Credits_Text", true, false)
	var rt2 = find_node("Credits_Text2", true, false)

	Line("Programming", "Lawnjelly")
	Line("Artwork", "Lawnjelly")
	Line("Animation", "Lawnjelly")
	Space()
	
	Title("Music")
	Line("Futurismo", "Eva")
	Line("SUB37", "Eva")
	Line("The End", "Eva")
	Line("Misc", "Eva")
	Line("20", "Eva")
	Line("26", "Eva")
	Line("9", "Eva")
	Line("Harmony", "Nomyn")
	Space()
	
	Title("Sound")
	Line("Misc", "FreeSFX")
	Space()

	Title("Textures")
	Line("Terrain", "SpiralGraphics")
	Space()
	
	Title("Software")
	Line("Engine", "Godot 3.1")
	Line("Modeling", "Blender")
	Line("Texturing", "3D Paint")
	Line("OS", "Linux Mint")

	Space()
	for _i in range (0, 5):
		Line("", "I am skill")
	
	rt.bbcode_text = m_T1
	rt2.bbcode_text = m_T2
	pass

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass


func _on_Back_pressed():
	Framework.ShowMenu(Framework.eMenu.MENU_TITLE)
	pass # replace with function body
