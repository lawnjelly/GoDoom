extends Node

func StrDeg(var rad : float):
	return str(int (rad2deg(rad)))

func NormalFromTriangle(var p0, var p1, var p2):
	var a = p1 - p0
	var b = p2 - p0
	
	var c = b.cross(a)
	c = c.normalized()
	return c


# helper funcs
func AngleToOffset(var angle, var length):
	var pt = Vector2(cos(angle), sin(angle))
	pt *= length
	return pt

func AngleToOffset3(var angle, var length):
	var pt = Vector3(cos(angle), 0, sin(angle))
	pt *= length
	return pt

func OffsetToAngle(var x, var y):
	return atan2(y, x)

func InterpolateBetweenAngles(var a1, var a2, var fraction):
	# difference
	var d = GetDifferenceBetweenAngles(a1, a2)
	
	# fraction
	d *= fraction
	
	if d >= 0:
		return CappedAddToAngle(a1, d)
		
	return CappedSubtractFromAngle(a1, -d)
	
func SmoothBetweenAngles(var a1, var a2, var max_change):
	# difference
	var d = GetDifferenceBetweenAngles(a1, a2)
	
	# absolute diff
	var ad = abs(d)
	
	# cap
	if ad > max_change:
		ad = max_change
	
	if d >= 0:
		return CappedAddToAngle(a1, ad)
		
	return CappedSubtractFromAngle(a1, ad) 

func CappedSubtractFromAngle(var a, var sub):
	a -= sub
	if a < -PI:
		a += (2*PI)
	return a
	
func CappedAddToAngle(var a, var add):
	a += add
	if a > PI:
		a -= (2*PI)
	return a
	
func CappedChangeAngle(var a, var change):
	if change >= 0.0:
		return CappedAddToAngle(a, change)
	return CappedSubtractFromAngle(a, -change)
	
	
func GetDifferenceBetweenAngles(var a1, var a2):
	var d
	if a2 >= a1:
		d = a2 - a1;
		if d <= PI:
			return d;

		d = (PI*2) - d;
		return -d;

	d = a1 - a2;
	if d <= PI:
		return -d;

	d = (PI*2) - d;
	return d;

func AngleBetweenVectors(var v1, var v2):
	v1 = v1.normalized()
	v2 = v2.normalized()
	return AngleBetweenVectors_Normalized(v1, v2)


func AngleBetweenVectors_Normalized(var v1, var v2):
	var d = v1.dot(v2)
	# needs this for safety to avoid NaN with acos
	d = clamp(d, -1.0, 1.0)
	return acos(d)

func CalculateTriangleNormal(var a, var b, var c):
	# find the surface normal given 3 vertices
	var side1 = b - a
	var side2 = c - a
	var normal = side1.cross(side2)
	return normal
