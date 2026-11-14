extends SceneTree
const Mission = preload("res://scripts/levels/aracatiba.gd")
const Progress = preload("res://scripts/core/mission_progress.gd")
var checks := 0
var failures := 0
func _initialize() -> void:
	call_deferred("run")
func frames(n: int = 3) -> void:
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
func make_level(tag: String):
	var level = load("res://scenes/levels/ubatiba.tscn").instantiate()
	level.progress_path = "res://tests/artifacts/ubatiba_" + tag + ".json"
	var file := FileAccess.open(level.progress_path, FileAccess.WRITE)
	file.store_string('{"version":2,"unlocked_level":4}')
	file.close()
	root.add_child(level)
	current_scene = level
	level.set_physics_process(false)
	await frames()
	return level
func dispose(level: Node) -> void:
	level.queue_free()
	await process_frame
func run() -> void:
	var level = await make_level("success")
	check(level.session.plots.size() == 12, "Doze pontos registrados")
	check(not level.session.act("ubatiba_00", "plant"), "Menu bloqueia ações")
	level.show_instructions()
	level.start_mission()
	check(not level.session.act("ubatiba_00", "plant"), "Exige inspeção antes da decisão")
	var point = get_nodes_in_group("planting_plots")[0]
	level.player.position = point.position + Vector3(0, 0.05, 1)
	await frames()
	level.get_node("Interaction").interact()
	check(level.inspection_target == point and not level.player.is_physics_processing(), "E abre inspeção e libera controle do mouse")
	level.advance_time(1)
	check(level.remaining == 299, "Tempo continua durante decisões")
	check(not level.choose_action("plant") and level.session.errors == 1, "Plantio antes de preparo conta decisão incorreta")
	check(level.choose_action("prepare"), "Preparo correto aceito")
	var score: int = level.session.score
	check(not level.choose_action("prepare") and level.session.score == score, "Preparo repetido não pontua")
	check(level.choose_action("plant") and level.session.planted == 1, "Plantio adequado registrado")
	check(level.session.assessed == 0, "Solo exposto exige proteção para concluir avaliação")
	check(level.choose_action("protect") and level.session.assessed == 1 and point.sapling.visible, "Proteção conclui ponto e altera visual")
	level.close_inspection()
	for item in get_nodes_in_group("planting_plots"):
		if level.session.resolved(level.session.plots[item.plot_id]):
			continue
		level.inspect_point(item)
		if item.apt:
			level.choose_action("prepare")
			level.choose_action("plant")
			if item.exposed:
				level.choose_action("protect")
		else:
			level.choose_action("preserve")
		level.close_inspection()
	check(level.state == Mission.State.VITORIA and level.session.assessed == 12 and level.session.planted == 8 and level.session.protected_soil == 3, "Todas as metas de Ubatiba concluídas")
	check(level.session.score == 365 and level.session.cleaning_index() == 100, "Placar exato após um erro e índice completo")
	check(Progress.new(level.progress_path).unlocked_level == 5 and not level.progress.campaign_completed, "Vitória libera Ponta Negra sem finalizar campanha")
	await dispose(level)
	level = await make_level("error")
	level.show_instructions()
	level.start_mission()
	var id := "ubatiba_08"
	level.session.inspect(id)
	for i in 3:
		level.session.act(id, "plant")
	check(level.state == Mission.State.JOGANDO and level.session.planted == 0, "Três erros não criam muda nem encerram")
	level.session.act(id, "prepare")
	check(level.state == Mission.State.DERROTA and level.session.errors == 4, "Quarta decisão incorreta encerra a fase")
	await dispose(level)
	level = await make_level("time")
	level.show_instructions()
	level.start_mission()
	level.advance_time(300)
	check(level.state == Mission.State.DERROTA, "Prazo de 300 segundos causa derrota")
	await dispose(level)
	var file := FileAccess.open("res://tests/artifacts/migration_three.json", FileAccess.WRITE)
	file.store_string('{"version":1,"unlocked_level":3,"campaign_completed":true}')
	file.close()
	var migrated := Progress.new("res://tests/artifacts/migration_three.json")
	check(migrated.unlocked_level == 4 and not migrated.campaign_completed and migrated.legacy_stats_missing, "Final antigo libera Ubatiba sem inventar pontuação")
	print("RESULT: %d verificações, %d falhas" % [checks, failures])
	quit(0 if failures == 0 else 1)
