extends Camera


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

onready var car = get_node("../Car")
onready var player = get_node("../Car/Driver/Bear")

var target : Node
var offset : Vector3

func _ready():
	offset = transform.origin
	player.connect("driver_control_change", self, "_on_driver_control_change")
	target = car

func _on_driver_control_change(is_driving):
	if is_driving:
		target = car
	else:
		target = player

func _physics_process(_delta):
	var pos = offset + target.transform.origin
	var up = Vector3(0, 1, 0)
	look_at_from_position(pos, target.transform.origin, up)
