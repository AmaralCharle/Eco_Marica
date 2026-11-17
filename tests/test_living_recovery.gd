extends SceneTree
const IDs = ["aracatiba","itaipuacu","centro","ubatiba","ponta_negra"]
var checks := 0
var failures := 0
var report: Array[Dictionary] = []
func _initialize() -> void: call_deferred("run")
func check(ok: bool, title: String) -> void:
	checks += 1
	if not ok: failures += 1; push_error(title)
func frames(n: int = 3) -> void:
	for i in n: await process_frame
func complete(level: Node) -> void:
	if level.mission_id == "ubatiba":
		for point in get_nodes_in_group("planting_plots"):
			if not level.is_ancestor_of(point): continue
			level.inspect_point(point)
			if point.apt:
				level.choose_action("prepare")
				level.choose_action("plant")
				if point.exposed: level.choose_action("protect")
			else: level.choose_action("preserve")
			level.close_inspection()
	else:
		for id in level.session.records:
			if level.session.records[id].state == level.session.WasteState.SORTED: continue
			if level.mission_id == "ponta_negra":
				level.session.store_from_boat(id)
				level.session.take_next_to_hand()
			else: level.session.collect(id)
			level.session.sort_into(level.session.records[id].material)
		for id in level.session.drains: level.session.clean_drain(id)
func snap(tag: String) -> void:
	if not OS.get_cmdline_user_args().has("--capture"): return
	await create_timer(1.3).timeout
	await RenderingServer.frame_post_draw
	var screenshot := root.get_texture().get_image()
	var resolution := screenshot.get_height()
	screenshot.save_png("res://tests/artifacts/living_%d_%s.png" % [resolution,tag])
