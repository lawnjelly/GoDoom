extends Reference

class_name Vec2I

var x : int = 0
var y : int = 0

func World():
	return Helper.VecToWorld(self)

func CopyTo(o : Vec2I):
	o.x = x
	o.y = y

func Add(o : Vec2I):
	x += o.x
	y += o.y
	
func Subtract(o : Vec2I):
	x -= o.x
	y -= o.y
	
func Zero():
	x = 0
	y = 0
	
func MultiplyI(m : int):
	x *= m
	y *= m
	
func DivideI(d : int):
	x /= d
	y /= d
	
func MultiplyF(m : float):
	x = int (x * m)
	y = int (y * m)
