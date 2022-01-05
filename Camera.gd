extends Camera

export var min_distance = 4.0
export var max_distance = 8.0
export var angle_v_adjust = 0.0

var collision_exception = []
export var height = 1.5

var mouseDelta : Vector2 = Vector2()

func _ready():
	# Find collision exceptions for ray.
	var node = self
	while(node):
		if (node is RigidBody):
			collision_exception.append(node.get_rid())
			break
		else:
			node = node.get_parent()

	# This detaches the camera transform from the parent spatial node.
	set_as_toplevel(true)

func _input(event):

	if event is InputEventMouseMotion:
		mouseDelta = event.relative


func _physics_process(_delta):
	var target = Vector3.ZERO

	if Input.is_action_pressed("throw_left"):
		var z = 10

		var position2D = get_viewport().get_mouse_position()
		var dropPlane  = Plane(Vector3(0, 0, 10), z)
		var position3D = dropPlane.intersects_ray(project_ray_origin(position2D), project_ray_normal(position2D))
		print(position3D)

		target = position3D
	else:
		target = get_parent().global_transform.origin

	var pos = get_global_transform().origin

	var from_target = pos - target

	# Check ranges.
	if from_target.length() < min_distance:
		from_target = from_target.normalized() * min_distance
	elif from_target.length() > max_distance:
		from_target = from_target.normalized() * max_distance

	from_target.y = height

	pos = target + from_target

	look_at_from_position(pos, target, Vector3.UP)

	# Turn a little up or down
	var t = get_transform()
	t.basis = Basis(t.basis[0], deg2rad(angle_v_adjust)) * t.basis
	set_transform(t)
