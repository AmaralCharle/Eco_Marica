extends SceneTree
const Mission = preload("res://scripts/levels/aracatiba.gd")
const Profile = preload("res://scripts/core/player_profile.gd")
const Progress = preload("res://scripts/core/mission_progress.gd")
const Config = preload("res://scripts/core/game_config.gd")
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
func make_level(tag: String, unlocked: int = 2):
	var path := "res://tests/artifacts/itaipuacu_progress_%s.json" % tag
	var file := FileAccess.open(path, FileAccess.WRITE)
	file.store_string(JSON.stringify({"version": 1, "unlocked_level": unlocked}))
	file.close()
	var profile_path := "res://tests/artifacts/itaipuacu_profile_%s.json" % tag
	Profile.new(profile_path).select_character("bia")
	var level = load("res://scenes/levels/itaipuacu.tscn").instantiate()
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
func correct_all(level: Node) -> void:
	for id in level.session.records.keys():
		if level.state != Mission.State.JOGANDO:
			break
		if level.session.records[id]["state"] == RecyclingSession.WasteState.AVAILABLE:
			level.session.collect(id)
			level.session.sort_into(level.session.records[id]["material"])
func run() -> void:
	var level = await make_level("locked", 1)
	start(level)
	expect(level.state == Mission.State.MENU and not level.session.active, "Fase 2 bloqueada antes de vencer Araçatiba")
	expect(not level.open_level("itaipuacu"), "Acesso direto também respeita bloqueio")
	await dispose(level)
	level = await make_level("drift")
	expect(level.session.records.size() == 20, "Vinte resíduos iniciais")
	expect(get_nodes_in_group("training_bins").size() == 12, "Três estações com quatro coletores")
	for material in Config.MATERIAL_ORDER:
		var count: int = 0
		for record in level.session.records.values():
			if record["material"] == material:
				count += 1
		expect(count == 5, "Cinco resíduos de " + material)
	expect(level.player.visual.character_id == "bia", "Personagem confirmado aplicado na fase 2")
	var moving := []
	for item in get_nodes_in_group("training_waste"):
		if item.drift_speed > 0:
			moving.append(item)
	expect(moving.size() == 7, "Sete resíduos têm deslocamento em direção ao mar")
	var first = moving[0]
	var x: float = first.position.x
	level.advance_time(10)
	expect(is_equal_approx(first.position.x, x) and level.remaining == 240, "Menu congela resíduos e cronômetro")
	start(level)
	level.advance_time(1)
	expect(is_equal_approx(first.position.x, x - first.drift_speed) and level.remaining == 239, "Deslocamento e cronômetro usam delta")
	expect(first.item_label.text.contains("→ MAR"), "Risco indicado por texto e tempo")
	level.set_state(Mission.State.PAUSADO)
	x = first.position.x
	level.advance_time(20)
	expect(is_equal_approx(first.position.x, x) and level.remaining == 239, "Pausa congela também os resíduos móveis")
	level.set_state(Mission.State.JOGANDO)
	level.session.collect(first.waste_id)
	x = first.position.x
	level.advance_time(5)
	expect(is_equal_approx(first.position.x, x), "Coleta interrompe deslocamento")
	expect(not level.session.mark_lost(first.waste_id), "Item carregado não pode ser perdido ao mar")
	level.session.sort_into("plastic" if first.material != "plastic" else "paper")
	expect(level.session.errors == 1 and level.session.carried_id == first.waste_id and level.session.correct == 0, "Erro de classificação preserva item na fase 2")
	level.session.sort_into(first.material)
	expect(level.session.correct == 1 and level.session.carried_id.is_empty(), "Correção conclui destino")
	await dispose(level)
	level = await make_level("losses")
	start(level)
	for i in 4:
		var item = get_nodes_in_group("training_waste")[i]
		item.position.x = Config.ITAIPUACU_SEA_LINE + 0.001
		item.drift_speed = 1.0
		item.advance_drift(0.1, level.session)
		expect(level.session.lost_count == i + 1 and not item.visible, "Perda %d contabilizada e ocultada" % (i + 1))
		expect(not level.session.mark_lost(item.waste_id) and not level.session.collect(item.waste_id), "Não duplica perda nem recoleta perdido %d" % i)
	expect(level.state == Mission.State.JOGANDO and level.session.records.size() == 24, "Quatro perdas mantêm missão possível com reposição única")
	correct_all(level)
	expect(level.state == Mission.State.VITORIA and level.session.correct == 20, "Vinte destinos ainda possíveis após quatro perdas")
	expect(level.session.cleaning_index() == 83 and level.session.lost_count == 4, "Índice registra perdas: 20/24, sem apagá-las")
	expect(level.progress.unlocked_level == 3 and Progress.new(level.progress_path).unlocked_level == 3, "Vitória grava desbloqueio do Centro")
	var score: int = level.session.score
	level.finish(true, "duplicada")
	expect(level.session.score == score, "Bônus da fase 2 é concedido uma única vez")
	expect(level.get_node("World/Recovery").visible, "Vitória recupera visualmente a praia")
	expect(not level.session.mark_lost("itaipuacu_004"), "Resultado final bloqueia novas perdas")
	await dispose(level)
	level = await make_level("five")
	start(level)
	for i in 5:
		var item = get_nodes_in_group("training_waste")[i]
		item.position.x = Config.ITAIPUACU_SEA_LINE + 0.001
		item.drift_speed = 1
		item.advance_drift(0.1, level.session)
	expect(level.state == Mission.State.DERROTA and level.session.lost_count == 5, "Quinta perda causa derrota")
	expect(level.result_reason.contains("mar") and level.session.records.size() == 24, "Quinta perda não cria reposição após derrota")
	expect(Progress.new(level.progress_path).unlocked_level == 2, "Derrota não apaga fase 2 desbloqueada")
	await dispose(level)
	level = await make_level("time")
	start(level)
	level.advance_time(240)
	expect(level.state == Mission.State.DERROTA and level.remaining == 0, "Tempo zero causa derrota na fase 2")
	await dispose(level)
	level = await make_level("perfect")
	start(level)
	correct_all(level)
	expect(level.state == Mission.State.VITORIA and level.session.score == 520 and level.session.cleaning_index() == 100, "Partida perfeita: 20 acertos, 520 pontos e 100%")
	var save_path: String = level.progress_path
	var profile_path: String = level.profile_path
	level.restart()
	await frames(6)
	level = current_scene
	level.set_physics_process(false)
	expect(level.mission_id == "itaipuacu" and level.state == Mission.State.JOGANDO and level.session.correct == 0 and level.remaining > 239, "Reinício preserva fase e zera objetivos/tempo")
	expect(level.profile_path == profile_path and level.progress_path == save_path and level.progress.unlocked_level == 3, "Reinício preserva perfil e progresso corretos")
	level.go_menu()
	await frames(6)
	level = current_scene
	expect(level.mission_id == "aracatiba" and level.state == Mission.State.MENU and level.progress.unlocked_level == 3, "Retorno ao menu mantém progresso da fase 2")
	expect(level.open_level("itaipuacu"), "Menu abre Itaipuaçu desbloqueada")
	await frames(6)
	level = current_scene
	level.set_physics_process(false)
	expect(level.mission_id == "itaipuacu" and level.state == Mission.State.INSTRUCOES, "Transição abre instruções da fase correta")
	expect(level.player.visual.character_id == "bia" and level.progress_path == save_path, "Transição preserva personagem e arquivo de progresso")
	await dispose(level)
	level = await make_level("physical")
	start(level)
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
	expect(level.state == Mission.State.VITORIA and level.session.correct == 20, "Interação integrada alcança os 20 itens e quatro materiais")
	await dispose(level)
	var progress := Progress.new(save_path)
	expect(progress.unlock_next_level(2) and progress.unlocked_level == 3, "Repetir fase anterior não rebaixa desbloqueio")
	expect(not progress.unlock_next_level(999) and progress.unlocked_level == 3, "Desbloqueio inválido rejeitado")
	print("RESULT: %d verificações, %d falhas" % [checks, failures])
	quit(0 if failures == 0 else 1)
