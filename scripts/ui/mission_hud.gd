extends CanvasLayer
const Catalog = preload("res://scripts/core/character_catalog.gd")
const Selector = preload("res://scripts/ui/character_selection.gd")
const Config = preload("res://scripts/core/game_config.gd")
const Mission = preload("res://scripts/levels/aracatiba.gd")
const Design = preload("res://scripts/ui/eco_theme.gd")
const Icon = preload("res://scripts/ui/eco_icon.gd")
var dashboard
var menu_card: PanelContainer
var screen_tween: Tween
var menu_scroll: ScrollContainer
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
var hud_widgets: Array[Control] = []
var cleaning_bar: ProgressBar

func _ready() -> void:
	mission = get_parent()
	session = mission.get_node("Session")
	dashboard = preload("res://scripts/ui/gameplay_dashboard.gd").new()
	dashboard.mission = mission
	dashboard.session = session
	add_child(dashboard)
	hud_widgets.append(dashboard)
	status = dashboard.status
	prompt = dashboard.prompt
	feedback = dashboard.feedback
	cleaning_bar = dashboard.cleaning_bar
	overlay = ColorRect.new()
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.color = Color(0.025, 0.07, 0.08, 0.48)
	add_child(overlay)
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.add_child(center)
	menu_card = PanelContainer.new()
	menu_card.custom_minimum_size = Vector2(1040, 0)
	menu_card.add_theme_stylebox_override("panel", style())
	center.add_child(menu_card)
	content = VBoxContainer.new()
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.add_theme_constant_override("separation", 10)
	menu_scroll = ScrollContainer.new()
	menu_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	menu_scroll.follow_focus = true
	menu_card.add_child(menu_scroll)
	menu_scroll.add_child(content)
	content.minimum_size_changed.connect(func(): call_deferred("fit_dialog"))
	results_button = Button.new()
	results_button.text = "Mostrar resultados"
	results_button.position = Vector2(24, 24)
	results_button.theme_type_variation = "PrimaryButton"
	results_button.pressed.connect(func(): overlay.show(); results_button.hide())
	results_button.hide()
	add_child(results_button)
	mission.state_changed.connect(update_screen)
	session.feedback.connect(show_feedback)
	mission.get_node("Interaction").prompt_changed.connect(func(text: String): prompt.text = text)
	call_deferred("update_screen")

func style() -> StyleBoxFlat:
	return Design.frame(0.94,24)

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
	hud_widgets.append(box)
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

func button(text: String, callback: Callable, disabled: bool = false, parent: Node = null, primary: bool = false) -> Button:
	var node := Button.new()
	node.text = text
	node.custom_minimum_size.y = 40
	node.add_theme_font_size_override("font_size", 16)
	node.theme_type_variation = "PrimaryButton" if primary else "Button"
	node.set_meta("action_text",text)
	node.disabled = disabled
	node.pressed.connect(callback)
	(parent if parent else content).add_child(node)
	return node

func update_screen() -> void:
	if not is_inside_tree() or mission.progress == null:
		return
	for node in content.get_children():
		content.remove_child(node)
		node.queue_free()
	overlay.visible = mission.state != Mission.State.JOGANDO
	results_button.hide()
	menu_card.custom_minimum_size.x = 1040 if mission.state in [Mission.State.MENU,Mission.State.SELECAO_PERSONAGEM] else 900 if mission.state == Mission.State.FINALIZADO else 840
	content.add_theme_constant_override("separation",10)
	match mission.state:
		Mission.State.MENU:
			build_menu()
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
			button("Começar missão", mission.start_mission,false,null,true)
			button("Voltar ao menu", mission.go_menu)
		Mission.State.FINALIZADO:
			build_finale()
		Mission.State.PAUSADO:
			build_pause()
		Mission.State.VITORIA, Mission.State.DERROTA:
			build_results()
	for node in content.find_children("*", "Button", true, false):
		if not node.disabled:
			node.grab_focus()
			break
	animate_screen()

func animate_screen() -> void:
	call_deferred("fit_dialog")
	if screen_tween and screen_tween.is_valid(): screen_tween.kill()
	content.modulate.a = 0.0
	screen_tween = create_tween()
	screen_tween.tween_property(content, "modulate:a", 1.0, 0.18)

func fit_dialog() -> void:
	if not is_instance_valid(menu_scroll): return
	var limit := maxf(320,get_viewport().get_visible_rect().size.y-96)
	menu_scroll.custom_minimum_size.y = minf(content.get_combined_minimum_size().y,limit)

func show_feedback(text: String, positive: bool) -> void:
	feedback.text = ("✓  " if positive else "ATENÇÃO  ·  ") + text
	feedback.modulate = Color("a4efc5") if positive else Color("ffd29a")
	feedback_time = 7.0

