tool
extends MeshInstance

export(int, "Straight", "Angled", "Corner", "Angled Corner", "4 Corner", "3 Way") var piece setget generate_piece
export(float, 0, 1) var road_width
export(bool) var update setget _update

# Called when the node enters the scene tree for the first time.

func _update(_value):
	print(self, ' ', '_update')
	generate_piece(piece)

func generate_piece(new_piece: int = 0):
	piece = new_piece

	print("Generating piece ", piece)
	var vertices = PoolVector3Array()

	match piece:
		0:
			vertices = generate_straight_piece()
		1:
			vertices = generate_angled_piece()
		2:
			vertices = generate_corner_piece()
		3:
			vertices = generate_angled_corner_piece()
		4:
			vertices = generate_four_corner_piece()
		5:
			vertices = generate_three_way_piece()


	var arr_mesh = ArrayMesh.new()
	var arrays = []
	arrays.resize(ArrayMesh.ARRAY_MAX)
	arrays[ArrayMesh.ARRAY_VERTEX] = vertices
	# Create the Mesh.
	arr_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)

	self.mesh = arr_mesh

func generate_straight_piece() -> PoolVector3Array:
	var vertices = PoolVector3Array()

	vertices.push_back(Vector3(-1, 0, road_width))
	vertices.push_back(Vector3(-1, 0, -road_width))
	vertices.push_back(Vector3(1, 0, road_width))
	
	vertices.push_back(Vector3(-1, 0, -road_width))
	vertices.push_back(Vector3(1, 0, -road_width))
	vertices.push_back(Vector3(1, 0, road_width))

	return vertices

func generate_angled_piece() -> PoolVector3Array:
	var vertices = PoolVector3Array()

	var d = road_width
	var y = sqrt(pow(d, 2)/2)

	vertices.push_back(Vector3(1 + y, 0, 1 - y))
	vertices.push_back(Vector3(1 - y, 0, 1 + y))
	vertices.push_back(Vector3(-1 + y, 0, -1 - y))

	vertices.push_back(Vector3(-1 + y, 0, -1 - y))
	vertices.push_back(Vector3(1 - y, 0, 1 + y))
	vertices.push_back(Vector3(-1 - y, 0, -1 + y))

	return vertices

func generate_corner_piece() -> PoolVector3Array:
	var vertices = PoolVector3Array()

	var p0 = Vector2(-1, road_width)
	var p1 = Vector2(road_width, road_width)
	var p2 = Vector2(road_width, -1)

	var p3 = Vector2(-1, -road_width)
	var p4 = Vector2(-road_width, -1)
	var p5 = Vector2(-road_width, -road_width)
	
	var step = .2
	var prev = p0
	var prev2 = p3
	for i in range(1, (1/step) + 1):
		var q0 = p0.linear_interpolate(p1, i * step)
		var q1 = p1.linear_interpolate(p2, i * step)
			
		var r = q0.linear_interpolate(q1, i * step)

		var q3 = p3.linear_interpolate(p5, i * step)
		var q4 = p5.linear_interpolate(p4, i * step)

		var r2 = q3.linear_interpolate(q4, i * step)
		
		#print(prev, i * step, r, r2)
		
		vertices.push_back(Vector3(prev.x, 0, prev.y))
		vertices.push_back(Vector3(prev2.x, 0, prev2.y))
		vertices.push_back(Vector3(r.x, 0, r.y))

		vertices.push_back(Vector3(r.x, 0, r.y))
		vertices.push_back(Vector3(prev2.x, 0, prev2.y))
		vertices.push_back(Vector3(r2.x, 0, r2.y))
		
		prev = r
		prev2 = r2

	return vertices

func generate_angled_corner_piece() -> PoolVector3Array:
	var vertices = PoolVector3Array()

	var d = road_width
	var y = sqrt(pow(d, 2)/2)

	var p0 = Vector2(-1 + y, 1 + y)
	var p1 = Vector2(road_width, road_width)
	var p2 = Vector2(road_width, -1)

	var p3 = Vector2(-1 - y, 1 - y)
	var p4 = Vector2(-road_width, -1)
	var p5 = Vector2(-road_width, -road_width)
	
	var step = .2
	var prev = p0
	var prev2 = p3
	for i in range(1, (1/step) + 1):
		var q0 = p0.linear_interpolate(p1, i * step)
		var q1 = p1.linear_interpolate(p2, i * step)
			
		var r = q0.linear_interpolate(q1, i * step)

		var q3 = p3.linear_interpolate(p5, i * step)
		var q4 = p5.linear_interpolate(p4, i * step)

		var r2 = q3.linear_interpolate(q4, i * step)
		
		#print(prev, i * step, r, r2)
		
		vertices.push_back(Vector3(prev.x, 0, prev.y))
		vertices.push_back(Vector3(prev2.x, 0, prev2.y))
		vertices.push_back(Vector3(r.x, 0, r.y))

		vertices.push_back(Vector3(r.x, 0, r.y))
		vertices.push_back(Vector3(prev2.x, 0, prev2.y))
		vertices.push_back(Vector3(r2.x, 0, r2.y))
		
		prev = r
		prev2 = r2

	return vertices

