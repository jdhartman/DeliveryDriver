extends KinematicBody


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var car = get_parent().get_parent()
onready var driver_seat = car.get_node("DriverSeatLocation")
onready var driver_exit = car.get_node("DriverExitLocation")
onready var driver_enter_area = car.get_node("DriverEnterArea")
onready var scene_root =  get_tree().root.get_children()[0]

export var is_driving = true
var has_exited_car = false
export var traction_fast = 0.02
export var friction = -4.0
export var drag = -7.0
export var move_speed = 5

signal driver_control_change(is_driving)
signal has_package(package)

var gravity = 0

var target_turn: Vector3
var acceleration = Vector3.ZERO
var turn_limit = 5
var velocity = Vector3.ZERO

var has_package = false
var current_package: RigidBody

# Called when the node enters the scene tree for the first time.
func _ready():
	gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

	if driver_enter_area:
		transform.origin = driver_seat.transform.origin

		driver_enter_area.connect("body_entered", self, "_on_driver_enter")
		driver_enter_area.connect("body_exited", self, "_on_driver_exit")
	
	var throw_manager = scene_root.get_node("ThrowTarget")

func _on_driver_enter(_body: Node):
	if is_driving or not has_exited_car:
		return

	$CollisionShape.disabled = true

	transform.origin = driver_seat.transform.origin

	scene_root.remove_child(self)
	car.add_child(self)
	
	is_driving = true
	has_exited_car = false
	emit_signal("driver_control_change", is_driving)

func _on_driver_exit(_body: Node):
	if not is_driving:
		has_exited_car = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	get_input()

	if not is_driving:
		get_movement(delta)
		apply_friction(delta)

		acceleration.y = -gravity
	
		velocity += acceleration * delta
		velocity = move_and_slide_with_snap(velocity, -transform.basis.y, Vector3.UP, true)

func get_input():
	if Input.is_action_just_released("eject") && is_driving:
		is_driving = false
		emit_signal("driver_control_change", is_driving)
		eject()

	if is_driving:
		return

	acceleration = Vector3.ZERO
	var player_is_moving = Input.is_action_pressed("ui_up") || Input.is_action_pressed("ui_down") || Input.is_action_pressed("ui_left") || Input.is_action_pressed("ui_right") 

	if player_is_moving:
		acceleration = -transform.basis.z * move_speed

	var x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	var z = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	
	target_turn = Vector3(x, max(abs(x) - .9, 0) + max(abs(z) - .9, 0), z).normalized()

func eject():
	car.remove_child(self)
	scene_root.add_child(self)

	transform.origin = driver_exit.global_transform.origin
	$CollisionShape.disabled = false

func apply_friction(delta):
	if velocity.length() < 1.8 and acceleration.length() == 0:
		velocity.x = 0
		velocity.z = 0
	var friction_force = velocity * friction * delta
	var drag_force = velocity * velocity.length() * drag * delta
	acceleration += drag_force + friction_force

func get_movement(delta):
	var traction = traction_fast

	velocity = lerp(velocity, target_turn * velocity.length(), traction)

	$Targets/Target_Reset_Left.transform.origin.z = velocity.length()
	$Targets/Target_Reset_Left.transform.origin.y = -3.5 + velocity.length() / 5
	$Targets/Target_Reset_Right.transform.origin.z = velocity.length()
	$Targets/Target_Reset_Right.transform.origin.y = -3.5 + velocity.length() / 5

	if target_turn.length() > 0:
		var new_transform = transform.looking_at(transform.origin + target_turn, Vector3.UP)
		transform = transform.interpolate_with(new_transform, turn_limit * delta)

func _on_package_entered(body: Node):
	if body.get_parent().get_instance_id() == self.get_instance_id():
		return
		
	if not has_package and not current_package:
		print("HAS PACKAGE")
		has_package = true

		scene_root.remove_child(body)
		self.add_child(body)

		current_package = body
		current_package.transform.origin = $PackageCarryPosition.transform.origin

		emit_signal("has_package", current_package)

func _on_package_exited(body: Node):
	print("TEST",body.get_parent())
	
	if has_package and current_package:
		print("PACKAGE THROWN")
		has_package = false
		current_package = null
	
