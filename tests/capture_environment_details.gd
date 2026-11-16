extends SceneTree
## Estados controlados para inspeção visual; não são uma partida humana.
func _initialize() -> void:
	call_deferred("run")
func snap(name: String) -> void:
	await create_timer(0.65).timeout
	await RenderingServer.frame_post_draw
	print("CAPTURE: ", name, " ", error_string(root.get_texture().get_image().save_png("res://tests/artifacts/env_detail_" + name + ".png")))
func run() -> void:
	var audio := root.get_node("GameAudio")
	audio.quality = 2
	for id: String in ["centro", "ubatiba", "ponta_negra"]:
		var scene = load("res://scenes/levels/%s.tscn" % id).instantiate()
		scene.profile_path = "res://tests/artifacts/env_review_profile.json"
		scene.progress_path = "res://tests/artifacts/env_review_progress.json"
		root.add_child(scene)
		current_scene = scene
		scene.set_physics_process(false)
		scene.set_state(scene.State.JOGANDO)
		scene.player.set_physics_process(false)
		if id == "centro":
			var drain = get_nodes_in_group("mission_drains")[0]
			var camera := Camera3D.new()
			scene.add_child(camera)
			camera.global_position = drain.global_position + Vector3(1.7, 2.1, 2.2)
			camera.look_at(drain.global_position)
			camera.current = true
			scene.get_node("World").advance_storm(0.9, 0)
			await snap("drain_before")
			scene.session.clean_drain(drain.drain_id)
			drain.show_cleaned()
			await snap("drain_clean")
		elif id == "ubatiba":
			var point = get_nodes_in_group("planting_plots")[0]
			var camera := Camera3D.new()
			scene.add_child(camera)
			camera.global_position = point.global_position + Vector3(1.4, 1.9, 2.6)
			camera.look_at(point.global_position + Vector3.UP * 0.4)
			camera.current = true
			await snap("soil_before")
			scene.session.inspect(point.plot_id)
			for action: String in ["prepare", "plant", "protect"]:
				scene.session.act(point.plot_id, action)
			point.update_plot(scene.session.plots[point.plot_id])
			await snap("soil_restored")
		else:
			var boat = scene.get_node("Boat")
			scene.player.position = boat.landing_position
			boat.embark(scene.player)
			boat.set_physics_process(false)
			boat.position = Vector3(0, 0.05, 6)
			await snap("boat")
			boat.speed = 3.0
			await snap("wake")
		scene.set_state(scene.State.PAUSADO)
		scene.queue_free()
		await process_frame
	quit()
