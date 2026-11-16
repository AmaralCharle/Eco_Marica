extends Node3D
## Camada decorativa sem corpos físicos. Layout, interação e navegação permanecem nas fases.
var mission: Node3D
var world: Node3D
var materials: Dictionary = {}
var extra: Node3D
var grass: MultiMeshInstance3D
var settings: Node
const WATER = preload("res://assets/materials/water.gdshader")
const LEAVES = preload("res://assets/materials/foliage.gdshader")
const SURFACE = preload("res://assets/materials/environment_surface.gdshader")
const Meshes = preload("res://scripts/effects/environment_meshes.gd")
const Config = preload("res://scripts/core/game_config.gd")
const ArtMeshes = preload("res://scripts/effects/art_direction_meshes.gd")
const AssetLibrary = preload("res://scripts/effects/asset_library.gd")
var imported: Node3D
var grass_capacity: int = 780
var sky_material: ProceduralSkyMaterial
var foliage_materials: Array[ShaderMaterial] = []
var wet_materials: Array[ShaderMaterial] = []
var storm_last: float = -1.0

func _ready() -> void:
	mission = get_parent().get_parent()
	world = mission.get_node("World")
	settings = get_node("/root/GameAudio")
	name = "WorldPolish"
	extra = Node3D.new()
	extra.name = "HighDetail"
	add_child(extra)
	imported = Node3D.new()
	imported.name = "ImportedArt"
	add_child(imported)
	upgrade_existing()
	landscape()
	configure_light()
	preload("res://scripts/effects/reference_art_pass.gd").new().apply(self)
	add_child(preload("res://scripts/effects/upgrade_visuals.gd").new())
	if AssetLibrary.enabled(mission.mission_id):
		if mission.mission_id == "centro": preload("res://scripts/effects/asset_revolution.gd").urban(self)
		AssetLibrary.batch(imported)
	batch_decoration(self)
	batch_decoration(extra)
	batch_world()
	mission.state_changed.connect(update_recovery)
	settings.preferences_changed.connect(apply_quality)
	apply_quality()

func surface(color: Color) -> StandardMaterial3D:
	var key := color.to_html()
	if not materials.has(key):
		var mat := StandardMaterial3D.new()
		mat.albedo_color = color
		mat.roughness = 0.85
		materials[key] = mat
	return materials[key]

func terrain(color: Color) -> StandardMaterial3D:
	var key := "terrain_"+color.to_html()
	if not materials.has(key):
		var mat: StandardMaterial3D = surface(color).duplicate()
		mat.vertex_color_use_as_albedo = true
		materials[key] = mat
	return materials[key]

func textured(kind: int, color: Color) -> ShaderMaterial:
	var key := "surface_%d_%s" % [kind, color.to_html()]
	if not materials.has(key):
		var mat := ShaderMaterial.new()
		mat.shader = SURFACE
		mat.set_shader_parameter("base_color", color)
		mat.set_shader_parameter("surface_type", kind)
		var pbr_name: String = {1:"Ground037",2:"Ground055S",4:"Asphalt001",6:"Wood001"}.get(kind,"")
		if not pbr_name.is_empty() and mission != null and AssetLibrary.enabled(mission.mission_id):
			mat.set_shader_parameter("use_pbr",true)
			var pbr_dir := "res://assets/imported/ambientcg/"+pbr_name+"/"+pbr_name+"_1K-JPG_"
			mat.set_shader_parameter("pbr_color",load(pbr_dir+"Color.jpg"))
			mat.set_shader_parameter("pbr_roughness",load(pbr_dir+"Roughness.jpg"))
			mat.set_shader_parameter("pbr_normal",load(pbr_dir+"NormalGL.jpg"))
		materials[key] = mat
		if kind == 4:
			wet_materials.append(mat)
	return materials[key]

func foliage(color: Color) -> ShaderMaterial:
	var key := "leaf_" + color.to_html()
	if not materials.has(key):
		var mat := ShaderMaterial.new()
		mat.shader = LEAVES
		mat.set_shader_parameter("leaf_color", color)
		materials[key] = mat
		foliage_materials.append(mat)
	return materials[key]

func mesh_at(parent: Node, mesh: Mesh, pos: Vector3, color: Color) -> MeshInstance3D:
	var instance := MeshInstance3D.new()
	instance.mesh = mesh
	instance.material_override = surface(color)
	instance.position = pos
	parent.add_child(instance)
	return instance

func ellipsoid(parent: Node, pos: Vector3, size: Vector3, color: Color) -> MeshInstance3D:
	var sphere := SphereMesh.new()
	sphere.radius = 0.5
	sphere.height = 1
	sphere.radial_segments = 10
	sphere.rings = 5
	var instance := mesh_at(parent, sphere, pos, color)
	instance.scale = size
	return instance

