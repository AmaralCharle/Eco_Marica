extends SceneTree
var checks := 0
var failures := 0
func _initialize() -> void:
	call_deferred("run")
func check(ok: bool, title: String) -> void:
	checks += 1
	if not ok: failures += 1; push_error(title)
func frames() -> void:
	for i in 4: await process_frame
func run() -> void:
	for id: String in ["aracatiba","itaipuacu","centro","ubatiba","ponta_negra"]:
		var level = load("res://scenes/levels/"+id+".tscn").instantiate()
		level.profile_path = "res://tests/artifacts/art_test_profile.json"
		level.progress_path = "res://tests/artifacts/art_test_progress.json"
		root.add_child(level)
		current_scene = level
		level.set_physics_process(false)
		await frames()
		var art = level.get_node("Presentation/WorldPolish")
		var manifest: Dictionary = art.get_meta("reference_art")
		var clear := true
		for pos: Vector3 in manifest.clusters:
			for point: Vector3 in manifest.clearances:
				if Vector2(pos.x-point.x,pos.z-point.z).length() < 2.2: clear = false
		check(clear,"Vegetação nova preserva distância aos objetivos: "+id)
		check(not manifest.clusters.is_empty(),"Camada de vegetação presente: "+id)
		check(level.get_node("WorldEnvironment").environment.background_mode == Environment.BG_SKY,"Céu coerente: "+id)
		check(art.find_children("*","CollisionObject3D",true,false).is_empty(),"Arte permanece sem corpos físicos: "+id)
		check(art.grass_capacity >= 360 and art.grass.multimesh.use_colors,"Vegetação agrupada com variação: "+id)
		for bin in get_nodes_in_group("training_bins"):
			if level.is_ancestor_of(bin):
				check(bin.label.text == bin.Config.MATERIAL_NAMES[bin.material] and bin.label.visibility_range_end >= 18,"Identificação do coletor preservada: "+id)
		if id == "centro":
			var sky: Color = art.sky_material.sky_top_color
			level.get_node("World").advance_storm(0.9,0)
			await frames()
			check(art.sky_material.sky_top_color != sky and level.get_node("World").storm_intensity == 0.9,"Atmosfera acompanha a intensidade original da tempestade")
			check(art.wet_materials[0].get_shader_parameter("wetness") > 0.85,"Asfalto continua acompanhando chuva")
			level.get_node("World").advance_storm(0.901,0)
			art._process(0)
			check(is_equal_approx(level.get_node("Sun").light_energy,lerpf(1.30,0.88,0.901)),"Luz não alterna com o padrão antigo entre atualizações pequenas da tempestade")
		if id == "ubatiba":
			var ground: MeshInstance3D
			for node in level.get_node("World").get_children():
				if node.get_meta("kind","") == "Ground": ground = node.get_child(0)
			check(ground.mesh is ArrayMesh,"Pele do solo abre riacho mantendo o corpo original")
			check(level.get_node("Session").plots.size() == 12,"Doze pontos de plantio preservados")
		if id in ["ponta_negra","ubatiba"]:
			for node in level.get_node("World").get_children():
				if node.get_meta("kind","") in ["Stream","Channel"]:
					var water: MeshInstance3D = node.get_child(0)
					check(water.mesh is PlaneMesh and is_equal_approx(water.global_position.y,-0.035),"Água fica abaixo da margem: "+id)
		level.queue_free()
		await process_frame
	print("RESULT: %d verificações, %d falhas" % [checks,failures])
	quit(0 if failures == 0 else 1)
