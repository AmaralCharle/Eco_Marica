extends SceneTree
func _initialize() -> void: call_deferred("run")
func run() -> void:
	root.size = Vector2i(1280,720)
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	root.get_node("GameAudio").quality = 2
	var level = load("res://scenes/levels/centro.tscn").instantiate()
	level.profile_path = "res://tests/artifacts/assets_profile.json"
	level.progress_path = "res://tests/artifacts/assets_progress.json"
	root.add_child(level)
	current_scene = level
	level.set_physics_process(false)
	level.set_state(level.State.JOGANDO)
	level.player.set_physics_process(false)
	level.get_node("World").advance_storm(0.9,0)
	for mode in 4:
		root.msaa_3d = [Viewport.MSAA_8X,Viewport.MSAA_2X,Viewport.MSAA_DISABLED,Viewport.MSAA_2X][mode]
		if mode == 3:
			for draw: MultiMeshInstance3D in level.get_node("Presentation/WorldPolish/ImportedArt").find_children("*","MultiMeshInstance3D",true,false): draw.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		for i in 40: await process_frame
		var start := Time.get_ticks_usec()
		for i in 150: await process_frame
		print("PILOT mode=%d fps=%.2f" % [mode,150000000.0/(Time.get_ticks_usec()-start)])
	await root.get_node("GameAudio").request_quit()
