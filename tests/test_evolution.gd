extends SceneTree
var checks := 0
var failures := 0
func _initialize() -> void: call_deferred("run")
func frames() -> void:
	for i in 5: await process_frame
func check(ok: bool,title: String) -> void:
	checks += 1
	if not ok: failures += 1; push_error(title)
func run() -> void:
	for id: String in ["aracatiba","itaipuacu","centro","ubatiba","ponta_negra"]:
		var level = load("res://scenes/levels/"+id+".tscn").instantiate()
		level.profile_path = "res://tests/artifacts/evolution_profile.json"
		level.progress_path = "res://tests/artifacts/evolution_progress.json"
		root.add_child(level)
		current_scene = level
		level.set_physics_process(false)
		await frames()
		var service = level.evolution
		check(not service.open_notebook(),"Caderno bloqueado fora da missão: "+id)
		level.set_state(level.State.JOGANDO)
		level.player.set_physics_process(false)
		var remaining: float = level.remaining
		var count: int = level.session.records.size()
		check(service.open_notebook() and not level.session.active,"Decisão pausa sem alterar a sessão: "+id)
		level.advance_time(10)
		check(level.remaining == remaining,"Tempo preservado durante leitura: "+id)
		var wrong := -1
		for i in service.question.options.size():
			if i not in service.question.accepted: wrong = i
		if wrong >= 0: check(not service.answer(wrong) and level.session.errors == 0 and level.session.score == 0,"Resposta errada não pune missão principal: "+id)
		check(service.answer(service.question.correct) and level.session.active,"Resposta fundamentada retoma missão: "+id)
		check(level.session.records.size() == count and level.session.score == 0,"Decisão não duplica objetos nem pontos: "+id)
		check(not service.answer(0),"Resposta não pode repetir com modal fechado: "+id)
		var notes := InputEventAction.new()
		notes.action = "field_notes"
		notes.pressed = true
		Input.parse_input_event(notes)
		await frames()
		Input.action_release("field_notes")
		check(is_instance_valid(service.modal) and level.state == level.State.PAUSADO,"Q real abre a decisão: "+id)
		var escape := InputEventAction.new()
		escape.action = "release_mouse"
		escape.pressed = true
		Input.parse_input_event(escape)
		await frames()
		Input.action_release("release_mouse")
		check(not is_instance_valid(service.modal) and level.state == level.State.JOGANDO,"Esc fecha só o caderno e retoma uma vez: "+id)
		if id == "aracatiba":
			var compounds := 0
			for item in get_nodes_in_group("training_waste"):
				if item.has_meta("compound"):
					compounds += 1
					check(not item.get_node("PaperSleeve").visible,"Preparação retira apenas a parte visual removível")
			check(compounds == 2 and service.completed.has(id) and count == 15,"Compostos mantêm meta original de quinze")
		if id == "itaipuacu":
			var item
			for candidate in get_nodes_in_group("training_waste"):
				if candidate.drift_speed > 0: item = candidate; break
			var start: Vector3 = item.position
			for i in 10: item.advance_drift(0.5,level.session)
			check(is_equal_approx(item.position.x,start.x-item.drift_speed*5) and absf(item.position.z-start.z) <= 0.45,"Vento lateral limitado preserva prazo até o mar")
			level.session.collect(item.waste_id)
			var stopped: Vector3 = item.position
			item.advance_drift(5,level.session)
			check(item.position == stopped,"Coletado deixa de sofrer vento")
		if id == "centro":
			var ranked: Array = service.priorities()
			level.session.clean_drain(ranked[0].node.drain_id)
			check(service.priority_hits == 1 and service.completed.has(id),"Atendimento real da prioridade conclui opcional")
		if id == "ubatiba": check(level.session.assessed == 0 and service.completed.has(id),"Leitura não substitui avaliações de terreno")
		if id == "ponta_negra":
			level.player.position = level.get_node("Boat").landing_position
			level.try_board()
			for key in level.session.records.keys().slice(0,4): level.session.store_from_boat(key)
			level.try_disembark()
			check(service.max_cargo == 4 and service.completed.has(id) and level.session.collected == 4,"Opcional de rota depende de carga e descarga reais")
		check(level.state == level.State.JOGANDO,"Opcionais não encerram missão principal: "+id)
		level.queue_free()
		await process_frame
	print("RESULT: %d verificações, %d falhas" % [checks,failures])
	quit(0 if failures == 0 else 1)