func open_settings() -> void:
	var settings := preload("res://scripts/ui/settings_panel.gd").new()
	add_child(settings)
	# O modal recebe Esc antes do controlador da missão.
	mission.set_process_input(false)
	settings.tree_exited.connect(func(): mission.set_process_input(true))

func _process(delta: float) -> void:
	for widget in hud_widgets:
		widget.visible = mission.state == Mission.State.JOGANDO and not overlay.visible
	if mission.progress == null:
		return
	dashboard.update_clock()
	if mission.state == Mission.State.JOGANDO:
		feedback_time = maxf(0.0, feedback_time - delta)
	feedback.visible = feedback_time > 0.0

func muted(parent: Node, value: String, size: int = 14) -> Label:
	var result := label(parent,value,size)
	result.add_theme_color_override("font_color",Design.MUTED)
	return result

func build_menu() -> void:
	var brand := HBoxContainer.new()
	brand.add_theme_constant_override("separation",16)
	content.add_child(brand)
	brand.add_child(preload("res://scripts/ui/eco_mark.gd").new())
	var words := VBoxContainer.new()
	words.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	brand.add_child(words)
	label(words,"ECO MARICÁ",30)
	muted(words,"GUARDIÕES DA CIDADE",13)
	var body := HBoxContainer.new()
	body.add_theme_constant_override("separation",28)
	content.add_child(body)
	var hero := VBoxContainer.new()
	hero.custom_minimum_size.x = 300
	hero.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hero.add_theme_constant_override("separation",8)
	body.add_child(hero)
	muted(hero,"AVENTURA AMBIENTAL",12)
	label(hero,"Uma cidade.\nCinco formas de cuidar.",29)
	muted(hero,"Da orla ao campo, cada escolha faz parte da jornada.",16)
	var next_id: String = mission.Definitions.IDS[clampi(mission.progress.unlocked_level-1,0,4)]
	button("Continuar • "+mission.Definitions.get_mission(next_id).short_name,func(): mission.open_level(next_id),false,hero,true)
	var divider := HSeparator.new()
	hero.add_child(divider)
	muted(hero,"SEU GUARDIÃO",11)
	var character: Dictionary = Catalog.get_character(mission.profile.selected_id)
	label(hero,character.name+" · "+character.role,17)
	button("Escolher personagem",mission.show_character_selection,false,hero)
	button("Treinar coleta e classificação",func(): get_tree().change_scene_to_file("res://scenes/levels/foundation.tscn"),false,hero)
	var actions := HBoxContainer.new()
	actions.add_theme_constant_override("separation",8)
	hero.add_child(actions)
	var options := button("Configurações",open_settings,false,actions)
	options.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var exit := button("Sair",func(): get_tree().quit(),false,actions)
	exit.theme_type_variation = "QuietButton"
	if mission.progress.campaign_completed:
		button("Campanha concluída • Rever conclusão",mission.show_campaign_completion,false,hero)
	var journey := VBoxContainer.new()
	journey.name = "PhaseSelection"
	journey.custom_minimum_size.x = 564
	journey.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	journey.add_theme_constant_override("separation",8)
	body.add_child(journey)
	muted(journey,"SUA JORNADA  ·  %d/5 MISSÕES CONCLUÍDAS" % mission.progress.completed_levels.size(),12)
	for id: String in mission.Definitions.IDS:
		var card := preload("res://scripts/ui/phase_card.gd").new()
		card.spec = mission.Definitions.get_mission(id)
		card.accessible = mission.progress.unlocked_level >= card.spec.number
		card.completed = mission.progress.completed_levels.has(id)
		card.current = id == next_id
		card.pressed.connect(func(): mission.open_level(id))
		journey.add_child(card)
	muted(content,"Um jogador · Offline · Progresso salvo neste computador · Cenários fictícios inspirados em Maricá",12)

func screen_title(title: String, subtitle: String, icon_kind: String = "leaf", color: Color = Design.MINT) -> void:
	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation",14)
	content.add_child(header)
	var icon := Icon.new()
	icon.kind = icon_kind
	icon.color = color
	icon.custom_minimum_size = Vector2(44,44)
	header.add_child(icon)
	var words := VBoxContainer.new()
	words.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(words)
	label(words,title,29)
	muted(words,subtitle,15)

func metric_grid(entries: Array) -> void:
	var grid := GridContainer.new()
	grid.columns = 3
	grid.add_theme_constant_override("h_separation",12)
	content.add_child(grid)
	for entry: Array in entries:
		var card := PanelContainer.new()
		card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		card.add_theme_stylebox_override("panel",Design.frame(0.45,14))
		grid.add_child(card)
		var rows := VBoxContainer.new()
		rows.add_theme_constant_override("separation",4)
		card.add_child(rows)
		muted(rows,entry[0],12)
		var value := label(rows,str(entry[1]),28)
		value.add_theme_color_override("font_color",Design.MINT)

