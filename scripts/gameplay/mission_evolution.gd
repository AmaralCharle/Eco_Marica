extends Node
## Decisões e opcionais leem a sessão. Nunca alteram pontos ou critérios de vitória.
const ThemeDesign = preload("res://scripts/ui/eco_theme.gd")
const OPTIONALS = {"aracatiba":"Preparar embalagem composta","itaipuacu":"Cinco destinos antes de uma perda","centro":"Atender um bueiro prioritário","ubatiba":"Interpretar solo e cobertura","ponta_negra":"Descarregar uma viagem com quatro itens"}
var mission: Node3D
var session: RecyclingSession
var completed: Dictionary = {}
var decisions: int = 0
var decision_errors: int = 0
var priority_hits: int = 0
var max_cargo: int = 0
var last_cargo: int = 0
var previous_drains: Dictionary = {}
var hud_text: String = ""
var refresh_time: float = 0.0
var modal: CanvasLayer
var question: Dictionary = {}
var answer_feedback: Label
var lesson_number: int = 0
func _ready() -> void:
	mission = get_parent()
	session = mission.session
	previous_drains = session.drains.duplicate()
	session.changed.connect(on_changed)
	if mission.mission_id == "aracatiba": prepare_compounds()
	refresh_hint()
func prepare_compounds() -> void:
	var count := 0
	for item in get_tree().get_nodes_in_group("training_waste"):
		if not mission.is_ancestor_of(item) or item.material != "plastic" or count >= 2: continue
		item.set_meta("compound",true)
		var sleeve := MeshInstance3D.new()
		sleeve.name = "PaperSleeve"
		var shape := CylinderMesh.new()
		shape.top_radius = 0.153
		shape.bottom_radius = 0.153
		shape.height = 0.13
		shape.radial_segments = 12
		sleeve.mesh = shape
		sleeve.position.y = 0.28
		var mat := StandardMaterial3D.new()
		mat.albedo_color = Color("dfd5ad")
		mat.roughness = 0.95
		sleeve.material_override = mat
		item.add_child(sleeve)
		item.item_label.text = "Plástico + rótulo removível • Q"
		count += 1
func _process(delta: float) -> void:
	if not session.active: return
	refresh_time -= delta
	if refresh_time <= 0:
		refresh_time = 0.25
		refresh_hint()
func urgency(drain: Node3D) -> int:
	var count := 0
	for item in get_tree().get_nodes_in_group("training_waste"):
		if mission.is_ancestor_of(item) and session.records.has(item.waste_id) and session.records[item.waste_id].state == session.WasteState.AVAILABLE and item.position.distance_to(drain.position) < 7.0: count += 1
	return count
func priorities(include_previous: bool = false) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for drain in get_tree().get_nodes_in_group("mission_drains"):
		if not mission.is_ancestor_of(drain): continue
		var cleaned: bool = previous_drains.get(drain.drain_id,false) if include_previous else session.drains[drain.drain_id]
		if not cleaned: result.append({"node":drain,"nearby":urgency(drain)})
	result.sort_custom(func(a: Dictionary,b: Dictionary): return a.nearby > b.nearby)
	return result
func complete_optional() -> void:
	var id: String = mission.mission_id
	if completed.has(id): return
	completed[id] = true
	session.feedback.emit("Opcional concluído: "+OPTIONALS[id]+". A missão principal continua.",true)
	get_node("/root/GameAudio").play_event("optional")
func on_changed() -> void:
	match mission.mission_id:
		"centro":
			var ranked := priorities(true)
			for id in session.drains:
				if session.drains[id] and not previous_drains.get(id,false):
					for entry in ranked:
						if entry.node.drain_id == id and entry.nearby == ranked[0].nearby:
							priority_hits += 1
							complete_optional()
			previous_drains = session.drains.duplicate()
		"itaipuacu":
			if session.correct >= 5 and session.lost_count == 0: complete_optional()
		"ponta_negra":
			max_cargo = maxi(max_cargo,session.boat_inventory.size())
			if session.boat_inventory.size() < last_cargo and max_cargo >= 4: complete_optional()
			last_cargo = session.boat_inventory.size()
	refresh_hint()
