extends Node3D
## Canteiro somente visual; não altera o piso, colisões ou pontos da missão.
const Library = preload("res://scripts/effects/asset_library.gd")
var revealed := false
func build(index: int, coastal: bool = false) -> void:
	var border := StandardMaterial3D.new()
	border.albedo_color = Color("b6a78a") if not coastal else Color("a89a75")
	border.roughness = 1
	var soil := MeshInstance3D.new()
	var bed := CylinderMesh.new()
	bed.top_radius = 0.78
	bed.bottom_radius = 0.78
	bed.height = 0.03
	bed.radial_segments = 12
	soil.mesh = bed
	soil.position.y = 0.025
	soil.scale.z = 1.08
	var mulch := StandardMaterial3D.new()
	mulch.albedo_color = Color("90754c")
	mulch.roughness = 1
	soil.material_override = mulch
	add_child(soil)
	for side in [-1,1]:
		var edge := MeshInstance3D.new()
		var mesh := BoxMesh.new()
		mesh.size = Vector3(0.09,0.13,1.75)
		edge.mesh = mesh
		edge.material_override = border
		edge.position = Vector3(side*0.75,0.065,0)
		add_child(edge)
	for side in [-1,1]:
		Library.place(self,"nature-kit","plant_bushSmall",Vector3(side*0.35,0.02,0),Vector3(0.65,0.55,0.70),index+side)
	for i in 6:
		Library.place(self,"nature-kit","flower_yellowC" if (index+i)%2 else "flower_purpleC",Vector3((i%2)*0.65-0.325,0.02,-0.6+(i/2)*0.6),Vector3.ONE*0.38,index+i)
	Library.batch(self)
	for mesh: GeometryInstance3D in find_children("*","GeometryInstance3D",true,false):
		mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	hide()
func reveal(animated: bool = true) -> void:
	if revealed: return
	revealed = true
	show()
	if not animated: return
	scale = Vector3(1,0.05,1)
	create_tween().tween_property(self,"scale",Vector3.ONE,1.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