func cylinder(parent: Node, pos: Vector3, height: float, radius: float, color: Color) -> MeshInstance3D:
	var mesh := CylinderMesh.new()
	mesh.height = height
	mesh.top_radius = radius * 0.75
	mesh.bottom_radius = radius
	mesh.radial_segments = 8
	return mesh_at(parent, mesh, pos, color)

func box(parent: Node, pos: Vector3, size: Vector3, color: Color) -> MeshInstance3D:
	var mesh := BoxMesh.new()
	mesh.size = size
	return mesh_at(parent, mesh, pos, color)

func upgrade_existing() -> void:
	var water := ShaderMaterial.new()
	water.shader = WATER
	for node in world.get_children():
		if node is Label3D:
			node.font_size = mini(node.font_size, 34)
			node.pixel_size = 0.005
			continue
		if node.get_child_count() == 0 or not node.get_child(0) is MeshInstance3D:
			continue
		var instance: MeshInstance3D = node.get_child(0)
		var kind: String = node.get_meta("kind", String(node.name))
		if not instance.mesh is BoxMesh:
			continue
		var size: Vector3 = instance.mesh.size
		if kind == "Trunk":
			if AssetLibrary.enabled(mission.mission_id):
				instance.hide()
				var variant := "tree_palmDetailedTall" if int(absf(node.position.z))%2 else "tree_palmDetailedShort"
				AssetLibrary.place(imported,"nature-kit",variant,node.position-Vector3.UP*size.y*0.5,Vector3(3.7,4.8,3.7),node.position.z*0.17)
				continue
			var trunk := CylinderMesh.new()
			trunk.height = size.y
			trunk.top_radius = size.x * 0.38
			trunk.bottom_radius = size.x * 0.6
			trunk.radial_segments = 8
			trunk.material = instance.mesh.material
			instance.mesh = trunk
			instance.material_override = textured(6, Color("94754f"))
		elif kind == "PalmLeaf":
			if AssetLibrary.enabled(mission.mission_id):
				instance.hide()
				continue
			instance.mesh = palm_fronds()
			instance.material_override = foliage(Color("3e7950"))
		elif kind in ["SoftHill", "Restinga", "Cloud"]:
			var original_material: Material = instance.mesh.material
			instance.mesh = Meshes.canopy(3)
			instance.scale = size
			instance.material_override = foliage(Color("56865a")) if kind == "Restinga" else original_material
			if kind == "SoftHill":
				instance.mesh = ArtMeshes.ridge(int(absf(node.position.z)))
				instance.position.y = -1.5
				instance.material_override = terrain(Color("5c884e"))
				instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
			if kind == "Cloud":
				instance.mesh = cloud_mesh()
				instance.scale = Vector3(size.x, size.y * 3.4, size.z * 0.75)
				instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
				if AssetLibrary.enabled(mission.mission_id): instance.hide()
		elif kind in ["Lagoon", "Sea", "Stream", "Channel"]:
			var sheet := PlaneMesh.new()
			sheet.size = Vector2(size.x,size.z)
			sheet.subdivide_width = 24
			sheet.subdivide_depth = 48
			instance.mesh = sheet
			instance.position.y = -0.035-node.position.y if kind in ["Stream","Channel"] else size.y*0.5
			instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
			var local_water: ShaderMaterial = water.duplicate()
			local_water.set_shader_parameter("half_width", size.x * 0.5)
			local_water.set_shader_parameter("center_x", node.position.x)
			local_water.set_shader_parameter("flow_speed", 0.55 if kind in ["Sea", "Stream"] else 0.30)
			local_water.set_shader_parameter("deep_color", Color("1c627b") if kind == "Sea" else Color("216f71"))
			local_water.set_shader_parameter("shallow_color", Color("69b8a4") if kind != "Sea" else Color("63b7c1"))
			instance.material_override = local_water
		elif kind in ["Grass", "Ground", "Land", "WestBank", "FarBank"]:
			if mission.mission_id == "ubatiba" and kind == "Ground": instance.mesh = ArtMeshes.rural_ground()
			instance.material_override = textured(0, Color("6b934c") if mission.mission_id != "centro" else Color("729051"))
		elif kind in ["Walkway", "Sidewalk", "AccessRamp"]:
			instance.material_override = textured(3, Color("c6bda2") if kind == "Walkway" else Color("bcb9aa"))
		elif kind in ["Sand", "WetSand", "Trail", "Street", "CycleLane", "Building"]:
			var color: Color = instance.mesh.material.albedo_color
			var type: int = {"Sand": 2, "WetSand": 2, "Trail": 1, "Street": 4, "CycleLane": 4, "Building": 5}[kind]
			if kind == "Street": color = Color("526267")
			if kind == "Trail": color = Color("bfa276")
			if kind == "Trail": instance.mesh = Meshes.trail(size.x, size.z)
			instance.material_override = textured(type, color)
		elif kind == "Roof":
			var roof := PrismMesh.new()
			roof.size = Vector3(size.x, 0.9, size.z)
			instance.mesh = roof
			instance.material_override = textured(7, Color("b57756"))
		elif kind in ["BenchSeat", "BenchBack", "BenchLeg", "RailPost", "LakeRail", "Pier", "Bridge", "BridgePost", "Trunk"]:
			instance.material_override = textured(6, Color("9e7952"))
		elif kind in ["Wave", "Ripple"]:
			instance.hide()
		elif kind.begins_with("Boundary") or kind in ["NavigationLimit", "ShoreLimit", "DuneLimit"]:
			# Mantém a barreira física, apresenta borda natural no lugar da parede lisa.
			instance.hide()
	configure_sky()

