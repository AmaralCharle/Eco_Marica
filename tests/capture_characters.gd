extends SceneTree
const Profile = preload("res://scripts/core/player_profile.gd")
const Catalog = preload("res://scripts/core/character_catalog.gd")
var failures: int = 0
func _initialize() -> void:
	call_deferred("run")
func snap(title: String) -> void:
	for i in 12:
		await process_frame
	await RenderingServer.frame_post_draw
	var error := root.get_texture().get_image().save_png("res://tests/artifacts/characters_%s.png" % title)
	if error != OK:
		failures += 1
	print("CAPTURE: ", title, " ", error_string(error))
func run() -> void:
	if DisplayServer.get_name() == "headless":
		quit(1)
		return
	var path := "res://tests/artifacts/characters_visual_profile.json"
	Profile.new(path).select_character("lucas")
	var level = load("res://scenes/levels/aracatiba.tscn").instantiate()
	level.profile_path = path
	level.progress_path = "res://tests/artifacts/characters_visual_progress.json"
	root.add_child(level)
	current_scene = level
	level.set_physics_process(false)
	await snap("menu")
	level.show_character_selection()
	var selector = level.get_node("MissionHUD").selector
	for id in Catalog.IDS:
		selector.choose(id)
		await snap(id)
	selector.confirm_button.pressed.emit()
	level.show_instructions()
	level.start_mission()
	level.player.visual.rotation.y = PI + 0.25
	await snap("bia_playing")
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	quit(0 if failures == 0 else 1)
