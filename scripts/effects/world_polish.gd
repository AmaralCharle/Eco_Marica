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

func _ready() -> void:
	mission = get_parent().get_parent()
	world = mission.get_node("World")
	settings = get_node("/root/GameAudio")
	name = "WorldPolish"
	extra = Node3D.new()
	extra.name = "HighDetail"
	add_child(extra)
	upgrade_existing()
	landscape()
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
			var trunk := CylinderMesh.new()
			trunk.height = size.y
			trunk.top_radius = size.x * 0.38
			trunk.bottom_radius = size.x * 0.6
			trunk.radial_segments = 8
			trunk.material = instance.mesh.material
			instance.mesh = trunk
		elif kind == "PalmLeaf":
			instance.mesh = palm_fronds()
			var mat := ShaderMaterial.new()
			mat.shader = LEAVES
			mat.set_shader_parameter("leaf_color", Color("438455"))
			instance.material_override = mat
		elif kind in ["SoftHill", "Restinga", "Cloud"]:
			var rounded := SphereMesh.new()
			rounded.radius = 0.5
			rounded.height = 1.0
			rounded.radial_segments = 12
			rounded.rings = 6
			rounded.material = instance.mesh.material
			instance.mesh = rounded
			instance.scale = size
			if kind == "Cloud":
				instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		elif kind in ["Lagoon", "Sea", "Stream", "Channel"]:
			instance.material_override = water
		elif kind.begins_with("Boundary"):
			# Mantém a barreira física, apresenta borda natural no lugar da parede lisa.
			instance.hide()
	if mission.mission_id != "centro":
		var environment: Environment = mission.get_node("WorldEnvironment").environment
		var sky := Sky.new()
		var sky_mat := ProceduralSkyMaterial.new()
		sky_mat.sky_top_color = Color("318dd0")
		sky_mat.sky_horizon_color = Color("b8dfe1")
		sky_mat.ground_horizon_color = Color("b8dfe1")
		sky_mat.ground_bottom_color = Color("739979")
		sky.sky_material = sky_mat
		environment.sky = sky
		environment.background_mode = Environment.BG_SKY
		environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
		environment.ambient_light_color = Color("c7dfe8")
		environment.ambient_light_energy = 0.48
	else:
		var environment: Environment = mission.get_node("WorldEnvironment").environment
		environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
		environment.ambient_light_color = Color("c3d5df")

func palm_fronds() -> ArrayMesh:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for side: float in [-1, 1]:
		var points: Array[Vector3] = [Vector3(0, 0, 0), Vector3(side * 1.2, 0.28, 0.32), Vector3(side * 2.1, -0.28, 0), Vector3(side * 1.2, 0.28, -0.32)]
		for index in [0, 1, 2, 0, 2, 3]:
			st.add_vertex(points[index])
	st.generate_normals()
	return st.commit()

func tree(pos: Vector3, seed_index: int = 0) -> void:
	cylinder(self, pos + Vector3(0, 1.25, 0), 2.5, 0.18, Color("85603f"))
	var colors: Array[Color] = [Color("3e9059"), Color("5caa61"), Color("39896a")]
	for i in 4:
		var angle := TAU * i / 4.0 + seed_index
		ellipsoid(self, pos + Vector3(cos(angle) * 0.65, 2.7 + (i % 2) * 0.4, sin(angle) * 0.65), Vector3(1.9, 1.7, 1.9), colors[(i + seed_index) % 3])

func garden(pos: Vector3, index: int) -> void:
	ellipsoid(self, pos + Vector3.UP * 0.22, Vector3(1.5, 0.5, 1.1), Color("4d9657"))
	for i in 5:
		var at := pos + Vector3(cos(i * 2.4) * 0.46, 0.46, sin(i * 2.4) * 0.36)
		cylinder(extra, at - Vector3.UP * 0.12, 0.24, 0.015, Color("427840"))
		ellipsoid(extra, at, Vector3(0.19, 0.13, 0.19), Color("f1c85d") if (i + index) % 2 == 0 else Color("d598bf"))

func lamp(pos: Vector3) -> void:
	cylinder(self, pos + Vector3.UP * 1.8, 3.6, 0.07, Color("34535b"))
	box(self, pos + Vector3(0.3, 3.6, 0), Vector3(0.7, 0.07, 0.1), Color("34535b"))
	ellipsoid(self, pos + Vector3(0.6, 3.53, 0), Vector3(0.45, 0.12, 0.3), Color("ffdd91"))

