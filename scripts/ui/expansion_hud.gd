extends "res://scripts/ui/mission_hud.gd"
var inspection_overlay: ColorRect
func _ready() -> void:
	super._ready()
	if mission.mission_id == "ubatiba":
		mission.inspection_changed.connect(refresh_inspection)
func update_screen() -> void:
	if not is_inside_tree() or mission.progress == null:
		return
	if mission.state != Mission.State.INSTRUCOES:
		super.update_screen()
		return
	for node in content.get_children():
		content.remove_child(node)
		node.queue_free()
	overlay.show()
	results_button.hide()
	menu_card.custom_minimum_size.x = 840
	label(content, mission.definition()["title"], 27)
	if mission.mission_id == "ubatiba":
		label(content, "Inspecione 12 pontos e escolha ações conforme o terreno.", 20)
		label(content, "• Conclua 12 avaliações, oito plantios corretos e três proteções.\n• Prepare os pontos aptos antes de plantar uma muda nativa adequada.\n• Nos três solos expostos, acrescente proteção após o plantio.\n• Preserve os quatro pontos não aptos; não plante em todo lugar.\n• Prazo: 300s. A quarta decisão incorreta encerra a missão.", 18)
		label(content, "E inspeciona • Escolha uma ação nos botões • Fechar/Esc volta ao terreno. O tempo continua durante a decisão. Plantio isolado não elimina riscos de deslizamento; a demonstração de chuva não é geotecnia.", 17)
	else:
		label(content, "Caminhe até o píer, use E no barco e navegue para coletar.", 20)
		label(content, "• Destine corretamente 20 resíduos em 360s.\n• No barco: W/S aceleram e freiam; A/D viram gradualmente.\n• E coleta na água; capacidade máxima de cinco itens.\n• Retorne devagar ao píer e use E para desembarcar.\n• Em terra, E classifica um item de cada vez; o próximo vem da carga.\n• Quinta saída de resíduo ou tempo zero encerra a missão.", 18)
		label(content, "Erros de classificação permitem corrigir. Até a quarta perda há reposição controlada. Navegação e água são simplificadas; não são instruções de operação de embarcação real.", 17)
	button("Começar missão", mission.start_mission,false,null,true)
	button("Voltar ao menu", mission.go_menu)
	animate_screen()
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
	label(rows, "INSPEÇÃO • PONTO %02d" % (point.plot_id.get_slice("_",1).to_int()+1), 25)
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
