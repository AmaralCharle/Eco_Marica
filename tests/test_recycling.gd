extends SceneTree
const Session = preload("res://scripts/gameplay/recycling_session.gd")
var failures: int = 0
var checks: int = 0
func _initialize() -> void:
	call_deferred("run")
func expect(ok: bool, label: String) -> void:
	checks += 1
	if ok:
		print("PASS: " + label)
	else:
		failures += 1
		push_error("FAIL: " + label)
func frames(count: int = 3) -> void:
	for i in count:
		await physics_frame
		await process_frame
func run() -> void:
	var session := Session.new()
	root.add_child(session)
	expect(session.cleaning_index() == 0, "Índice vazio seguro")
	expect(not session.register_waste("", "paper"), "ID vazio rejeitado")
	expect(not session.register_waste("bad", "unknown"), "Material desconhecido rejeitado")
	for i in 6:
		expect(session.register_waste(str(i), "paper"), "Registra ID único %d" % i)
	expect(not session.register_waste("0", "plastic"), "ID duplicado rejeitado")
	expect(not session.collect("missing"), "Coleta desconhecida rejeitada")
	expect(not session.sort_into("paper"), "Descarte sem item não pontua")
	expect(session.collect("0") and session.score == 5, "Coleta premia uma única vez")
	expect(not session.collect("0") and not session.collect("1"), "Não coleta duas vezes nem carrega dois itens")
	expect(not session.sort_into("plastic") and session.score == 0 and session.errors == 1, "Erro aplica penalidade")
	session.sort_into("plastic")
	expect(session.score == 0 and session.carried_id == "0", "Pontos mínimos zero e item preservado para corrigir")
	expect(not session.sort_into("unknown") and session.errors == 2, "Destino inválido não altera contadores")
	expect(session.sort_into("paper") and session.score == 10 and session.correct == 1, "Classificação correta consome item e pontua")
	expect(not session.collect("0") and not session.sort_into("paper") and session.score == 10, "Item destinado não pode render pontos novamente")
	for i in range(1, 3):
		session.collect(str(i))
		session.sort_into("paper")
	expect(session.score == 60 and session.streak == 3, "Terceiro acerto concede exatamente +20")
	expect(session.cleaning_index() == 50, "Índice mede destinos corretos, não coletas")
	session.collect("3")
	session.sort_into("plastic")
	expect(session.streak == 0, "Erro interrompe sequência")
	session.sort_into("paper")
	for i in range(4, 6):
		session.collect(str(i))
		session.sort_into("paper")
	expect(session.score == 120 and session.cleaning_index() == 100, "Nova sequência concede um bônus; conclusão chega a 100%")
	session.queue_free()
	await process_frame
	var scene = load("res://scenes/levels/foundation.tscn").instantiate()
	root.add_child(scene)
	current_scene = scene
	await frames()
	var player := scene.get_node("Player") as CharacterBody3D
	var interaction = scene.get_node("Interaction")
	var live = scene.get_node("Session")
	expect(live.records.size() == 6 and get_nodes_in_group("training_bins").size() == 2, "Treino cria seis resíduos e duas lixeiras")
	player.position = Vector3(10, 0, 10)
	await frames()
	interaction.interact()
	expect(live.collected == 0, "E fora de alcance não coleta")
	var waste = get_nodes_in_group("training_waste")[0]
	player.position = waste.position + Vector3(0, 0.05, 1)
	await frames()
	var event := InputEventAction.new()
	event.action = "interact"
	event.pressed = true
	Input.parse_input_event(event)
	await frames()
	event = InputEventAction.new()
	event.action = "interact"
	event.pressed = false
	Input.parse_input_event(event)
	expect(live.collected == 1 and not waste.visible and live.score == 5, "Entrada E coleta, oculta resíduo e atualiza pontos")
	interaction.interact()
	expect(live.collected == 1 and live.score == 5, "E repetido longe da lixeira não duplica coleta")
	var bins := get_nodes_in_group("training_bins")
	player.position = bins[1].position + Vector3(1.2, 0.05, 0)
	await frames()
	interaction.interact()
	expect(live.errors == 1 and live.correct == 0 and not live.carried_id.is_empty(), "Lixeira errada registra erro e preserva item")
	player.position = bins[0].position + Vector3(1.2, 0.05, 0)
	await frames()
	interaction.interact()
	expect(live.correct == 1 and live.carried_id.is_empty() and live.score == 10, "Lixeira certa conclui classificação")
	expect(scene.get_node("TrainingHUD").status.text.contains("Pontos: 10"), "HUD acompanha sessão real")
	var available = get_nodes_in_group("training_waste")[1]
	available.position = Vector3(0, 0, -7.7)
	player.position = Vector3(0, 0.05, -6.2)
	await frames()
	expect(not interaction.has_line_of_sight(available), "Parede bloqueia alcance de interação")
	interaction.interact()
	expect(live.collected == 1, "Não coleta através da parede")
	available.position = Vector3(1.1, 0, 0.5)
	for item in get_nodes_in_group("training_waste"):
		if live.records[item.waste_id]["state"] == Session.WasteState.SORTED:
			continue
		player.position = item.position + Vector3(0, 0.05, 1)
		await frames()
		interaction.interact()
		var bin = bins[0] if item.material == "paper" else bins[1]
		player.position = bin.position + Vector3(1.2, 0.05, 0)
		await frames()
		interaction.interact()
	expect(live.correct == 6 and live.collected == 6 and live.cleaning_index() == 100 and live.score == 125, "Ciclo completo de seis itens com placar e bônus exatos")
	expect(scene.get_node("TrainingHUD").prompt.text.contains("Treino concluído"), "Conclusão exibe orientação de reinício")
	var before = current_scene
	var restart := InputEventAction.new()
	restart.action = "restart_training"
	restart.pressed = true
	Input.parse_input_event(restart)
	await frames(5)
	expect(current_scene != before and current_scene.get_node("Session").score == 0 and current_scene.get_node("Session").collected == 0, "R reinicia cena e sessão sem pontos antigos")
	Input.action_release("restart_training")
	current_scene.queue_free()
	await process_frame
	print("RESULT: %d verificações, %d falhas" % [checks, failures])
	quit(0 if failures == 0 else 1)
