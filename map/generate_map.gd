extends Spatial

onready var grass = preload("res://map/floor.tscn")

onready var house1 = preload("res://map/houses/house1.tscn")
onready var house2 = preload("res://map/houses/house2.tscn")
onready var house3 = preload("res://map/houses/house3.tscn")
onready var house4 = preload("res://map/houses/house4.tscn")
onready var house5 = preload("res://map/houses/house5.tscn")
onready var house6 = preload("res://map/houses/house6.tscn")
onready var house7 = preload("res://map/houses/house7.tscn")

onready var delivery_tracker = get_node("../DeliveryTracker")
onready var mini_map = get_node("../MiniMap")

export var map_size = 2
export var tile_size = 6

var map_to_road_ratio = 6
var scalar = 0

var road_grid = null

var house_scenes = []
var tiles = []
var houses = []
var delivery_zones = []

var mid_matrix = []

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()

	scalar = tile_size / map_to_road_ratio

	#$Floor.transform.origin = Vector3(tile_size / 2 * scalar + tile_size, -.95, tile_size / 2 * scalar + tile_size)
	#$Floor.global_scale(Vector3(tile_size, 1, tile_size))

	$Floor.global_scale(Vector3(6, 1, 6))

	road_grid = $GridMaps/RoadGridMap
	house_scenes = [house1, house2, house3, house4, house5, house6, house7]

	$GridMaps.transform.origin = Vector3(scalar,-.95, scalar)
	$GridMaps.global_scale(Vector3(scalar, 1, scalar))

	for i in range(map_size):
		mid_matrix.append([])

		for j in range(map_size):
			add_tile(i, j)

	calculate_roads()

	if delivery_tracker:
		delivery_tracker.add_zones(houses)

	if mini_map:
		mini_map.add_houses(houses, tiles)
	
	
func add_tile(i, j):

	var middle_road = 7#randi() % 16
	mid_matrix[i].append(middle_road)

	var g = Vector3(-1 + i * map_to_road_ratio, 0, -1 + j * map_to_road_ratio)

	road_grid.set_cell_item(g.x, g.y, g.z, middle_road)

func calculate_roads():
	for i in range(map_size):
		for j in range(map_size):
			set_tile_roads(i, j)

func set_tile_roads(i, j):
	var m = mid_matrix[i][j]

	var house_probability = 1

	var x_scalar = i * map_to_road_ratio
	var z_scalar = j * map_to_road_ratio

	var up_locations = [
		Vector3(-2, -3, PI / 2),
		Vector3(0, -3, 3 * PI / 2),
	]

	var down_locations = [
		Vector3(-2, 2, PI / 2),
		Vector3(-2, 1, PI / 2),
		Vector3(0, 2, 3 * PI / 2),
		Vector3(0, 1, 3 * PI / 2)
	]

	var left_locations = [
		Vector3(-3, -2, 0),
		Vector3(-4, -2, 0),
		Vector3(-3, 0, PI),
		Vector3(-4, 0, PI),
	]

	var right_locations = [
		Vector3(1, -2, 0),
		Vector3(1, 0, PI),
	]

	if isUp(m):
		road_grid.set_cell_item(-1 + x_scalar, 0, -3 + z_scalar, 0)
		for location in up_locations:
			if (randf() > house_probability):
				continue
			createHouse(
				location.x + x_scalar,
				location.y + z_scalar,
				randi() % house_scenes.size(),
				location.z)

	if isDown(m):
		road_grid.set_cell_item(-1 + x_scalar, 0, 1 + z_scalar, 0)
		for location in down_locations:
			if (randf() > house_probability):
				continue
			createHouse(
				location.x + x_scalar,
				location.y + z_scalar,
				randi() % house_scenes.size(),
				location.z)

	if isLeft(m):
		road_grid.set_cell_item(-3 + x_scalar, 0, -1 + z_scalar, 12)
		for location in left_locations:
			if (randf() > house_probability):
				continue
			createHouse(
				location.x + x_scalar,
				location.y + z_scalar,
				randi() % house_scenes.size(),
				location.z)
	
	if isRight(m):
		road_grid.set_cell_item(1 + x_scalar, 0, -1 + z_scalar, 12)
		for location in right_locations:
			if (randf() > house_probability):
				continue
			createHouse(
				location.x + x_scalar,
				location.y + z_scalar,
				randi() % house_scenes.size(),
				location.z)

func isUp(m):
	return  m == 0 || m == 3 || m == 4 || m == 6 || m == 7 || m == 8 || m == 9 || m == 10

func isDown(m):
	return  m < 3 || m == 5 || m == 7 || m == 8 || m == 9 || m == 11

func isLeft(m):
	return m == 2 || m == 4 || m == 7 || m == 10 || m == 11 || m == 12 || m == 14

func isRight(m):
	return m == 1 || m == 3 || m == 7 || m == 8 || m == 10 || m == 11 || m == 12 || m == 13

func createHouse(x, z, house_index, angle):
	var house_grid_location = road_grid.map_to_world(x, 0, z)
	var house_global_location = road_grid.to_global(house_grid_location)

	var house_instance = house_scenes[house_index].instance()

	house_instance.translation = house_global_location

	house_instance.rotate_y(angle)

	add_child(house_instance)
	houses.append(house_instance)
		
