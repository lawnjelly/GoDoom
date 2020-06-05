extends Node

var m_Objects = []

const FRICTION = 0.95
const GRAVITY = 0.002
const RADIUS = 1.0
const RADIUS_DOUBLE = (RADIUS * 2.0)
const RADIUS_DOUBLE_SQUARED = (RADIUS_DOUBLE * RADIUS_DOUBLE)

class GObject:
	var m_SID : int = -1
	var m_ptPos : Vector3
	var m_ptVel : Vector3
	var m_bOnFloor : bool = false
	var m_bFlying : bool = false
	var m_Friction : float = FRICTION


class GTraceResult:
	var m_bHit : bool
	var m_ptHit : Vector3
	var m_Distance : float # dist to hit point

func _ready():
	pass # Replace with function body.


func create_obj()->int:
	var id = m_Objects.size()
	var o = GObject.new()
	o.m_SID = -1
	o.m_ptPos = Vector3(-26 + rand_range(-0.1, 0.1), 5, 0)
	m_Objects.push_back(o)
	return id
	
func get_obj(var id : int)->GObject:
	return m_Objects[id]
	
func get_obj_sid(var id : int)->int:
	return m_Objects[id].m_SID

func clear():
	m_Objects.clear()	
	
	
func push(var id : int, var ptVel):
	get_obj(id).m_ptVel += ptVel

func get_pos(var id : int)->Vector3:
	return get_obj(id).m_ptPos
	
	
	
func iterate_obj(var id : int):
	var o : GObject = get_obj(id)
	
	o.m_bOnFloor = false
	slide_move(o)
	
#	o.m_ptPos += o.m_ptVel
#
#	#if o.m_SID == -1:
#	var sid = Graph.find_sector(o.m_ptPos)
#	if sid != o.m_SID:
#		o.m_SID = sid
#		print("entering sector " + str(o.m_SID))
	
	# gravity
	if not o.m_bOnFloor:
		if not o.m_bFlying:
			o.m_ptVel.y -= GRAVITY
		else:
			o.m_ptVel.y *= o.m_Friction
		
	o.m_ptVel.x *= o.m_Friction # friction
	o.m_ptVel.z *= o.m_Friction # friction

func collision_check(var id_a : int, var id_b : int):
	var a : GObject = get_obj(id_a)
	var b : GObject = get_obj(id_b)
	
	var o : Vector3 = b.m_ptPos - a.m_ptPos
	var sl : float = o.length_squared()
	if sl >= RADIUS_DOUBLE_SQUARED:
		return
		
	var l : float = sqrt(sl)
	
	var f : float = l / RADIUS_DOUBLE
	#f *= f
	f = 1.0 - f
	#f *= f
	f *= 0.05
	
	# normalize direction
	o = o.normalized()
	o *= f
	
	a.m_ptVel -= o
	b.m_ptVel += o

func iterate_all():
	var nItems = m_Objects.size()
	
	# collision avoidance
	for n in range (nItems):
		for m in range (n+1, nItems):
			collision_check(n, m)
	
	
	for n in range (nItems):
		iterate_obj(n)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

# this is a safer routine to allow object to skim slide at an exact
# specified distance from the plane, without penetrating the plane
#func safe_slide(var ptNew: Vector3, var o : GObject, var p : Plane, var dist : float):
func safe_slide(var o : GObject, var norm : Vector3, var dist_from_plane, var desired_dist):

	# extra push to get out to desired distance
	var overlap = desired_dist - dist_from_plane
	var push = (overlap / desired_dist) * 0.001
	
	# cap
	push = clamp(push, 0.0, 0.005)

	var dot = o.m_ptVel.dot(norm)
	
	var res : bool = false
	
	if dot < 0.0:
	#if dot < push:
		
		var temp = o.m_ptVel.cross(norm)
		var dir = norm.cross(temp)
		o.m_ptVel = dir
		
		res = true

	if push > 0.0:
		# add push AFTER cross
		o.m_ptVel += (norm * push)
		

	return res

# return wall hit or -1	
func trace_walls(var sid  : int, var ptStart: Vector3, var ptDir : Vector3):
	# sector must be valid
	assert (sid != -1)
	
	# vector2 versions
	var v_start : Vector2 = Vector2(ptStart.x, ptStart.z)
	var v_dir : Vector2 = Vector2(ptDir.x, ptDir.z)
	# can't do anything if no direction
	var dir_sl = v_dir.length_squared()
	if (dir_sl < 0.01):
		return -1
		
	# only interested in the component in 2d
	v_dir = v_dir.normalized()
	var v_mid : Vector2 = v_start + v_dir
	
	# start sector
	var s : Graph.GSector = Graph.m_Sectors[sid]
	
	# go through and test each wall
	for w in range (s.m_NumWalls):
		# wall ids
		var wid0 = w + s.m_FirstWall
		var wid1 = ((w+1) % s.m_NumWalls) + s.m_FirstWall
		
		# ignore back facing walls
		var dot = ptDir.dot(Graph.m_Planes[wid0].normal)
		if dot < 0.0:
			# 2d points of the wall
			var p0 : Vector2 = Graph.m_Pts[wid0]
			var p1 : Vector2 = Graph.m_Pts[wid1]
			
			# do a ray line segment test against the wall
			var test_res = Math.Calculate_RayLineSegment_Intersection2D(v_start, v_mid, p0, p1)
			
			if test_res[0] == true:
				return w
			
	# this may never happen
	return -1
	

