extends SceneTree
const Profile = preload("res://scripts/core/player_profile.gd")
const Progress = preload("res://scripts/core/mission_progress.gd")
var failures: int = 0
func _initialize() -> void:
	call_deferred("run")
func snap(title: String) -> void:
	for i in 8:
		await process_frame
	await RenderingServer.frame_post_draw
	var error := root.get_texture().get_image().save_png("res://tests/artifacts/centro_%s.png" % title)
	if error != OK:
		failures += 1
	print("CAPTURE: ", title, " ", error_string(error))
func create_level():
	var level = load("res://scenes/levels/centro.tscn").instantiate()
	level.progress_path = "res://tests/artifacts/centro_visual_progress.json"
	level.profile_path = "res://tests/artifacts/centro_visual_profile.json"
	Progress.new(level.progress_path).unlock_next_level(3)
	Profile.new(level.profile_path).select_character("rafael")
	root.add_child(level)
	current_scene = level
	level.set_physics_process(false)
	return level
func run() -> void:
	if DisplayServer.get_name() == "headless":
		quit(1)
		return
	var level = create_level()
	await snap("menu")
	level.show_instructions()
	await snap("instructions")
	level.start_mission()
	level.player.get_node("CameraPivot").rotation.y = 0.2
	await snap("playing")
	level.advance_time(100)
	await snap("rain")
	var drain = get_nodes_in_group("mission_drains")[2]
	level.player.position = drain.position + Vector3(0, 0.05, 1)
	await physics_frame
	await snap("drain_before")
	level.get_node("Interaction").interact()
	await snap("drain_after")
	level.set_state(level.State.PAUSADO)
	await snap("paused")
	level.set_state(level.State.JOGANDO)
	for item in get_nodes_in_group("training_waste"):
		level.session.collect(item.waste_id)
		level.session.sort_into(item.material)
		item.hide()
	for id in level.session.drains.keys():
		level.session.clean_drain(id)
	for item in get_nodes_in_group("mission_drains"):
		item.show_cleaned()
	await snap("victory")
	level.show_campaign_completion()
	await snap("finalized")
	level.queue_free()
	await process_frame
	level = create_level()
	level.show_instructions()
	level.start_mission()
	level.advance_time(180)
	await snap("defeat")
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	quit(0 if failures == 0 else 1)
