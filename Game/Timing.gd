extends Node

# interpolation fraction for rendering
# is the fraction between the previous and current tick
var m_fFraction = 0.0 # frog
var m_fFraction_Lo = 0.0 # other

# counter of which tick the game is on
var m_iCurrentTick = 0 # frog
var m_iCurrentTick_Lo = 0 # other


# MS at start of level
var m_iMS_Start

# MS of last frame (to cap long frame delays)
var m_iMS_LastFrame

# new for godot driven physics ticks
var m_iMS_LastTick = 0

# determines logic / physics tick rate
var m_iTicksPerSec = 20
var m_iMS_PerTick = 50 # 100 / 33
var m_Sec_PerTick = 0.05
# we run the frog and input at high tick rate and all else at low tick rate
const m_iLoTickMultiple = 20
var m_iMS_PerTickLo = 50 * 1 

# from engine
var m_FrameDelta = 0

# shader
#var m_fShaderTime = 0.0

func _ready():
	var it = Engine.get_iterations_per_second()
	print("Iterations per second : " + str(it))
	m_iTicksPerSec = it
	m_iMS_PerTick = 1000 / it
	m_iMS_PerTickLo = m_iMS_PerTick * m_iLoTickMultiple
	m_Sec_PerTick = 1.0 / it
	pass

func _process(delta):
	# fix
	#delta = 1.0 / 60

	m_FrameDelta = delta
	
	# get MS since the start
	var iMS = OS.get_ticks_msec()
	
	
	# fix delta test
	#delta = 1.0 / 60.0
	#iMS = m_iMS_LastFrame + 17

	# store this just in case useful
	m_iMS_LastFrame = iMS
	
#	var ms_since_tick = iMS - m_iMS_LastTick
#	m_fFraction = float (ms_since_tick) / m_iMS_PerTick
#
#
#	# cap
#	if m_fFraction < 0.0:
#		m_fFraction = 0.0
#	if m_fFraction > 1.0:
#		m_fFraction = 1.0

	# August now use engine fraction
	m_fFraction = Engine.get_physics_interpolation_fraction()
	
	m_fFraction_Lo = m_fFraction

	# sea shader time
#	m_fShaderTime = iMS * 0.001
#	if Scene.m_Material_Sea != null:
#		Scene.m_Material_Sea.set_shader_param("shader_time", m_fShaderTime)
		#Scene.m_Material_Sea2.set_shader_param("shader_time", m_fShaderTime)
	
	Game.FrameUpdate()
	pass

func _physics_process(delta):
	if Framework.m_eGameState != Framework.eGameState.GS_RUNNING:
		return

	#print ("physics delta " + str(delta))

	# get MS since the start
	var iMS = OS.get_ticks_msec()

	# less glitching with this
	m_iMS_LastFrame = iMS
#
	#print ("physics gap " + str(iMS - m_iMS_LastTick))

	m_iMS_LastTick = iMS
#
	Game.TickUpdate()

	m_iCurrentTick += 1
	if (m_iCurrentTick % m_iLoTickMultiple) == 0:
		Game.LoTickUpdate()
		m_iCurrentTick_Lo += 1

	pass


func ResetTimer():
	# make a note of system time at start of level, all ticks will be based on this
	m_iMS_Start = OS.get_ticks_msec()
	m_iMS_LastFrame = m_iMS_Start
	m_iCurrentTick = 0
	m_iCurrentTick_Lo = 0


func DoTicks(var iMS):
	if Framework.m_eGameState != Framework.eGameState.GS_RUNNING:
		return
	
	# get MS since the start
	#var iMS = OS.get_ticks_msec()
	
	# cap to prevent really long frames (and multiple ticks) in the case of OS delays etc of seconds
	var ms_since_last = iMS - m_iMS_LastFrame
	if ms_since_last > 100:
		# make ms_since_last the number of MS overbudget
		ms_since_last -= 100
		m_iMS_Start += ms_since_last
	m_iMS_LastFrame = iMS
	
	
	iMS -= m_iMS_Start
	
	# how many ticks should have been complete by this time?
	var ticks_required = iMS / m_iMS_PerTick
	
	# left over MS not used by tick
	var ms_left = iMS % m_iMS_PerTick
	
	# calculate intpolation fraction
	m_fFraction = ms_left / float (m_iMS_PerTick)
	#print("fraction " + str(m_fFraction))

	# lo ticks
#	var tickslo_required = iMS / m_iMS_PerTickLo
	ms_left = iMS % m_iMS_PerTickLo
	m_fFraction_Lo = ms_left / float (m_iMS_PerTickLo)
	#print("fractionlo " + str(m_fFraction_Lo))

	
	# ticks required THIS update
	ticks_required -= m_iCurrentTick
	#tickslo_required -= Globals.m_iCurrentTick_Lo

	var lo_tick_check = m_iLoTickMultiple-1

	for _t in range (0, ticks_required):
		if Framework.m_eGameState != Framework.eGameState.GS_RUNNING:
			return
			
		# lo tick?
		if (m_iCurrentTick % m_iLoTickMultiple) == lo_tick_check:
			#$Movers.TickUpdate()
			Game.TickUpdate()
			
			if Framework.m_eGameState != Framework.eGameState.GS_RUNNING:
				return
				
			#$Actors.TickUpdate()
			#$SpotLight.TickUpdate()
			#$Frog.TickUpdate_Lo()
			m_iCurrentTick_Lo += 1
			#print("ticklo")
			
		# high resolution tick
		#$Frog.TickUpdate()
		# keep count of which tick we are on
		m_iCurrentTick += 1
		
	#assert (Globals.m_iCurrentTick_Lo == tickslo_required)