func configure_sky() -> void:
	var environment: Environment = mission.get_node("WorldEnvironment").environment
	var sky := Sky.new()
	sky_material = ProceduralSkyMaterial.new()
	sky_material.sky_top_color = Color("2e86c4")
	sky_material.sky_horizon_color = Color("b1dcd9")
	sky_material.ground_horizon_color = Color("b1dcd9")
	sky_material.ground_bottom_color = Color("739979")
	sky.sky_material = sky_material
	environment.sky = sky
	environment.background_mode = Environment.BG_SKY
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color("c7dfe8")
	if AssetLibrary.enabled(mission.mission_id) and mission.mission_id != "centro":
		var panorama := PanoramaSkyMaterial.new()
		panorama.panorama = load("res://assets/imported/polyhaven/kloppenheim_05_puresky_1k.hdr")
		panorama.energy_multiplier = 0.65
		sky.sky_material = panorama
		sky.radiance_size = Sky.RADIANCE_SIZE_128
		environment.sky_rotation.y = 0.45 if mission.mission_id == "ubatiba" else -0.35

func palm_fronds() -> ArrayMesh:
	return Meshes.palm_fronds()

func tree(pos: Vector3, seed_index: int = 0) -> void:
	if AssetLibrary.enabled(mission.mission_id):
		AssetLibrary.place(imported,"stylized-nature","CommonTree_3" if seed_index%2 else "CommonTree_5",pos,Vector3(4.6,5.2+(seed_index%4)*0.3,4.6),seed_index*1.37)
		return
	var height: float = 3.45 + (seed_index % 4) * 0.27
	var trunk := cylinder(self, pos + Vector3(0, height * 0.5, 0), height, 0.15, Color("85603f"))
	trunk.material_override = textured(6, Color("92734f"))
	var colors: Array[Color] = [Color("397b40"), Color("5a973d"), Color("377e51"), Color("6b9c43")]
	var distant := absf(pos.x) > 15 or pos.z < -15
	trunk.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF if distant else GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	for i in 5:
		var angle: float = i * 2.4 + seed_index
		var start := pos+Vector3.UP*height*0.62
		var tip := pos+Vector3(cos(angle)*0.78,height*0.98,sin(angle)*0.78)
		var branch := cylinder(self,(start+tip)*0.5,start.distance_to(tip),0.075,Color("85603f"))
		branch.basis = Basis(Quaternion(Vector3.UP,(tip-start).normalized()))
		var crown := mesh_at(self, Meshes.canopy(seed_index + i), pos + Vector3(cos(angle) * 0.70, height + 0.10 + (i % 3) * 0.38, sin(angle) * 0.70), Color.WHITE)
		crown.scale = Vector3(2.5 + (seed_index % 2) * 0.35, 2.15, 2.5)
		if distant: crown.scale *= 1.15
		crown.rotation.y = angle
		crown.material_override = foliage(colors[(i + seed_index) % 4])
		if distant or i >= 3:
			crown.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
			branch.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF

func garden(pos: Vector3, index: int) -> void:
	if AssetLibrary.enabled(mission.mission_id):
		if index%4 == 0:
			AssetLibrary.place(imported,"stylized-nature","Bush_Common_Flowers",pos,Vector3(1.3,0.8,1.15),index*1.3)
		else:
			AssetLibrary.place(imported,"nature-kit","plant_bushDetailed" if index%2 else "plant_bushSmall",pos,Vector3(1.25,0.8,1.15),index*1.3)
		for i in 3:
			AssetLibrary.place(imported,"nature-kit","flower_yellowC" if index%2 else "flower_purpleC",pos+Vector3(sin(i*2.4)*0.5,0,cos(i*2.4)*0.4),Vector3.ONE*0.38,index+i)
		return
	var shrub := mesh_at(self, Meshes.canopy(index), pos + Vector3.UP * 0.28, Color.WHITE)
	shrub.scale = Vector3(1.25, 0.70 + (index % 3) * 0.13, 0.95)
	shrub.rotation.y = index * 1.3
	shrub.material_override = foliage(Color("60854c") if index % 2 else Color("4a8058"))
	for i in 5:
		var at := pos + Vector3(cos(i * 2.4) * 0.46, 0.46, sin(i * 2.4) * 0.36)
		cylinder(extra, at - Vector3.UP * 0.12, 0.24, 0.015, Color("427840"))
		ellipsoid(extra, at, Vector3(0.19, 0.13, 0.19), Color("f1c85d") if (i + index) % 2 == 0 else Color("d598bf"))

