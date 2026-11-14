extends SceneTree
const Mission = preload("res://scripts/levels/aracatiba.gd")
const Profile = preload("res://scripts/core/player_profile.gd")
const Progress = preload("res://scripts/core/mission_progress.gd")
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
func make_level(tag: String, unlocked: int = 3):
	var path := "res://tests/artifacts/centro_progress_%s.json" % tag
	var file := FileAccess.open(path, FileAccess.WRITE)
	file.store_string(JSON.stringify({"version": 1, "unlocked_level": unlocked}))
	file.close()
	var profile_path := "res://tests/artifacts/centro_profile_%s.json" % tag
	Profile.new(profile_path).select_character("rafael")
	var level = load("res://scenes/levels/centro.tscn").instantiate()
	level.progress_path = path
	level.profile_path = profile_path
	root.add_child(level)
	current_scene = level
	level.set_physics_process(false)
	await frames()
	return level
func dispose(level: Node) -> void:
	level.queue_free()
	await process_frame
func start(level: Node) -> void:
	level.show_instructions()
	level.start_mission()
func sort_all(level: Node) -> void:
	for id in level.session.records.keys():
		level.session.collect(id)
		level.session.sort_into(level.session.records[id]["material"])
func clean_all(level: Node) -> void:
	for id in level.session.drains.keys():
		level.session.clean_drain(id)
