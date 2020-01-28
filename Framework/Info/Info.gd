extends Control

#var m_eInfoState = Framework.INFO_NONE
var m_iTicksLeft = 0

# the callback is a function reference that is called when the tick counter gets to zero
var m_Callback
var m_bNonPausedInfo : bool = false


func _physics_process(_delta):
	
	if m_bNonPausedInfo == false:
		if Framework.m_eGameState != Framework.eGameState.GS_INFO:
		#if m_eInfoState == Framework.INFO_NONE:
			return
	
	m_iTicksLeft -= 1
	
	if m_iTicksLeft > 0:
		return

	# has reached end of timeout	
	ClearMessage()
	m_bNonPausedInfo = false
	
	# callback
	if m_Callback != null:
		m_Callback.call_func()
	
	
#	var oldstate = m_eInfoState
#	ShowInfo(Framework.INFO_NONE)	
#
#	match oldstate:
#		Framework.INFO_GAME_OVER:
#			Framework.Delayed_GameOver()
#		Framework.INFO_LEVEL_COMPLETE:
#			Framework.Delayed_LevelComplete()
#		Framework.INFO_WON_GAME:
#			Framework.Delayed_LevelComplete()
#		Framework.INFO_DIED:
#			Framework.Delayed_Died()
#		Framework.INFO_REACHED_HOME:
#			Framework.Delayed_ReachedHome()
	pass

func ClearMessage():
	Framework._SetGameState(Framework.eGameState.GS_RUNNING)
	m_iTicksLeft = 0
	visible = false

func ShowMessage(var txt, var timeSeconds, var node = null, var szFunc = null, var bPause = true):
	_ShowMessage(txt)
	m_iTicksLeft = int (timeSeconds * Framework.m_iTicksPerSecond)
	# callback
	if node != null:
		m_Callback = funcref(node, szFunc)
	else:
		m_Callback = null
		
	if bPause:
		Framework._SetGameState(Framework.eGameState.GS_INFO)
		m_bNonPausedInfo = false
	else:
		m_bNonPausedInfo = true
	

func _ShowMessage(var txt):
	visible = true
	var lab = $Info_Node.get_child(0)
	lab.text = txt

#func ShowInfo(var i):
#	# set new state
#	m_eInfoState = i
#
#	print("ShowInfo " + str(i))
#
#	match i:
#		Framework.INFO_LEVEL_COMPLETE:
#			m_iTicksLeft = 20
#			ShowMessage("Level " + str(Framework.m_iLevel) + " Complete")
#		Framework.INFO_GAME_OVER:
#			m_iTicksLeft = 50
#			ShowMessage("It's Game Over man!")
#		Framework.INFO_INSTRUCTIONS:
#			m_iTicksLeft = 20
#			Instructions()
#		Framework.INFO_DIED:
#			m_iTicksLeft = 12
#			visible = false
#		Framework.INFO_REACHED_HOME:
#			m_iTicksLeft = 20
#			visible = false
#		Framework.INFO_WON_GAME:
#			m_iTicksLeft = 200
#			ShowMessage("Congratulations you have won!")
#		Framework.INFO_NONE:
#			m_iTicksLeft = 0
#			visible = false
#
#
#	if i != Framework.INFO_NONE:
#		Framework.m_eGameState = Framework.GS_INFO
#	else:
#		Framework.m_eGameState = Framework.GS_RUNNING
#	pass
