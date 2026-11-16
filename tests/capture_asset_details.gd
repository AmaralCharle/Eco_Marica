extends SceneTree
func _initialize() -> void:
	call_deferred("run")
func snap(title: String) -> void:
	await create_timer(0.35).timeout
	await RenderingServer.frame_post_draw
	print("CAPTURE: ",title," ",error_string(root.get_texture().get_image().save_png("res://tests/artifacts/assets_detail_"+title+".png")))
func run() -> void:
	root.size = Vector2i(1280,720)
	root.get_node("GameAudio").quality = 2
	for id: String in ["centro","ubatiba","ponta_negra"]:
		var scene = load("res://scenes/levels/"+id+".tscn").instantiate()
		scene.profile_path = "res://tests/artifacts/assets_detail_profile.json"
		scene.progress_path = "res://tests/artifacts/assets_detail_progress.json"
		root.add_child(scene)
		current_scene = scene
		scene.set_physics_process(false)
		scene.set_state(scene.State.JOGANDO)
		scene.player.set_physics_process(false)
		if id == "centro":
			await snap("centro_clear")
			scene.get_node("World").advance_storm(0.9,0)
			await snap("centro_storm")
			var camera := Camera3D.new()
			scene.add_child(camera)
			camera.position = Vector3(-3.5,2.5,0)
			camera.look_at(Vector3(-8,1.6,-5))
			camera.current = true
			await snap("cafe")
		elif id == "ubatiba":
			var camera := Camera3D.new()
			scene.add_child(camera)
			camera.position = Vector3(-7,3.0,12)
			camera.look_at(Vector3(-13,0.3,0))
			camera.current = true
			await snap("stream")
			camera.position = Vector3(7.4,2.1,13)
			camera.look_at(Vector3(10,0.6,10))
			await snap("field_cart")
		else:
			var boat = scene.get_node("Boat")
			scene.player.position = boat.landing_position
			if not scene.try_board(): quit(1); return
			await create_timer(0.5).timeout
			boat.set_physics_process(false)
			await snap("canal_boat")
		scene.queue_free()
		await process_frame
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	await root.get_node("GameAudio").request_quit()