func lamp(pos: Vector3) -> void:
	if AssetLibrary.enabled(mission.mission_id):
		AssetLibrary.place(imported,"city-kit-roads","light-curved",pos,Vector3(1.2,3.6,0.6),PI if pos.x>0 else 0.0)
		return
	cylinder(self, pos + Vector3.UP * 1.8, 3.6, 0.07, Color("34535b"))
	box(self, pos + Vector3(0.3, 3.6, 0), Vector3(0.7, 0.07, 0.1), Color("34535b"))
	ellipsoid(self, pos + Vector3(0.6, 3.53, 0), Vector3(0.45, 0.12, 0.3), Color("ffdd91"))

func landscape() -> void:
	var id: String = mission.mission_id
	for i in 8:
		var z: float = -16 + i * 4.5 + sin(i * 1.7) * 0.65
		if id == "aracatiba":
			garden(Vector3(10.8 + sin(i * 2.0) * 1.3, 0.05, z), i)
			if i % 2 == 0:
				tree(Vector3(12.5, 0, z), i)
				lamp(Vector3(4.2, 0, z))
		elif id == "itaipuacu":
			garden(Vector3(11, 0, z), i)
			hill(Vector3(17, -0.65, z), Vector3(10, 4, 10), Color("c7b68a"), i)
			rock(Vector3(-13, -0.02, z),Vector3(1.3,0.6,0.9),i)
		elif id == "centro":
			var side: float = -1 if i % 2 == 0 else 1
			var at := Vector3(side * 7.1, 0.12, z)
			tree(at, i)
			if i % 2 == 0:
				lamp(Vector3(side * 6.9, 0.12, z + 2.8))
		elif id == "ubatiba":
			for side: float in [-1, 1]:
				tree(Vector3(side * (13.8 + sin(i * 1.8) * 0.7), 0, z), i)
				garden(Vector3(side * (10.3 + sin(i * 2.8)), 0, z + 1), i)
				rock(Vector3(-12,0.05,z),Vector3(0.9,0.6,0.7),i)
		elif id == "ponta_negra":
			for side: float in [-1, 1]:
				garden(Vector3(-9 if side < 0 else 16.5, 0, z), i)
				if side < 0 or absf(z - 12.0) > 3.0:
					rock(Vector3(side * 8.5, -0.08, z), Vector3(1, 0.6, 1.3), i)
	# Morros no horizonte, inteiramente fora da área jogável.
	for i in 7:
		hill(Vector3(-42 + i * 14, -1.0, -48 - (i % 2) * 7), Vector3(28, 8 + i % 3 * 2.5, 22), Color("678775").lerp(Color("8eaaa0"), (i % 3) * 0.18), i)
	if id == "centro":
		facades()
	if id == "aracatiba":
		pavement()
	if id == "ponta_negra":
		pier_details()
	if id == "ubatiba":
		rural_details()
	if id in ["aracatiba", "itaipuacu", "ponta_negra"]:
		shore_details()
	build_grass()

