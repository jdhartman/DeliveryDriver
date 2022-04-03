extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var left_ik = $Bear/Targets/Target_Start_Left
onready var left_target = $Target_End_Left

onready var right_ik = $Bear/Targets/Target_Start_Right
onready var right_target = $Target_End_Right

var update_rate = 40
var current_frame = 0

var foot_speed = 6
var set_left_foot = false

#onready var left_ik = $Bear/Targets/Target_Start_Left
# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	#right_ik.transform = right_target.transform

func _physics_process(delta):
	if current_frame >= update_rate:
		var new_transform = $Bear/Targets/Target_Reset_Right.global_transform
		right_target.global_transform = new_transform
		
		current_frame = 0
		set_left_foot = false
		
	if current_frame >= update_rate / 2 and not set_left_foot:
		var new_transform = $Bear/Targets/Target_Reset_Left.global_transform
		left_target.global_transform = new_transform
		
		set_left_foot = true
		
	current_frame += 1

func _process(delta):
	right_ik.global_transform = right_ik.global_transform.interpolate_with(right_target.global_transform, foot_speed * delta)
	left_ik.global_transform = left_ik.global_transform.interpolate_with(left_target.global_transform, foot_speed * delta)
