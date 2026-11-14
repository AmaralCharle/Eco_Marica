extends SceneTree
const Progress = preload("res://scripts/core/mission_progress.gd")
func _initialize() -> void:
	call_deferred("run")
func snap(title: String, frames: int = 12) -> void:
	for i in frames:
		await process_frame
	await RenderingServer.frame_post_draw
	print("CAPTURE: ", title, " ", error_string(root.get_texture().get_image().save_png("res://tests/artifacts/ponta_" + title + ".png")))
func run() -> void:
	var level = load("res://scenes/levels/ponta_negra.tscn").instantiate()
	level.progress_path = "res://tests/artifacts/ponta_visual.json"
	var file := FileAccess.open(level.progress_path, FileAccess.WRITE)
	file.store_string('{"version":2,"unlocked_level":5}')
	file.close()
	root.add_child(level)
	current_scene = level
	level.set_physics_process(false)
	level.show_instructions()
	await snap("instructions")
	level.start_mission()
	await snap("land")
	var boat = level.get_node("Boat")
	var items := get_nodes_in_group("floating_waste")
	for batch in 4:
		boat.position = boat.dock_position
		level.player.position = boat.landing_position
		level.try_board()
		boat.set_physics_process(false)
		if batch == 0:
			boat.position = Vector3(0, 0.05, 6)
			await snap("boat")
		for i in range(batch * 5, batch * 5 + 5):
			boat.position = items[i].position + Vector3(0, 0, 1.5)
			level.boat_interact()
		if batch == 0:
			await snap("full")
		boat.position = boat.dock_position
		boat.speed = 0
		level.try_disembark()
		if batch == 0:
			await snap("unload")
		while not level.session.carried_id.is_empty():
			level.session.sort_into(level.session.records[level.session.carried_id]["material"])
	await snap("victory")
	# Usar os resultados reais do teste completo de cinco fases na visualização final.
	level.progress = Progress.new("res://tests/artifacts/campaign_flow_progress.json")
	level.show_campaign_completion()
	await snap("finale", 150)
	quit()
