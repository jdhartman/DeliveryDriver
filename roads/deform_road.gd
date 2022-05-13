tool
extends Spatial

enum ROAD_TYPE {ROAD, INTERSECTION}

var position_set = false
export var segment_size = 8
export var number_of_segments = 4
export(ROAD_TYPE) var road_type = ROAD_TYPE.ROAD

func _ready():
	if road_type == ROAD_TYPE.ROAD:
		add_road_points()
	elif road_type == ROAD_TYPE.INTERSECTION:
		add_intersection_points()

func add_road_points():
	$Path.transform.origin = Vector3(-(segment_size * number_of_segments) / 2, 0, 0)
	$Path.curve.clear_points()
	$Path.curve = Curve3D.new()
	
	for i in range(number_of_segments + 1):
		$Path.curve.add_point(Vector3(segment_size * i, 0, 0))

func add_intersection_points():
	$Path.transform.origin = Vector3(0, 0, 0)
	$Path.curve.clear_points()
	$Path.curve = Curve3D.new()

func set_position():
	for i in range(number_of_segments + 1):
		set_section_position(i)

	position_set = true

func set_section_position(index: int):

	var local = Vector3(segment_size * index, 0, 0)
	var p = $Path.to_global(local)
	var space_state = get_world().direct_space_state
	var result = space_state.intersect_ray(p, p + Vector3.DOWN * 4096)

	if not result:
		$Path.curve.remove_point(index)
		print("NOT COLLIDING")
		return
	
	var c = result.position

	if index == number_of_segments / 2:
		$Center.global_transform.origin = c

	var l = $Path.to_local(c)
	$Path.curve.set_point_position(index, l)
