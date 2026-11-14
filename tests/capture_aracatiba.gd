extends SceneTree
const Mission = preload("res://scripts/levels/aracatiba.gd")
var failures: int = 0
func _initialize() -> void:
	call_deferred("run")
func snap(title: String) -> void:
	for i in 5:
		await process_frame
	await RenderingServer.frame_post_draw
	var error := root.get_texture().get_image().save_png("res://tests/artifacts/aracatiba_%s.png" % title)
	if error != OK:
		failures += 1
	print("CAPTURE: ", title, " ", error_string(error))
func run() -> void:
	if DisplayServer.get_name() == "headless":
		quit(1)
		return
	var level = load("res://scenes/levels/aracatiba.tscn").instantiate()
	level.progress_path = "res://tests/artifacts/progress_visual.json"
	root.add_child(level)
	current_scene = level
	level.set_physics_process(false)
	await snap("menu")
	level.show_instructions()
	await snap("instructions")
	level.start_mission()
	# Ponto de vista da orla, sem alterar a câmera inicial do jogador.
	level.player.get_node("CameraPivot").rotation.y = 0.35
	await snap("playing")
	level.set_state(Mission.State.PAUSADO)
	await snap("paused")
	level.set_state(Mission.State.JOGANDO)
	level.remaining = 130
	for item in get_nodes_in_group("training_waste"):
		level.session.collect(item.waste_id)
		level.session.sort_into(item.material)
		item.hide()
	await snap("victory")
	level.get_node("MissionHUD").overlay.hide()
	level.get_node("MissionHUD").results_button.show()
	await snap("recovery")
	level.queue_free()
	await process_frame
	level = load("res://scenes/levels/aracatiba.tscn").instantiate()
	level.progress_path = "res://tests/artifacts/progress_visual.json"
	root.add_child(level)
	current_scene = level
	level.set_physics_process(false)
	level.show_instructions()
	level.start_mission()
	level.advance_time(300)
	await snap("defeat")
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	quit(0 if failures == 0 else 1)
