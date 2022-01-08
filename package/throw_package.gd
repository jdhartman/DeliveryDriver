extends "res://car/car.gd"

export (PackedScene) var package_scene
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

onready var throw_left_target = $ThrowLeftTarget
onready var throw_right_target = $ThrowRightTarget


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	var throw_left = Input.is_action_just_released("throw_left")
	var throw_right = Input.is_action_just_released("throw_right")

	throw_left_target.visible = Input.is_action_pressed("throw_left")
	throw_right_target.visible = Input.is_action_pressed("throw_right")

	# var is_throwing = Input.is_action_pressed("throw_left")
	# if is_throwing:
	# 	var v = 23

	# 	var driver_origin = self.global_transform.origin
	# 	var throw_origin = Vector3.ZERO
	# 	throw_origin = $ThrowLeft.global_transform.origin

	# 	var d = pow(v, 2) * sin(deg2rad(170)) / 9.8
	# 	var from_target = (throw_origin - driver_origin).normalized() * d

	# 	throwEnd.global_transform.origin = Vector3(from_target.x + throw_origin.x, throw_origin.y, from_target.z + throw_origin.z)


	if throw_left || throw_right:
		var package = package_scene.instance()
		var scene_root = get_tree().root.get_children()[0]

		scene_root.add_child(package)

		var driver_origin = self.global_transform.origin
		var throw_origin = Vector3.ZERO

		if throw_left:
			package.global_transform = $ThrowLeft.global_transform
			throw_origin = $ThrowLeft.global_transform.origin

		if throw_right:
			package.global_transform = $ThrowRight.global_transform
			throw_origin = $ThrowRight.global_transform.origin

		var from_target = (throw_origin - driver_origin).normalized()
		print(throw_origin)

		package.apply_impulse(Vector3(0,0,0), Vector3(230 * from_target.x, 50, 230 * from_target.z))
