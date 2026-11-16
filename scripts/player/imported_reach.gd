extends SkeletonModifier3D
## Alcance autoral sobre o próprio rig; sem reaproveitar clipes de luta ou retargeting.
var appearance: Node3D
var blend: float = 0.0
func _process_modification() -> void:
	var rig := get_skeleton()
	if appearance == null or rig == null: return
	var reaching: bool = appearance.animation_state in ["collect","plant","interact"]
	blend = move_toward(blend,1.0 if reaching else 0.0,get_process_delta_time()*7)
	if blend <= 0: return
	var frame := rig.global_transform.affine_inverse()*appearance.global_transform
	for side: String in ["L","R"]:
		var upper := rig.find_bone("UpperArm."+side)
		var lower := rig.find_bone("LowerArm."+side)
		if upper < 0 or lower < 0: continue
		var pose := rig.get_bone_global_pose(upper)
		var direction := rig.get_bone_global_pose(lower).origin-pose.origin
		var target: Vector3 = frame*Vector3(-0.15 if side == "L" else 0.15,1.05,-0.52)
		var desired := target-pose.origin
		if direction.length_squared() < 0.0001 or desired.length_squared() < 0.0001: continue
		var rotation := Quaternion(direction.normalized(),desired.normalized())
		pose.basis = Basis(Quaternion.IDENTITY.slerp(rotation,blend*0.8))*pose.basis
		rig.set_bone_global_pose(upper,pose)
