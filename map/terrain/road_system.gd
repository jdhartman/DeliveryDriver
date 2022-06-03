tool
extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

export(bool) var update setget _update
export(float, 0, 1) var road_width

var road_matrix: Array

func _update(value):
	print(road_matrix)
	print(self, ' ', '_update')
	generate_road()
	
	
func generate_road():
	var vertices = PoolVector3Array()
	#vertices.push_back(Vector3(-1, 0, 1))
	#vertices.push_back(Vector3(-1, 0, -1))
	#vertices.push_back(Vector3(1, 0, 1))
	
	#vertices.push_back(Vector3(-1, 0, -1))
	#vertices.push_back(Vector3(1, 0, -1))
	#vertices.push_back(Vector3(1, 0, 1))
	
	var p0 = Vector2(-1, road_width)
	var p1 = Vector2(1, 1)
	var p2 = Vector2(road_width, -1)
	
	var step = .2
	var pivot = Vector3(-road_width, 0, -road_width)
	var prev = p0
	for i in range(1, (1/step) + 1):
		var q0 = p0.linear_interpolate(p1, i * step)
		var q1 = p1.linear_interpolate(p2, i * step)
			
		var r = q0.linear_interpolate(q1, i * step)
		
		print(prev, i * step, r)
		
		vertices.push_back(Vector3(prev.x, 0, prev.y))
		vertices.push_back(pivot)
		vertices.push_back(Vector3(r.x, 0, r.y))
		
		prev = r
	
	# Initialize the ArrayMesh.
	var arr_mesh = ArrayMesh.new()
	var arrays = []
	arrays.resize(ArrayMesh.ARRAY_MAX)
	arrays[ArrayMesh.ARRAY_VERTEX] = vertices
	# Create the Mesh.
	arr_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	
	var m = MeshInstance.new()
	m.mesh = arr_mesh
	
	add_child(m)
	m.owner = get_tree().edited_scene_root
