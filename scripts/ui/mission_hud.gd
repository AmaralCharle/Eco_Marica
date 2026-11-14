extends CanvasLayer
const Catalog = preload("res://scripts/core/character_catalog.gd")
const Selector = preload("res://scripts/ui/character_selection.gd")
const Config = preload("res://scripts/core/game_config.gd")
const Mission = preload("res://scripts/levels/aracatiba.gd")
var mission: Node3D
var session: RecyclingSession
var status: Label
var prompt: Label
var feedback: Label
var overlay: ColorRect
var content: VBoxContainer
var results_button: Button
var selector: CharacterSelection
var feedback_time: float = 0.0

func _ready() -> void:
	mission = get_parent()
	session = mission.get_node("Session")
	var heading := panel(Control.PRESET_TOP_LEFT, Vector4(16, 16, 570, 160))
	var title := label(heading, "ECO MARICÁ • " + mission.definition()["title"], 22)
	title.add_theme_color_override("font_color", Color("a4efc5"))
	label(heading, mission.definition()["objective"], 18)
	label(heading, "WASD mover • Shift correr • Espaço pular", 16)
	label(heading, "Mouse câmera • E interagir • Esc pausar", 16)
	var stats := panel(Control.PRESET_TOP_RIGHT, Vector4(-350, 16, -16, 195))
	status = label(stats, "", 18)
	var bottom := panel(Control.PRESET_BOTTOM_WIDE, Vector4(16, -146, -16, -16))
	prompt = label(bottom, "", 20)
	feedback = label(bottom, "", 17)
	label(bottom, mission.definition()["note"], 14)
	overlay = ColorRect.new()
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.color = Color(0.015, 0.04, 0.06, 0.68)
	add_child(overlay)
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.add_child(center)
	var card := PanelContainer.new()
	card.custom_minimum_size = Vector2(760, 0)
	card.add_theme_stylebox_override("panel", style())
	center.add_child(card)
	content = VBoxContainer.new()
	content.add_theme_constant_override("separation", 12)
	card.add_child(content)
	results_button = Button.new()
	results_button.text = "Mostrar resultados"
	results_button.position = Vector2(590, 16)
	results_button.pressed.connect(func(): overlay.show(); results_button.hide())
	results_button.hide()
	add_child(results_button)
	mission.state_changed.connect(update_screen)
	session.feedback.connect(show_feedback)
	mission.get_node("Interaction").prompt_changed.connect(func(text: String): prompt.text = text)
	call_deferred("update_screen")

func style() -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = Color(0.025, 0.09, 0.12, 0.96)
	box.content_margin_left = 22
	box.content_margin_right = 22
	box.content_margin_top = 18
	box.content_margin_bottom = 18
	box.set_corner_radius_all(14)
	return box

func panel(preset: int, offsets: Vector4) -> VBoxContainer:
	var box := PanelContainer.new()
	box.set_anchors_and_offsets_preset(preset)
	box.offset_left = offsets.x
	box.offset_top = offsets.y
	box.offset_right = offsets.z
	box.offset_bottom = offsets.w
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_theme_stylebox_override("panel", style())
	add_child(box)
	var rows := VBoxContainer.new()
	rows.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rows.add_theme_constant_override("separation", 6)
	box.add_child(rows)
	return rows

func label(parent: Node, text: String, size: int = 19) -> Label:
	var node := Label.new()
	node.text = text
	node.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	node.add_theme_font_size_override("font_size", size)
	node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(node)
	return node

func button(text: String, callback: Callable, disabled: bool = false) -> Button:
	var node := Button.new()
	node.text = text
	node.custom_minimum_size.y = 43
	node.add_theme_font_size_override("font_size", 18)
	node.disabled = disabled
	node.pressed.connect(callback)
	content.add_child(node)
	return node

