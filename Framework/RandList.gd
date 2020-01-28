extends Node

var m_List = []
var m_CurrIndex = 0

#func _ready():
#	pass

func Reset(var myseed = 0):
	m_CurrIndex = myseed % m_List.size()

func Add(var v):
	m_List.append(v)

func Add4(var v0, var v1, var v2, var v3):
	m_List.append(v0)
	m_List.append(v1)
	m_List.append(v2)
	m_List.append(v3)

func GetValue():
	var v = m_List[m_CurrIndex]
	m_CurrIndex += 1
	if (m_CurrIndex >= m_List.size()):
		m_CurrIndex = 0
	return v

