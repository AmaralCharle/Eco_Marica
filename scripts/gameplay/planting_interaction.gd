extends "res://scripts/gameplay/interaction.gd"
func refresh_target() -> void:
	if not session.active:
		prompt_changed.emit("Interações suspensas")
		return
	if is_instance_valid(target):
		target.set_highlight(false)
	target = null
	if not session.active or get_parent().inspection_target != null:
		prompt_changed.emit("Leia o terreno e escolha uma ação")
		return
	var distance: float = Config.INTERACTION_DISTANCE
	for point in get_tree().get_nodes_in_group("planting_plots"):
		var candidate_distance: float = player.global_position.distance_to(point.global_position)
		if candidate_distance < distance and has_line_of_sight(point):
			target = point
			distance = candidate_distance
	if target != null:
		target.set_highlight(true)
	prompt_changed.emit("[E] Inspecionar ponto de recuperação" if target != null else "Aproxime-se dos 12 pontos e inspecione o terreno")
func interact() -> void:
	refresh_target()
	if target != null:
		get_parent().inspect_point(target)
