extends SceneTree
## Captura e benchmark real de viewport. Sem --headless. Não grava saves de usuário.
var samples: Array[Dictionary] = []
func _initialize() -> void:
	call_deferred("run")
func snap(path: String) -> void:
	await create_timer(0.25).timeout
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(path)
func run() -> void:
	if DisplayServer.get_name() == "headless":
		quit(1)
		return
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	Engine.max_fps = 0
	var arguments := OS.get_cmdline_user_args()
	var prefix: String = arguments[0] if arguments.size() > 0 else "polish"
	var audio := root.get_node("GameAudio")
	audio.quality = 2
	for id: String in ["aracatiba", "itaipuacu", "centro", "ubatiba", "ponta_negra"]:
		var start := Time.get_ticks_usec()
		var level = load("res://scenes/levels/%s.tscn" % id).instantiate()
		level.profile_path = "res://tests/artifacts/polish_profile.json"
		level.progress_path = "res://tests/artifacts/polish_progress.json"
		root.add_child(level)
		current_scene = level
		level.set_physics_process(false)
		level.set_state(level.State.JOGANDO)
		level.player.set_physics_process(false)
		if id == "centro":
			level.get_node("World").advance_storm(0.9, 0)
		for i in 60:
			await process_frame
		var times: Array[float] = []
		var previous := Time.get_ticks_usec()
		for i in 180:
			await process_frame
			var now := Time.get_ticks_usec()
			times.append((now - previous) / 1000.0)
			previous = now
		await snap("res://tests/artifacts/%s_%s.png" % [prefix, id])
		var total := 0.0
		for value in times:
			total += value
		times.sort()
		var record := {"mission": id, "mean_fps": 1000.0 / (total / times.size()), "p95_ms": times[roundi((times.size() - 1) * 0.95)], "worst_ms": times.back(), "elapsed_ms": (Time.get_ticks_usec() - start) / 1000.0, "draw_calls": Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME), "objects": Performance.get_monitor(Performance.RENDER_TOTAL_OBJECTS_IN_FRAME)}
		samples.append(record)
		print("BENCHMARK: ", JSON.stringify(record))
		if id == "aracatiba":
			level.set_state(level.State.MENU)
			await process_frame
			await snap("res://tests/artifacts/%s_menu.png" % prefix)
			level.show_character_selection()
			await process_frame
			await snap("res://tests/artifacts/%s_characters.png" % prefix)
		level.queue_free()
		await process_frame
	var file := FileAccess.open("res://tests/artifacts/%s_benchmark.json" % prefix, FileAccess.WRITE)
	file.store_string(JSON.stringify({"renderer": RenderingServer.get_current_rendering_method(), "adapter": RenderingServer.get_video_adapter_name(), "quality": "high", "resolution": root.size, "samples": samples}, "\t"))
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	quit()
