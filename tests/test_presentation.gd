extends SceneTree
var checks: int = 0
var failures: int = 0
var steps: int = 0
func _initialize() -> void:
	call_deferred("run")
func expect(ok: bool, title: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(title)
func frames(count: int = 3) -> void:
	for i in count:
		await physics_frame
		await process_frame
func run() -> void:
	root.size = Vector2i(1280, 720)
	var audio := root.get_node("GameAudio")
	audio.played.connect(func(event: String):
		if event.begins_with("step_"):
			steps += 1
	)
	for id: String in ["aracatiba", "itaipuacu", "centro", "ubatiba", "ponta_negra"]:
		var scene = load("res://scenes/levels/%s.tscn" % id).instantiate()
		scene.profile_path = "res://tests/artifacts/presentation_profile.json"
		scene.progress_path = "res://tests/artifacts/presentation_progress.json"
		root.add_child(scene)
		current_scene = scene
		scene.set_physics_process(false)
		await frames()
		var shapes: int = scene.find_children("*", "CollisionShape3D", true, false).size()
		var detail = scene.get_node("Presentation/WorldPolish")
		for quality in 3:
			audio.quality = quality
			detail.apply_quality()
			expect(scene.find_children("*", "CollisionShape3D", true, false).size() == shapes, "Qualidade preserva colisões: " + id)
		var hud = scene.get_node("MissionHUD")
		var words = hud.content.get_child(0).get_child(1)
		expect(words.size.x > 400 and hud.content.get_global_rect().end.y <= 720, "Menu cabe na tela: " + id)
		scene.set_state(scene.State.PAUSADO)
		hud.open_settings()
		await frames()
		var escape := InputEventAction.new()
		escape.action = "release_mouse"
		escape.pressed = true
		Input.parse_input_event(escape)
		await frames()
		Input.action_release("release_mouse")
		expect(scene.state == scene.State.PAUSADO and scene.is_processing_input(), "Esc fecha opções sem retomar: " + id)
		scene.set_state(scene.State.JOGANDO)
		if id == "aracatiba":
			await frames(30)
			steps = 0
			await frames(35)
			expect(steps == 0, "Parado não emite passos")
			Input.action_press("move_forward")
			await frames(35)
			Input.action_release("move_forward")
			expect(steps > 0, "Caminhada real emite passos")
			steps = 0
			Input.action_press("jump")
			Input.action_press("move_forward")
			await frames(15)
			Input.action_release("jump")
			Input.action_release("move_forward")
			expect(steps == 0, "Pulo não emite passos")
		if id == "ponta_negra":
			var boat = scene.get_node("Boat")
			scene.player.position = boat.landing_position
			expect(boat.embark(scene.player), "Embarca com visual atualizado")
			await frames(3)
			expect(boat.disembark(), "Desembarca durante blend sem bloquear")
			await frames(3)
			expect(boat.embark(scene.player), "Reembarque rápido aceito")
			await frames(35)
			expect(not boat.camera.is_set_as_top_level() and boat.camera.current and boat.camera.position.length() < 12, "Blend termina na câmera correta sem deslocamento acumulado")
			expect(steps == 0, "Embarcado não emite passos terrestres")
		scene.queue_free()
		await process_frame
	print("RESULT: %d verificações, %d falhas" % [checks, failures])
	quit(0 if failures == 0 else 1)
