class_name RecyclingInteraction
extends Node
signal prompt_changed(text: String)
const Config = preload("res://scripts/core/game_config.gd")
@export var player_path: NodePath = NodePath("../Player")
@export var session_path: NodePath = NodePath("../Session")
@onready var player: CharacterBody3D = get_node(player_path)
@onready var session: RecyclingSession = get_node(session_path)
var target: Node3D

func _ready() -> void:
	session.changed.connect(refresh_target)

func _physics_process(_delta: float) -> void:
	refresh_target()

func refresh_target() -> void:
	if is_instance_valid(target):
		target.set_highlight(false)
	target = null
	if not session.active:
		prompt_changed.emit("Interações suspensas")
		return
	var nearest: float = Config.INTERACTION_DISTANCE
	var group := "training_waste" if session.carried_id.is_empty() else "training_bins"
	var candidates: Array[Node] = get_tree().get_nodes_in_group(group)
	if session.carried_id.is_empty():
		candidates.append_array(get_tree().get_nodes_in_group("mission_drains"))
	for candidate: Node3D in candidates:
		if candidate.is_in_group("mission_drains"):
			if not session.drains.has(candidate.drain_id) or session.drains[candidate.drain_id]:
				continue
		elif group == "training_waste" and (not session.records.has(candidate.waste_id) or session.records[candidate.waste_id]["state"] != RecyclingSession.WasteState.AVAILABLE):
			continue
		var distance: float = player.global_position.distance_to(candidate.global_position)
		if distance < nearest and has_line_of_sight(candidate):
			nearest = distance
			target = candidate
	if is_instance_valid(target):
		target.set_highlight(true)
		if target.is_in_group("mission_drains"):
			prompt_changed.emit("[E] Limpar bueiro • Ação simulada")
		elif group == "training_waste":
			prompt_changed.emit("[E] Coletar %s" % Config.MATERIAL_NAMES[target.material])
		else:
			prompt_changed.emit("[E] Destinar à lixeira de %s" % Config.MATERIAL_NAMES[target.material])
	elif not session.carried_id.is_empty():
		prompt_changed.emit("Carregando %s • Aproxime-se de uma lixeira e pressione E" % session.carried_material_name())
	elif session.is_training and session.correct == session.records.size() and not session.records.is_empty():
		prompt_changed.emit("Treino concluído • R para recomeçar")
	else:
		prompt_changed.emit("Procure os resíduos • Aproxime-se e pressione E")

func has_line_of_sight(candidate: Node3D) -> bool:
	var query := PhysicsRayQueryParameters3D.create(player.global_position + Vector3.UP * 0.9, candidate.global_position + Vector3.UP * 0.6, 1)
	var hit := player.get_world_3d().direct_space_state.intersect_ray(query)
	return hit.is_empty() or candidate.is_ancestor_of(hit["collider"])

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and not event.is_echo():
		interact()
		get_viewport().set_input_as_handled()

func interact() -> void:
	# Revalida proximidade, visibilidade e estado no instante da ação.
	refresh_target()
	if not is_instance_valid(target):
		return
	if target.is_in_group("mission_drains"):
		var drain: Node3D = target
		if session.clean_drain(drain.drain_id):
			drain.show_cleaned()
			player.play_collect()
	elif target.is_in_group("training_waste"):
		var waste: Node3D = target
		if session.collect(waste.waste_id):
			player.play_collect()
			waste.hide()
	else:
		session.sort_into(target.material)
	refresh_target()
