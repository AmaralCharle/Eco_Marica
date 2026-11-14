extends SceneTree
func _initialize() -> void:
	call_deferred("run")
func snap(name: String) -> void:
	await create_timer(0.35).timeout
	await RenderingServer.frame_post_draw
	var error := root.get_texture().get_image().save_png("res://tests/artifacts/review_" + name + ".png")
	print("CAPTURE: ", name, " ", error_string(error))
func run() -> void:
	var scene = load("res://scenes/levels/aracatiba.tscn").instantiate()
	scene.profile_path = "res://tests/artifacts/polish_profile.json"
	scene.progress_path = "res://tests/artifacts/campaign_flow_progress.json"
	root.add_child(scene)
	current_scene = scene
	scene.set_physics_process(false)
	await snap("completed_menu")
	var hud = scene.get_node("MissionHUD")
	hud.open_settings()
	await snap("settings")
	for child in hud.get_children():
		if child is CanvasLayer:
			child.queue_free()
	await process_frame
	scene.set_state(scene.State.VITORIA)
	scene.result_reason = "Estado de revisão visual; não é resultado de jogador."
	scene.state_changed.emit()
	await snap("victory")
	scene.set_state(scene.State.DERROTA)
	await snap("defeat")
	scene.queue_free()
	await process_frame
	scene = load("res://scenes/levels/centro.tscn").instantiate()
	scene.profile_path = "res://tests/artifacts/polish_profile.json"
	scene.progress_path = "res://tests/artifacts/campaign_flow_progress.json"
	root.add_child(scene)
	current_scene = scene
	scene.set_physics_process(false)
	scene.set_state(scene.State.JOGANDO)
	scene.player.set_physics_process(false)
	scene.get_node("World").advance_storm(0.9, 0)
	await snap("storm")
	scene.set_state(scene.State.PAUSADO)
	await snap("pause")
	scene.queue_free()
	await process_frame
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	quit()
