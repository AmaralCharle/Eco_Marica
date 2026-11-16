class_name CharacterAppearance
extends Node3D
## Somente apresentação. O controlador conserva corpo, câmera e pontos de articulação.
const Catalog = preload("res://scripts/core/character_catalog.gd")
const Geo = preload("res://scripts/player/character_geometry.gd")
const Shapes = preload("res://scripts/effects/environment_meshes.gd")
const ModelAdapter = preload("res://scripts/player/character_model_adapter.gd")
@export var character_id: String = "lucas"
## IDs -> PackedScene de GLB; transformações opcionais de importação, em metros.
@export var external_models: Dictionary = {}
@export var external_transforms: Dictionary = {}
## Estados do jogo -> nomes dos clipes do rig importado.
@export var external_animations: Dictionary = {}
@export var animate_face: bool = true
var external_error: String = ""
var parts: Dictionary = {}
var decorations: Node3D
var outfit: StandardMaterial3D
var skin: StandardMaterial3D
var hair: StandardMaterial3D
var pants: StandardMaterial3D
var animation_state: String = "idle"
var materials: Dictionary = {}
var eyes: Array[Node3D] = []
var blink_clock: float = 0.0
var rebuilding: bool = false

func _ready() -> void:
	for title: String in ["Torso","Head","Backpack","Details","LeftLeg","RightLeg","LeftArm","RightArm"]:
		var pivot := Node3D.new()
		pivot.name = title
		add_child(pivot)
		parts[title] = pivot
	parts.LeftLeg.position = Vector3(-0.145,0.76,0)
	parts.RightLeg.position = Vector3(0.145,0.76,0)
	parts.LeftArm.position = Vector3(-0.31,1.32,0)
	parts.RightArm.position = Vector3(0.31,1.32,0)
	decorations = parts.Details
	apply_character(character_id)

func apply_character(id: String) -> void:
	character_id = id if Catalog.valid_id(id) else Catalog.DEFAULT_ID
	if parts.is_empty(): return
	rebuilding = true
	eyes.clear()
	for pivot: Node3D in parts.values():
		for node in pivot.get_children():
			pivot.remove_child(node)
			node.queue_free()
	materials.clear()
	var data := Catalog.get_character(character_id)
	outfit = material(data.outfit,0.90)
	skin = material(data.skin,0.72)
	hair = material(data.hair,0.66)
	pants = material(data.pants,0.93)
	build_body()
	build_face()
	match character_id:
		"lucas": build_lucas()
		"marina": build_marina()
		"rafael": build_rafael()
		"bia": build_bia()
	for pivot: Node3D in parts.values(): Geo.batch(pivot)
	blink_clock = Catalog.IDS.find(character_id)*0.74
	rebuilding = false
	var imported = external_models.get(character_id)
	if imported is PackedScene:
		attach_external_model(imported,external_transforms.get(character_id,Transform3D.IDENTITY))
	elif get_node_or_null("ExternalModel"):
		attach_external_model()

