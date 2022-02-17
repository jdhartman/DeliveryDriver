extends Camera


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

onready var player = get_node("../Car")
var offset : Vector3

func _ready():
	offset = transform.origin

func _physics_process(_delta):
	var target = player.transform.origin
	var pos = offset + target
	var up = Vector3(0, 1, 0)
	look_at_from_position(pos, target, up)
