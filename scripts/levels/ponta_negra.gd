extends "res://scripts/levels/aracatiba.gd"
var next_serial: int = 0
var on_boat: bool:
	get:
		return is_inside_tree() and get_node_or_null("Boat") != null and $Boat.pilot != null
func _ready() -> void:
	super._ready()
	player.collision_mask = player.collision_mask | 8
	session.changed.connect(auto_unload)
	var fisheries := preload("res://scripts/gameplay/canal_fisheries.gd").new()
	fisheries.name = "Fisheries"
	add_child(fisheries)
func spawn_objects() -> void:
	for i in Config.PONTA_TARGET:
		spawn_float(Vector3(-5 + (i % 5) * 2.5, 0.08, -13 + (i / 5) * 6), Config.MATERIAL_ORDER[i % 4], 0.035 + (i % 5) * 0.004 if i < 5 else 0.0)
	var bin_scene := preload("res://scenes/objects/recycling_bin.tscn")
	for i in 4:
		var bin := bin_scene.instantiate()
		bin.material = Config.MATERIAL_ORDER[i]
		bin.position = Vector3(10.6 + i * 1.7, 0, 10)
		add_child(bin)
func spawn_float(pos: Vector3, material: String, speed: float = 0) -> void:
	var item = preload("res://scenes/objects/floating_waste.tscn").instantiate()
	item.waste_id = "canal_%03d" % next_serial
	next_serial += 1
	item.material = material
	item.position = pos
	item.escape_speed = speed
	session.register_waste(item.waste_id, material)
	add_child(item)
func set_state(next: State) -> void:
	super.set_state(next)
	if get_node_or_null("Boat") != null:
		$Boat.active = next == State.JOGANDO and on_boat
		$Boat.set_physics_process($Boat.active)
		if on_boat:
			player.set_physics_process(false)
			player.set_process_unhandled_input(false)
func try_board() -> bool:
	if state != State.JOGANDO or on_boat or not session.carried_id.is_empty() or not session.boat_inventory.is_empty():
		return false
	return $Boat.embark(player)
func try_disembark() -> bool:
	if state != State.JOGANDO or not on_boat or not $Boat.disembark():
		return false
	auto_unload()
	return true
func auto_unload() -> void:
	if state == State.JOGANDO and not on_boat and session.carried_id.is_empty() and not session.boat_inventory.is_empty():
		session.take_next_to_hand()
func nearest_float() -> Node3D:
	var nearest: Node3D
	var distance: float = 2.4
	for item in get_tree().get_nodes_in_group("floating_waste"):
		if session.records[item.waste_id]["state"] != RecyclingSession.WasteState.AVAILABLE:
			continue
		var candidate: float = $Boat.global_position.distance_to(item.global_position)
		var ray := PhysicsRayQueryParameters3D.create($Boat.global_position + Vector3.UP, item.global_position + Vector3.UP * 0.5, 17)
		if candidate < distance and $Boat.get_world_3d().direct_space_state.intersect_ray(ray).is_empty():
			nearest = item
			distance = candidate
	return nearest
func boat_prompt() -> String:
	if not session.active:
		return "Interações suspensas"
	if $Boat.global_position.distance_to($Boat.dock_position) < 2.8:
		return "[E] Desembarcar no píer • Pare o barco" if absf($Boat.speed) > 0.6 else "[E] Desembarcar e separar a carga"
	if session.boat_inventory.size() >= 5:
		return "BARCO CHEIO • Retorne ao píer e pare para desembarcar"
	var item := nearest_float()
	return "[E] Recolher " + Config.MATERIAL_NAMES[item.material] if item != null else "Navegue até os resíduos • A/D vira • W/S acelera/freia"
func boat_interact() -> void:
	if state != State.JOGANDO or not on_boat:
		return
	if $Boat.global_position.distance_to($Boat.dock_position) < 2.8:
		try_disembark()
		return
	var item := nearest_float()
	if item != null and session.store_from_boat(item.waste_id):
		item.hide()
func advance_time(delta: float) -> void:
	if state != State.JOGANDO:
		return
	remaining = maxf(0, remaining - maxf(delta, 0))
	$World.advance_water(delta)
	if remaining <= 0:
		finish(false, "Tempo esgotado antes dos 20 destinos corretos.")
		return
	for item in get_tree().get_nodes_in_group("floating_waste"):
		if state != State.JOGANDO:
			break
		item.advance_float(delta, session)
func evaluate_objectives() -> void:
	if state != State.JOGANDO:
		return
	if session.lost_count >= 5:
		finish(false, "Cinco resíduos cruzaram a zona de saída do canal.")
	elif remaining <= 0:
		finish(false, "Tempo esgotado antes de concluir a operação.")
	elif session.correct >= 20:
		finish(true, "20 resíduos recolhidos por barco e destinados corretamente.")
	elif session.records.size() - session.lost_count < 20:
		spawn_float(Vector3(-4 + session.lost_count * 1.5, 0.08, 6 - session.lost_count * 3), Config.MATERIAL_ORDER[session.lost_count % 4])
