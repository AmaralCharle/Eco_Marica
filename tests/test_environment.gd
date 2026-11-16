extends SceneTree
## Compara a física imediatamente antes/depois da camada decorativa.
var checks: int = 0
var failures: int = 0
var baseline: Dictionary = {}
func _initialize() -> void:
	node_added.connect(watch_node)
	call_deferred("run")
func watch_node(node: Node) -> void:
	var script: Script = node.get_script()
	if script and script.resource_path == "res://scripts/effects/world_polish.gd":
		var mission := node.get_parent().get_parent()
		baseline[mission.mission_id] = collision_signature(mission)
func collision_signature(mission: Node) -> Dictionary:
	var result: Dictionary = {}
	for node: CollisionShape3D in mission.find_children("*", "CollisionShape3D", true, false):
		var geometry: Array = [node.shape.get_class(), node.shape.get_rid()]
		if node.shape is BoxShape3D: geometry.append(node.shape.size)
		if node.shape is CapsuleShape3D: geometry.append_array([node.shape.radius, node.shape.height])
		result[String(mission.get_path_to(node))] = [node.global_transform, node.disabled, geometry]
	return result
func expect(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)
func run() -> void:
	for id: String in ["aracatiba", "itaipuacu", "centro", "ubatiba", "ponta_negra"]:
		var level = load("res://scenes/levels/%s.tscn" % id).instantiate()
		level.profile_path = "res://tests/artifacts/env_test_profile.json"
		level.progress_path = "res://tests/artifacts/env_test_progress.json"
		root.add_child(level)
		current_scene = level
		expect(baseline.has(id) and collision_signature(level) == baseline[id], id + ": dimensões, identidade e transforms das colisões preservados")
		var visual = level.get_node("Presentation/WorldPolish")
		expect(visual.find_children("*", "CollisionObject3D", true, false).is_empty(), id + ": decoração não acrescenta obstáculos físicos")
		expect(not visual.find_children("StaticBatch*", "MeshInstance3D", true, false).is_empty(), id + ": malhas estáticas agrupadas")
		var pref := root.get_node("GameAudio")
		pref.quality = 0
		visual.apply_quality()
		var count: int = visual.grass.multimesh.visible_instance_count
		pref.quality = 2
		visual.apply_quality()
		expect(visual.grass.multimesh.visible_instance_count > count and collision_signature(level) == baseline[id], id + ": qualidade amplia detalhe preservando física")
		if id == "aracatiba":
			var material: ShaderMaterial = visual.foliage_materials[0]
			var initial: Color = material.get_shader_parameter("leaf_color")
			level.set_state(level.State.VITORIA)
			await create_timer(0.5).timeout
			expect(material.get_shader_parameter("leaf_color") != initial, "Recuperação alcança os shaders de folhas usados na renderização")
		if id == "centro":
			level.get_node("World").advance_storm(0.9, 0)
			await process_frame
			await process_frame
			expect(visual.wet_materials[0].get_shader_parameter("wetness") > 0.85, "Tempestade atualiza umidade visual do asfalto")
		level.queue_free()
		await process_frame
	print("RESULT: %d verificações, %d falhas" % [checks, failures])
	quit(0 if failures == 0 else 1)