func build_body() -> void:
	var body: Node3D = parts.Torso
	var cream := material(Color("e6d9b8"))
	var trim := material(outfit.albedo_color.darkened(0.24))
	var belt := material(Color("5b5543"))
	var shoe := material(Color("4e4b3d") if character_id == "rafael" else Color("344747"),0.78)
	var sole := material(Color("d2c7a5"))
	var metal := material(Color("a7b7ae"),0.36,0.5)
	mesh(body,"Jacket",Vector3.ZERO,Geo.loft([Vector4(0.77,0.25,0.15,0),Vector4(0.84,0.26,0.17,0),Vector4(1.12,0.295,0.18,0),Vector4(1.30,0.30,0.17,0),Vector4(1.37,0.245,0.145,0),Vector4(1.42,0.12,0.10,0)]),outfit)
	mesh(body,"Hips",Vector3.ZERO,Geo.loft([Vector4(0.67,0.245,0.145,0),Vector4(0.79,0.26,0.155,0),Vector4(0.84,0.245,0.15,0)]),pants)
	rounded(body,"Neck",Vector3(0,1.425,0),Vector3(0.21,0.21,0.19),skin)
	box(body,"Shirt",Vector3(0,1.16,-0.172),Vector3(0.16,0.45,0.032),cream)
	box(body,"Waistband",Vector3(0,0.825,-0.005),Vector3(0.49,0.065,0.305),belt)
	box(body,"Buckle",Vector3(0,0.825,-0.166),Vector3(0.08,0.052,0.02),metal)
	for side: float in [-1,1]:
		var panel := box(body,"VestPanel",Vector3(side*0.17,1.09,-0.16),Vector3(0.195,0.44,0.065),outfit)
		panel.rotation.y = -side*0.18
		var collar := box(body,"Collar",Vector3(side*0.095,1.355,-0.124),Vector3(0.105,0.13,0.045),trim)
		collar.rotation.z = side*0.35
		box(body,"Pocket",Vector3(side*0.175,1.02,-0.204),Vector3(0.15,0.13,0.046),trim)
		box(body,"PocketFlap",Vector3(side*0.175,1.075,-0.233),Vector3(0.16,0.045,0.026),outfit)
		box(body,"PocketSnap",Vector3(side*0.175,1.065,-0.25),Vector3(0.022,0.018,0.01),metal)
		var leg: Node3D = parts.LeftLeg if side < 0 else parts.RightLeg
		mesh(leg,"Trouser",Vector3.ZERO,Geo.loft([Vector4(-0.59,0.088,0.10,0.012),Vector4(-0.41,0.10,0.115,0.012),Vector4(-0.24,0.11,0.12,-0.006),Vector4(-0.05,0.126,0.137,0),Vector4(0.04,0.125,0.135,0)]),pants)
		box(leg,"KneeSeam",Vector3(0,-0.30,-0.111),Vector3(0.15,0.024,0.018),material(pants.albedo_color.lightened(0.13)))
		mesh(leg,"Shoe",Vector3.ZERO,Geo.loft([Vector4(-0.68,0.125,0.19,-0.055),Vector4(-0.61,0.128,0.19,-0.055),Vector4(-0.55,0.10,0.14,-0.025),Vector4(-0.52,0.087,0.09,0.01)]),shoe)
		mesh(leg,"Sole",Vector3.ZERO,Geo.loft([Vector4(-0.75,0.118,0.183,-0.055),Vector4(-0.725,0.132,0.197,-0.055),Vector4(-0.675,0.13,0.195,-0.055)]),sole)
		for i in 3: box(leg,"Lace",Vector3(0,-0.56-i*0.016,-0.108-i*0.028),Vector3(0.115,0.012,0.014),cream)
		var arm: Node3D = parts.LeftArm if side < 0 else parts.RightArm
		var sleeve: StandardMaterial3D = outfit if character_id == "bia" else cream
		mesh(arm,"Sleeve",Vector3(side*0.02,0,0),Geo.loft([Vector4(-0.245,0.092,0.105,0),Vector4(-0.18,0.109,0.125,0),Vector4(-0.035,0.12,0.135,0),Vector4(0.045,0.07,0.09,0)]),sleeve)
		mesh(arm,"Arm",Vector3(side*0.034,0,0),Geo.loft([Vector4(-0.465,0.065,0.071,-0.01),Vector4(-0.36,0.075,0.079,0),Vector4(-0.215,0.083,0.087,0)]),skin)
		rounded(arm,"Hand",Vector3(side*0.04,-0.49,-0.016),Vector3(0.145,0.19,0.15),skin)
		rounded(arm,"Thumb",Vector3(-side*0.025,-0.475,-0.062),Vector3(0.065,0.105,0.07),skin)
		box(arm,"Cuff",Vector3(side*0.025,-0.235,0),Vector3(0.19,0.04,0.214),material(sleeve.albedo_color.darkened(0.16)))
		if side < 0:
			box(arm,"WatchBand",Vector3(side*0.034,-0.415,0),Vector3(0.145,0.052,0.15),belt)
			box(arm,"WatchFace",Vector3(side*0.034,-0.415,-0.084),Vector3(0.066,0.06,0.025),metal)
	box(body,"Zip",Vector3(0,1.1,-0.205),Vector3(0.018,0.41,0.015),cream)
	box(body,"ZipPull",Vector3(0.007,1.18,-0.22),Vector3(0.027,0.045,0.012),metal)
	badge(body,Vector3(-0.17,1.245,-0.183),0.55)

