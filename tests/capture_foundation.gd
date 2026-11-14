extends SceneTree
func _initialize() -> void:
	call_deferred("capture")

func capture() -> void:
	if DisplayServer.get_name() == "headless":
		push_error("Captura visual exige renderizador gráfico, execute sem --headless.")
		quit(1)
		return
	var scene = load("res://scenes/levels/foundation.tscn").instantiate()
	root.add_child(scene)
	current_scene = scene
	for i in 15:
		await process_frame
	await RenderingServer.frame_post_draw
	var error := root.get_texture().get_image().save_png("res://tests/artifacts/foundation.png")
	print("CAPTURE: ", error_string(error))
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	quit(0 if error == OK else 1)
