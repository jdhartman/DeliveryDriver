tool
extends Spatial

var sn = OpenSimplexNoise.new()
var st = SurfaceTool.new()
var mdt = MeshDataTool.new()
var map_seed = 0

export (SpatialMaterial) var material
export var period = 0.7
export var noise_height = 20
export var size = 2 
export var subdivide = 6

var road_set = false
var town_aabb: AABB
var town: Spatial

var cell_matrix: Array
var road_matrix: Array

func _ready():
	map_seed = randi()
	generate_mesh()
	
func generate_mesh():
	print($StaticBody/CollisionShape)
	$DebugNormals.clear()

	var plane_mesh = PlaneMesh.new()
	plane_mesh.size = Vector2(size, size)
	plane_mesh.subdivide_depth = subdivide
	plane_mesh.subdivide_width = subdivide

	sn.period = period
	sn.seed = map_seed

	var array_plane = ArrayMesh.new()
	array_plane.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, plane_mesh.get_mesh_arrays())

	var error = mdt.create_from_surface(array_plane, 0)

	for i in range(mdt.get_vertex_count()):
		var vertex = mdt.get_vertex(i)
		#var v = to_global(vertex)
		#if not town_aabb.has_point(town.to_local(v)):
			#vertex.y = sn.get_noise_3dv(vertex) * noise_height
		mdt.set_vertex(i, vertex)
	
	generate_normals()

	for s in range(array_plane.get_surface_count()):
		array_plane.surface_remove(s)

	mdt.commit_to_surface(array_plane)
	
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	st.set_material(generate_voronoi())
	st.add_smooth_group(true)
	st.append_from(array_plane, 0, Transform.IDENTITY)
	
	$StaticBody/FloorMesh.mesh = st.commit()
	
	find_cell_boundaries()

	var col_shape = ConcavePolygonShape.new()
	col_shape.set_faces($StaticBody/FloorMesh.mesh.get_faces())
	$StaticBody/CollisionShape.set_shape(col_shape)

func deform_road_to_mesh(road):
	print ("DEFORM ROAD")
	$RayCast.global_transform.origin = road.global_transform.origin
	$RayCast.cast_to = Vector3(0, -1000, 0)

	if not $RayCast or not $RayCast.is_colliding():
		print ("Road not deforming:/")
		return
	

	print("DEFORMING")
	var c = $RayCast.get_collision_point()
	print(c)
	var n = $RayCast.get_collision_normal()
	$RayCast.enabled = false

	road.global_transform.origin = c
	road.global_transform = align_with_y(global_transform, n)
	road_set = true
	
func align_with_y(xform, new_y):
	xform.basis.y = new_y.normalized()
	xform.basis.x = -xform.basis.z.cross(new_y).normalized()
	xform.basis = xform.basis.orthonormalized()
	return xform	

	
func generate_normals():
	# Calculate vertex normals, face-by-face.
	for i in range(mdt.get_face_count()):
		# Get the index in the vertex array.
		var a = mdt.get_face_vertex(i, 0)
		var b = mdt.get_face_vertex(i, 1)
		var c = mdt.get_face_vertex(i, 2)
		# Get vertex position using vertex index.
		var ap = mdt.get_vertex(a)
		var bp = mdt.get_vertex(b)
		var cp = mdt.get_vertex(c)
		# Calculate face normal.
		var n = (bp - cp).cross(ap - bp).normalized()
		# Add face normal to current vertex normal.
		# This will not result in perfect normals, but it will be close.
		mdt.set_vertex_normal(a, n + mdt.get_vertex_normal(a))
		mdt.set_vertex_normal(b, n + mdt.get_vertex_normal(b))
		mdt.set_vertex_normal(c, n + mdt.get_vertex_normal(c))

	# Run through vertices one last time to normalize normals and
	# set color to normal.
	for i in range(mdt.get_vertex_count()):
		var v = mdt.get_vertex_normal(i).normalized()
		mdt.set_vertex_normal(i, v)
		mdt.set_vertex_color(i, Color(v.x, v.y, v.z))	

func generate_voronoi() -> Material: 
	
	var img = Image.new()
	img.create(24, 24, false, Image.FORMAT_RGBH)

	var points = []
	var colors = []
	
	cell_matrix = []
	road_matrix = []

	for _i in range(15):
		points.push_back(Vector2(int(randf()*img.get_size().x), int(randf()*img.get_size().y)))
		
		randomize()
		colors.push_back(Color(randf(), randf(), randf()))
		
	for y in range(img.get_size().y):
		cell_matrix.append([])
		road_matrix.append([])
		
		for x in range(img.get_size().x):
			var dmin = img.get_size().length()
			var j = -1
			for i in range(points.size()):
				var d = abs(points[i].x - x) + abs(points[i].y - y)
					
				if d < dmin:
					dmin = d
					j = i
			img.lock()
			img.set_pixel(x, y, colors[j])
			cell_matrix[y].append(j)
			img.unlock()

	var texture = ImageTexture.new()
	texture.create_from_image(img, ImageTexture.FLAG_MIPMAPS)
	var new_material = material
	new_material.set_texture(0, texture)
	
	print(cell_matrix)

	return new_material
	
func find_cell_boundaries():
	for n in $RoadParent.get_children():
		$RoadParent.remove_child(n)
		n.queue_free()
	
	for x in range(cell_matrix.size()):
		for y in range(cell_matrix[x].size()):
			var x_diff = x < cell_matrix.size() - 1 and cell_matrix[x][y] != cell_matrix[x + 1][y] 
			var y_diff = y < cell_matrix.size() - 1 and cell_matrix[x][y] != cell_matrix[x][y + 1]
			
			var x_and_y_diff = y < cell_matrix.size() - 1 and x < cell_matrix.size() - 1 and cell_matrix[x][y] != cell_matrix[x + 1][y + 1]
			
			var bad_corner = x_diff and not y_diff and not x_and_y_diff
			
			var place_marker = (x_diff or y_diff) and not bad_corner
			
			if place_marker:
				place_cell_marker(y, x)
			
			road_matrix[x].append(place_marker)	
				
	$RoadParent.road_matrix = road_matrix
	$RoadParent._update(true)
	
func place_cell_marker(x, y):
	var cell_size = size / 24
	
	var pos = CSGBox.new()
	pos.name = "Road %d %d" % [y, x]
	
	var pos_x = x * cell_size + (cell_size - size) / 2
	var pos_y =  y * cell_size + (cell_size - size) / 2
	pos.global_transform.origin = Vector3(pos_x, 10, pos_y)
	pos.width = cell_size
	pos.depth = cell_size
	
	$RoadParent.add_child(pos)
	pos.owner = get_tree().edited_scene_root
	
func draw_normals(array_plane):
	var error = mdt.create_from_surface(array_plane, 0)
	
	for i in range(mdt.get_face_count()):
		var a = mdt.get_face_vertex(i, 0)
		var b = mdt.get_face_vertex(i, 1)
		var c = mdt.get_face_vertex(i, 2)
		
		var ap = mdt.get_vertex(a)
		var bp = mdt.get_vertex(b)
		var cp = mdt.get_vertex(c)
		
		var center = (ap + bp + cp) / 3
		
		var normal = mdt.get_face_normal(i) + center
		
		$DebugNormals.begin(Mesh.PRIMITIVE_LINE_STRIP)
		$DebugNormals.set_color(Color.purple)
		$DebugNormals.add_vertex(center)
		$DebugNormals.add_vertex(normal)
		$DebugNormals.end()
