extends KinematicBody


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	#wheel_base = ($Wheel_FL.transform.basis.z - $Wheel_BL.transform.basis.z).abs()  / 2
	pass # Replace with function body.

export var gravity = -20.0

export var steering_limit = 5.0  # front wheel max turning angle (deg)

export var engine_power = 6.0
export var braking = -9.0
export var friction = -2.0
export var drag = -2.0
export var max_speed_reverse = 3.0
export var slip_speed = 9.0
export var traction_slow = 0.75
export var traction_fast = 0.02

var drifting = false

var acceleration = Vector3.ZERO
var velocity = Vector3.ZERO
var steer_angle = 0.0
var target_turn = 0.0
var current_turn = 0.0

var wheel_base = 0.6

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if is_on_floor():
		get_input()
		apply_friction(delta)
		calculate_steering(delta)
	acceleration.y = gravity
	velocity += acceleration * delta
	velocity = move_and_slide_with_snap(velocity, -transform.basis.y, Vector3.UP, true)


func apply_friction(delta):
	if velocity.length() < .8 and acceleration.length() == 0:
		velocity.x = 0
		velocity.z = 0
	var friction_force = velocity * friction * delta
	var drag_force = velocity * velocity.length() * drag * delta
	acceleration += drag_force + friction_force
	
func get_input():
	acceleration = Vector3.ZERO
	var car_is_moving = Input.is_action_pressed("ui_up") || Input.is_action_pressed("ui_down") || Input.is_action_pressed("ui_left") || Input.is_action_pressed("ui_right") 

	if car_is_moving:
		acceleration = -transform.basis.z * engine_power

	var turn = 0
	var x = 0
	var z = 0

	x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	z = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")

	if Input.is_action_pressed("ui_left") && abs(transform.basis.z.x - 1) > .001 :
		turn = 1 if transform.basis.z.z > 0 else -1
	if Input.is_action_pressed("ui_right") && abs(transform.basis.z.x + 1) > .001:
		turn = -1 if transform.basis.z.z > 0 else 1

	if Input.is_action_pressed("ui_up") && abs(transform.basis.z.z - 1) > .001 :
		turn = -1 if transform.basis.z.x > 0 else 1
	if Input.is_action_pressed("ui_down") && abs(transform.basis.z.z + 1) > .001 :
		turn = 1 if transform.basis.z.x > 0 else -1
	
	target_turn = Vector3(x, 0, z)
	
	var turn_limit = steering_limit / max(1, velocity.length() * .12)
	if acceleration.length() < 0.2:
		turn_limit = steering_limit / max(1, velocity.length() * .2)
		
	steer_angle = turn * deg2rad(turn_limit)

	$Wheel_FL.rotation.y = steer_angle*2
	$Wheel_FR.rotation.y = steer_angle*2

func calculate_steering(delta):
	if not drifting and velocity.length() > slip_speed:
		drifting = true
	if drifting and velocity.length() < slip_speed:
		drifting = false
	var traction = traction_fast

	velocity = lerp(velocity, target_turn * velocity.length(), traction)

	if target_turn.length() > 0:
		var new_transform = transform.looking_at(transform.origin + target_turn, Vector3.UP)
		transform = transform.interpolate_with(new_transform, steering_limit * delta)
		
