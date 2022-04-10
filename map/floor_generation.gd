tool
extends Spatial

var sn = OpenSimplexNoise.new()
var st = SurfaceTool.new()
var mdt = MeshDataTool.new()

export (SpatialMaterial) var material
export var period = 0.7
export var noise_height = 20

func _ready():
	print($StaticBody/CollisionShape)
	
	var plane_mesh = PlaneMesh.new()
	plane_mesh.size = Vector2(2, 2)
	plane_mesh.subdivide_depth = 64
	plane_mesh.subdivide_width = 64

	sn.period = period
	sn.seed = randi()

	st.create_from(plane_mesh, 0)
	var array_plane = st.commit()

	var error = mdt.create_from_surface(array_plane, 0)

	for i in range(mdt.get_vertex_count()):
		var vertex = mdt.get_vertex(i)
		vertex.y = sn.get_noise_3dv(vertex) * noise_height
		mdt.set_vertex(i, vertex)

	for s in range(array_plane.get_surface_count()):
		array_plane.surface_remove(s)

	mdt.commit_to_surface(array_plane)
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	st.set_material(material)
	#st.add_smooth_group(true)
	st.append_from(array_plane, 0, Transform.IDENTITY)
	st.generate_normals()
	
	$StaticBody/FloorMesh.mesh = st.commit()

	var col_shape = ConcavePolygonShape.new()
	col_shape.set_faces($StaticBody/FloorMesh.mesh.get_faces())
	$StaticBody/CollisionShape.set_shape(col_shape)
