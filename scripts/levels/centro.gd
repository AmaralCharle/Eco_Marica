extends "res://scripts/levels/aracatiba.gd"

func spawn_objects() -> void:
	var waste_scene := preload("res://scenes/objects/waste.tscn")
	for i in Config.CENTRO_TARGET:
		var item := waste_scene.instantiate()
		item.waste_id = "centro_%02d" % i
		item.material = Config.MATERIAL_ORDER[i % 4]
		var x: float = [-5.0, 0.0, 5.0][i % 3]
		item.position = Vector3(x, 0.15 if absf(x) > 4 else 0.0, -13 + (i / 3) * 6)
		session.register_waste(item.waste_id, item.material)
		add_child(item)
	var bin_scene := preload("res://scenes/objects/recycling_bin.tscn")
	for station in 3:
		for i in 4:
			var bin := bin_scene.instantiate()
			bin.material = Config.MATERIAL_ORDER[i]
			bin.position = Vector3(-5.5 + i * 3.0, 0.15, [-16.0, 2.0, 16.0][station])
			add_child(bin)
	var drain_scene := preload("res://scenes/objects/storm_drain.tscn")
	var positions: Array[Vector3] = [Vector3(-3.2, 0, -10), Vector3(3.2, 0, -3), Vector3(-3.2, 0, 8)]
	for i in Config.CENTRO_DRAINS:
		var drain := drain_scene.instantiate()
		drain.drain_id = "centro_drain_%d" % i
		drain.position = positions[i]
		session.register_drain(drain.drain_id)
		add_child(drain)

func advance_time(delta: float) -> void:
	if state != State.JOGANDO:
		return
	remaining = maxf(0.0, remaining - maxf(delta, 0.0))
	$World.advance_storm(1.0 - remaining / Config.CENTRO_DURATION, delta)
	if remaining <= 0:
		finish(false, "O tempo acabou antes dos 15 destinos corretos e dos três bueiros limpos.")

func evaluate_objectives() -> void:
	if state != State.JOGANDO:
		return
	if remaining <= 0:
		finish(false, "O tempo acabou antes de concluir as tarefas.")
	elif session.correct >= Config.CENTRO_TARGET and session.drains_cleaned >= Config.CENTRO_DRAINS:
		finish(true, "15 destinos corretos e três bueiros desobstruídos na simulação.")