func facades() -> void:
	if AssetLibrary.enabled(mission.mission_id): return
	for side: float in [-1, 1]:
		for i in 4:
			var z: float = -13 + i * 8
			var x: float = side * 8.42
			var rise: float = [0.0, 1.25, 0.45, 1.75][i]
			var wall_colors: Array[Color] = [Color("d5bd9d"), Color("91b1ab"), Color("c3aeac"), Color("d1c49d")]
			if rise > 0:
				var floor_part := box(self, Vector3(side * 11.5, 4.2 + rise * 0.5, z), Vector3(6, rise, 5.5), Color.WHITE)
				floor_part.material_override = textured(5, wall_colors[i])
				for offset: float in [-1.5, 1.5]:
					box(self, Vector3(x, 4.2 + rise * 0.5, z + offset), Vector3(0.07, rise * 0.6, 0.85), Color("47656c"))
			for node in world.get_children():
				if node.get_meta("kind", "") == "Roof" and absf(node.position.x - side * 11.5) < 0.1 and absf(node.position.z - z) < 0.1:
					node.position.y += rise
			var sign := box(self, Vector3(x - side * 0.07, 3.79, z), Vector3(0.10, 0.51, 3.2), Color("3b5b59"))
			sign.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
			for offset: float in [-1.5, 1.5]:
				var shutter := box(self, Vector3(x, 2.7, z + offset + 0.67), Vector3(0.08, 1.1, 0.22), Color("9b7956"))
				shutter.material_override = textured(6, Color("9b7956"))
				box(extra, Vector3(x, 2.08, z + offset), Vector3(0.36, 0.11, 1.3), Color("d1c3a7"))
			box(self, Vector3(x, 0.15, z), Vector3(0.08, 0.25, 5.45), Color("a8a393"))
			var awning := box(self, Vector3(x - side * 0.32, 2.3, z), Vector3(0.9, 0.15, 3.7), Color("ba6754") if i % 2 == 0 else Color("437c80"))
			awning.rotation.z = side * 0.12
			for j in 7:
				box(extra, Vector3(x - side * 0.65, 2.24, z - 1.5 + j * 0.5), Vector3(0.3, 0.18, 0.24), Color("f4d6a4"))
			for offset: float in [-1.5, 1.5]:
				box(self, Vector3(x, 2.7, z + offset), Vector3(0.07, 1.05, 0.05), Color("edddbf"))
				box(self, Vector3(x, 2.7, z + offset), Vector3(0.07, 0.05, 1.15), Color("edddbf"))
			box(self, Vector3(x, 0.2, z + 1.5), Vector3(0.4, 0.3, 1.4), Color("bd895c"))
			garden(Vector3(x - side * 0.1, 0.3, z + 1.5), i)
		# Cabos finos e postes sem novas luzes dinâmicas.
		for z: float in [-17, -1, 15]:
			cylinder(self, Vector3(side * 7.65, 2.9, z), 5.8, 0.08, Color("67716b"))
		for i in 24:
			var z: float = -17 + i * 1.4
			var wire := box(extra, Vector3(side * 7.65, 5.55 - sin(fposmod(z + 17, 16) / 16 * PI) * 0.25, z), Vector3(0.022, 0.022, 1.43), Color("465957"))
			wire.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF

func pavement() -> void:
	# Juntas agora pertencem ao material compartilhado; sem dezenas de faixas independentes.
	for x: float in [-3.55, 3.55]:
		var curb := box(self, Vector3(x, 0.027, 0), Vector3(0.16, 0.045, 35), Color("a7a78c"))
		curb.material_override = textured(3, Color("b0ad94"))

func pier_details() -> void:
	# Continuação somente visual do canal; os limites físicos e a zona de perdas ficam intactos.
	var continuation := box(self, Vector3(0, -0.035, -45), Vector3(16, 0.004, 50), Color.WHITE)
	var water := ShaderMaterial.new()
	water.shader = WATER
	water.set_shader_parameter("deep_color", Color("216f71"))
	water.set_shader_parameter("shallow_color", Color("69b8a4"))
	water.set_shader_parameter("flow_speed", 0.30)
	continuation.material_override = water
	continuation.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	for side: float in [-1, 1]:
		var bank := box(self, Vector3(13 if side > 0 else -11, -0.03, -34), Vector3(10 if side > 0 else 6, 0.06, 28), Color.WHITE)
		bank.material_override = textured(0, Color("829d65"))
		bank.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	for i in 7:
		cylinder(self, Vector3(-6.6 + i * 2.2, -0.04, -18.4), 0.22, 0.13, Color("d4ae69"))
		cylinder(self, Vector3(-6.6 + i * 2.2, 0.11, -18.4), 0.12, 0.10, Color("eee0b6"))
	for i in 12:
		box(self, Vector3(8, 0.004, 10.15 + i * 0.33), Vector3(3.95, 0.008, 0.026), Color("8f7959"))
	# Cantos distantes do ponto de desembarque; sem colisões novas.
	for z: float in [10.1, 13.9]:
		cylinder(self, Vector3(9.7, 0.3, z), 0.6, 0.11, Color("917454"))
		# Colunas sob o tablado, deixando livre a passagem terra/barco.
		cylinder(self, Vector3(6.15, -0.35, z), 0.7, 0.10, Color("80684d"))
	for x: float in [-6.5, 6.5]:
		box(self, Vector3(x, 2.95, -1), Vector3(0.65, 0.65, 2.1), Color("9e9e87"))
	for i in 11:
		box(self, Vector3(-7.5 + i * 1.5, 4, -2.14), Vector3(0.08, 0.8, 0.08), Color("eee0b6"))
		box(self, Vector3(-7.5 + i * 1.5, 4, 0.14), Vector3(0.08, 0.8, 0.08), Color("eee0b6"))
	box(self, Vector3(0, 4.4, -2.14), Vector3(17, 0.08, 0.1), Color("eee0b6"))
	box(self, Vector3(0, 4.4, 0.14), Vector3(17, 0.08, 0.1), Color("eee0b6"))

