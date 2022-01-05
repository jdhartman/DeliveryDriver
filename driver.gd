extends VehicleBody

export (PackedScene) var package_scene

const STEER_SPEED = 4.5
const STEER_LIMIT = 0.8	

var steer_target = 0

export var engine_force_value = 60

func _physics_process(delta):
	var fwd_mps = transform.basis.xform_inv(linear_velocity).x

	steer_target = Input.get_action_strength("ui_left") - Input.get_action_strength("ui_right")
	steer_target *= STEER_LIMIT

	var throw_left = Input.is_action_just_released("throw_left")
	var throw_right = Input.is_action_just_released("throw_right")

	if throw_left || throw_right:
		var package = package_scene.instance()
		var scene_root = get_tree().root.get_children()[0]

		scene_root.add_child(package)

		var driver_origin = self.global_transform.origin
		var throw_origin = Vector3(0,0,0)

		if throw_left:
			package.global_transform = $ThrowLeft.global_transform
			throw_origin = $ThrowLeft.global_transform.origin

		if throw_right:
			package.global_transform = $ThrowRight.global_transform
			throw_origin = $ThrowRight.global_transform.origin

		var from_target = (throw_origin - driver_origin).normalized()
		print(from_target)

		package.apply_impulse(Vector3(0,0,0	), Vector3(230 * from_target.x, 50, 230 * from_target.z))

	if Input.is_action_pressed("ui_up"):
		# Increase engine force at low speeds to make the initial acceleration faster.
		var speed = linear_velocity.length()
		if speed < 5 and speed != 0:
			engine_force = clamp(engine_force_value * 5 / speed, 0, 100)
		else:
			engine_force = engine_force_value
	else:
		engine_force = 0

	if Input.is_action_pressed("ui_down"):
		# Increase engine force at low speeds to make the initial acceleration faster.
		if fwd_mps >= -1:
			var speed = linear_velocity.length()
			if speed < 5 and speed != 0:
				engine_force = -clamp(engine_force_value * 5 / speed, 0, 100)
			else:
				engine_force = -engine_force_value
		else:
			brake = 1
	else:
		brake = 0.0

	steering = move_toward(steering, steer_target, STEER_SPEED * delta)
