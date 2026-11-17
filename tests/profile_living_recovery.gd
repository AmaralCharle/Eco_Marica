extends SceneTree
var results: Array[Dictionary] = []
func _initialize() -> void: call_deferred("run")
func run() -> void:
	root.get_node("GameAudio").quality = 2
	for id: String in ["aracatiba","itaipuacu","centro","ubatiba","ponta_negra"]:
		var level = load("res://scenes/levels/"+id+".tscn").instantiate()
		level.profile_path = "user://living_benchmark_profile.json"
		level.progress_path = "user://living_benchmark_progress.json"
		root.add_child(level)
		current_scene = level
		level.set_physics_process(false)
		level.set_state(level.State.JOGANDO)
		level.player.set_physics_process(false)
		# Estado sintético de apresentação: não é uma partida ou resultado educativo.
		for key in level.session.records:
			level.session.records[key].state = level.session.WasteState.SORTED
		level.session.correct = level.definition().target
		if id == "centro":
			for key in level.session.drains: level.session.drains[key] = true
			level.session.drains_cleaned = 3
		if id == "ubatiba":
			level.session.assessed = 12
			level.session.planted = 8
			level.session.protected_soil = 3
			for point in get_nodes_in_group("planting_plots"):
				var data: Dictionary = level.session.plots[point.plot_id]
				data.planted = point.apt
				data.protected = point.exposed
				data.preserved = not point.apt
				point.update_plot(data)
		level.finish(true,"Estado sintético para benchmark visual")
		var recovery: Node3D = level.get_node("Presentation/EnvironmentalRecovery")
		for i in 90: await process_frame
		recovery.stop_cinematic()
		recovery.played = false
		recovery.start_cinematic()
		var times: Array[float] = []
		var previous := Time.get_ticks_usec()
		while recovery.active:
			await process_frame
			var now := Time.get_ticks_usec()
			times.append((now-previous)/1000.0)
			previous = now
		var total := 0.0
		for ms in times: total += ms
		times.sort()
		var result := {"phase":id,"quality":2,"window":DisplayServer.window_get_size(),"frames":times.size(),"fps_mean":1000.0/(total/times.size()),"p95_ms":times[mini(times.size()-1,int(times.size()*0.95))],"worst_ms":times.back(),"vram_mib":Performance.get_monitor(Performance.RENDER_VIDEO_MEM_USED)/1048576.0,"draw_calls":Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME)}
		results.append(result)
		print("PROFILE: ",JSON.stringify(result))
		level.queue_free()
		for i in 8: await process_frame
	var file := FileAccess.open("res://tests/artifacts/living_performance.json",FileAccess.WRITE)
	file.store_string(JSON.stringify({"scenario":"Tomadas de recuperação em estados sintéticos, após 90 frames de aquecimento; execução isolada. Não representa partida humana nem FPS mínimo sustentado.","results":results},"\t"))
	file.close()
	await root.get_node("GameAudio").request_quit()
