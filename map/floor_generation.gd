tool
extends Spatial

var sn = OpenSimplexNoise.new()
var st = SurfaceTool.new()
var mdt = MeshDataTool.new()

export (SpatialMaterial) var material
export var period = 0.7
export var noise_height = 20
export var subdivide = 64

func _ready():
	print($StaticBody/CollisionShape)
	
	var plane_mesh = PlaneMesh.new()
	plane_mesh.size = Vector2(2, 2)
	plane_mesh.subdivide_depth = subdivide
	plane_mesh.subdivide_width = subdivide

	sn.period = period
	sn.seed = randi()

	var array_plane = ArrayMesh.new()
	array_plane.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, plane_mesh.get_mesh_arrays())

	var error = mdt.create_from_surface(array_plane, 0)

	$DebugNormals.clear()

	for i in range(mdt.get_vertex_count()):
		var vertex = mdt.get_vertex(i)
		vertex.y = sn.get_noise_3dv(vertex) * noise_height
		mdt.set_vertex(i, vertex)
		
		#$DebugNormals.begin(Mesh.PRIMITIVE_LINE_STRIP)
		
		#$DebugNormals.set_color(Color.blue)
		#$DebugNormals.add_vertex(vertex)
		#vertex.y += 10
		#$DebugNormals.add_vertex(vertex)
		
		#$DebugNormals.end()
		

	for s in range(array_plane.get_surface_count()):
		array_plane.surface_remove(s)

	mdt.commit_to_surface(array_plane)
	
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	st.set_material(material)
	st.add_smooth_group(true)
	st.generate_normals(true)
	st.append_from(array_plane, 0, Transform.IDENTITY)
	
	$StaticBody/FloorMesh.mesh = st.commit()

	var col_shape = ConcavePolygonShape.new()
	col_shape.set_faces($StaticBody/FloorMesh.mesh.get_faces())
	$StaticBody/CollisionShape.set_shape(col_shape)
