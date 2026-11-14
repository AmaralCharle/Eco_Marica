extends SceneTree
const Config = preload("res://scripts/core/game_config.gd")
var failures: int = 0
var checks: int = 0

func _initialize() -> void:
	call_deferred("run")

func expect(condition: bool, label: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		push_error("FAIL: " + label)
	else:
		print("PASS: " + label)

func frames(count: int) -> void:
	for i in count:
		await physics_frame
		await process_frame

func release_actions() -> void:
	for action: String in ["move_forward", "move_back", "move_left", "move_right", "sprint", "jump"]:
		Input.action_release(action)

func reset_player(player: CharacterBody3D) -> void:
	release_actions()
	player.position = Vector3(0, 0.05, 4)
	player.velocity = Vector3.ZERO
	player.get_node("CameraPivot").rotation = Vector3(-0.28, 0, 0)
	await frames(20)

func run() -> void:
	var packed = load("res://scenes/levels/foundation.tscn") as PackedScene
	expect(packed != null, "Cena principal carrega")
	if packed == null:
		quit(1)
		return
	var scene := packed.instantiate()
	root.add_child(scene)
	current_scene = scene
	await frames(30)
	var player := scene.get_node("Player") as CharacterBody3D
	expect(player.is_on_floor(), "Personagem repousa no chão")
	expect(absf(player.position.y) < 0.1, "Colisão impede atravessar o chão")
	var start := player.position
	Input.action_press("move_forward")
	await frames(30)
	var walk_distance: float = start.distance_to(player.position)
	expect(walk_distance > 1.5 and walk_distance < 2.5, "W desloca aproximadamente 2 m em 30 ticks")
	expect(absf(Vector2(player.velocity.x, player.velocity.z).length() - Config.WALK_SPEED) < 0.01, "Velocidade de caminhada configurada")
	await reset_player(player)
	start = player.position
	Input.action_press("move_forward")
	Input.action_press("sprint")
	await frames(30)
	expect(start.distance_to(player.position) > walk_distance * 1.5, "Corrida desloca mais que caminhada")
	expect(absf(Vector2(player.velocity.x, player.velocity.z).length() - Config.RUN_SPEED) < 0.01, "Velocidade de corrida configurada")
	await reset_player(player)
	Input.action_press("move_right")
	Input.action_press("move_forward")
	await frames(10)
	expect(absf(Vector2(player.velocity.x, player.velocity.z).length() - Config.WALK_SPEED) < 0.01, "Diagonal não aumenta a velocidade")
	await reset_player(player)
	Input.action_press("jump")
	await frames(1)
	Input.action_release("jump")
	await frames(10)
	expect(player.position.y > 0.4 and not player.is_on_floor(), "Espaço inicia pulo")
	await frames(75)
	expect(player.is_on_floor() and absf(player.position.y) < 0.1, "Gravidade devolve ao chão")
	await reset_player(player)
	Input.action_press("move_forward")
	Input.action_press("sprint")
	await frames(150)
	expect(player.position.z > -6.5 and player.position.z < -6.0, "Parede bloqueia o personagem")
	await reset_player(player)
	player.get_node("CameraPivot").rotation.y = PI / 2
	Input.action_press("move_forward")
	await frames(15)
	expect(player.position.x < -0.7 and absf(player.position.z - 4.0) < 0.1, "Movimento acompanha a orientação da câmera")
	await reset_player(player)
	player.position.z = 0.0
	await frames(5)
	Input.action_press("move_right")
	Input.action_press("sprint")
	await frames(150)
	expect(player.position.x < 12.6 and player.position.x > 12.0, "Limite lateral impede saída da área")
	player.apply_look(Vector2(100, -10000))
	expect(is_equal_approx(player.get_node("CameraPivot").rotation.x, Config.CAMERA_MAX_PITCH), "Câmera limita inclinação superior")
	player.apply_look(Vector2(0, 20000))
	expect(is_equal_approx(player.get_node("CameraPivot").rotation.x, Config.CAMERA_MIN_PITCH), "Câmera limita inclinação inferior")
	expect(player.get_node("CameraPivot/SpringArm3D/Camera3D").current, "Câmera de terceira pessoa ativa")
	release_actions()
	print("RESULT: %d verificações, %d falhas" % [checks, failures])
	scene.queue_free()
	await process_frame
	quit(0 if failures == 0 else 1)
