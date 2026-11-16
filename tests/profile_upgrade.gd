extends SceneTree
## Benchmark controlado: apenas saves de teste; mede memória do processo via Windows.
var samples: Array[Dictionary] = []
func _initialize() -> void: call_deferred("run")
func run() -> void:
	root.size = Vector2i(1280,720)
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	root.get_node("GameAudio").quality = 2
	var args := OS.get_cmdline_user_args()
	var prefix: String = args[0] if args.size() else "upgrade_baseline"
	for id: String in ["aracatiba","itaipuacu","centro","ubatiba","ponta_negra"]:
		var started := Time.get_ticks_usec()
		var level = load("res://scenes/levels/"+id+".tscn").instantiate()
		level.profile_path = "res://tests/artifacts/upgrade_profile.json"
		level.progress_path = "res://tests/artifacts/upgrade_progress.json"
		root.add_child(level)
		current_scene = level
		level.set_physics_process(false)
		level.set_state(level.State.JOGANDO)
		level.player.set_physics_process(false)
		if id == "centro": level.get_node("World").advance_storm(0.9,0)
		var load_ms := (Time.get_ticks_usec()-started)/1000.0
		for i in 40: await process_frame
		var times: Array[float] = []
		var previous := Time.get_ticks_usec()
		for i in 150:
			await process_frame
			var now := Time.get_ticks_usec()
			times.append((now-previous)/1000.0)
			previous = now
		var total := 0.0
		for value in times: total += value
		times.sort()
		var materials: Dictionary = {}
		for instance: MeshInstance3D in level.find_children("*","MeshInstance3D",true,false):
			if instance.material_override: materials[instance.material_override.get_instance_id()] = true
			if instance.mesh:
				for surface in instance.mesh.get_surface_count():
					var mat := instance.mesh.surface_get_material(surface)
					if mat: materials[mat.get_instance_id()] = true
		var output: Array = []
		OS.execute("powershell.exe",["-NoProfile","-Command","$p=Get-Process -Id %d; Write-Output ($p.WorkingSet64.ToString()+','+$p.PrivateMemorySize64.ToString())" % OS.get_process_id()],output)
		var memory: PackedStringArray = str(output[0]).strip_edges().split(",") if not output.is_empty() else PackedStringArray(["0","0"])
		var row := {"phase":id,"fps":1000.0/(total/times.size()),"p95_ms":times[roundi((times.size()-1)*0.95)],"worst_ms":times.back(),"load_ms":load_ms,"rss_mib":int(memory[0])/1048576.0,"private_mib":int(memory[1])/1048576.0,"vram_mib":Performance.get_monitor(Performance.RENDER_VIDEO_MEM_USED)/1048576.0,"draw_calls":Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME),"primitives":Performance.get_monitor(Performance.RENDER_TOTAL_PRIMITIVES_IN_FRAME),"materials":materials.size(),"lights":level.find_children("*","Light3D",true,false).size(),"collision_shapes":level.find_children("*","CollisionShape3D",true,false).size(),"gpu_particles":level.find_children("*","GPUParticles3D",true,false).size(),"objects":Performance.get_monitor(Performance.RENDER_TOTAL_OBJECTS_IN_FRAME)}
		samples.append(row)
		print("SAMPLE: ",JSON.stringify(row))
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://tests/artifacts/"+prefix+"_"+id+".png")
		level.queue_free()
		for i in 5: await process_frame
	var file := FileAccess.open("res://tests/artifacts/"+prefix+".json",FileAccess.WRITE)
	file.store_string(JSON.stringify({"renderer":RenderingServer.get_current_rendering_method(),"gpu":RenderingServer.get_video_adapter_name(),"resolution":"1280x720","quality":2,"samples":samples},"\t"))
	file.close()
	quit()
