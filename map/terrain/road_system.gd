tool
extends Spatial

export(bool) var update setget _update
export(float, 0, 1) var road_width

onready var road_piece = preload("../../roads/road_piece.tscn")

var map_size = 4
var cell_size = 2

var road_matrix: Array
var piece_matrix: Array

func _update(_value):
	print(self, ' ', '_update')
	generate_road()
	
func generate_road():
	for n in get_children():
		if n.name == "MeshInstance":
			continue

		remove_child(n)
		n.queue_free()

	piece_matrix = []

	for i in range(road_matrix.size()):
		piece_matrix.append([])
		for j in range(road_matrix[i].size()):
			if road_matrix[i][j] == true:
				piece_matrix[i].append(get_piece(i, j))
			else:
				piece_matrix[i].append(Vector3(-1, 0, 0))

	print(piece_matrix)

	for i in range(piece_matrix.size()):
		for j in range(piece_matrix[i].size()):
			if piece_matrix[i][j].x > -1:
				var piece = road_piece.instance()
				piece.name = "RoadPiece"

				add_child(piece)
				piece.owner = get_tree().edited_scene_root

				piece.road_width = road_width
				piece.generate_piece(piece_matrix[i][j].x)

				var pos_x = j * cell_size + (cell_size - map_size) / 2
				var pos_y =  i * cell_size + (cell_size - map_size) / 2

				piece.global_transform.origin = Vector3(pos_x, 15, pos_y)
				piece.rotate_y(piece_matrix[i][j].y)
				piece.scale = Vector3(float(cell_size) / 2, float(cell_size) / 2, float(cell_size) / 2)

				
# the vector 3 will return the piece index, rotation, and if it is flipped or not
func get_piece(i : int, j : int) -> Vector3:
	var neighbors: PoolVector2Array = []

	#top row
	if i > 0 and j > 0 and road_matrix[i - 1][j - 1] == true:
		neighbors.push_back(Vector2(-1, -1))

	if i > 0 and road_matrix[i - 1][j] == true:
		neighbors.push_back(Vector2(-1, 0))

	if i > 0 and j < road_matrix.size() - 1 and road_matrix[i - 1][j + 1] == true:
		neighbors.push_back(Vector2(-1, 1))

	#middle row
	if j > 0 and road_matrix[i][j - 1] == true:
		neighbors.push_back(Vector2(0, -1))
	if j > 0 and road_matrix[i][j + 1] == true:
		neighbors.push_back(Vector2(0, 1))
	
	#bottom row
	if i < road_matrix.size() - 1 and j > 0 and road_matrix[i + 1][j - 1] == true:
		neighbors.push_back(Vector2(1, -1))
	if i < road_matrix.size() - 1 and road_matrix[i + 1][j] == true:
		neighbors.push_back(Vector2(1, 0))
	if i < road_matrix.size() - 1 and j < road_matrix.size() - 1 and road_matrix[i + 1][j + 1] == true:
		neighbors.push_back(Vector2(1, 1))


	if neighbors.size() <= 1:
		return Vector3(0, 0, 0)
	elif neighbors.size() == 2:
		var n1 = neighbors[0]
		var n2 = neighbors[1]

		if n1 == Vector2(-1, -1) and Vector2(1, 1):
			return Vector3(1, 0, 0)
		if n1 == Vector2(-1, 1) and Vector2(1, -1):
			return Vector3(1, PI / 2, 0)
		#vertical straight
		elif n1 == Vector2(-1, 0) and n2 == Vector2(1, 0):
			return Vector3(0, PI / 2, 0)
		#horizontal straight
		elif n1 == Vector2(0, -1) and n2 == Vector2(-1, 1):
			return Vector3(0, 0, 0)

	return Vector3(0, 0, 0)