func build_face() -> void:
	var head: Node3D = parts.Head
	var face_skin: StandardMaterial3D = skin.duplicate()
	face_skin.vertex_color_use_as_albedo = true
	mesh(head,"Face",Vector3.ZERO,Geo.tint_cheeks(Geo.loft([Vector4(1.43,0.075,0.08,-0.012),Vector4(1.465,0.165,0.145,-0.015),Vector4(1.53,0.24,0.205,0),Vector4(1.64,0.278,0.237,0),Vector4(1.76,0.273,0.23,0),Vector4(1.87,0.23,0.20,0.008),Vector4(1.94,0.14,0.13,0.01),Vector4(1.97,0.01,0.01,0.01)],24)),face_skin)
	var warm := material(skin.albedo_color.lerp(Color("c67e66"),0.22),0.8)
	var dark_skin := material(skin.albedo_color.darkened(0.18),0.8)
	var white := material(Color("fff4de"),0.42)
	var iris := material({"lucas":Color("587c62"),"marina":Color("4e8589"),"rafael":Color("8a6b42"),"bia":Color("82613c")}[character_id],0.42)
	var pupil := material(Color("233b38"),0.32)
	for side: float in [-1,1]:
		rounded(head,"Ear",Vector3(side*0.272,1.645,0),Vector3(0.105,0.15,0.085),skin)
		rounded(head,"EarInset",Vector3(side*0.286,1.645,-0.04),Vector3(0.05,0.083,0.026),warm)
		var eye := Node3D.new()
		eye.name = "LeftEye" if side < 0 else "RightEye"
		eye.position = Vector3(side*0.105,1.699,-0.218)
		eye.set_meta("dynamic_visual",true)
		head.add_child(eye)
		eyes.append(eye)
		rounded(eye,"Lid",Vector3.ZERO,Vector3(0.155,0.17,0.048),dark_skin)
		rounded(eye,"White",Vector3(0,0,-0.014),Vector3(0.136,0.147,0.041),white)
		rounded(eye,"Iris",Vector3(-side*0.006,-0.002,-0.036),Vector3(0.077,0.103,0.016),iris)
		rounded(eye,"Pupil",Vector3(-side*0.006,-0.002,-0.045),Vector3(0.035,0.068,0.009),pupil)
		rounded(eye,"Glint",Vector3(-0.015,0.026,-0.051),Vector3(0.021,0.025,0.008),material(Color("ffffff"),0.22))
		Geo.batch(eye)
		var brow_points: Array[Vector3] = [Vector3(side*0.042,1.799,-0.213),Vector3(side*0.10,1.819,-0.215),Vector3(side*0.171,1.803,-0.177)]
		mesh(head,"Brow",Vector3.ZERO,Geo.tube(brow_points,0.013),hair)
	rounded(head,"NoseBridge",Vector3(0,1.659,-0.235),Vector3(0.067,0.11,0.065),skin)
	rounded(head,"NoseTip",Vector3(0,1.621,-0.26),Vector3(0.10,0.075,0.10),skin)
	var smile: Array[Vector3] = [Vector3(-0.079,1.558,-0.197),Vector3(-0.044,1.538,-0.212),Vector3(0,1.531,-0.218),Vector3(0.044,1.538,-0.212),Vector3(0.079,1.558,-0.197)]
	mesh(head,"Smile",Vector3.ZERO,Geo.tube(smile,0.009),material(Color("774d3d")))
	mesh(head,"SmileHighlight",Vector3.ZERO,Geo.tube([Vector3(-0.04,1.542,-0.219),Vector3(0,1.537,-0.225),Vector3(0.04,1.542,-0.219)],0.005),white)

func build_lucas() -> void:
	mesh(decorations,"HairCap",Vector3.ZERO,Geo.hair_cap(),hair)
	var lighter := material(hair.albedo_color.lightened(0.06),0.70)
	for i in 4:
		var lock := mesh(decorations,"SweptLock",Vector3(-0.15+i*0.10,1.925-i*0.005,-0.238),Geo.loft([Vector4(-0.065,0.008,0.012,0),Vector4(-0.03,0.043,0.036,0),Vector4(0.035,0.061,0.052,0.008),Vector4(0.085,0.02,0.025,0.03)],12),lighter if i == 1 else hair)
		lock.rotation.z = -0.38
		lock.rotation.x = -0.15
	build_pack(Color("62754d"),Color("d1b47d"))

