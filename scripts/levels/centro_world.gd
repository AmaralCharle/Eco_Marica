extends "res://scripts/levels/aracatiba_world.gd"
const Config = preload("res://scripts/core/game_config.gd")
var storm_intensity: float = 0.0
var rain: MultiMeshInstance3D
var drops: Array[Vector3] = []
var cloud_material: StandardMaterial3D

func _ready() -> void:
	box("Ground", Vector3(0, -0.25, 0), Vector3(34, 0.5, 40), Color("a2af91"), true)
	box("Street", Vector3(0, 0.015, 0), Vector3(8, 0.03, 38), Color("69777c"))
	for side: float in [-1.0, 1.0]:
		box("Sidewalk", Vector3(side * 5.5, 0.06, 0), Vector3(3, 0.12, 38), Color("c9c6b8"), true)
		box("Boundary", Vector3(side * 16.5, 0.5, 0), Vector3(0.3, 1, 40), Color("718c79"), true)
		for i in 4:
			var z: float = -13 + i * 8.0
			building(Vector3(side * 11.5, 0, z), i, side)
	# Rampas atravessam o meio-fio; o controlador não precisa saltar um degrau.
	for side: float in [-1.0, 1.0]:
		for z: float in [-16.0, 2.0, 16.0]:
			var ramp := box("AccessRamp", Vector3(side * 3.5, 0.02, z), Vector3(1.6, 0.08, 3.2), Color("c9c6b8"), true)
			ramp.rotation.z = side * atan(0.12 / 1.6)
	for z: float in [-19.5, 19.5]:
		box("Boundary", Vector3(0, 0.5, z), Vector3(33, 1, 0.3), Color("718c79"), true)
	for z: float in [-15.0, -10.0, -5.0, 0.0, 5.0, 10.0, 15.0]:
		box("RoadMark", Vector3(0, 0.04, z), Vector3(0.12, 0.02, 1.5), Color("e2ca88"))
	for x: float in [-3.0, -2.0, -1.0, 0.0, 1.0, 2.0, 3.0]:
		box("Crosswalk", Vector3(x, 0.04, 4), Vector3(0.6, 0.02, 2), Color("e7e2cf"))
	label("CENTRO • ALERTA DE TEMPESTADE", Vector3(0, 3.5, -18), 43)
	label("Cuide dos resíduos e da drenagem • Simulação", Vector3(0, 2.9, -18), 27)
	cloud_material = StandardMaterial3D.new()
	cloud_material.albedo_color = Color("c5d0d3")
	for i in 8:
		var cloud := box("Cloud", Vector3(-10 + (i % 3) * 9, 9 + (i % 2), -16 + i * 4.5), Vector3(8, 0.8, 4), Color.WHITE)
		cloud.get_child(0).mesh.material = cloud_material
	build_rain()
	recovery = Node3D.new()
	recovery.name = "Recovery"
	add_child(recovery)
	for side: float in [-1.0, 1.0]:
		var plant := box("RecoveryPlanter", Vector3(side * 7.7, 0.3, 7), Vector3(0.8, 0.6, 2), Color("489171"))
		plant.reparent(recovery)
	recovery.hide()
	advance_storm(0.0, 0.0)

func building(pos: Vector3, index: int, side: float) -> void:
	var colors: Array[Color] = [Color("d4b190"), Color("9dbabd"), Color("bca6c5"), Color("c9bd8f")]
	box("Building", pos + Vector3(0, 2.1, 0), Vector3(6, 4.2, 5.5), colors[index], true)
	box("Roof", pos + Vector3(0, 4.3, 0), Vector3(6.4, 0.3, 5.9), Color("8d756c"))
	var front_x: float = pos.x - side * 3.04
	for z: float in [-1.5, 1.5]:
		box("Window", Vector3(front_x, 2.7, pos.z + z), Vector3(0.08, 1.1, 1.1), Color("547a8b"))
	box("Door", Vector3(front_x, 1, pos.z), Vector3(0.1, 2, 1), Color("6e807e"))
	var sign := Label3D.new()
	sign.text = ["MERCEARIA", "CAFÉ", "LIVRARIA", "CASA"][index]
	sign.position = Vector3(front_x - side * 0.1, 3.8, pos.z)
	sign.rotation.y = -side * PI / 2
	sign.font_size = 40
	sign.pixel_size = 0.007
	add_child(sign)

func build_rain() -> void:
	rain = MultiMeshInstance3D.new()
	rain.name = "Rain"
	var mesh := BoxMesh.new()
	mesh.size = Vector3(0.022, 0.38, 0.022)
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color("91b4c8")
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mesh.material = mat
	var multi := MultiMesh.new()
	multi.transform_format = MultiMesh.TRANSFORM_3D
	multi.mesh = mesh
	multi.instance_count = Config.STORM_RAIN_COUNT
	var random := RandomNumberGenerator.new()
	random.seed = 6072
	for i in Config.STORM_RAIN_COUNT:
		var pos := Vector3(random.randf_range(-7.8, 7.8), random.randf_range(0.5, 7.5), random.randf_range(-18, 18))
		drops.append(pos)
		multi.set_instance_transform(i, Transform3D(Basis.IDENTITY, pos))
	rain.multimesh = multi
	add_child(rain)
	rain.hide()

func advance_storm(intensity: float, delta: float) -> void:
	storm_intensity = clampf(intensity, 0.0, 1.0)
	var environment: Environment = get_parent().get_node("WorldEnvironment").environment
	environment.background_color = Color("a3c5d2").lerp(Color("687b8d"), storm_intensity)
	environment.ambient_light_energy = lerpf(0.65, 0.55, storm_intensity)
	get_parent().get_node("Sun").light_energy = lerpf(1.1, 0.65, storm_intensity)
	cloud_material.albedo_color = Color("c5d0d3").lerp(Color("70808d"), storm_intensity)
	rain.visible = storm_intensity >= Config.STORM_RAIN_THRESHOLD
	rain.multimesh.visible_instance_count = maxi(0, roundi((storm_intensity - Config.STORM_RAIN_THRESHOLD) / (1.0 - Config.STORM_RAIN_THRESHOLD) * Config.STORM_RAIN_COUNT))
	for i in drops.size():
		drops[i].y -= maxf(delta, 0.0) * 8.0
		drops[i].y = fposmod(drops[i].y, 7.5)
		rain.multimesh.set_instance_transform(i, Transform3D(Basis.IDENTITY, drops[i]))

func weather_text() -> String:
	if storm_intensity >= 0.75:
		return "Chuva intensa se aproxima"
	if storm_intensity >= Config.STORM_RAIN_THRESHOLD:
		return "Chuva chegando"
	return "Nuvens se aproximam"

func recover_area() -> void:
	recovery.show()
	for node in get_children():
		if node is Label3D and node.text == "CENTRO • ALERTA DE TEMPESTADE":
			node.text = "TAREFAS CONCLUÍDAS • Siga os alertas oficiais"