func update_screen() -> void:
	if not is_inside_tree() or mission.progress == null:
		return
	for node in content.get_children():
		content.remove_child(node)
		node.queue_free()
	overlay.visible = mission.state != Mission.State.JOGANDO
	results_button.hide()
	match mission.state:
		Mission.State.MENU:
			label(content, "ECO MARICÁ — Guardiões da Cidade", 30)
			label(content, "Uma jornada de cuidado com os espaços públicos.", 21)
			label(content, "Guardião: %s • Um jogador • Offline" % Catalog.get_character(mission.profile.selected_id)["name"], 17)
			button("Escolher personagem", mission.show_character_selection)
			for id in mission.Definitions.IDS:
				var destination: Dictionary = mission.Definitions.get_mission(id)
				var accessible: bool = mission.progress.unlocked_level >= destination["number"]
				button(("Jogar • " if accessible else "Bloqueada • ") + destination["title"], func(): mission.open_level(id), not accessible)
			button("Treinar coleta e classificação", func(): get_tree().change_scene_to_file("res://scenes/levels/foundation.tscn"))
			if mission.progress.campaign_completed:
				button("Campanha concluída • Rever conclusão", mission.show_campaign_completion)
			button("Sair", func(): get_tree().quit())
		Mission.State.SELECAO_PERSONAGEM:
			selector = Selector.new()
			selector.pending_id = mission.profile.selected_id
			content.add_child(selector)
			selector.confirmed.connect(func(id: String):
				if not mission.confirm_character(id):
					selector.show_save_error()
			)
			selector.back_requested.connect(mission.cancel_character_selection)
		Mission.State.INSTRUCOES:
			var spec: Dictionary = mission.definition()
			label(content, "MISSÃO %02d • %s" % [spec["number"], spec["title"]], 27)
			if mission.mission_id == "centro":
				label(content, "Uma equipe de guardiões cuida de uma cidade fictícia antes da tempestade. Conclua as duas tarefas antes do prazo.", 18)
				label(content, "• Destine corretamente os 15 resíduos em até 180 segundos.\n• Com as mãos livres, use E para limpar três bueiros.\n• Erros de classificação permitem corrigir, com penalidade de pontos.\n• Nuvens e chuva se intensificam conforme o tempo passa.", 18)
				label(content, "Limpeza de bueiros aqui é uma ação simulada. Reduzir obstruções não garante evitar enchentes. Na vida real, comunique obstruções à prefeitura e evite áreas alagadas.", 18)
			elif mission.mission_id == "itaipuacu":
				label(content, "Uma praia fictícia inspirada em Itaipuaçu. Classifique quatro materiais e priorize os resíduos que se aproximam do mar.")
				label(content, "• Conclua 20 destinos corretos em até 240 segundos.\n• Cinco resíduos levados ao mar encerram a missão.\n• Itens com → MAR mostram quanto tempo falta para alcançarem a água.\n• Coletar interrompe o deslocamento. Erro de classificação permite corrigir.\n• Após uma perda, um novo item aparece na areia; a perda continua registrada.", 18)
				label(content, "Papel: azul • Plástico: vermelho • Vidro: verde • Metal: amarelo", 18)
			else:
				label(content, "Explore uma orla fictícia inspirada em Maricá. Recolha e classifique os materiais para cuidar desse espaço.")
				label(content, "• Recolha e destine os 15 resíduos em até 300 segundos.\n• Acerte pelo menos 12 destinos; o quarto erro encerra a missão.\n• Leve um item por vez até uma lixeira e use E.\n• Na missão, o descarte errado consome o item e conta como erro.\n• Papel: coletor azul. Plástico: coletor vermelho. Leia os nomes.")
			label(content, "WASD mover • Mouse câmera • Shift correr • Espaço pular\nE coletar/destinar • Esc pausar. O tempo começa ao clicar abaixo.", 17)
			button("Começar missão", mission.start_mission)
			button("Voltar ao menu", mission.go_menu)
		Mission.State.FINALIZADO:
			content.add_theme_constant_override("separation", 7)
			label(content, "ECO MARICÁ • Campanha concluída!", 27)
			label(content, "Cinco locais • Uma jornada de cuidado", 18)
			var map := preload("res://scripts/ui/campaign_map.gd").new()
			map.completed = mission.progress.completed_levels
			content.add_child(map)
			var totals: Dictionary = mission.progress.totals()
			label(content, "Pontuação acumulada (melhores missões): %d\nDestinos corretos: %d • Plantios: %d • Proteções: %d • Bueiros: %d" % [mission.progress.total_score(), totals["correct"], totals["planted"], totals["protected"], totals["drains"]], 19)
			label(content, "Mapa esquemático. Estatísticas são ações no jogo, não impacto ambiental real." + (" Fases antigas não possuem estatísticas detalhadas." if mission.progress.legacy_stats_missing else ""), 16)
			label(content, "Obrigado por cuidar da cidade. Coleta local, restauração orientada e prevenção exigem ações contínuas. O jogo não comprova aprendizagem nem elimina riscos reais.", 18)
			label(content, "Guardião: " + Catalog.get_character(mission.profile.selected_id)["name"] + (" • Conclusão registrada localmente" if mission.save_ok else " • Conclusão nesta sessão; não foi possível gravar"), 17)
			button("Voltar ao menu", mission.go_menu)
			button("Rejogar Operação Araçatiba", func(): mission.open_level("aracatiba"))
		Mission.State.PAUSADO:
			label(content, "MISSÃO PAUSADA", 30)
			label(content, "O cronômetro e as interações estão suspensos.")
			button("Continuar", func(): mission.set_state(Mission.State.JOGANDO))
			button("Reiniciar missão", mission.restart)
			button("Voltar ao menu", mission.go_menu)
		Mission.State.VITORIA, Mission.State.DERROTA:
			var won: bool = mission.state == Mission.State.VITORIA
			label(content, mission.definition()["short_name"].to_upper() + " • Missão concluída!" if won else "MISSÃO ENCERRADA • Tente novamente", 28)
			label(content, mission.result_reason)
			label(content, "Pontos: %d   •   Tempo utilizado: %ds\nColetados: %d   •   Acertos: %d   •   Erros: %d\nÍndice de Limpeza: %d%%" % [session.score, ceili(mission.definition()["duration"] - mission.remaining), session.collected, session.correct, session.errors, session.cleaning_index()], 21)
			if mission.mission_id == "centro":
				label(content, "Bueiros limpos: %d/%d • Ação de redução de risco simulada" % [session.drains_cleaned, Config.CENTRO_DRAINS], 18)
			elif mission.mission_id == "itaipuacu":
				label(content, "Resíduos levados ao mar: %d/5 • Meta: 20 destinos corretos" % session.lost_count, 18)
			if won:
				label(content, "Bônus de missão: +100 • Campanha concluída" if mission.mission_id == "ponta_negra" else "Bônus de missão: +100 • Próxima área: " + mission.definition()["next_name"], 18)
				label(content, "Recuperação visual simbólica. O índice considera destinos corretos e bueiros limpos; não é uma medida real de segurança." if mission.mission_id == "centro" else "A área recebeu uma recuperação visual simbólica. O índice considera somente destinos corretos; a aparência não apaga erros.", 17)
				if not mission.save_ok:
					label(content, "Não foi possível gravar o desbloqueio em disco; ele vale nesta sessão.", 17)
				button("Ver área recuperada", func(): overlay.hide(); results_button.show())
				var next_index: int = mission.definition()["number"]
				if next_index < 5:
					var next_id: String = mission.Definitions.IDS[next_index]
					button("Próxima fase • " + mission.Definitions.get_mission(next_id)["title"], func(): mission.open_level(next_id))
				else:
					button("Ver conclusão da campanha", mission.show_campaign_completion)
			else:
				if mission.mission_id == "centro":
					label(content, "Dica: alterne rotas de coleta e bueiros; deixe as mãos livres antes de limpar. Conclua ambas as metas.", 18)
				elif mission.mission_id == "itaipuacu":
					label(content, "Dica: priorize o menor tempo → MAR e planeje o trajeto até o coletor. Leia o material antes de confirmar.", 18)
				else:
					label(content, "Dica: " + ("Leia o material do item e o nome do coletor antes de confirmar." if session.errors >= Config.ARACATIBA_ERROR_LIMIT else "Planeje trajetos curtos entre resíduos e os três pares de coletores."), 18)
			button("Jogar novamente", mission.restart)
			button("Voltar ao menu", mission.go_menu)
	for node in content.get_children():
		if node is Button and not node.disabled:
			node.grab_focus()
			break

