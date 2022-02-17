extends Spatial

export (PackedScene) var package_scene

onready var throw_target_node = $ThrowLeftTarget
onready var car = get_node("../Car")
onready var throw_origin_node = get_node("../Car/ThrowLeft")
onready var camera = get_node("../Camera")

var viewport_size = 0;
var max_throw_distance = 15;
var ray_length = 1000;


# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
	var throw = Input.is_action_just_released("throw")
	var throw_origin = throw_origin_node.global_transform.origin
	
	track_throw_target(throw_origin)

	if throw:
		throw_package(throw_origin)

func track_throw_target(throw_origin):
	var mouse_position = get_viewport().get_mouse_position()
	
	var from = camera.project_ray_origin(mouse_position)
	var to = from + camera.project_ray_normal(mouse_position) * ray_length
	var space_state = get_world().get_direct_space_state()
	# use global coordinates, not local to node
	var result = space_state.intersect_ray( from, to )

	throw_target_node.visible = Input.is_action_pressed("throw")

	if result.has("position"):
		var distance = result.position.distance_to(throw_origin)

		if (distance > max_throw_distance + 1):
			var throw_direction =  (result.position - throw_origin).normalized()
			
			throw_target_node.global_transform.origin = throw_origin + (throw_direction * max_throw_distance)
		else:
			throw_target_node.global_transform.origin = result.position

func throw_package(throw_origin):
	var throw_target = throw_target_node.global_transform.origin
	var driver_origin = car.global_transform.origin
	var throw_vector = Vector3.ZERO

	var package = package_scene.instance()
	var scene_root = get_tree().root.get_children()[0]

	scene_root.add_child(package)

	package.global_transform.origin = throw_origin
	var throw_direction = (throw_target - throw_origin).normalized()
	throw_direction.y = 0

	var distance = throw_target.distance_to(throw_origin);
	throw_vector = driver_origin + throw_direction

	var from_target = (throw_vector - driver_origin).normalized()

	package.apply_impulse(Vector3.ZERO, Vector3(distance * 15 * from_target.x, 50, distance * 15 * from_target.z))
