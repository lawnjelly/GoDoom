extends Node

var m_bSoundOn = true
var m_Infos = []
var m_Node_Sound


func LoadSound(var szFilename, var szBus = "Short", var bOneOnly = true, var pitchvar = 0.3):

	var i = SoundInfo.new()
	i.m_Stream = load(szFilename)
	i.m_Bus = szBus
	i.m_bOneOnly = bOneOnly
	i.m_PitchVariation = pitchvar
	
	m_Infos.append(i)
	

func _ready():
	# create pool
	m_Node_Sound = load("res://Framework/Sound/Sound.tscn")
	
	
	# load the streams
	LoadSound("res://Assets/Sound/keyboard_tap.wav")
	LoadSound("res://Assets/Sound/bonk.wav")
	LoadSound("res://Assets/Sound/thrust.wav")
	#LoadSound("res://Assets/Sound/bleep.wav",4)
	LoadSound("res://Assets/Sound/scifidrone.wav", "Long")
	
	LoadSound("res://Assets/Sound/explosion0.wav", "Short", false)
	LoadSound("res://Assets/Sound/laser.wav", "Short", false, 0.1)
	LoadSound("res://Assets/Sound/drop.wav", "Short", false, 0.1)
	
	LoadSound("res://Assets/Sound/ufo.wav", "Long")
	LoadSound("res://Assets/Sound/whirring.wav", "Long")
	LoadSound("res://Assets/Sound/scifiair.wav", "Long")
	LoadSound("res://Assets/Sound/punch.wav", "Short", false, 0.1)
	LoadSound("res://Assets/Sound/zap3.wav")
	LoadSound("res://Assets/Sound/bigzap.wav")
	LoadSound("res://Assets/Sound/droppiano.wav")
	LoadSound("res://Assets/Sound/respawn.wav")
	LoadSound("res://Assets/Sound/beep.wav", "Short", true, 0.0)
	LoadSound("res://Assets/Sound/fuel.wav", "Short", true, 0.0)
	LoadSound("res://Assets/Sound/electro_ching.wav", "Short", true, 0.0)

	
	pass

func StopSound(var stype : int, var node):
	if m_bSoundOn == false:
		return
	
	if node == null:
		node = Scene.m_Node_Camera
		
	var source_stream = StreamFromSType(stype)

	# is the sound type already playing on this node?
	for i in range(0, node.get_child_count()):
		var child = node.get_child(i)
		if child is AudioStreamPlayer3D:
			if child.stream == source_stream:
				child.stop()
				var tim : Timer = Timer.new()
				tim.connect("timeout", child, "queue_free")
				tim.set_wait_time(0.1)
				add_child(tim)
				tim.start()
		
	pass

func PlaySound(var stype : int, var node = null, var volume : float = 1.0):
	if m_bSoundOn == false:
		return
	
	if node == null:
		node = Scene.m_Node_Camera
		# listener is now attached to player
		#node = Scene.m_Rep_Player
		
	var info : SoundInfo = m_Infos[stype]
	#var source_stream = StreamFromSType(stype)

	# is the sound type already playing on this node?
	if info.m_bOneOnly:
		for i in range(0, node.get_child_count()):
			var child = node.get_child(i)
			if child is AudioStreamPlayer3D:
				if child.stream == info.m_Stream:
					# already playing
					return
			

#	var player : AudioStreamPlayer3D = AudioStreamPlayer3D.new()
	var player : AudioStreamPlayer3D = m_Node_Sound.instance()

	node.add_child(player)
		
	player.bus = info.m_Bus
	player.stream = info.m_Stream
	player.pitch_scale = 1.0 - info.m_PitchVariation + (randf() * info.m_PitchVariation * 2)
	player.set_max_db(_DBFromVolume(volume))
	player.connect("finished", player, "queue_free")
	player.play()
	
	player.pause_mode = PAUSE_MODE_PROCESS

func _DBFromVolume(vol : float)->float:
	return 20.0 * log(vol)

# 0 to 2 with 1 default (0db)
func ChangeVolume(var vol):
	
	if vol == 0.0:
		m_bSoundOn = false
	else:
		m_bSoundOn = true
	
	pass

func StreamFromSType(var stype)->AudioStream:
	return m_Infos[stype].m_Stream


