extends SceneTree
const Profile = preload("res://scripts/core/player_profile.gd")
func _initialize() -> void:
	call_deferred("run")
func snap(id: String) -> void:
	for i in 10:
		await process_frame
	await RenderingServer.frame_post_draw
	var result := root.get_texture().get_image().save_png("res://tests/artifacts/ubatiba_" + id + ".png")
	print("CAPTURE: ", id, " ", error_string(result))
func run() -> void:
	var scene = load("res://scenes/levels/ubatiba.tscn").instantiate()
	scene.progress_path = "res://tests/artifacts/ubatiba_visual.json"
	var file := FileAccess.open(scene.progress_path, FileAccess.WRITE)
	file.store_string('{"version":2,"unlocked_level":4}')
	file.close()
	root.add_child(scene)
	current_scene = scene
	scene.set_physics_process(false)
	scene.show_instructions()
	await snap("instructions")
	scene.start_mission()
	await snap("playing")
	var first = get_nodes_in_group("planting_plots")[0]
	scene.player.position = first.position + Vector3(0, 0.05, 1.4)
	scene.inspect_point(first)
	await snap("inspection")
	for point in get_nodes_in_group("planting_plots"):
		scene.inspect_point(point)
		if point.apt:
			scene.choose_action("prepare")
			scene.choose_action("plant")
			if point.exposed:
				scene.choose_action("protect")
		else:
			scene.choose_action("preserve")
		scene.close_inspection()
	await snap("victory")
	quit()
