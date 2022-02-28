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
