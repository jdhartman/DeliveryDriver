extends MarginContainer

onready var delivery_tracker = get_node("../DeliveryTracker")
onready var delivery_counter_label = $HBoxContainer/Label2

var delivery_format = "%s / %s"

# Called when the node enters the scene tree for the first time.
func _ready():
	delivery_tracker.connect("delivery_made", self, "_on_delivery_made")

	delivery_counter_label.text = delivery_format % [delivery_tracker.delivery_count, delivery_tracker.total]


func _on_delivery_made(amount, total):
	delivery_counter_label.text = delivery_format % [amount, total]
