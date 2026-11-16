extends SceneTree
func _initialize() -> void: call_deferred("run")
func snap(title: String) -> void:
	for i in 24: await process_frame
	await RenderingServer.frame_post_draw
	print("CAPTURE: ",title," ",error_string(root.get_texture().get_image().save_png("res://tests/artifacts/fisheries_"+title+".png")))
func run() -> void:
	root.size = Vector2i(1280,720)
	root.get_node("GameAudio").quality = 2
	var level = load("res://scenes/levels/ponta_negra.tscn").instantiate()
	level.profile_path = "res://tests/artifacts/fisheries_capture_profile.json"
	level.progress_path = "res://tests/artifacts/fisheries_capture_progress.json"
	root.add_child(level)
	current_scene = level
	level.set_physics_process(false)
	level.set_state(level.State.JOGANDO)
	level.player.set_physics_process(false)
	level.get_node("Interaction").set_physics_process(false)
	var system: Node3D = level.get_node("Fisheries")
	system.set_physics_process(false)
	var camera := Camera3D.new()
	level.add_child(camera)
	camera.current = true
	for i in 4:
		var npc: Node3D = system.fishermen[i]
		npc.show_dialog(npc.greeting)
		camera.position = npc.position+Vector3(3,2.0,4.8)
		camera.look_at(npc.position+Vector3(0,1.8,0))
		system.update_focus(camera,camera.unproject_position(npc.position+Vector3.UP*1.05))
		await snap("greeting_%d" % i)
		npc.greeting_left = 0
		npc.warning_left = 0
		npc.refresh_dialog()
	var npc: Node3D = system.fishermen[0]
	npc.enter(npc.Phase.PREPARE)
	camera.position = Vector3(2,4.5,11)
	camera.look_at(Vector3(6,1.5,5))
	await snap("prepare")
	npc.enter(npc.Phase.OPEN)
	npc.update_net()
	await snap("net_open")
	npc.enter(npc.Phase.WAIT)
	npc.update_net()
	var boat: Node3D = level.get_node("Boat")
	level.player.position = boat.landing_position
	for id: String in ["lucas","marina","rafael","bia"]:
		level.player.set_character(id)
		if not level.try_board(): quit(1); return
		boat.set_physics_process(false)
		boat.speed = 3
		camera.current = true
		camera.position = boat.position+Vector3(2.9,1.6,2.1)
		camera.look_at(boat.position+Vector3.UP*0.65)
		await snap(id+"_rowing")
		boat.speed = 0
		if not level.try_disembark(): quit(1); return
	level.queue_free()
	for i in 5: await process_frame
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	await root.get_node("GameAudio").request_quit()
