tool
extends MeshInstance

var st = SurfaceTool.new()
var mdt = MeshDataTool.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	generate_mesh()

func generate_mesh():
	#print($StaticBody/CollisionShape)
	#$DebugNormals.clear()

	var plane_mesh = CubeMesh.new()
	plane_mesh.size = Vector3(33, 0.5, 10)

	var array_plane = ArrayMesh.new()
	array_plane.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, plane_mesh.get_mesh_arrays())

	var error = mdt.create_from_surface(array_plane, 0)

	for i in range(12, 16):
		var vertex = mdt.get_vertex(i)
		vertex.y += randi() % 10
		mdt.set_vertex(i, vertex)
	
	#generate_normals()

	for s in range(array_plane.get_surface_count()):
		array_plane.surface_remove(s)

	mdt.commit_to_surface(array_plane)
	
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	#st.set_material(material)
	st.add_smooth_group(true)
	st.append_from(array_plane, 0, Transform.IDENTITY)
	
	mesh = st.commit()

	#var col_shape = ConcavePolygonShape.new()
	#col_shape.set_faces(mesh.get_faces())
	#$StaticBody/CollisionShape.set_shape(col_shape)

