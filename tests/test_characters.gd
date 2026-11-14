extends SceneTree
const Catalog = preload("res://scripts/core/character_catalog.gd")
const Profile = preload("res://scripts/core/player_profile.gd")
const Mission = preload("res://scripts/levels/aracatiba.gd")
const Progress = preload("res://scripts/core/mission_progress.gd")
const PROFILE_PATH := "res://tests/artifacts/character_profile_test.json"
const PROGRESS_PATH := "res://tests/artifacts/character_progress_test.json"
var checks: int = 0
var failures: int = 0
func _initialize() -> void:
	call_deferred("run")
func expect(ok: bool, title: String) -> void:
	checks += 1
	if ok:
		print("PASS: " + title)
	else:
		failures += 1
		push_error("FAIL: " + title)
func frames(count: int = 3) -> void:
	for i in count:
		await physics_frame
		await process_frame
func write_file(path: String, text: String) -> void:
	var file := FileAccess.open(path, FileAccess.WRITE)
	file.store_string(text)
func make_mission():
	var scene = load("res://scenes/levels/aracatiba.tscn").instantiate()
	scene.profile_path = PROFILE_PATH
	scene.progress_path = PROGRESS_PATH
	root.add_child(scene)
	current_scene = scene
	scene.set_physics_process(false)
	await frames()
	return scene
func run() -> void:
	expect(Catalog.IDS.size() == 4 and not Catalog.valid_id("desconhecido"), "Quatro identidades válidas")
	var missing := Profile.new("res://tests/artifacts/missing_character_profile_4.json")
	expect(missing.selected_id == "lucas", "Perfil ausente usa Lucas")
	write_file(PROFILE_PATH, "{}")
	var profile := Profile.new(PROFILE_PATH)
	for id in Catalog.IDS:
		expect(profile.select_character(id) and Profile.new(PROFILE_PATH).selected_id == id, "Grava e recarrega " + id)
	expect(not profile.select_character("unknown") and Profile.new(PROFILE_PATH).selected_id == "bia", "ID inválido não sobrescreve escolha válida")
	for invalid: String in ["{", "[]", "{\"version\":1,\"selected_character\":5}", "{\"version\":1,\"selected_character\":\"hacker\"}", "{\"version\":2,\"selected_character\":\"bia\"}"]:
		write_file(PROFILE_PATH, invalid)
		expect(Profile.new(PROFILE_PATH).selected_id == "lucas", "Perfil inválido usa padrão: " + invalid)
	profile = Profile.new("res://tests/artifacts/unavailable_profile_directory_4/profile.json")
	expect(not profile.select_character("bia") and profile.selected_id == "lucas", "Falha de escrita preserva seleção anterior")
	profile = Profile.new(PROFILE_PATH)
	profile.select_character("lucas")
	var progress := Progress.new(PROGRESS_PATH)
	progress.unlock_next_level()
	var scene = await make_mission()
	expect(scene.player.visual.character_id == "lucas", "Menu aplica perfil ao jogador")
	scene.show_character_selection()
	var selector = scene.get_node("MissionHUD").selector
	expect(scene.state == Mission.State.SELECAO_PERSONAGEM and selector.avatars.size() == 4, "Seleção cria quatro prévias e bloqueia missão")
	selector.choice_buttons["marina"].pressed.emit()
	expect(selector.pending_id == "marina" and Profile.new(PROFILE_PATH).selected_id == "lucas", "Prévia não salva antes de confirmar")
	scene.advance_time(20)
	expect(scene.remaining == 300 and not scene.session.active, "Seleção não consome tempo nem permite coleta")
	scene.cancel_character_selection()
	expect(scene.profile.selected_id == "lucas" and scene.player.visual.character_id == "lucas", "Cancelar preserva personagem anterior")
	for id in Catalog.IDS:
		scene.show_character_selection()
		selector = scene.get_node("MissionHUD").selector
		selector.choose(id)
		selector.confirm_button.pressed.emit()
		await frames()
		expect(scene.state == Mission.State.MENU and scene.player.visual.character_id == id and Profile.new(PROFILE_PATH).selected_id == id, "Confirmação integrada aplica e salva " + id)
	expect(Progress.new(PROGRESS_PATH).unlocked_level == 2, "Seleção não apaga desbloqueio de fases")
	scene.queue_free()
	await process_frame
	scene = await make_mission()
	expect(scene.profile.selected_id == "bia" and scene.player.visual.character_id == "bia", "Nova instância recupera Bia do disco")
	scene.show_character_selection()
	var escape := InputEventAction.new()
	escape.action = "release_mouse"
	escape.pressed = true
	Input.parse_input_event(escape)
	await frames()
	Input.action_release("release_mouse")
	expect(scene.state == Mission.State.MENU and scene.profile.selected_id == "bia", "Esc volta da seleção sem alterar perfil")
	scene.show_character_selection()
	selector = scene.get_node("MissionHUD").selector
	scene.profile.file_path = "res://tests/artifacts/unavailable_profile_directory_4/profile.json"
	selector.choose("marina")
	selector.confirm_button.pressed.emit()
	expect(scene.state == Mission.State.SELECAO_PERSONAGEM and selector.error_label.visible and scene.player.visual.character_id == "bia", "Interface informa falha de gravação e mantém escolha anterior")
	scene.queue_free()
	await process_frame
	# Mesmo controlador e mesma cápsula, com movimento físico para cada aparência.
	scene = load("res://scenes/levels/foundation.tscn").instantiate()
	scene.get_node("Player").profile_path = PROFILE_PATH
	root.add_child(scene)
	current_scene = scene
	await frames(20)
	var player = scene.get_node("Player")
	expect(player.visual.character_id == "bia", "Treino carrega escolha salva pelo controlador compartilhado")
	for id in Catalog.IDS:
		player.set_character(id)
		player.set_character(id)
		player.position = Vector3(0, 0.05, 4)
		player.velocity = Vector3.ZERO
		await frames(10)
		Input.action_press("move_forward")
		await frames(10)
		expect(is_equal_approx(Vector2(player.velocity.x, player.velocity.z).length(), 4.0), id + ": mesma caminhada")
		Input.action_press("sprint")
		await frames(5)
		expect(is_equal_approx(Vector2(player.velocity.x, player.velocity.z).length(), 7.0), id + ": mesma corrida")
		Input.action_release("sprint")
		Input.action_release("move_forward")
		Input.action_press("jump")
		await frames(1)
		Input.action_release("jump")
		await frames(5)
		expect(player.position.y > 0.3, id + ": pulo disponível")
		await frames(50)
		expect(is_equal_approx(player.get_node("CollisionShape3D").shape.radius, 0.32) and player.is_on_floor(), id + ": mesma cápsula e retorno ao chão")
		player.play_collect()
		await frames(5)
		expect(player.collection_time > 0 and absf(player.left_arm.rotation.x) > 0.1, id + ": animação de coleta compartilhada")
	var cuffs: int = 0
	player.set_character("rafael")
	player.set_character("rafael")
	for child in player.left_leg.get_children():
		if child.name.begins_with("BootCuff"):
			cuffs += 1
	expect(cuffs == 1, "Troca repetida não duplica acessórios")
	player.set_character("invalid")
	expect(player.visual.character_id == "lucas" and player.visual.get_node("Backpack").visible, "Aparência inválida volta ao padrão seguro")
	scene.queue_free()
	await process_frame
	print("RESULT: %d verificações, %d falhas" % [checks, failures])
	quit(0 if failures == 0 else 1)
