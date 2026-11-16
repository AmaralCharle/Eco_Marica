extends RefCounted
## Direção artística decorativa: nenhum corpo físico, objetivo ou controle.
const ArtMeshes = preload("res://scripts/effects/art_direction_meshes.gd")
var art: Node3D
var cleared: Array[Vector3] = []
var placements: Array[Vector3] = []
func apply(presentation: Node3D) -> void:
	art = presentation
	ground_extensions()
	for group: String in ["training_waste","training_bins","mission_drains","planting_plots","floating_waste"]:
		for point in art.get_tree().get_nodes_in_group(group):
			if art.mission.is_ancestor_of(point): cleared.append(point.position)
	match art.mission.mission_id:
		"centro": urban()
		"ubatiba": rural()
		"ponta_negra": coastal()
		_:
			for i in 7:
				cluster(Vector3(11.3,0,-16+i*5.0),i)
	foreground_signs()
	labels()
	art.set_meta("reference_art",{"clusters":placements,"clearances":cleared,"radius":2.2})

func ground_extensions() -> void:
	var id: String = art.mission.mission_id
	if id in ["ubatiba","centro"]:
		var apron: MeshInstance3D = art.box(art,Vector3(0,-0.13,-25),Vector3(130,0.06,145),Color.WHITE)
		apron.material_override = art.textured(0,Color("658b4c") if id == "ubatiba" else Color("729051"))
		apron.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	elif id == "ponta_negra":
		for side: float in [-1,1]:
			var apron: MeshInstance3D = art.box(art,Vector3(side*53,-0.13,-25),Vector3(90,0.06,145),Color.WHITE)
			apron.material_override = art.textured(0,Color("6b934c"))
			apron.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF

func safe(pos: Vector3) -> bool:
	for point in cleared:
		if Vector2(pos.x-point.x,pos.z-point.z).length() < 2.2: return false
	return true

func cluster(pos: Vector3, index: int) -> void:
	if not safe(pos): return
	placements.append(pos)
	for i in 3:
		var shrub: MeshInstance3D = art.mesh_at(art,art.Meshes.canopy(index+i),pos+Vector3(sin(i*2.4)*0.36,0.25+i*0.07,cos(i*2.4)*0.30),Color.WHITE)
		shrub.scale = Vector3(1.1,0.60+(index%3)*0.12,0.95)
		shrub.material_override = art.foliage(Color("397b44") if i%2 else Color("629e45"))
	for i in 4:
		var at := pos+Vector3(sin(i*2.4)*0.6,0.52,cos(i*2.4)*0.58)
		art.cylinder(art.extra,at-Vector3.UP*0.14,0.28,0.011,Color("46773d"))
		var flower: MeshInstance3D = art.mesh_at(art.extra,ArtMeshes.blossom(),at,Color("efc75d") if index%2 else Color("d99ab3"))
		flower.rotation = Vector3(0.2,index+i,0.18)
		flower.material_override.cull_mode = BaseMaterial3D.CULL_DISABLED

func urban() -> void:
	for side: float in [-1,1]:
		for i in 5:
			var z := -17+i*7.7
			var pos := Vector3(side*7.75,0.12,z)
			cluster(pos,i)
			art.box(art,pos+Vector3(0,0.15,0),Vector3(0.70,0.30,1.35),Color("ad8b68"))
			for off: float in [-0.66,0.66]: art.box(art,pos+Vector3(0,0.31,off),Vector3(0.76,0.06,0.08),Color("d8c5a1"))
		for i in 4:
			var z := -13+i*8.0
			# Requadros, bandeiras e painéis comerciais no recuo das fachadas.
			for dz: float in [-2.45,2.45]:
				art.box(art,Vector3(side*8.40,1.95,z+dz),Vector3(0.12,3.65,0.15),Color("e7d8ba"))
			for dz: float in [-1.55,1.55]:
				art.box(art,Vector3(side*8.35,2.7,z+dz),Vector3(0.03,0.85,0.94),Color("547d83"))
			art.box(art,Vector3(side*8.37,0.78,z),Vector3(0.06,1.45,0.8),Color("405f64"))
			if i == 1:
				for dz: float in [-1.15,1.15]:
					var at := Vector3(side*7.77,0.12,z+dz)
					art.cylinder(art,at+Vector3.UP*0.68,0.08,0.34,Color("bd8c58"))
					art.cylinder(art,at+Vector3.UP*0.33,0.65,0.045,Color("465b55"))
		# Árvores de fundo dão continuidade às quadras sem criar ruas transitáveis.
		for i in 5: art.tree(Vector3(side*(18+i%2*2),0,-22+i*10),i+41)
	# Marco cívico fictício no ponto de fuga, inteiramente além do limite físico.
	art.box(art,Vector3(0,2.5,-32),Vector3(5.8,5,5),Color("dcd2b5"))
	art.box(art,Vector3(0,6.2,-32),Vector3(2.6,4.2,2.8),Color("ece0c2"))
	var roof := PrismMesh.new()
	roof.size = Vector3(3.2,1.45,3.4)
	var top: MeshInstance3D = art.mesh_at(art,roof,Vector3(0,8.65,-32),Color.WHITE)
	top.material_override = art.textured(7,Color("b9764f"))
	for x: float in [-1.8,0,1.8]: art.box(art,Vector3(x,1.55,-29.47),Vector3(0.7,2.4,0.045),Color("4f746d"))
	var clock: MeshInstance3D = art.cylinder(art,Vector3(0,6.4,-30.57),0.06,0.66,Color("4d6d69"))
	clock.rotation.x = PI/2
	art.box(art,Vector3(0,6.5,-30.50),Vector3(0.045,0.65,0.045),Color("eee2b9"))
	art.box(art,Vector3(0.17,6.2,-30.50),Vector3(0.38,0.045,0.045),Color("eee2b9"))

