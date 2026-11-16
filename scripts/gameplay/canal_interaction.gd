extends "res://scripts/gameplay/interaction.gd"
func refresh_target() -> void:
	var fisheries := get_parent().get_node_or_null("Fisheries")
	if fisheries:
		var camera := get_viewport().get_camera_3d()
		var point := get_viewport().get_visible_rect().size*0.5 if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED else get_viewport().get_mouse_position()
		fisheries.update_focus(camera,point)
	if not session.active:
		prompt_changed.emit("Interações suspensas")
		return
	var mission = get_parent()
	if mission.on_boat:
		prompt_changed.emit("Tarrafa na água — contorne ou aguarde." if fisheries and fisheries.feedback_left>0 else mission.boat_prompt())
		return
	super.refresh_target()
	# Em terra, só coletores e acesso ao barco; resíduos flutuantes exigem embarcação.
	if is_instance_valid(target) and target.is_in_group("floating_waste"):
		target.set_highlight(false)
		target = null
	if session.carried_id.is_empty() and player.global_position.distance_to(mission.get_node("Boat").global_position) < 3:
		prompt_changed.emit("[E] Embarcar • WASD navega • Carga máxima 5")
	elif session.carried_id.is_empty():
		prompt_changed.emit("Caminhe até o barco no píer e pressione E")
func interact() -> void:
	var mission = get_parent()
	if not session.active:
		return
	if mission.on_boat:
		mission.boat_interact()
	elif session.carried_id.is_empty():
		mission.try_board()
	else:
		super.interact()
