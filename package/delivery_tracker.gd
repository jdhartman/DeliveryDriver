extends Node

export var total = 20

var delivery_zones = []
var delivery_count = 0

signal delivery_made(amount, total)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func add_zones(houses):
	houses.shuffle()

	for delivery in range(total):
		var delivery_zone = houses[delivery].get_node("DeliveryZone")

		delivery_zone.visible = true
		print(delivery_zone)
		delivery_zone.connect("body_entered", self, "_delivery_made")

		delivery_zones.append(delivery_zone)

func _delivery_made(_body):
	delivery_count += 1
	print("DELIVERY MADE")
	emit_signal("delivery_made", delivery_count, total)