func run() -> void:
	for id: String in IDs:
		var level = load("res://scenes/levels/"+id+".tscn").instantiate()
		level.profile_path = "user://living_test_profile.json"
		level.progress_path = "user://living_test_"+id+".json"
		root.add_child(level)
		current_scene = level
		level.set_physics_process(false)
		await frames()
		var recovery: Node3D = level.get_node("Presentation/EnvironmentalRecovery")
		recovery.set_process(false)
		check(recovery.gardens.size()==3 and recovery.stage==0,id+": três setores ocultos no início")
		check(recovery.find_children("*","CollisionObject3D",true,false).is_empty(),id+": nenhuma colisão acrescentada")
		check(not recovery.start_cinematic(),id+": menu nunca inicia tomada")
		level.set_state(level.State.JOGANDO)
		level.player.set_physics_process(false)
		check(not recovery.start_cinematic() and level.session.active,id+": sem retirada de controle durante missão")
		if id == "centro":
			var drains: Array = level.session.drains.keys()
			level.session.clean_drain(drains[0])
			check(recovery.stage==1 and recovery.drain_markers[drains[0]].visible,"Centro: primeiro bueiro abre setor e indica drenagem")
			for drain in get_nodes_in_group("mission_drains"):
				if level.is_ancestor_of(drain) and drain.drain_id == drains[0]:
					check(drain.cleaned and not drain.debris.visible,"Centro: resíduos do bueiro removidos pelo estado real")
		elif id != "ubatiba":
			var item_ids: Array = level.session.records.keys()
			for i in int(ceil(level.definition().target/3.0)):
				var waste_id: String = item_ids[i]
				if id == "ponta_negra":
					level.session.store_from_boat(waste_id)
					level.session.take_next_to_hand()
				else: level.session.collect(waste_id)
				level.session.sort_into(level.session.records[waste_id].material)
			check(recovery.stage==1,id+": primeiro terço ativa um setor progressivo")
		var score_before: int = level.session.score
		recovery.sync_progress()
		recovery.sync_progress()
		check(level.session.score==score_before,id+": sincronização visual não concede pontos")
		var original_camera: Camera3D = root.get_camera_3d()
		complete(level)
		await frames()
		check(level.state==level.State.VITORIA and recovery.stage==3,id+": objetivos reais produzem três setores e vitória")
		for group: String in ["training_waste","floating_waste"]:
			var cleared := true
			for item in get_nodes_in_group(group):
				if level.is_ancestor_of(item) and level.session.records[item.waste_id].state != level.session.WasteState.AVAILABLE and item.visible: cleared = false
			check(cleared,id+": resíduos resolvidos saem da apresentação: "+group)
		var result: Dictionary = level.result_record().duplicate(true)
		var saved := FileAccess.get_file_as_string(level.progress_path)
		var remaining: float = level.remaining
		var auto_expected: bool = DisplayServer.get_name() != "headless" and not OS.get_cmdline_user_args().has("--no-recovery-cinema")
		check(recovery.active if auto_expected else recovery.start_cinematic(),id+": tomada disponível após vitória, automática no renderizador")
		check(recovery.active and recovery.camera.current and not level.session.active,id+": câmera de recuperação com missão já encerrada")
		check(not level.get_node("MissionHUD").overlay.visible,id+": resultado oculto durante tomada")
		recovery._process(1.8)
		check(recovery.camera.position.distance_to(recovery.from_position)>0.1,id+": câmera realmente se movimenta")
		await snap(id+"_recovered")
		var rect: Rect2 = recovery.skip_button.get_global_rect()
		check(root.get_visible_rect().encloses(rect) and rect.size.y>=44,id+": botão pular cabe na resolução")
		if id == "ponta_negra":
			check(recovery.reaction_labels.size()==4,"Quatro pescadores mantidos com reação de conclusão")
			var count := 0
			for label in recovery.reaction_labels: if label.visible: count += 1
			check(count==1 and not recovery.reaction_caption.text.is_empty() and recovery.reaction_caption.get_combined_minimum_size().x<root.get_visible_rect().size.x,"Uma reação por vez e legenda legível dentro da tela")
		var event := InputEventKey.new()
		event.keycode = KEY_SPACE
		event.pressed = true
		recovery._input(event)
		check(not recovery.active and root.get_camera_3d()==original_camera,id+": Espaço pula e restaura câmera")
		check(level.get_node("MissionHUD").overlay.visible and not level.get_node("MissionHUD").cinematic_active,id+": resultados restaurados após pular")
		check(level.result_record()==result and level.remaining==remaining and FileAccess.get_file_as_string(level.progress_path)==saved,id+": score, relógio e save intactos")
		check(not recovery.start_cinematic(),id+": sinal repetido não reproduz duas vezes")
		# Repetição explícita só no teste para validar também término natural e Esc.
		recovery.played = false
		recovery.start_cinematic()
		recovery._process(recovery.DURATION)
		check(not recovery.active and level.get_node("MissionHUD").overlay.visible,id+": término natural em 6,5s devolve resultado")
		recovery.played = false
		recovery.start_cinematic()
		event.keycode = KEY_ESCAPE
		Input.parse_input_event(event)
		await frames(1)
		check(not recovery.active,id+": Esc também pula")
		event.pressed = false
		Input.parse_input_event(event)
		level.set_state(level.State.DERROTA)
		recovery.played = false
		check(not recovery.start_cinematic(),id+": derrota não mostra celebração")
		report.append({"phase":id,"stage":recovery.stage,"score":level.session.score,"cinematic_seconds":recovery.DURATION,"saved_unchanged":true,"viewport_logical_height":root.get_visible_rect().size.y})
		level.queue_free()
		await frames(5)
	var file := FileAccess.open("res://tests/artifacts/living_recovery_validation.json",FileAccess.WRITE)
	file.store_string(JSON.stringify({"checks":checks,"failures":failures,"phases":report},"\t"))
	file.close()
	print("RESULT: %d verificações, %d falhas" % [checks,failures])
	if OS.get_cmdline_user_args().has("--capture"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		await root.get_node("GameAudio").request_quit()
	else: quit(0 if failures==0 else 1)
