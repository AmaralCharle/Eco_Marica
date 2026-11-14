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
	var scene = load("res://scenes/levels/boat_prototype.tscn").instantiate()
	root.add_child(scene)
	await frames(10)
	var boat = scene.get_node("Boat")
	var player = scene.get_node("Player")
	check(boat.embark(player) and not player.visible and boat.camera.current, "Embarque troca controle, visual e câmera")
	Input.action_press("move_forward")
	await frames(30)
	check(boat.speed > 1 and boat.speed < 2 and boat.position.z < 12, "Aceleração gradual e avanço")
	await frames(120)
	check(boat.speed <= 6.01 and boat.speed > 5.9, "Velocidade máxima limitada")
	Input.action_press("move_left")
	var yaw: float = boat.rotation.y
	await frames(20)
	Input.action_release("move_left")
	check(boat.rotation.y > yaw, "Rotação gradual com A")
	check(not boat.disembark(), "Não desembarca longe do píer ou em movimento")
	Input.action_release("move_forward")
	await frames(100)
	check(absf(boat.speed) < 0.01, "Desaceleração ao soltar comando")
	boat.position = Vector3(0, 0.05, 0)
	boat.rotation.y = -PI / 2
	Input.action_press("move_forward")
	await frames(180)
	Input.action_release("move_forward")
	check(boat.position.x < 7.3, "Colisão impede atravessar margem")
	boat.position = boat.dock_position
	boat.speed = 0
	check(boat.disembark() and player.visible and player.is_physics_processing(), "Desembarque restaura personagem no píer")
	check(player.position.distance_to(boat.landing_position) < 0.1, "Desembarque tem posição segura")
	print("RESULT: %d verificações, %d falhas" % [checks, failures])
	scene.queue_free()
	await process_frame
	quit(0 if failures == 0 else 1)