func build_grass() -> void:
	grass = MultiMeshInstance3D.new()
	grass.name = "BatchedGrass"
	var multi := MultiMesh.new()
	multi.transform_format = MultiMesh.TRANSFORM_3D
	multi.mesh = Meshes.tuft()
	grass_capacity = {"ubatiba":2100,"ponta_negra":1700,"centro":360}.get(mission.mission_id,1400)
	multi.use_colors = true
	multi.instance_count = grass_capacity
	var rng := RandomNumberGenerator.new()
	rng.seed = 12973
	var plot_positions: Array[Vector3] = []
	for point in get_tree().get_nodes_in_group("planting_plots"):
		if mission.is_ancestor_of(point): plot_positions.append(point.position)
	for i in grass_capacity:
		var side: float = -1 if i % 2 == 0 else 1
		var x: float = side * rng.randf_range(8.7, 13.5)
		if mission.mission_id == "itaipuacu":
			x = rng.randf_range(9, 11.5)
		elif mission.mission_id == "ponta_negra":
			x = rng.randf_range(16, 17.5) if side > 0 else rng.randf_range(-12, -9)
		elif mission.mission_id == "centro":
			x = side * rng.randf_range(15, 16)
		elif mission.mission_id == "ubatiba" and i % 3 == 0:
			x = side * rng.randf_range(2.9, 8.8)
		var z: float = rng.randf_range(-18, 18)
		for point in plot_positions:
			if Vector2(x - point.x, z - point.z).length() < 1.6:
				x = side * 10.7
		var basis := Basis(Vector3.UP, rng.randf() * TAU).scaled(Vector3.ONE * rng.randf_range(0.65, 1.35))
		multi.set_instance_transform(i, Transform3D(basis, Vector3(x, 0.03, z)))
		multi.set_instance_color(i,Color.WHITE.darkened(rng.randf_range(0,0.18)))
	grass.multimesh = multi
	var mat := ShaderMaterial.new()
	mat.shader = LEAVES
	mat.set_shader_parameter("leaf_color", Color("51823c"))
	grass.material_override = mat
	grass.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(grass)

func apply_quality() -> void:
	var quality: int = settings.quality
	var sun: DirectionalLight3D = mission.get_node("Sun")
	sun.shadow_enabled = quality > 0
	sun.directional_shadow_max_distance = 45.0 if quality == 1 else 65.0
	sun.directional_shadow_mode = DirectionalLight3D.SHADOW_PARALLEL_4_SPLITS if quality == 2 else DirectionalLight3D.SHADOW_PARALLEL_2_SPLITS
	extra.visible = quality == 2
	grass.multimesh.visible_instance_count = int(grass_capacity*[0.22,0.55,1.0][quality])
	get_viewport().msaa_3d = [Viewport.MSAA_DISABLED, Viewport.MSAA_2X, Viewport.MSAA_4X if AssetLibrary.enabled(mission.mission_id) else Viewport.MSAA_8X][quality]
	get_viewport().scaling_3d_scale = 0.8 if quality == 0 else 1.0

func cloud_mesh() -> ArrayMesh:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for i in 4:
		var sphere := SphereMesh.new()
		sphere.radius = 0.30
		sphere.height = 0.60
		sphere.radial_segments = 10
		sphere.rings = 5
		var basis := Basis.IDENTITY.scaled(Vector3(1.1, 0.8 + (i % 2) * 0.4, 0.9))
		st.append_from(sphere, 0, Transform3D(basis, Vector3(-0.3 + i * 0.19, (i % 2) * 0.1, sin(i * 1.7) * 0.12)))
	return st.commit()

func configure_light() -> void:
	var id: String = mission.mission_id
	var sun: DirectionalLight3D = mission.get_node("Sun")
	sun.rotation_degrees = Vector3(-43, -32, 0)
	if id == "ubatiba": sun.rotation_degrees = Vector3(-38, 32, 0)
	if id == "centro": sun.rotation_degrees = Vector3(-48, -52, 0)
	if id == "itaipuacu": sun.rotation_degrees = Vector3(-54, -36, 0)
	sun.light_color = Color("fff0d6") if id != "centro" else Color("e4e9e9")
	sun.light_energy = 1.10
	sun.shadow_bias = 0.04
	sun.shadow_normal_bias = 0.8
	var env: Environment = mission.get_node("WorldEnvironment").environment
	env.ambient_light_color = Color("bbd2db")
	env.ambient_light_energy = 0.34 if id != "centro" else 0.42
	env.fog_enabled = true
	env.fog_density = 0.0028 if id != "centro" else 0.0038
	env.fog_light_color = Color("9dbab5") if id != "centro" else Color("a8b5bc")
	env.fog_sky_affect = 0.28

func hill(pos: Vector3, size: Vector3, color: Color, index: int) -> void:
	var item := mesh_at(self, ArtMeshes.ridge(index), pos, color)
	item.scale = size
	item.rotation.y = sin(index*1.7)*0.2
	item.material_override = terrain(color)
	item.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF

