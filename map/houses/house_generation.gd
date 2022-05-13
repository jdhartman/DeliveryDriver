extends Spatial
export(String, DIR) var textures

var position_set = false

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
	var origin = global_transform.origin

	var space_state = get_world().direct_space_state
	var result = space_state.intersect_ray(origin, origin + Vector3.DOWN * 4096)
	
	if not result:
		visible = false
		print("NOT COLLIDING HOUSE")
		return
	
	var c = result.position
	var n = result.normal

	global_transform.origin = c
	global_transform = align_with_y(global_transform, n)
	position_set = true
	
func align_with_y(xform, new_y):
	xform.basis.y = new_y.normalized()
	xform.basis.x = -xform.basis.z.cross(new_y).normalized()
	xform.basis = xform.basis.orthonormalized()
	return xform	
