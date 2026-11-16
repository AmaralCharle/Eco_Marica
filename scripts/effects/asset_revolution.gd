extends RefCounted
const Library = preload("res://scripts/effects/asset_library.gd")

static func urban(art: Node3D) -> void:
	# AABB dos edifícios coincide com o volume lateral antigo; nada invade a calçada.
	for node: Node in art.world.get_children():
		if node.get_meta("kind", "") in ["Building", "Roof", "Window", "Door"]:
			for mesh: MeshInstance3D in node.find_children("*", "MeshInstance3D", true, false): mesh.hide()
	for side: float in [-1, 1]:
		for i in 4:
			var pos := Vector3(side * 11.5, 0.12, -13 + i * 8)
			Library.place(art.imported, "city-kit-commercial", "building-" + ["a","b","c","d"][i], pos, Vector3(5.5, [5.8,6.3,5.2,6.5][i],6), side * PI/2, true)
			Library.place(art.imported, "city-kit-commercial", "detail-awning", Vector3(side*8.34,2.25,pos.z), Vector3(2.8,0.6,0.75), side*PI/2)
		for z: float in [-17,-1,15]:
			Library.place(art.imported,"city-kit-roads","electricity-pole",Vector3(side*7.65,0.12,z),Vector3(1.1,5.8,1.1))
		for i in 32:
			var z := -16.5+i
			var sag := sin(fposmod(z+17,16)/16*PI)*0.28
			var wire: MeshInstance3D = art.box(art,Vector3(side*7.65,5.15-sag,z),Vector3(0.018,0.018,1.02),Color("465957"))
			wire.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		for z: float in [-18,18]:
			Library.place(art.imported,"city-kit-roads","construction-cone",Vector3(side*7.45,0.12,z),Vector3(0.35,0.55,0.35))
