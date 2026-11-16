extends SkeletonModifier3D
## Pose sentada e remada autorais no próprio esqueleto, sem clipes de outro rig.
var appearance: Node3D
func _process_modification() -> void:
	var rig := get_skeleton()
	if rig == null or appearance == null or not appearance.seated: return
	var frame := rig.global_transform.affine_inverse()*appearance.global_transform
	var stroke: float = sin(appearance.rowing_phase)*appearance.rowing_amount*0.26
	for side: String in ["L","R"]:
		var sign_value := -1.0 if side == "L" else 1.0
		aim(rig,"UpperLeg."+side,"LowerLeg."+side,frame.basis*Vector3(0,-0.06,-0.45),false)
		aim(rig,"LowerLeg."+side,"Foot."+side,frame.basis*Vector3(0,-0.5,0.03),false)
		aim(rig,"UpperArm."+side,"LowerArm."+side,frame*Vector3(sign_value*0.45,1.12,-0.05),true)
		var hand := "Wrist."+side if rig.find_bone("Wrist."+side)>=0 else "Palm."+side
		aim(rig,"LowerArm."+side,hand,frame*Vector3(sign_value*0.70,1.05,-0.28+stroke),true)

func aim(rig: Skeleton3D, bone_name: String, child_name: String, goal: Vector3, absolute: bool) -> void:
	var bone := rig.find_bone(bone_name)
	var child := rig.find_bone(child_name)
	if bone<0 or child<0: return
	var pose := rig.get_bone_global_pose(bone)
	var from := rig.get_bone_global_pose(child).origin-pose.origin
	var to := goal-pose.origin if absolute else goal
	if from.length_squared()<0.00001 or to.length_squared()<0.00001: return
	pose.basis = Basis(Quaternion(from.normalized(),to.normalized()))*pose.basis
	rig.set_bone_global_pose(bone,pose)
