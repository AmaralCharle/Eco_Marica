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
	if ok:
		print("PASS: ", title)
	else:
		failures += 1
		push_error(title)
func make_level(tag: String):
	var level = load("res://scenes/levels/ponta_negra.tscn").instantiate()
	level.progress_path = "res://tests/artifacts/ponta_" + tag + ".json"
	var file := FileAccess.open(level.progress_path, FileAccess.WRITE)
	file.store_string('{"version":2,"unlocked_level":5}')
	file.close()
	root.add_child(level)
	current_scene = level
	level.set_physics_process(false)
	level.show_instructions()
	level.start_mission()
	await frames()
	return level
func dispose(level: Node) -> void:
	level.queue_free()
	await process_frame
func run() -> void:
	var level = await make_level("cycle")
	check(level.session.records.size() == 20 and level.session.boat_inventory.is_empty(), "Vinte resíduos recuperáveis e carga vazia")
	var boat = level.get_node("Boat")
	level.player.position = boat.landing_position
	await frames()
	check(level.try_board() and level.on_boat, "Embarca pelo acesso ao píer")
	boat.set_physics_process(false)
	var items := get_nodes_in_group("floating_waste")
	for i in 5:
		boat.position = items[i].position + Vector3(0, 0, 1.5)
		level.boat_interact()
	check(level.session.boat_inventory.size() == 5 and level.session.collected == 5 and level.session.score == 25, "Capacidade de cinco, coleta única e pontos exatos")
	boat.position = items[5].position + Vector3(0, 0, 1.5)
	level.boat_interact()
	check(level.session.collected == 5 and level.session.boat_inventory.size() == 5, "Sexto item impedido quando carga cheia")
	check(not level.session.mark_lost(items[0].waste_id), "Item na carga não escapa")
	check(not level.try_disembark(), "Desembarque rejeitado fora do píer")
	boat.position = boat.dock_position
	boat.speed = 0
	check(level.try_disembark() and not level.on_boat and not level.session.carried_id.is_empty() and level.session.boat_inventory.size() == 4, "Desembarque transfere um item para mãos sem nova coleta")
	check(not level.try_board(), "Carga pendente precisa ser destinada antes de embarcar")
	var original_id: String = level.session.carried_id
	level.session.sort_into("metal" if level.session.records[original_id]["material"] != "metal" else "paper")
	check(level.session.carried_id == original_id and level.session.errors == 1, "Erro permite corrigir item da carga")
	while not level.session.carried_id.is_empty():
		level.session.sort_into(level.session.records[level.session.carried_id]["material"])
	check(level.session.correct == 5 and level.session.boat_inventory.is_empty(), "Descarga encadeada destina os cinco itens")
	for batch in 3:
		boat.position = boat.dock_position
		level.player.position = boat.landing_position
		level.try_board()
		boat.set_physics_process(false)
		for i in range(5 + batch * 5, 10 + batch * 5):
			boat.position = items[i].position + Vector3(0, 0, 1.5)
			level.boat_interact()
		boat.position = boat.dock_position
		boat.speed = 0
		level.try_disembark()
		while not level.session.carried_id.is_empty():
			var id: String = level.session.carried_id
			var bin = get_nodes_in_group("training_bins")[0]
			for candidate in get_nodes_in_group("training_bins"):
				if candidate.material == level.session.records[id]["material"]:
					bin = candidate
			level.player.position = bin.position + Vector3(0, 0.05, 1.2)
			await frames()
			level.get_node("Interaction").interact()
	check(level.state == Mission.State.VITORIA and level.session.correct == 20 and level.session.collected == 20, "Quatro viagens completam vinte destinos usando barco e coletores")
	check(level.progress.campaign_completed and Progress.new(level.progress_path).campaign_completed, "Apenas a quinta fase encerra e salva campanha")
	check(level.session.score == 515 and level.progress.total_score() == 515, "Placar real com um erro e soma persistida")
	level.show_campaign_completion()
	check(level.state == Mission.State.FINALIZADO, "Celebração abre mapa e estatísticas das cinco fases")
	await dispose(level)
	level = await make_level("escape")
	items = get_nodes_in_group("floating_waste")
	var item = items[0]
	item.position.z = -16.99
	item.escape_speed = 0.01
	item.advance_float(0.1, level.session)
	check(level.session.lost_count == 0, "Não conta perda antes de cruzar a zona")
	item.advance_float(2, level.session)
	check(level.session.lost_count == 1 and level.session.records.size() == 21, "Cruzamento real conta uma perda e uma reposição")
	item.advance_float(100, level.session)
	check(level.session.lost_count == 1, "Objeto perdido não gera perdas repetidas")
	for i in range(1, 5):
		items[i].position.z = -17.01
		items[i].escape_speed = 0.1
		items[i].advance_float(0.1, level.session)
	check(level.state == Mission.State.DERROTA and level.session.lost_count == 5 and level.session.records.size() == 24, "Quinta perda encerra sem criar reposição adicional")
	await dispose(level)
	level = await make_level("recovery")
	items = get_nodes_in_group("floating_waste")
	for i in 4:
		items[i].position.z = -17.01
		items[i].escape_speed = 0.1
		items[i].advance_float(0.1, level.session)
	var recoverable: Array[Node] = []
	for candidate in get_nodes_in_group("floating_waste"):
		if level.session.records[candidate.waste_id]["state"] == RecyclingSession.WasteState.AVAILABLE:
			recoverable.append(candidate)
	boat = level.get_node("Boat")
	for batch in 4:
		boat.position = boat.dock_position
		level.player.position = boat.landing_position
		level.try_board()
		boat.set_physics_process(false)
		for i in range(batch * 5, batch * 5 + 5):
			boat.position = recoverable[i].position
			level.boat_interact()
		boat.position = boat.dock_position
		boat.speed = 0
		level.try_disembark()
		while not level.session.carried_id.is_empty():
			level.session.sort_into(level.session.records[level.session.carried_id]["material"])
	check(level.state == Mission.State.VITORIA and level.session.correct == 20 and level.session.lost_count == 4 and level.session.cleaning_index() == 83, "Quatro perdas ainda permitem vitória com reposição e índice de 83%")
	await dispose(level)
	level = await make_level("time")
	level.advance_time(360)
	check(level.state == Mission.State.DERROTA, "Prazo de 360 segundos encerra fase incompleta")
	await dispose(level)
	print("RESULT: %d verificações, %d falhas" % [checks, failures])
	quit(0 if failures == 0 else 1)