func rock(pos: Vector3, size: Vector3, index: int) -> void:
	if AssetLibrary.enabled(mission.mission_id):
		if index%3 == 0:
			AssetLibrary.place(imported,"stylized-nature","Rock_Medium_1" if index%2 else "Rock_Medium_2",pos,size,index*1.7,true)
		else:
			AssetLibrary.place(imported,"nature-kit","rock_largeA" if index%2 else "rock_largeC",pos,size,index*1.7,true)
		return
	var item := mesh_at(self, Meshes.canopy(index + 42), pos, Color("929e8c") if index % 2 else Color("7e8e85"))
	item.scale = size
	item.rotation = Vector3(index * 0.25, index * 1.7, 0.12)

func reed(pos: Vector3, index: int) -> void:
	for j in 4:
		var stem := cylinder(self, pos + Vector3(sin(j * 2.4) * 0.12, 0.35, cos(j * 2.4) * 0.12), 0.7 + (j % 2) * 0.15, 0.014, Color("819750"))
		stem.rotation.z = sin(index + j) * 0.13
		var leaf := mesh_at(self, Meshes.tuft(), pos, Color.WHITE)
		leaf.scale = Vector3(1.4, 1.7, 1.4)
		leaf.material_override = foliage(Color("6d8b46"))

func fern(pos: Vector3, index: int) -> void:
	for i in 3:
		var leaf := mesh_at(self, Meshes.palm_fronds(), pos + Vector3.UP * 0.36, Color.WHITE)
		leaf.scale = Vector3(0.33, 0.46, 0.56)
		leaf.rotation.y = i * PI / 3.0 + index
		leaf.material_override = foliage(Color("4b8456"))

func rural_details() -> void:
	for i in 24:
		var x: float = (-1.0 if i % 2 == 0 else 1.0) * (3.0 + (i % 3) * 2.5)
		var z: float = -16 + (i / 6) * 7 + sin(i * 1.8) * 0.7
		var patch := mesh_at(self, Meshes.ground_patch(i), Vector3(x, 0.007, z), Color.WHITE)
		patch.scale = Vector3(1.4, 1, 0.9)
		patch.material_override = textured(0, Color("78905b") if i % 2 else Color("8c9f69"))
		patch.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		if i % 3 == 0:
			for j in 3:
				var at := Vector3(x + sin(j * 2.4) * 0.22, 0.24, z + cos(j * 2.4) * 0.2)
				cylinder(extra, at - Vector3.UP * 0.1, 0.2, 0.012, Color("548453"))
				ellipsoid(extra, at, Vector3(0.13, 0.07, 0.13), Color("ebcf85") if i % 2 else Color("c7aad1"))
	for side: float in [-1, 1]:
		for i in 9:
			var z: float = -17 + i * 4.3
			var x: float = side * (9.4 + sin(i * 2.2) * 0.4)
			fern(Vector3(x, 0.03, z + 1), i)
			if i % 2 == 0:
				rock(Vector3(side * 11.8, 0.22, z), Vector3(1.3, 0.8, 1.2), i)
			# Cerca acompanha a borda da área, sem atravessar pontos de plantio.
			cylinder(self, Vector3(side * 14.8, 0.5, z), 1.0, 0.065, Color("a38a5b"))
			if i < 8:
				box(self, Vector3(side * 14.8, 0.54, z + 2.15), Vector3(0.06, 0.08, 4.3), Color("a38a5b"))
	for i in 13:
		var z: float = -17 + i * 2.75
		rock(Vector3(-12.0 - (i % 2) * 0.2, 0.13, z), Vector3(0.8, 0.5, 0.7), i)
		if i % 2 == 0:
			reed(Vector3(-13.7, 0.02, z), i)
	# Abrigo rural inteiramente fora da área jogável.
	box(self, Vector3(22, 1.6, -10), Vector3(5.5, 3.2, 5), Color("d7cba7"))
	var roof := PrismMesh.new()
	roof.size = Vector3(6.2, 1.5, 5.6)
	var roof_node := mesh_at(self, roof, Vector3(22, 3.5, -10), Color.WHITE)
	roof_node.material_override = textured(7, Color("a96946"))
	box(self, Vector3(19.23, 1.2, -10), Vector3(0.03, 2.3, 0.9), Color("78694e"))
	for node in world.get_children():
		if node is Label3D and node.text.begins_with("Exposto / protegido"):
			node.text = "SOLO E COBERTURA\nDemonstração simplificada"
			node.position = Vector3(-5.4, 1.5, 14.2)
			node.font_size = 26
			node.pixel_size = 0.004
			box(self, node.position + Vector3(0, 0, -0.025), Vector3(2.5, 0.65, 0.07), Color("765c3d"))
			cylinder(self, node.position + Vector3(0, -0.8, -0.03), 1.3, 0.055, Color("947449"))

