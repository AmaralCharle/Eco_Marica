extends SceneTree
func _initialize() -> void:
	call_deferred("capture")
func save_frame(title: String) -> void:
	for i in 5:
		await process_frame
	await RenderingServer.frame_post_draw
	var result := root.get_texture().get_image().save_png("res://tests/artifacts/recycling_%s.png" % title)
	if result != OK:
		push_error(error_string(result))
		quit(1)
	print("CAPTURE: ", title, " ", error_string(result))
func capture() -> void:
	if DisplayServer.get_name() == "headless":
		quit(1)
		return
	var scene = load("res://scenes/levels/foundation.tscn").instantiate()
	root.add_child(scene)
	current_scene = scene
	await save_frame("initial")
	var player = scene.get_node("Player")
	var session = scene.get_node("Session")
	var interaction = scene.get_node("Interaction")
	var waste = get_nodes_in_group("training_waste")[0]
	player.position = waste.position + Vector3(0, 0.05, 1)
	await physics_frame
	interaction.interact()
	await save_frame("carried")
	var bins := get_nodes_in_group("training_bins")
	player.position = bins[1].position + Vector3(1.2, 0.05, 0)
	await physics_frame
	interaction.interact()
	if session.errors != 1:
		push_error("Captura de erro não alcançou o estado esperado")
		quit(1)
		return
	await save_frame("wrong")
	player.position = bins[0].position + Vector3(1.2, 0.05, 0)
	await physics_frame
	interaction.interact()
	if session.correct != 1:
		push_error("Captura de acerto não alcançou o estado esperado")
		quit(1)
		return
	await save_frame("correct")
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	quit(0)