func show_feedback(text: String, positive: bool) -> void:
	feedback.text = ("CERTO • " if positive else "ATENÇÃO • ") + text
	feedback.modulate = Color("a4efc5") if positive else Color("ffd29a")
	feedback_time = 7.0

func _process(delta: float) -> void:
	if mission.progress == null:
		return
	var seconds: int = ceili(mission.remaining)
	if mission.mission_id == "centro":
		status.text = "TEMPO %02d:%02d • Pontos %d\nDestinos corretos %d/15\nBueiros %d/3 • Erros %d\nLimpeza %d%%\nEm mãos: %s" % [seconds / 60, seconds % 60, session.score, session.correct, session.drains_cleaned, session.errors, session.cleaning_index(), session.carried_material_name()]
	elif mission.mission_id == "itaipuacu":
		status.text = "TEMPO %02d:%02d • Pontos %d\nDestinos corretos %d/20\nLevados ao mar %d/5 • Erros %d\nLimpeza %d%% • Coletados %d\nEm mãos: %s" % [seconds / 60, seconds % 60, session.score, session.correct, session.lost_count, session.errors, session.cleaning_index(), session.collected, session.carried_material_name()]
	else:
		status.text = "TEMPO %02d:%02d   •   Pontos %d\nColetados %d/15   •   Acertos %d\nErros %d/4   •   Limpeza %d%%\nEm mãos: %s" % [seconds / 60, seconds % 60, session.score, session.collected, session.correct, session.errors, session.cleaning_index(), session.carried_material_name()]
	if mission.state == Mission.State.JOGANDO:
		feedback_time = maxf(0.0, feedback_time - delta)
	if is_zero_approx(feedback_time):
		feedback.text = (mission.get_node("World").weather_text() + " • Destine 15 itens e limpe três bueiros com as mãos livres") if mission.mission_id == "centro" else "Priorize → MAR • Coletar interrompe o deslocamento • Procure o nome do material" if mission.mission_id == "itaipuacu" else "Cada destino conta • Procure os nomes PAPEL e PLÁSTICO • Até três erros permitidos"
