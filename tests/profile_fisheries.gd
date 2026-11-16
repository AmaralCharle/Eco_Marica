extends SceneTree
func _initialize() -> void: call_deferred("run")
func run() -> void:
	root.size = Vector2i(1280,720)
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	var args := OS.get_cmdline_user_args()
	var quality := int(args[0]) if not args.is_empty() else 2
	root.get_node("GameAudio").quality = quality
	var started := Time.get_ticks_usec()
	var level = load("res://scenes/levels/ponta_negra.tscn").instantiate()
	level.profile_path = "res://tests/artifacts/fisheries_benchmark_profile.json"
	level.progress_path = "res://tests/artifacts/fisheries_benchmark_progress.json"
	root.add_child(level)
	current_scene = level
	level.set_physics_process(false)
	level.set_state(level.State.JOGANDO)
	level.player.position = level.get_node("Boat").landing_position
	if not level.try_board(): quit(1); return
	var boat: Node3D = level.get_node("Boat")
	boat.set_physics_process(false)
	boat.speed = 3.0
	var load_ms := (Time.get_ticks_usec()-started)/1000.0
	for i in 40: await process_frame
	var times: Array[float] = []
	var previous := Time.get_ticks_usec()
	var total := 0.0
	var max_nets := 0
	for i in 1000:
		await process_frame
		var now := Time.get_ticks_usec()
		var ms := (now-previous)/1000.0
		times.append(ms)
		total += ms
		previous = now
		max_nets = maxi(max_nets,level.get_node("Fisheries").active_count())
	times.sort()
	var memory: Array = []
	OS.execute("powershell.exe",["-NoProfile","-Command","$p=Get-Process -Id %d; Write-Output $p.WorkingSet64" % OS.get_process_id()],memory)
	var data := {"quality":quality,"resolution":"1280x720","frames":times.size(),"fps_mean":1000.0/(total/times.size()),"p95_ms":times[roundi(times.size()*0.95)],"worst_ms":times.back(),"load_ms":load_ms,"max_active_nets":max_nets,"npc_count":4,"rss_mib":float(str(memory[0]).strip_edges())/1048576.0,"vram_mib":Performance.get_monitor(Performance.RENDER_VIDEO_MEM_USED)/1048576.0,"draw_calls":Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME),"scenario":"passageiro remando, quatro NPCs, ciclos reais; barco fixo para comparação; prazo da missão congelado"}
	var file := FileAccess.open("res://tests/artifacts/fisheries_performance_%d.json" % quality,FileAccess.WRITE)
	file.store_string(JSON.stringify(data,"\t"))
	file.close()
	print("PROFILE: ",JSON.stringify(data))
	await root.get_node("GameAudio").request_quit()