func generate_four_corner_piece() -> PoolVector3Array:
	var vertices = PoolVector3Array()
	var step = .2

	vertices += generate_corner(Vector2(-1, -road_width),
		Vector2(-road_width, -1),
		Vector2(-road_width, -road_width),
		Vector2(-1, 0),
		Vector2(0, -1),
		step,
		1)

	vertices += generate_corner(Vector2(1, -road_width),
		Vector2(road_width, -1),
		Vector2(road_width, -road_width),
		Vector2(1, 0),
		Vector2(0, -1),
		step)

	vertices += generate_corner(Vector2(1, road_width),
		Vector2(road_width, 1),
		Vector2(road_width, road_width),
		Vector2(1, 0),
		Vector2(0, 1),
		step,
		1)

	vertices += generate_corner(Vector2(-1, road_width),
		Vector2(-road_width, 1),
		Vector2(-road_width, road_width),
		Vector2(-1, 0),
		Vector2(0, 1),
		step)

	return vertices

func generate_three_way_piece() -> PoolVector3Array:
	var vertices = PoolVector3Array()
	var step = .2

	vertices += generate_corner(Vector2(-1, -road_width),
		Vector2(-road_width, -1),
		Vector2(-road_width, -road_width),
		Vector2(-1, 0),
		Vector2(0, -1),
		step,
		1)

	vertices += generate_corner(Vector2(1, -road_width),
		Vector2(road_width, -1),
		Vector2(road_width, -road_width),
		Vector2(1, 0),
		Vector2(0, -1),
		step)

	vertices.push_back(Vector3(1, 0, 0))
	vertices.push_back(Vector3(1, 0, road_width))
	vertices.push_back(Vector3(-1, 0, road_width))

	vertices.push_back(Vector3(1, 0, 0))
	vertices.push_back(Vector3(-1, 0, road_width))
	vertices.push_back(Vector3(-1, 0, 0))

	return vertices

func generate_corner(p3: Vector2, p4: Vector2, p5: Vector2, start: Vector2, end: Vector2, step: float, order: int = 0) -> PoolVector3Array:
	var vertices = PoolVector3Array()

	var prev2 = p3

	if order == 1:
		vertices.push_back(Vector3(start.x, 0, start.y))
		vertices.push_back(Vector3(prev2.x, 0, prev2.y))
		vertices.push_back(Vector3(0, 0, 0))
	else:
		vertices.push_back(Vector3(start.x, 0, start.y))
		vertices.push_back(Vector3(0, 0, 0))
		vertices.push_back(Vector3(prev2.x, 0, prev2.y))

	for i in range(1, (1/step) + 1):
		var q3 = p3.linear_interpolate(p5, i * step)
		var q4 = p5.linear_interpolate(p4, i * step)

		var r2 = q3.linear_interpolate(q4, i * step)

		#print(prev2, i * step, r2)
		
		if order == 1:
			vertices.push_back(Vector3(prev2.x, 0, prev2.y))
			vertices.push_back(Vector3(r2.x, 0, r2.y))
			vertices.push_back(Vector3(0, 0, 0))
		else:
			vertices.push_back(Vector3(prev2.x, 0, prev2.y))
			vertices.push_back(Vector3(0, 0, 0))
			vertices.push_back(Vector3(r2.x, 0, r2.y))

		prev2 = r2

	if order == 1:
		vertices.push_back(Vector3(end.x, 0, end.y))
		vertices.push_back(Vector3(0, 0, 0))
		vertices.push_back(Vector3(prev2.x, 0, prev2.y))
	else:
		vertices.push_back(Vector3(end.x, 0, end.y))
		vertices.push_back(Vector3(prev2.x, 0, prev2.y))
		vertices.push_back(Vector3(0, 0, 0))

	return vertices
