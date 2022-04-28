extends Spatial

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var positions_set = [false, false, false]
var position_set = false

func set_position():
	if position_set:
		print("ALREADY SET")
		return

	var skel = $straight_road/Armature/Skeleton
	var road1_tip = skel.find_bone("Bone.001")

	var t = skel.get_bone_global_pose(road1_tip)
	var tip_origin = skel.to_global(t.origin)

	var rayCast = $RayCast

	rayCast.cast_to = Vector3(0, -1000, 0)

	if not rayCast or not rayCast.is_colliding():
		print(road, rayCast.is_colliding())
		return
	
	var c = rayCast.get_collision_point()
	var n = rayCast.get_collision_normal()
	rayCast.enabled = false

	road.global_transform.origin = c
	road.global_transform = align_with_y(road.global_transform, n)
	
	#set_section_position($Road, 0)
	set_section_position($Road2, 1)
	#set_section_position($Road3, 2)

	position_set = true
	
func align_with_y(xform, new_y):
	xform.basis.y = new_y.normalized()
	xform.basis.x = -xform.basis.z.cross(new_y).normalized()
	xform.basis = xform.basis.orthonormalized()
	return xform	

func set_section_position(road, index: int):
	if positions_set[index]:
		print("ALREADY SET")
		return

	var rayCast = road.get_node("RayCast")

	rayCast.cast_to = Vector3(0, -1000, 0)

	if not rayCast or not rayCast.is_colliding():
		print(road, rayCast.is_colliding())
		return
	
	var c = rayCast.get_collision_point()
	var n = rayCast.get_collision_normal()
	rayCast.enabled = false

	road.global_transform.origin = c
	road.global_transform = align_with_y(road.global_transform, n)

	position_set = true