func refresh_hint() -> void:
	var detail := "Q  Caderno de decisões"
	match mission.mission_id:
		"itaipuacu": detail = "Brisa lateral suave · Q para observar"
		"centro":
			var ranked := priorities()
			if not ranked.is_empty(): detail = "Prioridade: bueiro %d · %d resíduos próximos" % [int(ranked[0].node.drain_id.get_slice("_",2))+1,ranked[0].nearby]
		"ponta_negra":
			var boat = mission.get_node("Boat")
			var origin: Vector3 = boat.position if mission.on_boat else mission.player.position
			var distance: float = Vector2(origin.x-boat.dock_position.x,origin.z-boat.dock_position.z).length()
			detail = "Píer %.0f m · %d vagas · Q planejar" % [distance,5-session.boat_inventory.size()]
	hud_text = "OPCIONAL · "+("Concluído ✓" if completed.has(mission.mission_id) else OPTIONALS[mission.mission_id])+"\n"+detail
func make_question() -> Dictionary:
	var title := "Caderno de decisões"
	var body := ""
	var options: Array[String] = []
	var correct := 0
	var accepted: Array[int] = [0]
	match mission.mission_id:
		"aracatiba":
			title = "Uma embalagem, duas partes"
			body = "Duas garrafas desta missão têm um rótulo de papel limpo e removível. Como preparar esse exemplo?\nO corpo plástico continua sendo uma unidade da meta; o rótulo ilustra a separação e não gera pontos extras."
			options.assign(["Separar as partes removíveis e consultar a coleta local","Classificar toda embalagem composta como papel","Descartar no ambiente porque tem dois materiais"])
		"itaipuacu":
			title = "Vento e prioridade na praia"
			body = "A brisa desloca os itens lateralmente, de modo lento e limitado. O marcador → MAR informa o prazo de cada item móvel. Qual informação ajuda a escolher o próximo resgate?"
			options.assign(["Priorizar o menor prazo → MAR, observando a rota","Ignorar os marcadores e esperar o vento parar","Supor que itens já coletados continuam à deriva"])
		"centro":
			title = "Qual bueiro atender primeiro?"
			body = "Na simulação, a prioridade considera os resíduos ainda soltos a menos de 7 m do bueiro. Não é uma previsão de enchentes. Compare os valores; empates são equivalentes."
			var ranked := priorities()
			if ranked.is_empty():
				options.assign(["Todos já foram atendidos; concluir os resíduos","Limpar novamente para duplicar os pontos","Ignorar o prazo da missão"])
			else:
				accepted.clear()
				for entry in ranked:
					if entry.nearby == ranked[0].nearby: accepted.append(options.size())
					options.append("Bueiro %d · %d resíduos próximos" % [int(entry.node.drain_id.get_slice("_",2))+1,entry.nearby])
		"ubatiba":
			title = "Ler o solo antes de agir"
			var nearest: Node3D
			var distance := INF
			for point in get_tree().get_nodes_in_group("planting_plots"):
				if mission.is_ancestor_of(point) and point.position.distance_to(mission.player.position) < distance:
					nearest = point
					distance = point.position.distance_to(mission.player.position)
			body = "Laudo do ponto mais próximo: "+nearest.reason+"\nUse E no terreno para executar as ações. Esta leitura é opcional e não substitui as 12 avaliações."
			var action := "Preparar, plantar muda adequada e proteger o solo" if nearest.exposed else "Preparar e plantar a muda adequada" if nearest.apt else "Preservar a cobertura; não abrir um plantio"
			options.assign([action,"Plantar sem considerar o laudo","Retirar toda a cobertura existente"])
		"ponta_negra":
			title = "Planejar a próxima viagem"
			var boat = mission.get_node("Boat")
			body = "Carga %d/5 · Píer a %.0f m · Tempo restante %ds.\nA distância é uma indicação em linha reta; considere a margem e o acesso ao píer." % [session.boat_inventory.size(),boat.position.distance_to(boat.dock_position),ceili(mission.remaining)]
			options.assign(["Voltar ao píer e descarregar antes de coletar mais" if session.boat_inventory.size() == 5 else "Planejar lotes de até cinco e reservar tempo para retornar","Ignorar a capacidade e coletar dez itens","Tentar desembarcar em qualquer ponto da margem"])
	# Reordenação determinística evita que a resposta seja sempre o primeiro botão.
	var shift := lesson_number%options.size()
	for i in shift: options.push_back(options.pop_front())
	correct = posmod(-shift,options.size())
	for i in accepted.size(): accepted[i] = posmod(accepted[i]-shift,options.size())
	return {"title":title,"body":body,"options":options,"correct":correct,"accepted":accepted}