func build_marina() -> void:
	mesh(decorations,"TiedHair",Vector3.ZERO,Geo.hair_cap(),hair)
	var highlight := material(hair.albedo_color.lightened(0.10),0.68)
	for side: float in [-1,1]:
		var lock := rounded(decorations,"SideLock",Vector3(side*0.235,1.77,0.013),Vector3(0.11,0.30,0.27),hair)
		lock.rotation.z = side*0.18
	var fringe := rounded(decorations,"SideFringe",Vector3(-0.09,1.889,-0.19),Vector3(0.32,0.17,0.12),highlight)
	fringe.rotation.z = -0.30
	rounded(decorations,"Bun",Vector3(0,1.79,0.285),Vector3(0.30,0.30,0.25),hair)
	for side: float in [-1,1]:
		rounded(decorations,"BunFold",Vector3(side*0.075,1.81,0.36),Vector3(0.13,0.22,0.12),highlight)
	box(decorations,"HairTie",Vector3(0,1.79,0.218),Vector3(0.22,0.045,0.10),material(Color("d6d4a2")))
	build_pack(Color("356d70"),Color("adc7b4"),false)
	box(decorations,"FieldPouch",Vector3(0.30,0.96,0.035),Vector3(0.16,0.22,0.19),material(Color("aa966c")),0.035)
	box(decorations,"PouchFlap",Vector3(0.30,1.055,0.04),Vector3(0.18,0.055,0.21),material(Color("c8b88d")))
	box(decorations,"Notebook",Vector3(0.30,1.095,0.035),Vector3(0.10,0.075,0.12),material(Color("e5ddbf")))

func build_rafael() -> void:
	mesh(decorations,"Hair",Vector3.ZERO,Geo.hair_cap(),hair)
	var hat := material(outfit.albedo_color.darkened(0.10))
	var trim := material(Color("514c37"))
	mesh(decorations,"Cap",Vector3.ZERO,Geo.loft([Vector4(1.85,0.287,0.257,0.014),Vector4(1.94,0.282,0.25,0.014),Vector4(2.015,0.20,0.17,0.014),Vector4(2.045,0.025,0.02,0.014)],20),hat)
	mesh(decorations,"CapBand",Vector3.ZERO,Geo.loft([Vector4(1.846,0.291,0.262,0.014),Vector4(1.875,0.291,0.262,0.014)],20),trim)
	var visor := box(decorations,"CapVisor",Vector3(0,1.853,-0.26),Vector3(0.54,0.045,0.32),hat,0.09)
	visor.rotation.x = -0.055
	badge(decorations,Vector3(0,1.915,-0.267),0.45)
	var reflector := material(Color("e6dfaf"),0.55,0.12)
	for side: float in [-1,1]:
		box(decorations,"Reflector",Vector3(side*0.20,1.215,-0.236),Vector3(0.035,0.32,0.025),reflector)
		var leg: Node3D = parts.LeftLeg if side < 0 else parts.RightLeg
		var cuff := Node3D.new()
		cuff.name = "BootCuff"
		leg.add_child(cuff)
		mesh(cuff,"BootAnkle",Vector3.ZERO,Geo.loft([Vector4(-0.61,0.105,0.12,0.01),Vector4(-0.41,0.104,0.12,0.01),Vector4(-0.38,0.111,0.126,0.01)]),material(Color("4e4b3d"),0.78))
		box(cuff,"BootTrim",Vector3(0,-0.39,0.01),Vector3(0.21,0.04,0.25),trim)
	box(decorations,"ReflectiveBand",Vector3(0,0.925,-0.185),Vector3(0.48,0.035,0.025),reflector)
	var pack: Node3D = parts.Backpack
	box(pack,"UtilityPack",Vector3(0,1.10,0.25),Vector3(0.38,0.42,0.24),trim,0.055)
	box(pack,"PackPanel",Vector3(0,1.13,0.383),Vector3(0.30,0.27,0.03),hat)
	badge(pack,Vector3(0,1.15,0.405),0.9,true)
	for side: float in [-1,1]:
		mesh(pack,"Strap",Vector3.ZERO,Geo.tube([Vector3(side*0.18,0.88,-0.18),Vector3(side*0.22,1.23,-0.19),Vector3(side*0.20,1.38,0.05),Vector3(side*0.18,1.25,0.28)],0.022),trim)
	box(decorations,"Radio",Vector3(-0.285,1.18,-0.14),Vector3(0.085,0.16,0.075),trim)
	box(decorations,"Antenna",Vector3(-0.285,1.30,-0.14),Vector3(0.015,0.12,0.015),trim)

