extends "res://scripts/levels/aracatiba.gd"
var next_serial: int = 0

func spawn_objects() -> void:
	for i in Config.ITAIPUACU_TARGET:
		var row: int = i / 4
		var column: int = i % 4
		var moving: bool = column == 0 or (column == 1 and row % 2 == 1)
		var pos := Vector3(-6.0 + column * 4.0, 0, -10.0 + row * 5.0)
		var speed: float = Config.ITAIPUACU_DRIFT_SPEED + row * Config.ITAIPUACU_DRIFT_INCREMENT if moving else 0.0
		spawn_waste(pos, Config.MATERIAL_ORDER[(column + row) % 4], speed)
	var bin_scene := preload("res://scenes/objects/recycling_bin.tscn")
	for station in 3:
		for i in 4:
			var bin := bin_scene.instantiate()
			bin.material = Config.MATERIAL_ORDER[i]
			bin.position = Vector3(-7.0 + i * 3.0, 0, [-13.0, 2.5, 13.0][station])
			add_child(bin)

func spawn_waste(pos: Vector3, material: String, speed: float = 0.0) -> void:
	var waste = preload("res://scenes/objects/drifting_waste.tscn").instantiate()
	waste.waste_id = "itaipuacu_%03d" % next_serial
	next_serial += 1
	waste.material = material
	waste.position = pos
	waste.drift_speed = speed
	waste.sea_line = Config.ITAIPUACU_SEA_LINE
	session.register_waste(waste.waste_id, material)
	add_child(waste)
	if speed > 0:
		waste.item_label.text = Config.MATERIAL_NAMES[material] + "\n→ MAR • %ds" % ceili(waste.seconds_to_sea())

func advance_time(delta: float) -> void:
	if state != State.JOGANDO:
		return
	remaining = maxf(0.0, remaining - maxf(delta, 0.0))
	if remaining <= 0:
		finish(false, "O tempo acabou antes dos 20 destinos corretos.")
		return
	for waste in get_tree().get_nodes_in_group("training_waste"):
		if state != State.JOGANDO:
			break
		if waste.has_method("advance_drift"):
			waste.advance_drift(delta, session)

func evaluate_objectives() -> void:
	if state != State.JOGANDO:
		return
	if session.lost_count >= Config.ITAIPUACU_LOSS_LIMIT:
		finish(false, "Cinco resíduos alcançaram o mar: limite de perdas atingido.")
	elif remaining <= 0:
		finish(false, "O tempo acabou antes dos 20 destinos corretos.")
	elif session.correct >= Config.ITAIPUACU_TARGET:
		finish(true, "20 resíduos destinados corretamente e perdas abaixo do limite.")
	elif session.records.size() - session.lost_count < Config.ITAIPUACU_TARGET:
		# Uma perda não torna a meta inalcançável antes da quinta perda.
		var material: String = Config.MATERIAL_ORDER[session.lost_count % 4]
		spawn_waste(Vector3(8, 0, 9 - session.lost_count * 4), material)