func rural() -> void:
	for side: float in [-1,1]:
		for i in 14:
			var z := -24+i*3.7
			art.tree(Vector3(side*(17+(i%3)*2.2),-0.10,z),i+30)
		for i in 16:
			var at := Vector3(side*(8.9+sin(i*1.7)*0.7),0.02,-17+i*2.25)
			cluster(at,i+12)
	for i in 7:
		art.tree(Vector3(-16+i*5.2,-0.1,-26-(i%2)*3),i+61)
	# Morros assimétricos em duas profundidades; só decorativos.
	for i in 5:
		art.hill(Vector3(-38+i*18,-1,-65),Vector3(38,15+i%2*3,32),Color("638b72"),i+22)
	for i in 12: cluster(Vector3(-17+i*3.1,-0.05,-25),i+60)
	# Carrinho de campo em área sem pontos de missão.
	var cart := Vector3(10,0,10)
	art.box(art,cart+Vector3(0,0.66,0),Vector3(0.9,0.34,0.75),Color("8a9f9e"))
	art.box(art,cart+Vector3(0,0.84,0),Vector3(1.0,0.035,0.85),Color("b7c6bd"))
	var wheel: MeshInstance3D = art.cylinder(art,cart+Vector3(0,0.24,-0.66),0.13,0.24,Color("425a54"))
	wheel.rotation.z = PI/2
	for side: float in [-1,1]:
		art.box(art,cart+Vector3(side*0.37,0.46,0.44),Vector3(0.06,0.06,1.35),Color("bda172"))
		art.cylinder(art,cart+Vector3(side*0.30,0.23,0.24),0.46,0.035,Color("687c6d"))
	for i in 3:
		art.cylinder(art,cart+Vector3(-0.26+i*0.25,0.90,0),0.14,0.09,Color("4e6950"))
		var leaf: MeshInstance3D = art.mesh_at(art,art.Meshes.leaf(),cart+Vector3(-0.26+i*0.25,0.94,0),Color.WHITE)
		leaf.scale = Vector3.ONE*0.5
		leaf.material_override = art.foliage(Color("80ad4e"))

func coastal() -> void:
	for side: float in [-1,1]:
		# Massas baixas de fundo evitam que a extensão da margem pareça um plano vazio.
		art.hill(Vector3(side*40,-0.1,-5),Vector3(32,6,90),Color("6d9256"),int(side)+37)
		for i in 8: art.tree(Vector3(side*(26.5+i%2),0,-21+i*6),i+94)
		for i in 13:
			var z := -20+i*3.3
			if side > 0 and z > 7 and z < 16: continue
			cluster(Vector3(-10.3 if side < 0 else 16.4,0,z),i+28)
			if i%3 == 0: art.tree(Vector3(-15.0 if side < 0 else 21.0,-0.1,z),i+9)
	for i in 9:
		art.tree(Vector3(-15+i*4.0,-0.1,-32-(i%2)*3),i+51)
	# Continuação das margens reforça profundidade sem tocar na zona de perdas.
	for i in 8:
		art.garden(Vector3(-10.2,0,-23-i*3.5),i+80)
		art.garden(Vector3(16.6,0,-23-i*3.5),i+80)
	# Abrigo costeiro lateral, separado do píer e dos coletores.
	art.box(art,Vector3(20.5,1.35,-8),Vector3(4.2,2.7,4.8),Color("d6c9a8"))
	var roof := PrismMesh.new()
	roof.size = Vector3(4.9,1.05,5.4)
	var top: MeshInstance3D = art.mesh_at(art,roof,Vector3(20.5,3.05,-8),Color.WHITE)
	top.material_override = art.textured(7,Color("a36c4b"))
	art.box(art,Vector3(18.36,1.35,-8),Vector3(0.04,1.9,1.1),Color("3b7979"))
	for z: float in [-9.5,-6.5]: art.box(art,Vector3(18.35,1.6,z),Vector3(0.035,0.8,0.75),Color("5b9290"))

func foreground_signs() -> void:
	# Os textos de missão continuam presentes, agora apoiados em placas laterais.
	for node in art.world.get_children():
		if not node is Label3D: continue
		if "•" not in node.text: continue
		if not node.text.begins_with({"centro":"CENTRO","ubatiba":"UBATIBA","ponta_negra":"PONTA NEGRA","aracatiba":"OPERAÇÃO","itaipuacu":"RESGATE"}.get(art.mission.mission_id,"~~~")): continue
		node.position = Vector3(-9 if art.mission.mission_id == "ponta_negra" else 8.3,2.0,-17.8)
		node.font_size = 25
		node.pixel_size = 0.004
		art.box(art,node.position+Vector3(0,0,-0.04),Vector3(2.9,0.9,0.12),Color("49654c"))
		for x: float in [-1.05,1.05]: art.cylinder(art,node.position+Vector3(x,-1.0,-0.03),1.6,0.055,Color("a68a60"))

func labels() -> void:
	for group: String in ["training_bins","training_waste","floating_waste"]:
		for node in art.get_tree().get_nodes_in_group(group):
			if not art.mission.is_ancestor_of(node): continue
			for label: Label3D in node.find_children("*","Label3D",true,false):
				if group == "training_bins" and label == node.label:
					label.font_size = 38
					label.pixel_size = 0.004
					label.visibility_range_end = 18
				elif group != "training_bins":
					label.font_size = mini(label.font_size,30)
					label.pixel_size = 0.0045