func build_pause() -> void:
	menu_card.custom_minimum_size.x = 620
	screen_title("Missão pausada",mission.definition().short_name,"pause")
	muted(content,"O cronômetro e as interações estão suspensos.",16)
	var seconds: int = ceili(mission.remaining)
	metric_grid([["TEMPO RESTANTE","%02d:%02d" % [seconds/60,seconds%60]],["PONTOS",session.score],["ÍNDICE",str(session.cleaning_index())+"%"]])
	button("Continuar",func(): mission.set_state(Mission.State.JOGANDO),false,null,true)
	button("Configurações • áudio, câmera e gráficos",open_settings)
	button("Reiniciar missão",mission.restart)
	button("Voltar ao menu",mission.go_menu)

func build_results() -> void:
	var won: bool = mission.state == Mission.State.VITORIA
	screen_title("Missão concluída!" if won else "Vamos tentar de novo",mission.definition().short_name,"check" if won else "leaf",Design.MINT if won else Design.AMBER)
	label(content,mission.result_reason,17)
	metric_grid([["PONTUAÇÃO",session.score],["TEMPO UTILIZADO",str(ceili(mission.definition().duration-mission.remaining))+" s"],["ÍNDICE",str(session.cleaning_index())+"%"]])
	if mission.mission_id == "ubatiba":
		label(content,"Avaliações %d/12 · Plantios %d/8 · Proteções %d/3\nDecisões incorretas %d" % [session.assessed,session.planted,session.protected_soil,session.errors],17)
		muted(content,"Mudas e cobertura são ações complementares. Estabilidade de encostas exige avaliação técnica; o jogo não elimina riscos reais.")
	else:
		label(content,"Coletados %d · Destinos corretos %d · Erros %d" % [session.collected,session.correct,session.errors],17)
		if mission.mission_id in ["itaipuacu","ponta_negra"]: label(content,"Perdas %d/5 · Meta: 20 destinos corretos" % session.lost_count,16)
		if mission.mission_id == "centro": label(content,"Bueiros limpos %d/3 · Meta: 15 destinos corretos" % session.drains_cleaned,16)
	if won:
		muted(content,"Bônus de missão +100 · "+("Campanha concluída" if mission.mission_id == "ponta_negra" else "Próxima área: "+mission.definition().next_name),15)
		muted(content,"Recuperação visual simbólica. Os índices registram ações no jogo, não impacto ambiental real.",13)
		if not mission.save_ok:
			var warning := label(content,"Não foi possível gravar o resultado; ele vale nesta sessão.",15)
			warning.add_theme_color_override("font_color",Design.AMBER)
		var next_index: int = mission.definition().number
		if next_index < 5:
			var id: String = mission.Definitions.IDS[next_index]
			button("Próxima fase • "+mission.Definitions.get_mission(id).short_name,func(): mission.open_level(id),false,null,true)
		else:
			button("Celebrar conclusão da campanha",mission.show_campaign_completion,false,null,true)
		button("Ver área recuperada",func(): overlay.hide(); results_button.show())
	else:
		var tip: String = {"centro":"Alterne coleta e bueiros; deixe as mãos livres para limpar.","itaipuacu":"Priorize o menor tempo → MAR e planeje a rota até o coletor.","ubatiba":"Inspecione antes de agir. Prepare pontos aptos e preserve os não aptos.","ponta_negra":"Faça viagens curtas e volte ao píer com a carga cheia."}.get(mission.mission_id,"Leia o material do resíduo e o nome do coletor antes de confirmar.")
		muted(content,"Dica · "+tip,15)
	button("Jogar novamente",mission.restart,false,null,not won)
	button("Voltar ao menu",mission.go_menu)

func build_finale() -> void:
	screen_title("Uma jornada de cuidado", "Campanha concluída · Cinco locais de Maricá", "check")
	var map := preload("res://scripts/ui/campaign_map.gd").new()
	map.completed = mission.progress.completed_levels
	content.add_child(map)
	var totals: Dictionary = mission.progress.totals()
	metric_grid([["MELHORES MISSÕES",mission.progress.total_score()],["DESTINOS CORRETOS",totals.correct],["MUDAS PLANTADAS",totals.planted]])
	label(content,"Proteções de solo %d · Bueiros limpos %d\nGuardião: %s" % [totals.protected,totals.drains,Catalog.get_character(mission.profile.selected_id).name],16)
	muted(content,"Obrigado por cuidar da cidade. Coleta local, restauração orientada e prevenção exigem ações contínuas. O jogo não comprova aprendizagem nem elimina riscos reais.",15)
	muted(content,"Mapa esquemático. Estatísticas são ações simuladas."+(" Fases antigas não possuem estatísticas detalhadas." if mission.progress.legacy_stats_missing else ""),13)
	if not mission.save_ok: label(content,"Não foi possível gravar a conclusão; ela vale nesta sessão.",15)
	button("Voltar ao menu",mission.go_menu,false,null,true)
	button("Rejogar Operação Araçatiba",func(): mission.open_level("aracatiba"))
