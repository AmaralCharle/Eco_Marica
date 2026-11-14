extends SceneTree
const Mission = preload("res://scripts/levels/aracatiba.gd")
var failures := 0
var checks := 0
func _initialize() -> void:
	call_deferred("run")
func frames(n: int) -> void:
	for i in n:
		await physics_frame
		await process_frame
func check(ok: bool, title: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(title)
	else:
		print("PASS: ", title)
func run() -> void:
	var level = load("res://scenes/levels/centro.tscn").instantiate()
	root.add_child(level)
	current_scene = level
	level.set_state(Mission.State.JOGANDO)
	level.set_physics_process(false)
	await frames(3)
	var player = level.player
	player.camera_pivot.rotation.y = 0
	for bin in get_nodes_in_group("training_bins"):
		player.position = Vector3(0, 0.05, bin.position.z + 2)
		player.velocity = Vector3.ZERO
		await frames(10)
		var action: String = "move_left" if bin.position.x < 0 else "move_right"
		Input.action_press(action)
		await frames(roundi(absf(bin.position.x) / 4 * 60))
		Input.action_release(action)
		Input.action_press("move_forward")
		await frames(12)
		Input.action_release("move_forward")
		await frames(2)
		check(player.position.distance_to(bin.position) < 2.2 and level.get_node("Interaction").has_line_of_sight(bin), "Acesso sem pulo ao coletor " + bin.material + " z=" + str(bin.position.z))
	for side: float in [-1.0, 1.0]:
		player.position = Vector3(side * 2, 0.04, 3.4)
		player.velocity = Vector3.ZERO
		await frames(10)
		var action: String = "move_left" if side < 0 else "move_right"
		Input.action_press(action)
		await frames(45)
		Input.action_release(action)
		await frames(5)
		check(absf(player.position.x) > 4.5 and player.position.y > 0.1 and player.is_on_floor(), "Rampa permite subir a calçada sem pulo lado " + str(side))
	print("RESULT: %d verificações, %d falhas" % [checks, failures])
	level.queue_free()
	await process_frame
	quit(0 if failures == 0 else 1)
