extends SceneTree
const Mission = preload("res://scripts/levels/aracatiba.gd")
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
func write_file(path: String, text: String) -> void:
	var file := FileAccess.open(path, FileAccess.WRITE)
	file.store_string(text)
func make_mission(tag: String):
	var level = load("res://scenes/levels/aracatiba.tscn").instantiate()
	level.progress_path = "res://tests/artifacts/progress_%s.json" % tag
	write_file(level.progress_path, "{}")
	root.add_child(level)
	current_scene = level
	# Tempo determinístico: mesmo método advance_time usado por _physics_process.
	level.set_physics_process(false)
	await frames()
	return level
func dispose(level: Node) -> void:
	level.queue_free()
	await process_frame
func start(level: Node) -> void:
	level.show_instructions()
	level.start_mission()
func classify(level: Node, index: int, wrong: bool = false) -> void:
	var id := "aracatiba_%02d" % index
	level.session.collect(id)
	var actual: String = level.session.records[id]["material"]
	var material: String = ("plastic" if actual == "paper" else "paper") if wrong else actual
	level.session.sort_into(material)
func run() -> void:
	var level = await make_mission("menu")
	expect(level.state == Mission.State.MENU and not level.session.active, "Menu bloqueia interações")
	expect(level.session.records.size() == 15 and get_nodes_in_group("training_bins").size() == 6, "Missão cria 15 resíduos e três pares de coletores")
	level.advance_time(30)
	expect(level.remaining == 300, "Menu não consome tempo")
	expect(not level.session.collect("aracatiba_00"), "Não coleta antes de começar")
	level.show_instructions()
	level.advance_time(30)
	expect(level.state == Mission.State.INSTRUCOES and level.remaining == 300, "Instruções não consomem tempo")
	level.start_mission()
	level.advance_time(10)
	expect(level.remaining == 290 and level.session.active, "Começar ativa missão e cronômetro")
	var escape := InputEventAction.new()
	escape.action = "release_mouse"
	escape.pressed = true
	Input.parse_input_event(escape)
	await frames()
	expect(level.state == Mission.State.PAUSADO and not level.player.is_physics_processing(), "Esc pausa personagem e missão")
	level.advance_time(40)
	expect(level.remaining == 290 and not level.session.collect("aracatiba_00"), "Pausa congela tempo e coleta")
	escape = InputEventAction.new()
	escape.action = "release_mouse"
	escape.pressed = true
	Input.parse_input_event(escape)
	await frames()
	expect(level.state == Mission.State.JOGANDO, "Esc retoma a missão")
	Input.action_release("release_mouse")
	level.advance_time(290)
	expect(level.state == Mission.State.DERROTA and level.remaining == 0, "Tempo exatamente zero causa derrota")
	expect(level.result_reason.contains("tempo"), "Derrota informa motivo específico")
	var score: int = level.session.score
	expect(not level.session.collect("aracatiba_00") and level.session.score == score, "Resultado trava novas ações e pontos")
	await dispose(level)
	level = await make_mission("errors")
	start(level)
	for i in 3:
		classify(level, i, true)
	expect(level.state == Mission.State.JOGANDO and level.session.errors == 3, "Até três erros mantêm a missão ativa")
	expect(level.session.carried_id.is_empty() and not level.session.collect("aracatiba_00"), "Erro consome item e impede recoleta")
	classify(level, 3, true)
	expect(level.state == Mission.State.DERROTA and level.session.errors == 4, "Quarto erro causa derrota imediata")
	await dispose(level)
	level = await make_mission("threshold")
	start(level)
	for i in 14:
		classify(level, i, i < 3)
	expect(level.state == Mission.State.JOGANDO, "Não vence com um item ainda pendente")
	classify(level, 14)
	expect(level.state == Mission.State.VITORIA and level.session.correct == 12 and level.session.errors == 3, "Vitória aceita exatamente 12 acertos e 3 erros")
	expect(level.session.cleaning_index() == 80 and level.session.score == 360, "Limpeza 80% e placar de 360 sem apagar erros")
	expect(level.get_node("World/Recovery").visible, "Vitória ativa transformação do cenário")
	expect(level.progress.unlocked_level == 2 and level.save_ok, "Vitória desbloqueia e grava próxima área")
	var loaded := Progress.new(level.progress_path)
	expect(loaded.unlocked_level == 2, "Desbloqueio recuperado do disco")
	level.finish(true, "duplicada")
	expect(level.session.score == 360, "Bônus de missão não pode ser duplicado")
	await dispose(level)
	level = await make_mission("perfect")
	start(level)
	level.advance_time(299.9)
	for i in 15:
		classify(level, i)
	expect(level.state == Mission.State.VITORIA and level.session.score == 425 and level.session.cleaning_index() == 100, "Vitória antes do fim: 15 acertos, 425 pontos e 100%")
	# Uma derrota posterior não deve tocar no arquivo de desbloqueio.
	var path: String = level.progress_path
	await dispose(level)
	level = load("res://scenes/levels/aracatiba.tscn").instantiate()
	level.progress_path = path
	root.add_child(level)
	current_scene = level
	level.set_physics_process(false)
	start(level)
	level.advance_time(300)
	expect(Progress.new(path).unlocked_level == 2, "Derrota preserva desbloqueio anterior")
	level.restart()
	await frames(6)
	level = current_scene
	level.set_physics_process(false)
	expect(level.state == Mission.State.JOGANDO and level.session.score == 0 and level.session.collected == 0 and level.remaining > 299, "Reinício começa sessão limpa com cronômetro completo")
	level.go_menu()
	await frames(6)
	level = current_scene
	expect(level.state == Mission.State.MENU and level.session.score == 0, "Voltar ao menu encerra sessão anterior")
	await dispose(level)
	level = await make_mission("physical")
	start(level)
	for item in get_nodes_in_group("training_waste"):
		level.player.position = item.position + Vector3(0, 0.05, 1)
		await frames()
		level.get_node("Interaction").interact()
		var correct_bin: Node3D = null
		for bin in get_nodes_in_group("training_bins"):
			if bin.material == item.material:
				correct_bin = bin
				break
		level.player.position = correct_bin.position + Vector3(1.2, 0.05, 0)
		await frames()
		level.get_node("Interaction").interact()
	expect(level.state == Mission.State.VITORIA and level.session.correct == 15, "Percurso integrado alcança os 15 itens e destinos sem bloqueios")
	await dispose(level)
	var corrupt_path := "res://tests/artifacts/progress_corrupt.json"
	for invalid: String in ["quebrado", "[]", "{\"version\":1,\"unlocked_level\":999}", "{\"version\":1,\"unlocked_level\":\"2\"}", "{\"version\":1,\"unlocked_level\":1.5}"]:
		write_file(corrupt_path, invalid)
		expect(Progress.new(corrupt_path).unlocked_level == 1, "Progresso inválido usa padrão seguro: " + invalid)
	print("RESULT: %d verificações, %d falhas" % [checks, failures])
	quit(0 if failures == 0 else 1)
