extends "res://scripts/ui/mission_hud.gd"
var inspection_overlay: ColorRect
func _ready() -> void:
	super._ready()
	if mission.mission_id == "ubatiba":
		mission.inspection_changed.connect(refresh_inspection)
func update_screen() -> void:
	if not is_inside_tree() or mission.progress == null:
		return
	if mission.state not in [Mission.State.INSTRUCOES, Mission.State.VITORIA, Mission.State.DERROTA]:
		super.update_screen()
		return
	for node in content.get_children():
		content.remove_child(node)
		node.queue_free()
	overlay.show()
	results_button.hide()
	if mission.state == Mission.State.INSTRUCOES:
		label(content, mission.definition()["title"], 27)
		if mission.mission_id == "ubatiba":
			label(content, "Inspecione 12 pontos e escolha ações conforme o terreno.", 20)
			label(content, "• Conclua 12 avaliações, oito plantios corretos e três proteções.\n• Prepare os pontos aptos antes de plantar uma muda nativa adequada.\n• Nos três solos expostos, acrescente proteção após o plantio.\n• Preserve os quatro pontos não aptos; não plante em todo lugar.\n• Prazo: 300s. A quarta decisão incorreta encerra a missão.", 18)
			label(content, "E inspeciona • Escolha uma ação nos botões • Fechar/Esc volta ao terreno. O tempo continua durante a decisão. Plantio isolado não elimina riscos de deslizamento; a demonstração de chuva não é geotecnia.", 17)
		else:
			label(content, "Caminhe até o píer, use E no barco e navegue para coletar.", 20)
			label(content, "• Destine corretamente 20 resíduos em 360s.\n• No barco: W/S aceleram e freiam; A/D viram gradualmente.\n• E coleta na água; capacidade máxima de cinco itens.\n• Retorne devagar ao píer e use E para desembarcar.\n• Em terra, E classifica um item de cada vez; o próximo vem da carga.\n• Quinta saída de resíduo ou tempo zero encerra a missão.", 18)
			label(content, "Erros de classificação permitem corrigir. Até a quarta perda há reposição controlada. Navegação e água são simplificadas; não são instruções de operação de embarcação real.", 17)
		button("Começar missão", mission.start_mission)
		button("Voltar ao menu", mission.go_menu)
	else:
		var won: bool = mission.state == Mission.State.VITORIA
		label(content, mission.definition()["short_name"] + (" • Missão concluída!" if won else " • Tente novamente"), 28)
		label(content, mission.result_reason, 19)
		label(content, "Pontos: %d • Tempo usado: %ds • Índice: %d%%" % [session.score, ceili(mission.definition()["duration"] - mission.remaining), session.cleaning_index()], 20)
		if mission.mission_id == "ubatiba":
			label(content, "Avaliações %d/12 • Plantios %d/8\nProteções %d/3 • Decisões incorretas %d" % [session.assessed, session.planted, session.protected_soil, session.errors], 20)
			label(content, "Mudas e cobertura são ações complementares. Estabilidade de encostas exige avaliação técnica; o jogo não elimina riscos reais.", 17)
		else:
			label(content, "Destinos corretos %d/20 • Perdas %d/5 • Erros %d" % [session.correct, session.lost_count, session.errors], 20)
		if won:
			label(content, "Bônus de missão: +100 • Resultado registrado no jogo", 18)
			if not mission.save_ok:
				label(content, "Falha ao gravar: resultado vale somente nesta sessão.", 17)
			button("Ver área recuperada", func(): overlay.hide(); results_button.show())
			if mission.mission_id == "ubatiba":
				button("Próxima fase • Ponta Negra", func(): mission.open_level("ponta_negra"))
			else:
				button("Celebrar • Ver conclusão da campanha", mission.show_campaign_completion)
		button("Jogar novamente", mission.restart)
		button("Voltar ao menu", mission.go_menu)
func _process(delta: float) -> void:
	if mission.progress == null:
		return
	var seconds: int = ceili(mission.remaining)
	if mission.mission_id == "ubatiba":
		status.text = "TEMPO %02d:%02d • Pontos %d\nAvaliações %d/12 • Plantios %d/8\nProteções %d/3 • Erros %d/4\nRecuperação %d%%" % [seconds / 60, seconds % 60, session.score, session.assessed, session.planted, session.protected_soil, session.errors, session.cleaning_index()]
	else:
		status.text = "TEMPO %02d:%02d • Pontos %d\nDestinos %d/20 • Perdas %d/5\nCarga %d/5 • Em mãos %s\nModo: %s • Limpeza %d%%" % [seconds / 60, seconds % 60, session.score, session.correct, session.lost_count, session.boat_inventory.size(), session.carried_material_name(), "BARCO" if mission.on_boat else "TERRA", session.cleaning_index()]
	if mission.state == Mission.State.JOGANDO:
		feedback_time = maxf(0, feedback_time - delta)
	if is_zero_approx(feedback_time):
		feedback.text = "Cada ponto tem uma necessidade. Inspecione antes de agir." if mission.mission_id == "ubatiba" else "Carga cheia? Retorne ao píer, pare e use E para desembarcar."
func refresh_inspection() -> void:
	if is_instance_valid(inspection_overlay):
		remove_child(inspection_overlay)
		inspection_overlay.queue_free()
		inspection_overlay = null
	if mission.inspection_target == null or mission.state != Mission.State.JOGANDO:
		return
	inspection_overlay = ColorRect.new()
	inspection_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	inspection_overlay.color = Color(0.01, 0.04, 0.03, 0.6)
	add_child(inspection_overlay)
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	inspection_overlay.add_child(center)
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(720, 0)
	panel.add_theme_stylebox_override("panel", style())
	center.add_child(panel)
	var rows := VBoxContainer.new()
	rows.add_theme_constant_override("separation", 8)
	panel.add_child(rows)
	var point = mission.inspection_target
	var data: Dictionary = session.plots[point.plot_id]
	label(rows, "INSPEÇÃO • " + point.plot_id, 25)
	label(rows, point.reason, 19)
	label(rows, "Apto: %s • Solo exposto: %s\nPreparado: %s • Plantado: %s • Protegido: %s" % ["sim" if data["apt"] else "não", "sim" if data["exposed"] else "não", "sim" if data["prepared"] else "não", "sim" if data["planted"] else "não", "sim" if data["protected"] else "não"], 18)
	for action: String in ["prepare", "plant", "protect", "preserve", "exotic"]:
		var choice := Button.new()
		choice.text = {"prepare": "Preparar ponto apto", "plant": "Plantar muda nativa adequada", "protect": "Aplicar proteção complementar ao solo", "preserve": "Preservar: não plantar neste ponto", "exotic": "Plantar espécie sem verificar adequação"}[action]
		choice.custom_minimum_size.y = 38
		choice.add_theme_font_size_override("font_size", 18)
		choice.disabled = session.resolved(data)
		choice.pressed.connect(func(): mission.choose_action(action))
		rows.add_child(choice)
	var close := Button.new()
	close.text = "Concluir inspeção • Voltar ao terreno"
	close.custom_minimum_size.y = 40
	close.pressed.connect(mission.close_inspection)
	rows.add_child(close)
	close.grab_focus()
