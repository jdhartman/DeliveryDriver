extends MarginContainer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


onready var player = get_parent().get_node("Car/Driver/Bear")
onready var grid = $Grid
onready var delivery_marker = $Grid/Delivery
onready var player_marker = $Grid/Player
onready var grid_tile = $Grid/Grid

var house_markers = {}
var houses = []

# Called when the node enters the scene tree for the first time.
func _ready():
	player_marker.position = grid.rect_size / 2
	place_markers()

func place_markers():

	for house in houses:
		var zone = house.get_node("DeliveryZone")
		if not zone.visible:
			continue

		var new_marker = delivery_marker.duplicate()
		grid.add_child(new_marker)
		new_marker.show()
		house_markers[house] = new_marker

func add_houses(house_array, tile_array):
	houses = house_array

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if !player:
		print("NO PLAYER")
		return

	player_marker.rotation = -player.global_transform.basis.get_euler().y

	for house in house_markers:
		var zone = house.get_node("DeliveryZone")
		if not zone.visible:
			house_markers[house].queue_free()
			house_markers.erase(house)
			continue

		var house_diff = house.global_transform.origin - player.global_transform.origin
		house_diff = Vector2(house_diff.x, house_diff.z)

		var obj_pos = house_diff + grid.rect_size / 2

		if grid.get_rect().has_point(obj_pos + grid.rect_position):
			house_markers[house].scale = Vector2(1, 1)
		else:
			house_markers[house].scale = Vector2(.75, .75)

		obj_pos.x = clamp(obj_pos.x, 0, grid.rect_size.x)
		obj_pos.y = clamp(obj_pos.y, 0, grid.rect_size.y)		

		house_markers[house].position = obj_pos
		