func build_bia() -> void:
	mesh(decorations,"CurlBase",Vector3.ZERO,Geo.hair_cap(),hair)
	var highlight := material(hair.albedo_color.lightened(0.095),0.73)
	for i in 14:
		var a := TAU*i/14.0
		var curl := rounded(decorations,"Curl",Vector3(cos(a)*0.235,1.90+cos(a*2)*0.025,sin(a)*0.205+0.02),Vector3(0.17,0.19+(i%3)*0.018,0.17),hair if i%3 else highlight)
		curl.rotation.z = sin(a)*0.35
	for x: float in [-0.13,0,0.13]:
		rounded(decorations,"CrownCurl",Vector3(x,1.995,0.015),Vector3(0.19,0.17,0.21),hair)
	for side: float in [-1,1]:
		rounded(decorations,"SideCurl",Vector3(side*0.253,1.765,0.03),Vector3(0.13,0.24,0.20),hair)
	var clip := box(decorations,"HairClip",Vector3(-0.18,1.876,-0.205),Vector3(0.10,0.036,0.024),material(Color("dfbd72")))
	clip.rotation.z = -0.5
	var cloth := material(Color("ac986b"))
	var edge := material(Color("796b4b"))
	var bag: Node3D = parts.Backpack
	box(bag,"Satchel",Vector3(-0.31,0.94,0.065),Vector3(0.23,0.30,0.25),cloth,0.045)
	box(bag,"SatchelFlap",Vector3(-0.31,1.05,0.09),Vector3(0.25,0.11,0.26),edge,0.035)
	box(bag,"Clasp",Vector3(-0.31,1.025,-0.055),Vector3(0.044,0.056,0.02),material(Color("e1c995"),0.55))
	mesh(bag,"CrossBodyStrap",Vector3.ZERO,Geo.tube([Vector3(-0.31,0.97,-0.06),Vector3(-0.23,1.0,-0.267),Vector3(-0.08,1.15,-0.257),Vector3(0.12,1.33,-0.22),Vector3(0.20,1.38,-0.12),Vector3(0.23,1.37,0.03),Vector3(0.15,1.25,0.20),Vector3(-0.31,0.96,0.20)],0.024,8),edge)
	badge(bag,Vector3(-0.31,0.94,-0.067),0.55)
	box(decorations,"JacketHem",Vector3(0,0.855,0),Vector3(0.52,0.045,0.30),material(outfit.albedo_color.darkened(0.20)))

func build_pack(color: Color, strap_color: Color, bottle: bool = true) -> void:
	var pack: Node3D = parts.Backpack
	pack.visible = true
	var fabric := material(color)
	var seam := material(color.darkened(0.20))
	var trim := material(strap_color)
	box(pack,"PackBody",Vector3(0,1.10,0.257),Vector3(0.43,0.49,0.27),fabric,0.065)
	box(pack,"TopFlap",Vector3(0,1.32,0.29),Vector3(0.45,0.13,0.28),seam,0.055)
	box(pack,"Pocket",Vector3(0,0.98,0.405),Vector3(0.32,0.21,0.075),seam,0.035)
	box(pack,"PocketFlap",Vector3(0,1.065,0.45),Vector3(0.33,0.052,0.032),fabric)
	box(pack,"Zip",Vector3(0,1.09,0.408),Vector3(0.31,0.014,0.014),trim)
	box(pack,"ZipPull",Vector3(0.12,1.065,0.426),Vector3(0.02,0.045,0.015),material(Color("b8c2b8"),0.35,0.6))
	mesh(pack,"Handle",Vector3.ZERO,Geo.tube([Vector3(-0.09,1.36,0.23),Vector3(-0.075,1.425,0.23),Vector3(0.075,1.425,0.23),Vector3(0.09,1.36,0.23)],0.022),seam)
	for side: float in [-1,1]:
		mesh(pack,"Strap",Vector3.ZERO,Geo.tube([Vector3(side*0.19,0.88,-0.19),Vector3(side*0.21,1.18,-0.196),Vector3(side*0.20,1.36,-0.09),Vector3(side*0.19,1.38,0.18),Vector3(side*0.19,0.89,0.34)],0.027,8),trim)
		box(pack,"StrapBuckle",Vector3(side*0.21,1.0,-0.226),Vector3(0.065,0.068,0.022),seam)
	badge(pack,Vector3(0,1.16,0.403),0.90,true)
	if bottle:
		rounded(pack,"Bottle",Vector3(0.27,1.03,0.27),Vector3(0.105,0.27,0.10),material(Color("619ca5"),0.37))
		box(pack,"BottlePocket",Vector3(0.255,0.955,0.28),Vector3(0.14,0.12,0.12),seam)
		box(pack,"BottleCap",Vector3(0.27,1.17,0.27),Vector3(0.08,0.04,0.08),trim)