func shore_details() -> void:
	var id: String = mission.mission_id
	for i in 14:
		var z: float = -17 + i * 2.6
		if id == "aracatiba":
			rock(Vector3(-13.9, -0.12, z), Vector3(1.3, 0.8, 1.5), i)
			if i % 3 == 0: reed(Vector3(-14.2, -0.05, z), i)
		elif id == "itaipuacu":
			if i % 2 == 0: fern(Vector3(9.7 + sin(i) * 0.45, 0, z), i)
			rock(Vector3(12.3, 0.1, z), Vector3(1.3, 0.75, 1.4), i)
		else:
			for side: float in [-1, 1]:
				if side > 0 and z > 9 and z < 15: continue
				rock(Vector3(side * 8.25, -0.12, z), Vector3(1.1, 0.9, 1.9), i)
				if i % 3 == 0 and not (z > 9 and z < 15):
					reed(Vector3(side * 8.6, 0.0, z), i)

func batch_decoration(parent: Node) -> void:
	var instances: Array[MeshInstance3D] = []
	for node in parent.get_children():
		if node is MeshInstance3D and node.visible:
			instances.append(node)
	merge_instances(parent, instances,true)

func batch_world() -> void:
	var instances: Array[MeshInstance3D] = []
	for node in world.get_children():
		if not node.has_meta("kind") or node.get_meta("kind") in ["Cloud", "Ripple", "DemoRain"]:
			continue
		for child in node.get_children():
			if child is MeshInstance3D and child.visible:
				instances.append(child)
	merge_instances(self, instances)

func merge_instances(parent: Node, instances: Array[MeshInstance3D], release_sources: bool = false) -> void:
	var groups: Dictionary = {}
	for instance in instances:
		if instance.mesh == null or instance.mesh.get_surface_count() != 1: continue
		var mat: Material = instance.material_override if instance.material_override else instance.mesh.surface_get_material(0)
		if mat == null: continue
		var key := str(mat.get_instance_id()) + "_" + str(instance.cast_shadow)
		if not groups.has(key):
			var builder := SurfaceTool.new()
			builder.begin(Mesh.PRIMITIVE_TRIANGLES)
			groups[key] = {"builder": builder, "material": mat, "shadow": instance.cast_shadow}
		var transform: Transform3D = (parent as Node3D).global_transform.affine_inverse() * instance.global_transform
		groups[key].builder.append_from(instance.mesh, 0, transform)
		if release_sources:
			instance.get_parent().remove_child(instance)
			instance.queue_free()
		else: instance.hide()
	for group: Dictionary in groups.values():
		var combined := MeshInstance3D.new()
		combined.name = "StaticBatch"
		combined.mesh = group.builder.commit()
		combined.material_override = group.material
		combined.cast_shadow = group.shadow
		parent.add_child(combined)

func update_recovery() -> void:
	if mission.state != mission.State.VITORIA: return
	for mat in foliage_materials:
		var color: Color = mat.get_shader_parameter("leaf_color")
		create_tween().tween_method(func(value: Color): mat.set_shader_parameter("leaf_color", value), color, color.lerp(Color("4d995c"), 0.3), 1.2)

func _process(_delta: float) -> void:
	if mission.mission_id != "centro": return
	var intensity: float = world.storm_intensity
	var env: Environment = mission.get_node("WorldEnvironment").environment
	# O mundo também escreve a luz a cada tick; a apresentação mantém o acabamento contínuo.
	env.ambient_light_energy = lerpf(0.34,0.42,intensity)
	var sun: DirectionalLight3D = mission.get_node("Sun")
	sun.light_energy = lerpf(1.30,0.88,intensity)
	sun.light_color = Color("fff0d9").lerp(Color("cfdae2"),intensity)
	var rain_fraction := clampf((intensity-Config.STORM_RAIN_THRESHOLD)/(1.0-Config.STORM_RAIN_THRESHOLD),0,1)
	world.rain.multimesh.visible_instance_count = roundi(rain_fraction*[32,96,Config.STORM_RAIN_COUNT][settings.quality])
	if absf(intensity - storm_last) < 0.01: return
	storm_last = intensity
	env.fog_density = lerpf(0.0038, 0.0075, intensity)
	env.fog_light_color = Color("afc2c7").lerp(Color("8c9da8"), intensity)
	sky_material.sky_top_color = Color("3b93ce").lerp(Color("4d627b"),intensity)
	sky_material.sky_horizon_color = Color("c6ded6").lerp(Color("9cabb4"),intensity)
	sky_material.ground_horizon_color = sky_material.sky_horizon_color
	for mat in wet_materials:
		mat.set_shader_parameter("wetness", intensity)
