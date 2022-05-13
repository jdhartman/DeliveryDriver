tool
extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var bone_ends = ["Bone.001", "Bone.003", "Bone.005", "Bone.007"]
var bone_roots = ["Bone", "Bone.002", "Bone.004", "Bone.006"]
var skel

# Called when the node enters the scene tree for the first time.
func _ready():
	skel = $intersection/Armature/Skeleton
	#set_position()


func set_position():
	set_center()

	for i in range(bone_roots.size()):
		set_root_bones(bone_roots[i], bone_ends[i])

func set_center():
	var origin = global_transform.origin

	var space_state = get_world().direct_space_state
	var result = space_state.intersect_ray(origin, origin + Vector3.DOWN * 4096)
	
	if not result:
		#visible = false
		print("NOT COLLIDING INTERSECTION")
		return
	
	var c = result.position

	global_transform.origin = c

func set_root_bones(bone_start: String, bone_end: String):
	var id = skel.find_bone(bone_start)
	var rest = skel.get_bone_rest(id)
	var end = calculate_ray(bone_end)

	if not end:
		print("AHHH")
		return

	print(global_transform.origin, end)
	rest.basis.y.y = (end.y + 1) / 8
	skel.set_bone_rest(id, rest)


func calculate_ray(bone_name: String):
	var id = skel.find_bone(bone_name)
	var pose = skel.get_bone_global_pose((id))

	var space_state = get_world().direct_space_state
	var result = space_state.intersect_ray(pose.origin, pose.origin + Vector3.DOWN * 4096)
	
	if not result:
		#visible = false
		print("NOT COLLIDING BONE")
		return
	
	var c = result.position
	return c
