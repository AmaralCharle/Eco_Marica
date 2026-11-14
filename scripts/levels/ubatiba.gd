extends "res://scripts/levels/aracatiba.gd"
signal inspection_changed
var inspection_target: Node3D
func spawn_objects() -> void:
	for i in Config.UBATIBA_PLOTS:
		var point = preload("res://scenes/objects/planting_plot.tscn").instantiate()
		point.plot_id = "ubatiba_%02d" % i
		point.apt = i < 8
		point.exposed = i < 3
		point.reason = "Solo exposto apto: preparar, plantar muda nativa adequada e aplicar cobertura." if i < 3 else ("Falha de cobertura apta: preparar e introduzir muda nativa adequada." if i < 8 else ("Cobertura existente: preservar a regeneração, sem abrir novo plantio." if i < 10 else "Ponto úmido não apto à muda proposta: preservar e buscar orientação técnica."))
		point.position = Vector3(-6 + (i % 3) * 6, 0, -12 + (i / 3) * 7)
		session.register_plot(point.plot_id, point.apt, point.exposed, point.reason)
		add_child(point)
func inspect_point(point: Node3D) -> void:
	if state != State.JOGANDO or not session.inspect(point.plot_id):
		return
	inspection_target = point
	player.set_physics_process(false)
	player.set_process_unhandled_input(false)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	inspection_changed.emit()
func choose_action(action: String) -> bool:
	if state != State.JOGANDO or inspection_target == null:
		return false
	var point: Node3D = inspection_target
	var success: bool = session.act(point.plot_id, action)
	point.update_plot(session.plots[point.plot_id])
	if success:
		player.play_collect()
	if state == State.JOGANDO:
		inspection_changed.emit()
	return success
func close_inspection() -> void:
	inspection_target = null
	if state == State.JOGANDO:
		player.set_physics_process(true)
		player.set_process_unhandled_input(true)
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED if DisplayServer.get_name() != "headless" else Input.MOUSE_MODE_VISIBLE
	inspection_changed.emit()
func set_state(next: State) -> void:
	super.set_state(next)
	if next != State.JOGANDO:
		inspection_target = null
		inspection_changed.emit()
func _input(event: InputEvent) -> void:
	if inspection_target != null and event.is_action_pressed("release_mouse"):
		close_inspection()
		get_viewport().set_input_as_handled()
	else:
		super._input(event)
func advance_time(delta: float) -> void:
	if state == State.JOGANDO:
		remaining = maxf(0, remaining - maxf(delta, 0))
		$World.advance_demo(delta)
		if remaining <= 0:
			finish(false, "O prazo terminou antes de avaliar e recuperar todos os pontos.")
func evaluate_objectives() -> void:
	if state != State.JOGANDO:
		return
	if session.errors >= Config.UBATIBA_ERROR_LIMIT:
		finish(false, "Quarta decisão incorreta: limite de erros atingido.")
	elif remaining <= 0:
		finish(false, "O tempo acabou antes de concluir a recuperação.")
	elif session.assessed == 12 and session.planted == 8 and session.protected_soil == 3:
		finish(true, "12 pontos avaliados, oito plantios e três proteções de solo concluídos.")