func open_notebook() -> bool:
	if not session.active or is_instance_valid(modal): return false
	question = make_question()
	lesson_number += 1
	mission.set_state(mission.State.PAUSADO)
	modal = CanvasLayer.new()
	modal.layer = 15
	add_child(modal)
	var dim := ColorRect.new()
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dim.color = Color(0.025,0.065,0.07,0.82)
	modal.add_child(dim)
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dim.add_child(center)
	var panel := PanelContainer.new()
	panel.custom_minimum_size.x = 760
	panel.add_theme_stylebox_override("panel",ThemeDesign.frame(0.97,24))
	center.add_child(panel)
	var rows := VBoxContainer.new()
	rows.add_theme_constant_override("separation",12)
	panel.add_child(rows)
	add_text(rows,"DECISÃO OPCIONAL · O tempo fica pausado",13)
	add_text(rows,question.title,26)
	add_text(rows,question.body,17)
	for i in question.options.size():
		var button := Button.new()
		button.text = question.options[i]
		button.custom_minimum_size.y = 42
		button.add_theme_font_size_override("font_size",16)
		button.pressed.connect(answer.bind(i))
		rows.add_child(button)
	answer_feedback = add_text(rows,"Errar aqui não altera os erros ou pontos da missão principal.",14)
	var back := Button.new()
	back.text = "Voltar ao cenário · Esc"
	back.custom_minimum_size.y = 40
	back.pressed.connect(close_notebook)
	rows.add_child(back)
	rows.get_child(3).grab_focus()
	return true
func add_text(parent: Node,value: String,size: int) -> Label:
	var label := Label.new()
	label.text = value
	label.custom_minimum_size.x = 700
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("font_size",size)
	parent.add_child(label)
	return label
func answer(index: int) -> bool:
	if not is_instance_valid(modal) or index < 0 or index >= question.options.size(): return false
	decisions += 1
	if index not in question.accepted:
		decision_errors += 1
		answer_feedback.text = "Reveja o laudo e os valores. A missão principal não foi penalizada."
		return false
	get_node("/root/GameAudio").play_event("decision")
	if mission.mission_id in ["aracatiba","ubatiba"]: complete_optional()
	if mission.mission_id == "aracatiba":
		for item in get_tree().get_nodes_in_group("training_waste"):
			if mission.is_ancestor_of(item) and item.has_meta("compound"):
				item.get_node("PaperSleeve").hide()
				item.item_label.text = "Garrafa plástica • Partes separadas"
	close_notebook()
	return true
func close_notebook() -> void:
	if not is_instance_valid(modal): return
	modal.queue_free()
	modal = null
	if mission.state == mission.State.PAUSADO: mission.set_state(mission.State.JOGANDO)
	refresh_hint()
func _input(event: InputEvent) -> void:
	if event.is_echo(): return
	if is_instance_valid(modal) and event.is_action_pressed("release_mouse"):
		close_notebook()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("field_notes"):
		if open_notebook(): get_viewport().set_input_as_handled()
