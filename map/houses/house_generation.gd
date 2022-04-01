extends Spatial
export(String, DIR) var textures

# Called when the node enters the scene tree for the first time.
func _ready():
	var files = []
	var dir = Directory.new()
	dir.open(textures)
	dir.list_dir_begin()

	while true:
		var file = dir.get_next()
		if file == "":
			break
		elif not file.begins_with(".") && file.ends_with(".tres"):
			files.append(load(textures + "/" + file))

	$MeshInstance.set_surface_material(0, files[randi() % files.size()])
	
func set_position():
	if not $RayCast or not $RayCast.is_colliding():
		return
	
	var n = $RayCast.get_collision_point()
	print(global_transform.origin)
	print(n)
	global_transform.origin = n
	
	
func align_with_y(xform, new_y):
	xform.basis.y = new_y.normalized()
	xform.basis.x = -xform.basis.z.cross(new_y).normalized()
	xform.basis = xform.basis.orthonormalized()
	return xform	