func landscape() -> void:
	var id: String = mission.mission_id
	for i in 8:
		var z: float = -16 + i * 4.5
		if id == "aracatiba":
			garden(Vector3(11.7, 0.05, z), i)
			if i % 2 == 0:
				tree(Vector3(12.5, 0, z), i)
				lamp(Vector3(4.2, 0, z))
		elif id == "itaipuacu":
			garden(Vector3(11, 0, z), i)
			ellipsoid(self, Vector3(16, 0, z), Vector3(8, 3, 8), Color("c9bc91"))
			ellipsoid(self, Vector3(-13, -0.02, z), Vector3(1.3, 0.6, 0.9), Color("8d9c92"))
		elif id == "centro":
			var side: float = -1 if i % 2 == 0 else 1
			var at := Vector3(side * 7.1, 0.12, z)
			tree(at, i)
			if i % 2 == 0:
				lamp(Vector3(side * 6.9, 0.12, z + 2.8))
		elif id == "ubatiba":
			for side: float in [-1, 1]:
				tree(Vector3(side * 14, 0, z), i)
				garden(Vector3(side * 11.7, 0, z + 1), i)
				ellipsoid(self, Vector3(-12, 0.18, z), Vector3(0.9, 0.6, 0.7), Color("9ba79b"))
		elif id == "ponta_negra":
			for side: float in [-1, 1]:
				garden(Vector3(-9 if side < 0 else 16.5, 0, z), i)
				ellipsoid(self, Vector3(side * 8.5, -0.08, z), Vector3(1, 0.6, 1.3), Color("819c92"))
	# Morros no horizonte, inteiramente fora da área jogável.
	for i in 7:
		ellipsoid(self, Vector3(-38 + i * 13, 0, -34 - (i % 2) * 6), Vector3(22, 8 + i % 3 * 3, 17), Color("6d967d").lerp(Color("91b4a1"), i * 0.07))
	if id == "centro":
		facades()
	if id == "aracatiba":
		pavement()
	if id == "ponta_negra":
		pier_details()
	build_grass()

func facades() -> void:
	for side: float in [-1, 1]:
		for i in 4:
			var z: float = -13 + i * 8
			var x: float = side * 8.42
			var awning := box(self, Vector3(x - side * 0.32, 2.3, z), Vector3(0.9, 0.15, 3.7), Color("ba6754") if i % 2 == 0 else Color("437c80"))
			awning.rotation.z = side * 0.12
			for j in 7:
				box(extra, Vector3(x - side * 0.65, 2.24, z - 1.5 + j * 0.5), Vector3(0.3, 0.18, 0.24), Color("f4d6a4"))
			for offset: float in [-1.5, 1.5]:
				box(self, Vector3(x, 2.7, z + offset), Vector3(0.07, 1.05, 0.05), Color("edddbf"))
				box(self, Vector3(x, 2.7, z + offset), Vector3(0.07, 0.05, 1.15), Color("edddbf"))
			box(self, Vector3(x, 0.2, z + 1.5), Vector3(0.4, 0.3, 1.4), Color("bd895c"))
			garden(Vector3(x - side * 0.1, 0.3, z + 1.5), i)

func pavement() -> void:
	for i in 36:
		box(extra, Vector3(0, 0.052, -17.5 + i), Vector3(6.9, 0.005, 0.018), Color("cdbd9b"))
	for x: float in [-2.3, 0, 2.3]:
		box(extra, Vector3(x, 0.052, 0), Vector3(0.018, 0.005, 35), Color("cdbd9b"))

func pier_details() -> void:
	for i in 12:
		box(self, Vector3(8, 0.004, 10.15 + i * 0.33), Vector3(3.95, 0.008, 0.026), Color("8f7959"))
	# Cantos distantes do ponto de desembarque; sem colisões novas.
	for z: float in [10.1, 13.9]:
		cylinder(self, Vector3(9.7, 0.3, z), 0.6, 0.11, Color("917454"))
	for i in 11:
		box(self, Vector3(-7.5 + i * 1.5, 4, -2.14), Vector3(0.08, 0.8, 0.08), Color("eee0b6"))
	box(self, Vector3(0, 4.4, -2.14), Vector3(17, 0.08, 0.1), Color("eee0b6"))

func build_grass() -> void:
	grass = MultiMeshInstance3D.new()
	grass.name = "BatchedGrass"
	var multi := MultiMesh.new()
	multi.transform_format = MultiMesh.TRANSFORM_3D
	var blade := PrismMesh.new()
	blade.size = Vector3(0.15, 0.35, 0.06)
	multi.mesh = blade
	multi.instance_count = 360
	var rng := RandomNumberGenerator.new()
	rng.seed = 12973
	for i in 360:
		var side: float = -1 if i % 2 == 0 else 1
		var x: float = side * rng.randf_range(10.8, 13.5)
		if mission.mission_id == "itaipuacu":
			x = rng.randf_range(9, 11.5)
		elif mission.mission_id == "ponta_negra":
			x = rng.randf_range(16, 17.5) if side > 0 else rng.randf_range(-12, -9)
		elif mission.mission_id == "centro":
			x = side * rng.randf_range(15, 16)
		var basis := Basis(Vector3.UP, rng.randf() * TAU).scaled(Vector3.ONE * rng.randf_range(0.65, 1.35))
		multi.set_instance_transform(i, Transform3D(basis, Vector3(x, 0.17, rng.randf_range(-18, 18))))
	grass.multimesh = multi
	var mat := ShaderMaterial.new()
	mat.shader = LEAVES
	mat.set_shader_parameter("leaf_color", Color("659a50"))
	grass.material_override = mat
	add_child(grass)

func apply_quality() -> void:
	var quality: int = settings.quality
	var sun: DirectionalLight3D = mission.get_node("Sun")
	sun.shadow_enabled = quality > 0
	sun.directional_shadow_max_distance = 45.0 if quality == 1 else 65.0
	sun.directional_shadow_mode = DirectionalLight3D.SHADOW_PARALLEL_2_SPLITS
	extra.visible = quality == 2
	grass.multimesh.visible_instance_count = [100, 240, 360][quality]
	get_viewport().msaa_3d = [Viewport.MSAA_DISABLED, Viewport.MSAA_2X, Viewport.MSAA_4X][quality]
