extends SceneTree
var checks := 0
var failures := 0
func _initialize() -> void:
	call_deferred("run")
func frames(n: int) -> void:
	for i in n:
		await physics_frame
		await process_frame
func check(ok: bool, title: String) -> void:
	checks += 1
	if ok:
		print("PASS: ", title)
	else:
		failures += 1
		push_error(title)
func run() -> void:
	var level = load("res://scenes/levels/ponta_negra.tscn").instantiate()
	level.progress_path = "res://tests/artifacts/ponta_access.json"
	var file := FileAccess.open(level.progress_path, FileAccess.WRITE)
	file.store_string('{"version":2,"unlocked_level":5}')
	file.close()
	root.add_child(level)
	current_scene = level
	level.set_physics_process(false)
	level.show_instructions()
	level.start_mission()
	await frames(10)
	Input.action_press("move_left")
	await frames(55)
	Input.action_release("move_left")
	check(level.player.position.x < 7.6 and level.player.is_on_floor(), "Caminha da margem ao píer sem pulo")
	check(level.try_board(), "Embarque alcançável caminhando")
	var boat = level.get_node("Boat")
	level.set_state(level.State.PAUSADO)
	var pos: Vector3 = boat.position
	var item = get_nodes_in_group("floating_waste")[0]
	var item_pos: Vector3 = item.position
	Input.action_press("move_forward")
	await frames(10)
	level.advance_time(10)
	check(boat.position == pos and item.position == item_pos and level.remaining == 360, "Pausa congela barco, resíduos e prazo")
	level.set_state(level.State.JOGANDO)
	boat.position = Vector3(0, 0.05, 3)
	boat.rotation.y = 0
	await frames(120)
	check(boat.position.z < -2 and absf(boat.position.y - 0.05) < 0.01, "Embarcação passa sob ponte sem atravessar estrutura")
	Input.action_release("move_forward")
	boat.position = Vector3(0, 0.05, 6)
	boat.rotation.y = -PI / 2
	boat.speed = 0
	Input.action_press("move_forward")
	await frames(180)
	Input.action_release("move_forward")
	check(boat.position.x < 7.1, "Margem da fase limita barco com colisão real")
	boat.position = boat.dock_position
	boat.speed = 0
	level.try_disembark()
	Input.action_press("move_left")
	await frames(80)
	Input.action_release("move_left")
	check(level.player.position.x > 6.1 and level.player.is_on_floor(), "Limite do píer impede caminhar para dentro do canal")
	print("RESULT: %d verificações, %d falhas" % [checks, failures])
	level.queue_free()
	await process_frame
	quit(0 if failures == 0 else 1)
