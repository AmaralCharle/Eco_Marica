extends SceneTree
var samples: Array[Dictionary] = []
func _initialize() -> void: call_deferred("run")
func memory() -> Dictionary:
	var output: Array = []
	OS.execute("powershell.exe",["-NoProfile","-Command","$p=Get-Process -Id %d; Write-Output ($p.WorkingSet64.ToString()+','+$p.PrivateMemorySize64.ToString())" % OS.get_process_id()],output)
	var values := str(output[0]).strip_edges().split(",")
	return {"rss_mib":int(values[0])/1048576.0,"private_mib":int(values[1])/1048576.0,"nodes":Performance.get_monitor(Performance.OBJECT_NODE_COUNT),"orphans":Performance.get_monitor(Performance.OBJECT_ORPHAN_NODE_COUNT)}
func run() -> void:
	root.size = Vector2i(1280,720)
	root.get_node("GameAudio").quality = 1
	for cycle in 4:
		for id: String in ["aracatiba","itaipuacu","centro","ubatiba","ponta_negra"]:
			var level = load("res://scenes/levels/"+id+".tscn").instantiate()
			level.profile_path = "res://tests/artifacts/memory_profile.json"
			level.progress_path = "res://tests/artifacts/memory_progress.json"
			root.add_child(level)
			current_scene = level
			level.set_physics_process(false)
			level.set_state(level.State.JOGANDO)
			level.player.set_physics_process(false)
			for i in 20: await process_frame
			level.queue_free()
			for i in 12: await process_frame
		await create_timer(0.15).timeout
		var sample := memory()
		sample["cycle"] = cycle+1
		samples.append(sample)
		print("CYCLE: ",JSON.stringify(sample))
	var file := FileAccess.open("res://tests/artifacts/upgrade_memory_cycles.json",FileAccess.WRITE)
	file.store_string(JSON.stringify(samples,"\t"))
	file.close()
	root.get_node("GameAudio").request_quit()
