extends Spatial

onready var grass = preload("res://map/floor.tscn")
onready var house1 = preload("res://map/houses/house1.tscn")

export var map_size = 2
export var tile_size = 6

var map_to_road_ratio = 6
var scalar = 0

var road_grid = null
var house_grid = null

var mid_matrix = []

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()

	scalar = tile_size / map_to_road_ratio

	road_grid = $GridMaps/RoadGridMap
	house_grid = $GridMaps/HouseGridMap

	$GridMaps.global_transform.origin = Vector3(scalar,-.95, scalar)
	$GridMaps.global_scale(Vector3(scalar, 1, scalar))
	house_grid.global_scale(Vector3(1, scalar, 1))

	for i in range(map_size):
		mid_matrix.append([])

		for j in range(map_size):
			add_tile(i, j)

	calculate_roads()			
	
	
func add_tile(i, j):
	var grass_instance = grass.instance()
	
	grass_instance.global_transform.origin = Vector3(i * tile_size * 2, 0, j * tile_size * 2)
	grass_instance.scale = Vector3(scalar, 1, scalar)

	add_child(grass_instance)

	var middle_road = 7#randi() % 16
	mid_matrix[i].append(middle_road)

	road_grid.set_cell_item(-1 + i * map_to_road_ratio, 0, -1 + j * map_to_road_ratio, middle_road)

	house_grid.set_cell_item(1 + i * map_to_road_ratio, 0, 1 + j * map_to_road_ratio, randi() % 3)
	house_grid.set_cell_item(i * map_to_road_ratio, 0, j * map_to_road_ratio, randi() % 3)
	house_grid.set_cell_item(-2 + i * map_to_road_ratio, 0, 1 + j * map_to_road_ratio, randi() % 3)
	house_grid.set_cell_item(2 + i * map_to_road_ratio, 0, -2 + j * map_to_road_ratio, randi() % 3)

func calculate_roads():
	for i in range(map_size):
		for j in range(map_size):
			set_tile_roads(i, j)

func set_tile_roads(i, j):
	var m = mid_matrix[i][j]

	if isUp(m):
		road_grid.set_cell_item(-1 + i * map_to_road_ratio, 0, -3 + j * map_to_road_ratio, 0)

	if isDown(m):
		road_grid.set_cell_item(-1 + i * map_to_road_ratio, 0, 1 + j * map_to_road_ratio, 0)

	if isLeft(m):
		road_grid.set_cell_item(-3 + i * map_to_road_ratio, 0, -1 + j * map_to_road_ratio, 12)
	
	if isRight(m):
		road_grid.set_cell_item(1 + i * 6, 0, -1 + j * 6, 12)

func isUp(m):
	return  m == 0 || m == 3 || m == 4 || m == 6 || m == 7 || m == 8 || m == 9 || m == 10

func isDown(m):
	return  m < 3 || m == 5 || m == 7 || m == 8 || m == 9 || m == 11

func isLeft(m):
	return m == 2 || m == 4 || m == 7 || m == 10 || m == 11 || m == 12 || m == 14

func isRight(m):
	return m == 1 || m == 3 || m == 7 || m == 8 || m == 10 || m == 11 || m == 12 || m == 13
