extends Spatial

onready var grass = preload("res://map/terrain/floor.tscn")

onready var house1 = preload("res://map/houses/scenes/house1.tscn")
onready var house2 = preload("res://map/houses/scenes/house2.tscn")
onready var house3 = preload("res://map/houses/scenes/house3.tscn")
onready var house4 = preload("res://map/houses/scenes/house4.tscn")
onready var house5 = preload("res://map/houses/scenes/house5.tscn")
onready var house6 = preload("res://map/houses/scenes/house6.tscn")
onready var house7 = preload("res://map/houses/scenes/house7.tscn")

onready var road1 = preload("res://roads/up_down_road.tscn")
onready var intersection = preload("res://roads/intersection.tscn")

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
var unset_houses = []
var prev_unset_houses = 0

var roads = []
var unset_roads = []
var prev_unset_roads = 0

var delivery_zones = []

var mid_matrix = []
var town_center: Vector2

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()

	road_grid = $GridMaps/RoadGridMap
	house_scenes = [house1, house2, house3, house4, house5, house6, house7]
	scalar = tile_size / map_to_road_ratio
	print(scalar)

	$GridMaps.transform.origin = Vector3(tile_size / 2 * -scalar - tile_size / 2, -.95, tile_size / 2 * -scalar - tile_size / 2)
	$GridMaps.global_scale(Vector3(scalar, 1, scalar))

	town_center = Vector2((randi() % (map_size - 1)) + 1, (randi() % (map_size - 1)) + 1)
	print(town_center)
	var grid_location = road_grid.map_to_world(-1 + town_center.x * map_to_road_ratio, 0, -1 + town_center.y * map_to_road_ratio)
	var global_location = road_grid.to_global(grid_location)

	$TownMesh.global_transform.origin = global_location
	$TownMesh.global_scale(Vector3(2, 2, 2))

	$Floor.size = scalar * 72
	$Floor.town = $TownMesh
	$Floor.town_aabb = $TownMesh/TownMesh.get_aabb()
	$Floor.generate_mesh()

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

	if town_center.x == i and town_center.y == j:
		print("TOWN CENTER", i, j)
		return

	createIntersection(g)

func calculate_roads():
	for i in range(map_size):
		for j in range(map_size):
			if town_center.x == i and town_center.y == j:
				print("TOWN CENTER", i, j)
				continue
			set_tile_roads(i, j)

	unset_houses = houses
	unset_roads = roads

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
		createStreet(Vector3(-1, 0, -3), Vector2(x_scalar, z_scalar), up_locations, 0)

	if isDown(m):
		createStreet(Vector3(-1, 0, 1), Vector2(x_scalar, z_scalar), down_locations, 0)

	if isLeft(m):
		createStreet(Vector3(-3, 0, -1), Vector2(x_scalar, z_scalar), left_locations, 12)
	
	if isRight(m):
		createStreet(Vector3(1, 0, -1), Vector2(x_scalar, z_scalar), right_locations, 12)

func isUp(m):
	return  m == 0 || m == 3 || m == 4 || m == 6 || m == 7 || m == 8 || m == 9 || m == 10

func isDown(m):
	return  m < 3 || m == 5 || m == 7 || m == 8 || m == 9 || m == 11

func isLeft(m):
	return m == 2 || m == 4 || m == 7 || m == 10 || m == 11 || m == 12 || m == 14

func isRight(m):
	return m == 1 || m == 3 || m == 7 || m == 8 || m == 10 || m == 11 || m == 12 || m == 13

func createStreet(road_position: Vector3, scalars: Vector2, house_locations: Array, road_piece: int = 0):

	var x_scalar = scalars.x
	var z_scalar = scalars.y

	createRoad(road_position, x_scalar, z_scalar, road_piece)

	for location in house_locations:
		if (randf() > 1):
			continue
		createHouse(
			location.x + x_scalar,
			location.y + z_scalar,
			randi() % house_scenes.size(),
			location.z)

func createIntersection(position: Vector3):
	var grid_location = road_grid.map_to_world(position.x, position.y + 10, position.z)
	var global_location = road_grid.to_global(grid_location)

	var road_instance = road1.instance()
	road_instance.translation = global_location
	road_instance.rotate_y(PI / 2)

	add_child(road_instance)
	road_instance.set_position()
	var center = road_instance.get_node("Center")
	center.visible = true
	roads.append(road_instance)

	var road2_instance = road1.instance()
	road2_instance.translation = global_location

	add_child(road2_instance)
	road2_instance.set_position()
	roads.append(road2_instance)

func createRoad(road_position: Vector3, x_scalar: int, z_scalar: int, road_piece: int):

	var road_grid_location = road_grid.map_to_world(road_position.x + x_scalar, road_position.y + 10, road_position.z + z_scalar)
	var road_global_location = road_grid.to_global(road_grid_location)

	var road_instance = road1.instance()

	road_instance.translation = road_global_location

	if road_piece == 0:
		road_instance.rotate_y(PI / 2)

	add_child(road_instance)
	road_instance.set_position()
	roads.append(road_instance)

func createHouse(x, z, house_index, angle):
	var house_grid_location = road_grid.map_to_world(x, 3, z)
	var house_global_location = road_grid.to_global(house_grid_location)

	var house_instance = house_scenes[house_index].instance()

	house_instance.translation = house_global_location

	house_instance.rotate_y(angle)

	add_child(house_instance)
	house_instance.set_position()
	houses.append(house_instance)