func run() -> void:
	var level = await make_level("locked", 2)
	start(level)
	expect(level.state == Mission.State.MENU and not level.open_level("centro"), "Centro bloqueado antes de vencer Itaipuaçu")
	await dispose(level)
	level = await make_level("weather")
	expect(level.session.records.size() == 15 and level.session.drains.size() == 3, "Quinze resíduos e três bueiros únicos")
	expect(level.player.visual.character_id == "rafael", "Personagem confirmado aplicado no Centro")
	expect(not level.session.register_drain("") and not level.session.register_drain("centro_drain_0"), "Bueiros sem ID ou duplicados rejeitados")
	expect(not level.session.clean_drain("centro_drain_0"), "Menu bloqueia limpeza")
	level.advance_time(50)
	expect(level.remaining == 180 and level.get_node("World").storm_intensity == 0, "Menu não avança tempestade nem relógio")
	start(level)
	level.advance_time(90)
	var world = level.get_node("World")
	expect(is_equal_approx(world.storm_intensity, 0.5) and world.rain.visible and world.rain.multimesh.visible_instance_count > 0, "Metade do prazo intensifica céu e chuva")
	var color: Color = level.get_node("WorldEnvironment").environment.background_color
	var drop: Vector3 = world.drops[0]
	level.set_state(Mission.State.PAUSADO)
	level.advance_time(30)
	expect(level.remaining == 90 and world.drops[0] == drop and level.get_node("WorldEnvironment").environment.background_color == color, "Pausa congela chuva, céu e tempo")
	level.set_state(Mission.State.JOGANDO)
	expect(not level.session.clean_drain("unknown"), "Limpeza de bueiro desconhecido rejeitada")
	level.session.collect("centro_00")
	expect(not level.session.clean_drain("centro_drain_0"), "Exige mãos livres para limpar")
	level.session.sort_into("metal")
	expect(level.session.carried_id == "centro_00" and level.session.errors == 1, "Erro mantém resíduo para correção na fase final")
	level.session.sort_into("paper")
	var before: int = level.session.score
	expect(level.session.clean_drain("centro_drain_0") and level.session.score == before + 30, "Limpar bueiro concede +30")
	expect(not level.session.clean_drain("centro_drain_0") and level.session.score == before + 30, "Bueiro não pode render pontos repetidos")
	level.advance_time(90)
	expect(level.state == Mission.State.DERROTA and level.remaining == 0 and not level.progress.campaign_completed, "Tempo zero encerra missão sem concluir campanha")
	expect(not level.session.clean_drain("centro_drain_1"), "Resultado bloqueia limpeza pendente")
	await dispose(level)
	level = await make_level("waste_only")
	start(level)
	sort_all(level)
	expect(level.state == Mission.State.JOGANDO and level.session.cleaning_index() == 83, "Só os 15 resíduos não vencem; índice considera bueiros")
	clean_all(level)
	expect(level.state == Mission.State.VITORIA and level.session.score == 515 and level.session.cleaning_index() == 100, "Quinze destinos e três bueiros: vitória, 515 pontos e 100%")
	expect(level.progress.unlocked_level == 4 and not Progress.new(level.progress_path).campaign_completed, "Centro salva desbloqueio de Ubatiba sem encerrar campanha")
	expect(level.get_node("World/Recovery").visible, "Vitória ativa recuperação urbana simbólica")
	level.finish(true, "duplicada")
	expect(level.session.score == 515, "Bônus de missão final não duplica")
	level.show_campaign_completion()
	expect(level.state == Mission.State.VITORIA and not level.session.active, "Terceira fase não abre final prematuro")
	var path: String = level.progress_path
	var profile_path: String = level.profile_path
	level.go_menu()
	await frames(6)
	level = current_scene
	expect(level.state == Mission.State.MENU and level.progress.unlocked_level == 4 and level.progress_path == path, "Menu recupera campanha concluída sem apagar perfil")
	level.show_campaign_completion()
	expect(level.state == Mission.State.MENU, "Final permanece bloqueado até quinta fase")
	expect(level.open_level("centro"), "Campanha concluída permite rejogar Centro")
	await frames(6)
	level = current_scene
	level.set_physics_process(false)
	level.start_mission()
	level.advance_time(180)
	expect(level.state == Mission.State.DERROTA and Progress.new(path).unlocked_level == 4, "Derrota posterior preserva campanha concluída")
	level.restart()
	await frames(6)
	level = current_scene
	level.set_physics_process(false)
	expect(level.mission_id == "centro" and level.session.drains_cleaned == 0 and level.session.correct == 0 and level.remaining > 179, "Reinício zera tarefas e tempestade da fase final")
	expect(level.progress_path == path and level.profile_path == profile_path and level.player.visual.character_id == "rafael", "Reinício preserva personagem e arquivos corretos")
	await dispose(level)
	level = await make_level("drains_only")
	start(level)
	clean_all(level)
	expect(level.state == Mission.State.JOGANDO and level.session.cleaning_index() == 17, "Só três bueiros não vencem; índice 3/18")
	await dispose(level)
	level = await make_level("physical")
	start(level)
	var drain = get_nodes_in_group("mission_drains")[0]
	level.player.position = drain.position + Vector3(0, 0.05, 1)
	await frames()
	var event := InputEventAction.new()
	event.action = "interact"
	event.pressed = true
	Input.parse_input_event(event)
	await frames()
	Input.action_release("interact")
	expect(level.session.drains_cleaned == 1 and drain.cleaned and not drain.debris.visible, "Entrada E limpa bueiro e altera visual")
	level.get_node("Interaction").interact()
	expect(level.session.drains_cleaned == 1, "E repetido não duplica limpeza")
	for item in get_nodes_in_group("training_waste"):
		level.player.position = item.position + Vector3(0, 0.05, 1)
		await frames()
		level.get_node("Interaction").interact()
		var bin: Node3D = null
		for candidate in get_nodes_in_group("training_bins"):
			if candidate.material == item.material:
				bin = candidate
				break
		level.player.position = bin.position + Vector3(0, 0.05, 1.2)
		await frames()
		level.get_node("Interaction").interact()
	for candidate in get_nodes_in_group("mission_drains"):
		if not candidate.cleaned:
			level.player.position = candidate.position + Vector3(0, 0.05, 1)
			await frames()
			level.get_node("Interaction").interact()
	expect(level.state == Mission.State.VITORIA and level.session.correct == 15 and level.session.drains_cleaned == 3, "Ciclo integrado alcança os 15 resíduos e três bueiros")
	await dispose(level)
	var progress := Progress.new(path)
	expect(progress.unlock_next_level(2) and not Progress.new(path).campaign_completed and progress.unlocked_level == 4, "Repetir fase anterior preserva conclusão")
	var invalid_path := "res://tests/artifacts/centro_invalid_completion.json"
	for payload: String in ["{\"version\":1,\"unlocked_level\":3,\"campaign_completed\":\"true\"}", "{\"version\":1,\"unlocked_level\":1,\"campaign_completed\":true}"]:
		var file := FileAccess.open(invalid_path, FileAccess.WRITE)
		file.store_string(payload)
		file.close()
		expect(not Progress.new(invalid_path).campaign_completed, "Conclusão inválida rejeitada")
	print("RESULT: %d verificações, %d falhas" % [checks, failures])
	quit(0 if failures == 0 else 1)
