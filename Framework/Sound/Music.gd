extends Node

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

var m_Track = -1
var m_bPlaying = true
var m_PlaybackPosition = 0.0

#var m_Track0

const m_ciNumPrev = 4 # 3
var m_Tracks = []
var m_Tracks_prev = []
var m_PrevCount = 0

var m_iNumTracks = 1

func LoadTracks():
	m_Tracks.append(load("res://Assets/Music/Harmony.ogg"))
	
#	m_Tracks.append(load("res://Assets/Music/devil_voices.ogg"))
	m_Tracks.append(load("res://Assets/Music/Eva/Eva_9.ogg"))
	m_Tracks.append(load("res://Assets/Music/Eva/eva_jap.ogg"))
	m_Tracks.append(load("res://Assets/Music/Eva/Futurismo.ogg"))
	m_Tracks.append(load("res://Assets/Music/Eva/No Artificial Flavoring.ogg"))
	m_Tracks.append(load("res://Assets/Music/Eva/SUB37.ogg"))
	m_Tracks.append(load("res://Assets/Music/Eva/20.ogg"))
	m_Tracks.append(load("res://Assets/Music/Eva/26.ogg"))
	m_Tracks.append(load("res://Assets/Music/Eva/The End.ogg"))




	#m_Tracks.append(load("res://Assets/Music/pastoral.ogg"))
	#m_Tracks.append(load("res://Assets/Music/Idyllic.ogg")) # NO
#	m_Tracks.append(load("res://Assets/Music/Lightness.ogg"))
	#m_Tracks.append(load("res://Assets/Music/Promise.ogg"))
	#m_Tracks.append(load("res://Assets/Music/Reverie.ogg"))

	m_iNumTracks = m_Tracks.size()

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	LoadTracks()
	
	m_iNumTracks = m_Tracks.size()
	
	if m_iNumTracks != 0:
		for i in range(0, m_ciNumPrev):
			#m_Tracks_prev.append(Framework.Rand_Music() % m_iNumTracks)
			m_Tracks_prev.append(0)
	
	#SelectNextTrack()
	
	_on_AudioStreamPlayer_finished()
	$AudioStreamPlayer.volume_db = -15 # -10
	pass

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass

# volume 0 to 2, 1 is normal
func ChangeVolume(var vol):
	
	if vol == 0.0:
		m_bPlaying = false
		m_PlaybackPosition = $AudioStreamPlayer.get_playback_position()
		$AudioStreamPlayer.stop()
	else:
		if m_bPlaying == false:
			m_bPlaying = true
			$AudioStreamPlayer.play(m_PlaybackPosition)
			
	vol = _DBFromVolume(vol)
	$AudioStreamPlayer.volume_db = vol
			
	pass

func _DBFromVolume(vol : float)->float:
#	var v = 20.0 * log(vol)
#	if vol > 1.0:
#		vol -= 1.0
#		vol *= 3.0
	vol *= 20.0
	vol -= 40.0
	
	print ("music vol " + str(vol) + "dB") 
	return vol


func SelectNextTrack():
	var next = 0
	var bNew = false

	#randomize()	
	if m_iNumTracks > m_ciNumPrev:
		while bNew == false:
			next = Framework.Rand_Music() % m_iNumTracks
			bNew = true
			for i in range(0, m_ciNumPrev):
				if m_Tracks_prev[i] == next:
					bNew = false
	else:
		next = Framework.Rand_Music() % m_iNumTracks
		
		
	# next should now be unique	
	# store in the previous circular buffer
	m_Tracks_prev[m_PrevCount] = next
	m_PrevCount += 1
	if (m_PrevCount >= m_ciNumPrev):
		m_PrevCount = 0
		
	m_Track = next
	print ("next audio track : " + str(m_Track))

func _on_AudioStreamPlayer_finished():
	if m_iNumTracks == 0:
		return
	
	SelectNextTrack()	
	
	#m_Track += 1
	#if m_Track > 4:
		#m_Track = 0
		
	var stream = m_Tracks[m_Track]
			
	$AudioStreamPlayer.stream = stream
	$AudioStreamPlayer.play()
	pass # replace with function body