func badge(parent: Node3D, pos: Vector3, factor: float, back: bool = false) -> void:
	var node := mesh(parent,"EcoLeaf",pos,Geo.leaf(),material(Color("e3eac1")))
	node.scale = Vector3.ONE*factor
	if back: node.rotation.y = PI
	var points: Array[Vector3] = [Vector3(-0.03,-0.06,-0.008),Vector3(0.038,0.064,-0.008)]
	var stem := mesh(parent,"LeafStem",pos,Geo.tube(points,0.004),material(Color("e3eac1")))
	stem.scale = Vector3.ONE*factor
	if back: stem.rotation.y = PI

func material(color: Color, roughness: float = 0.88, metallic: float = 0.0) -> StandardMaterial3D:
	var key := color.to_html()+str(roughness)+str(metallic)
	if materials.has(key): return materials[key]
	var result := StandardMaterial3D.new()
	result.albedo_color = color
	result.roughness = roughness
	result.metallic = metallic
	result.metallic_specular = 0.28
	materials[key] = result
	return result

func mesh(parent: Node, title: String, pos: Vector3, shape: Mesh, surface: Material) -> MeshInstance3D:
	var node := MeshInstance3D.new()
	node.name = title
	node.position = pos
	node.mesh = shape
	node.material_override = surface
	parent.add_child(node)
	return node

func box(parent: Node, title: String, pos: Vector3, size: Vector3, surface: Material, bevel: float = 0.018) -> MeshInstance3D:
	return mesh(parent,title,pos,Shapes.beveled_box(size,bevel),surface)

func rounded(parent: Node, title: String, pos: Vector3, size: Vector3, surface: Material) -> MeshInstance3D:
	var shape := SphereMesh.new()
	shape.radius = 0.5
	shape.height = 1.0
	shape.radial_segments = 20
	shape.rings = 10
	var node := mesh(parent,title,pos,shape,surface)
	node.scale = size
	return node

func _process(delta: float) -> void:
	if rebuilding or not animate_face or not is_visible_in_tree(): return
	blink_clock = fposmod(blink_clock+delta,4.8)
	var close := sin(clampf((blink_clock-4.58)/0.18,0.0,1.0)*PI) if blink_clock > 4.58 else 0.0
	for eye in eyes: eye.scale.y = 1.0-close*0.94

func set_face_animation(enabled: bool) -> void:
	animate_face = enabled
	for eye in eyes: eye.scale.y = 1.0

func attach_external_model(model: PackedScene = null, adjustment: Transform3D = Transform3D.IDENTITY) -> Node3D:
	var existing := get_node_or_null("ExternalModel")
	if existing:
		remove_child(existing)
		existing.queue_free()
	for pivot: Node3D in parts.values(): pivot.show()
	external_error = ""
	if model == null: return null
	var adapter := ModelAdapter.new()
	adapter.name = "ExternalModel"
	adapter.animation_map = external_animations.duplicate()
	add_child(adapter)
	var instance: Node3D = adapter.mount(model,adjustment)
	if instance == null:
		external_error = adapter.last_error
		remove_child(adapter)
		adapter.queue_free()
		return null
	for pivot: Node3D in parts.values(): pivot.hide()
	adapter.play_state(animation_state)
	return instance

func set_animation(state: String) -> void:
	if animation_state == state: return
	animation_state = state
	var external := get_node_or_null("ExternalModel")
	if external: external.request_state(state)
