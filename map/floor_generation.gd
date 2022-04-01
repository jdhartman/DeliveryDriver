tool
extends Spatial

var sn = OpenSimplexNoise.new()
var st = SurfaceTool.new()
var mdt = MeshDataTool.new()

func _ready():
	var plane_mesh = PlaneMesh.new()
	plane_mesh.size = Vector2(2, 2)
	plane_mesh.subdivide_depth = 64
	plane_mesh.subdivide_width = 64

	sn.period = 0.7

	st.create_from(plane_mesh, 0)
	var array_plane = st.commit()
	mdt.create_from_surface(array_plane, 0)

	var error = mdt.create_from_surface(array_plane, 0)
	for i in range(mdt.get_vertex_count()):
		var vtx = mdt.get_vertex(i)
		vtx.y = sn.get_noise_3dv(vtx) * 20
		mdt.set_vertex(i, vtx)

	for s in range(array_plane.get_surface_count()):
		array_plane.surface_remove(s)

	mdt.commit_to_surface(array_plane)
	st.create_from(array_plane, 0)
	st.generate_normals(true)
	$StaticBody/FloorMesh.mesh = st.commit()

	var col_shape = ConcavePolygonShape.new()
	col_shape.set_faces($StaticBody/FloorMesh.mesh.get_faces())
	$StaticBody/CollisionShape.set_shape(col_shape)
