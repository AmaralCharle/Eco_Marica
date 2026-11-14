extends SceneTree
const Mission = preload("res://scripts/levels/aracatiba.gd")
const Profile = preload("res://scripts/core/player_profile.gd")
const Progress = preload("res://scripts/core/mission_progress.gd")
var failures: int = 0
func _initialize() -> void:
	call_deferred("run")
func snap(title: String) -> void:
	for i in 8:
		await process_frame
	await RenderingServer.frame_post_draw
	var error := root.get_texture().get_image().save_png("res://tests/artifacts/itaipuacu_%s.png" % title)
	if error != OK:
		failures += 1
	print("CAPTURE: ", title, " ", error_string(error))
func create_level():
	var level = load("res://scenes/levels/itaipuacu.tscn").instantiate()
	level.progress_path = "res://tests/artifacts/itaipuacu_visual_progress.json"
	level.profile_path = "res://tests/artifacts/itaipuacu_visual_profile.json"
	Progress.new(level.progress_path).unlock_next_level(2)
	Profile.new(level.profile_path).select_character("marina")
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
	level.player.get_node("CameraPivot").rotation.y = 0.45
	await snap("playing")
	level.advance_time(30)
	level.player.position = Vector3(-5, 0.05, 5)
	level.player.get_node("CameraPivot").rotation.y = 0.9
	await snap("risk")
	level.set_state(Mission.State.PAUSADO)
	await snap("paused")
	level.set_state(Mission.State.JOGANDO)
	level.session.collect("itaipuacu_002")
	level.session.sort_into("metal")
	await snap("wrong")
	level.session.sort_into("glass")
	for item in get_nodes_in_group("training_waste"):
		if level.session.records[item.waste_id]["state"] == RecyclingSession.WasteState.AVAILABLE:
			level.session.collect(item.waste_id)
			level.session.sort_into(item.material)
		item.hide()
	await snap("victory")
	level.get_node("MissionHUD").overlay.hide()
	level.get_node("MissionHUD").results_button.show()
	await snap("recovery")
	level.queue_free()
	await process_frame
	level = create_level()
	level.show_instructions()
	level.start_mission()
	for i in 5:
		var item = get_nodes_in_group("training_waste")[i]
		item.position.x = -11.499
		item.drift_speed = 1
		item.advance_drift(0.1, level.session)
	await snap("defeat")
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	quit(0 if failures == 0 else 1)