# start sector id
func trace(var sid  : int, var ptStart: Vector3, var ptDir : Vector3):
	# default trace result
	var hit_res : GTraceResult = GTraceResult.new()
	hit_res.m_bHit = false
	
	if sid == -1:
		sid = Graph.find_sector(ptStart)

	# start sector
	var sector : Graph.GSector = Graph.m_Sectors[sid]

	# is a wall hit?
	var hit_wall : int = trace_walls(sid, ptStart, ptDir)
	if hit_wall != -1:
		var wid : int = hit_wall + sector.m_FirstWall
		
		# find the hit point with the wall plane
		var ptHit = Graph.m_Planes[wid].intersects_ray(ptStart, ptDir)
		if ptHit:
			# does it go through a portal?
			
			var nsid : int = Graph.m_LinkedSectors[wid]
			if nsid != -1:
				# what is the height of the opening
				var nwid : int = Graph.m_LinkedWalls[wid]
				var heights : Vector2 = Graph.m_WallHeights[nwid]

				# within the opening?
				if (ptHit.y >= heights.x) and (ptHit.y <= heights.y):
					return trace(nsid, ptHit, ptDir)
			
			hit_res.m_bHit = true
			hit_res.m_ptHit = ptHit
			hit_res.m_Distance = (ptHit - ptStart).length_squared()

	#  check against ground for closer hits
	var planes = []
	planes.push_back(Graph.m_FloorPlanes[sid])
	planes.push_back(Graph.m_CeilPlanes[sid])
	
	for p in range (2):
		var plane : Plane = planes[p]
		
		var ptHit = plane.intersects_ray(ptStart, ptDir)
		if ptHit:
			var dist = (ptHit - ptStart).length_squared()
			if !hit_res.m_bHit or hit_res.m_Distance > dist:
				hit_res.m_bHit = true
				hit_res.m_ptHit = ptHit
				hit_res.m_Distance = (ptHit - ptStart).length_squared()

	return hit_res
	
	
func slide_move(var o : GObject, var count : int = 0):
	var pt : Vector3 = o.m_ptPos + o.m_ptVel
	
	# special case of no existing sector
	if o.m_SID == -1:
		o.m_SID = Graph.find_sector(pt)
		o.m_ptPos = pt
		return
	
	# how close we can get to planes (radius of object)
	var proximity = 0.7 # 0.5
	
	var sid : int = o.m_SID
	
	var s : Graph.GSector = Graph.m_Sectors[sid]

	for w in range (s.m_NumWalls):
		var wid = w + s.m_FirstWall
		
		var plane : Plane = Graph.m_Planes[wid]
		var dist = plane.distance_to(pt)
		
		if dist < proximity:
			# portal
			var bSlide = true
			
			var nsid : int = Graph.m_LinkedSectors[wid]
			if nsid != -1:
				# what is the height of the opening
				var nwid : int = Graph.m_LinkedWalls[wid]
				var heights : Vector2 = Graph.m_WallHeights[nwid]
				
				# within the opening?
				if (pt.y >= heights.x) and (pt.y <= heights.y):
					if (dist < 0.0):
						# crossing portal
						o.m_SID = nsid
						#Scene.m_node_Root.get_node("Cube").translation = Graph.m_SectorCentres[o.m_SID]
						slide_move(o, count + 1)
						return
						
					bSlide = false
					
			if bSlide:
				# slide
				if safe_slide(o, plane.normal, dist, proximity):
					if count <= 4:
						slide_move(o, count + 1)
					return

	var plane_floor : Plane = Graph.m_FloorPlanes[sid]
	var fdist = plane_floor.distance_to(pt)
	
	if fdist < (proximity + 0.1):
		o.m_bOnFloor = true
		if (fdist < proximity):
			if (safe_slide(o, plane_floor.normal, fdist, proximity)):
				if count <= 4:
					slide_move(o, count + 1)
				return

	var plane_ceil = Graph.m_CeilPlanes[sid]
	var cdist = plane_ceil.distance_to(pt)
	if (cdist < proximity) and (safe_slide(o, plane_ceil.normal, cdist, proximity)):
		if count <= 4:
			slide_move(o, count + 1)
		return
	
	o.m_ptPos = pt

# return floor and ceiling in vector2
func get_linked_wall_heights(var wid : int)->Vector2:
	return Graph.m_WallHeights[wid]
#	var res : Vector2 = Vector2()
#	var inter_floor = Graph.m_FloorPlanes[sid].intersects_ray(Vector3(pos.x, 1000.0, pos.y), Vector3(0, -1, 0))
#	res.x = inter_floor.y
#
#	var inter_ceil = Graph.m_CeilPlanes[sid].intersects_ray(Vector3(pos.x, -1000.0, pos.y), Vector3(0, 1, 0))
#	res.y = inter_ceil.y
#
#	return res
