extends SceneTree
func _initialize() -> void:
	call_deferred("run")
func snap(title: String) -> void:
	await RenderingServer.frame_post_draw
	var result := root.get_texture().get_image().save_png("res://tests/artifacts/assets_motion_"+title+".png")
	print("CAPTURE: ",title," ",error_string(result))
func run() -> void:
	root.size = Vector2i(1280,720)
	var scene = load("res://scenes/levels/aracatiba.tscn").instantiate()
	scene.profile_path = "res://tests/artifacts/assets_motion_profile.json"
	scene.progress_path = "res://tests/artifacts/assets_motion_progress.json"
	root.add_child(scene)
	current_scene = scene
	scene.set_physics_process(false)
	scene.set_state(scene.State.JOGANDO)
	await create_timer(0.3).timeout
	for id: String in ["lucas","marina","rafael","bia"]:
		scene.player.set_character(id)
		scene.player.position = Vector3(0,0.05,8)
		scene.player.set_physics_process(true)
		Input.action_press("move_forward")
		Input.action_press("sprint")
		await create_timer(0.2).timeout
		scene.player.set_physics_process(false)
		Input.action_release("move_forward")
		Input.action_release("sprint")
		await snap(id+"_run")
		scene.player.set_physics_process(true)
		scene.player.play_action("plant")
		await create_timer(0.17).timeout
		scene.player.set_physics_process(false)
		await snap(id+"_action")
	scene.queue_free()
	await process_frame
	scene = load("res://scenes/levels/ponta_negra.tscn").instantiate()
	scene.profile_path = "res://tests/artifacts/assets_motion_profile.json"
	scene.progress_path = "res://tests/artifacts/assets_motion_progress.json"
	root.add_child(scene)
	current_scene = scene
	scene.set_physics_process(false)
	scene.set_state(scene.State.JOGANDO)
	for id: String in ["lucas","marina","rafael","bia"]:
		scene.player.set_character(id)
		scene.player.position = scene.get_node("Boat").landing_position
		if not scene.try_board(): quit(1); return
		await create_timer(0.55).timeout
		await snap(id+"_boat")
		if not scene.try_disembark(): quit(1); return
		await create_timer(0.55).timeout
	scene.queue_free()
	await process_frame
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	await root.get_node("GameAudio").request_quit()
