extends SceneTree
## Exercita dados reais, navegação e limites visuais em 1280×720.
## --capture-ui também registra as mesmas telas no renderizador gráfico.
var checks := 0
var failures := 0
var capture: bool = false
const IDS = ["aracatiba","itaipuacu","centro","ubatiba","ponta_negra"]
func _initialize() -> void:
	capture = "--capture-ui" in OS.get_cmdline_user_args()
	call_deferred("run")
func check(ok: bool, title: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(title)
func settle() -> void:
	for i in 5:
		await process_frame
	if capture: await create_timer(0.25).timeout
func snap(title: String) -> void:
	if not capture: return
	if title == "finale": await create_timer(1.5).timeout
	await RenderingServer.frame_post_draw
	var error := root.get_texture().get_image().save_png("res://tests/artifacts/ui_"+title+".png")
	check(error == OK,"Captura "+title)
func fits(control: Control) -> bool:
	var rect := control.get_global_rect()
	return rect.position.x >= 0 and rect.position.y >= 0 and rect.end.x <= 1281 and rect.end.y <= 721
func buttons(hud: Node) -> Array[Node]:
	return hud.content.find_children("*","Button",true,false)
func screen(hud: Node, title: String) -> void:
	await settle()
	check(hud.overlay.visible and fits(hud.menu_card),"Tela inteira sem corte: "+title)
	for node in buttons(hud):
		check(fits(node),"Botão acessível: "+title+" / "+str(node.get_meta("action_text",node.text)))
	await snap(title)
func run() -> void:
	root.size = Vector2i(1280,720)
	var file := FileAccess.open("res://tests/artifacts/ui_progress.json",FileAccess.WRITE)
	file.store_string('{"version":2,"unlocked_level":1}')
	file.close()
	for id: String in IDS:
		var scene = load("res://scenes/levels/"+id+".tscn").instantiate()
		scene.profile_path = "res://tests/artifacts/ui_profile.json"
		scene.progress_path = "res://tests/artifacts/ui_progress.json"
		root.add_child(scene)
		current_scene = scene
		scene.set_physics_process(false)
		await settle()
		var hud = scene.get_node("MissionHUD")
		if id == "aracatiba":
			await screen(hud,"menu")
			var locked := 0
			for node in buttons(hud):
				if node.name.begins_with("Phase_") and node.disabled: locked += 1
			check(locked == 4,"Campanha nova mantém quatro cartões bloqueados")
			var original: String = scene.profile.selected_id
			scene.show_character_selection()
			await screen(hud,"characters")
			check(hud.selector.avatars.size() == 4,"Quatro personagens presentes")
			hud.selector.choose("bia")
			await settle()
			check(scene.profile.selected_id == original,"Prévia não altera o perfil")
			hud.selector.show_save_error()
			await screen(hud,"character_error")
			scene.cancel_character_selection()
			hud.open_settings()
			await settle()
			var settings: CanvasLayer
			for node in hud.get_children():
				if node is CanvasLayer: settings = node
			var card: Control = settings.get_child(0).get_child(0).get_child(0)
			check(fits(card),"Configurações cabem em 720p")
			await snap("settings")
			settings.queue_free()
			await process_frame
		scene.progress.unlocked_level = 5
		scene.show_instructions()
		await screen(hud,id+"_instructions")
		scene.start_mission()
		scene.player.set_physics_process(false)
		await settle()
		var dashboard = hud.dashboard
		check(dashboard.visible and not hud.overlay.visible,"Cenário liberado: "+id)
		check(dashboard.time_value.text == "%02d:%02d" % [int(scene.definition().duration)/60,int(scene.definition().duration)%60],"Tempo correto: "+id)
		check(dashboard.score_value.text == str(scene.session.score),"Pontos corretos: "+id)
		check(dashboard.controls.text.contains("WASD") and dashboard.controls.text.contains("Esc"),"Lembrete dos controles terrestres preservado: "+id)
		for node in dashboard.get_children():
			if node is PanelContainer: check(fits(node),"Painel cabe na tela: "+id)
		for kind: String in dashboard.material_counts:
			var count: Label = dashboard.material_counts[kind]
			check(count.size.y <= 22 and count.size.x >= 25,"Material legível sem letras empilhadas: "+id+" / "+kind)
		await snap(id+"_gameplay")
		if id == "ubatiba":
			var point = get_nodes_in_group("planting_plots")[0]
			scene.inspect_point(point)
			await settle()
			var inspection: Control = hud.inspection_overlay.get_child(0).get_child(0)
			check(fits(inspection),"Inspeção mantém todas as ações acessíveis")
			await snap("inspection")
			scene.close_inspection()
		elif id == "ponta_negra":
			var boat = scene.get_node("Boat")
			scene.player.position = boat.landing_position
			check(scene.try_board(),"Barco embarca com HUD nova")
			boat.set_physics_process(false)
			for key in scene.session.records.keys().slice(0,5): scene.session.store_from_boat(key)
			await settle()
			check(dashboard.inventory_value.text == "Carga 5 / 5" and dashboard.cargo_slots.size() == 5,"Carga cheia apresentada numericamente e em cinco marcas")
			check(dashboard.controls.text.contains("W/S") and dashboard.controls.text.contains("A/D"),"Lembrete de controles acompanha embarque")
			check(dashboard.status.text.contains("Coletados 5") and dashboard.score_value.text == "25","Carga atualiza pontos e coleta")
			await snap("boat_full")
		else:
			var key: String = scene.session.records.keys()[0]
			var material: String = scene.session.records[key].material
			scene.session.collect(key)
			await settle()
			check(dashboard.inventory_value.text.to_lower() == scene.session.carried_material_name().to_lower(),"Inventário acompanha coleta: "+id)
			scene.session.sort_into(material)
			await settle()
			check(dashboard.score_value.text == "15" and dashboard.status.text.contains("1"),"Destino atualiza HUD sem recalcular regras: "+id)
			check(dashboard.cleaning_bar.value == scene.session.cleaning_index(),"Limpeza acompanha sessão: "+id)
		hud.show_feedback("Ainda não: este item é plástico. Procure a identificação do coletor; ele continua com você. Leia os nomes antes de confirmar a destinação.",false)
		await settle()
		check(hud.feedback.visible and fits(dashboard.context) and dashboard.context.position.y >= 480,"Aviso longo cresce para cima e preserva o centro: "+id)
		scene.set_state(scene.State.PAUSADO)
		await screen(hud,id+"_pause")
		var remaining: float = scene.remaining
		await settle()
		check(scene.remaining == remaining and not scene.session.active,"Pausa mantém tempo e sessão parados: "+id)
		scene.result_reason = "Prévia de interface • dados desta sessão de teste."
		scene.set_state(scene.State.DERROTA)
		await screen(hud,id+"_defeat")
		scene.save_ok = false
		scene.set_state(scene.State.VITORIA)
		await screen(hud,id+"_victory_save_warning")
		for node in buttons(hud):
			if node.text == "Ver área recuperada": node.pressed.emit()
		await settle()
		check(not hud.dashboard.visible and hud.results_button.visible,"Área recuperada sem HUD sobre o botão de retorno: "+id)
		hud.results_button.pressed.emit()
		check(hud.overlay.visible and not hud.results_button.visible,"Resultado pode ser reaberto: "+id)
		if id == "ponta_negra":
			scene.progress.campaign_completed = true
			scene.progress.completed_levels.assign(IDS)
			scene.progress.unlocked_level = 5
			scene.set_state(scene.State.FINALIZADO)
			await screen(hud,"finale")
			scene.set_state(scene.State.MENU)
			await screen(hud,"completed_menu")
		scene.queue_free()
		await process_frame
	var training = load("res://scenes/levels/foundation.tscn").instantiate()
	root.add_child(training)
	current_scene = training
	await settle()
	var training_hud = training.get_node("TrainingHUD")
	for node in training_hud.get_children():
		if node is PanelContainer: check(fits(node),"Treino permanece legível e dentro da tela")
	await snap("training")
	training.queue_free()
	await process_frame
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	print("RESULT: %d verificações, %d falhas" % [checks,failures])
	quit(0 if failures == 0 else 1)
