tool
extends Spatial

var sn = OpenSimplexNoise.new()
var st = SurfaceTool.new()
var mdt = MeshDataTool.new()

export (SpatialMaterial) var material
export var period = 0.7
export var noise_height = 20
export var size = 2 
export var subdivide = 64

func _ready():
	generate_mesh()
	
func generate_mesh():
	print($StaticBody/CollisionShape)
	$DebugNormals.clear()

	var plane_mesh = PlaneMesh.new()
	plane_mesh.size = Vector2(size, size)
	plane_mesh.subdivide_depth = subdivide
	plane_mesh.subdivide_width = subdivide

	sn.period = period
	sn.seed = randi()

	var array_plane = ArrayMesh.new()
	array_plane.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, plane_mesh.get_mesh_arrays())

	var error = mdt.create_from_surface(array_plane, 0)

	for i in range(mdt.get_vertex_count()):
		var vertex = mdt.get_vertex(i)
		vertex.y = sn.get_noise_3dv(vertex) * noise_height
		mdt.set_vertex(i, vertex)
	
	generate_normals()

	for s in range(array_plane.get_surface_count()):
		array_plane.surface_remove(s)

	mdt.commit_to_surface(array_plane)
	
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	st.set_material(material)
	st.add_smooth_group(true)
	st.append_from(array_plane, 0, Transform.IDENTITY)
	
	#draw_normals(array_plane)
	
	$StaticBody/FloorMesh.mesh = st.commit()

	var col_shape = ConcavePolygonShape.new()
	col_shape.set_faces($StaticBody/FloorMesh.mesh.get_faces())
	$StaticBody/CollisionShape.set_shape(col_shape)
	
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
		print(v)
		mdt.set_vertex_normal(i, v)
		mdt.set_vertex_color(i, Color(v.x, v.y, v.z))	
	
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
		print(normal)
		
		$DebugNormals.begin(Mesh.PRIMITIVE_LINE_STRIP)
		$DebugNormals.set_color(Color.purple)
		$DebugNormals.add_vertex(center)
		$DebugNormals.add_vertex(normal)
		$DebugNormals.end()
