extends Node3D
signal state_changed
const Config = preload("res://scripts/core/game_config.gd")
const Definitions = preload("res://scripts/core/mission_definitions.gd")
@export_enum("aracatiba", "itaipuacu", "centro", "ubatiba", "ponta_negra") var mission_id: String = "aracatiba"
const Profile = preload("res://scripts/core/player_profile.gd")
const Progress = preload("res://scripts/core/mission_progress.gd")
enum State { MENU, INSTRUCOES, JOGANDO, PAUSADO, VITORIA, DERROTA, SELECAO_PERSONAGEM, FINALIZADO }
@export var profile_path: String = "user://player_profile.json"
@export var progress_path: String = "user://mission_progress.json"
var state: State = State.MENU
var remaining: float = Config.ARACATIBA_DURATION
var result_reason: String = ""
var profile: PlayerProfile
var progress: MissionProgress
var save_ok: bool = true
@onready var session: RecyclingSession = $Session
@onready var player: CharacterBody3D = $Player

func _ready() -> void:
	var entry: String = "menu"
	var transfer = get_tree().get_meta("mission_transfer", {})
	if transfer is Dictionary and transfer.get("id") == mission_id:
		profile_path = transfer.get("profile_path", profile_path)
		progress_path = transfer.get("progress_path", progress_path)
		entry = transfer.get("entry", "menu")
		get_tree().remove_meta("mission_transfer")
	remaining = definition()["duration"]
	profile = Profile.new(profile_path)
	player.set_character(profile.selected_id)
	progress = Progress.new(progress_path)
	session.active = false
	spawn_objects()
	session.changed.connect(evaluate_objectives)
	if get_tree().get_meta("mission_restart", false):
		get_tree().remove_meta("mission_restart")
		set_state(State.JOGANDO)
	else:
		set_state(State.INSTRUCOES if entry == "instructions" else State.MENU)

func definition() -> Dictionary:
	return Definitions.get_mission(mission_id)

func spawn_objects() -> void:
	var waste_scene := preload("res://scenes/objects/waste.tscn")
	var bin_scene := preload("res://scenes/objects/recycling_bin.tscn")
	for i in Config.ARACATIBA_WASTE:
		var waste := waste_scene.instantiate()
		waste.waste_id = "aracatiba_%02d" % i
		waste.material = "paper" if i % 2 == 0 else "plastic"
		waste.position = Vector3([-2.0, 2.0, 8.0][i % 3], 0, 6.0 - floorf(i / 3.0) * 4.5)
		session.register_waste(waste.waste_id, waste.material)
		add_child(waste)
	for station in 3:
		for i in 2:
			var bin := bin_scene.instantiate()
			bin.material = "paper" if i == 0 else "plastic"
			bin.position = Vector3(-4.5 + i * 3, 0, 7.0 - station * 9.0)
			add_child(bin)

func set_state(next: State) -> void:
	state = next
	var playing: bool = state == State.JOGANDO
	session.active = playing
	player.set_physics_process(playing)
	player.set_process_unhandled_input(playing)
	if not playing:
		player.velocity = Vector3.ZERO
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED if playing and DisplayServer.get_name() != "headless" else Input.MOUSE_MODE_VISIBLE
	$Interaction.refresh_target()
	state_changed.emit()

func show_character_selection() -> void:
	if state == State.MENU:
		set_state(State.SELECAO_PERSONAGEM)

func confirm_character(id: String) -> bool:
	if state != State.SELECAO_PERSONAGEM:
		return false
	if not profile.select_character(id):
		return false
	player.set_character(profile.selected_id)
	set_state(State.MENU)
	return true

func cancel_character_selection() -> void:
	if state == State.SELECAO_PERSONAGEM:
		set_state(State.MENU)

func show_instructions() -> void:
	if state == State.MENU and progress.unlocked_level >= definition()["number"]:
		set_state(State.INSTRUCOES)

func start_mission() -> void:
	if state == State.INSTRUCOES and progress.unlocked_level >= definition()["number"]:
		set_state(State.JOGANDO)

func _physics_process(delta: float) -> void:
	advance_time(delta)

func advance_time(delta: float) -> void:
	if state != State.JOGANDO:
		return
	remaining = maxf(0.0, remaining - maxf(delta, 0.0))
	if remaining <= 0:
		finish(false, "O tempo acabou antes de concluir a coleta e a classificação.")

func evaluate_objectives() -> void:
	if state != State.JOGANDO:
		return
	if session.errors >= Config.ARACATIBA_ERROR_LIMIT:
		finish(false, "Quatro descartes incorretos: limite de erros atingido.")
	elif remaining <= 0:
		finish(false, "O tempo acabou antes de concluir a missão.")
	elif session.collected == Config.ARACATIBA_WASTE and session.correct + session.errors == Config.ARACATIBA_WASTE and session.correct >= Config.ARACATIBA_MIN_CORRECT:
		finish(true, "Coleta concluída e meta de classificação alcançada.")

func finish(won: bool, reason: String) -> void:
	if state != State.JOGANDO:
		return
	result_reason = reason
	# Trava o resultado antes de emitir sinais; impede bônus duplicado.
	set_state(State.VITORIA if won else State.DERROTA)
	if won:
		session.score += Config.POINTS_MISSION
		save_ok = progress.record_result(mission_id, result_record())
		$World.recover_area()
	session.changed.emit()
	state_changed.emit()

func result_record() -> Dictionary:
	var record: Dictionary = {"score": session.score, "collected": session.collected, "correct": session.correct, "errors": session.errors, "lost": session.lost_count, "drains": session.drains_cleaned, "seconds": ceili(definition()["duration"] - remaining)}
	if mission_id == "ubatiba":
		record.merge({"assessed": session.assessed, "planted": session.planted, "protected": session.protected_soil})
	return record

func show_campaign_completion() -> void:
	if progress.campaign_completed and state in [State.MENU, State.VITORIA]:
		set_state(State.FINALIZADO)

func transfer_paths(id: String, entry: String = "menu") -> void:
	get_tree().set_meta("mission_transfer", {"id": id, "entry": entry, "profile_path": profile_path, "progress_path": progress_path})

func open_level(id: String) -> bool:
	if id not in ["aracatiba", "itaipuacu", "centro", "ubatiba", "ponta_negra"]:
		return false
	var next := Definitions.get_mission(id)
	if progress.unlocked_level < next["number"]:
		return false
	if id == mission_id:
		set_state(State.INSTRUCOES)
		return true
	transfer_paths(id, "instructions")
	return get_tree().change_scene_to_file(next["scene"]) == OK

func restart() -> void:
	transfer_paths(mission_id)
	get_tree().set_meta("mission_restart", true)
	get_tree().reload_current_scene()

func go_menu() -> void:
	# Recarrega uma sessão limpa; o arquivo de desbloqueio não é apagado.
	if get_tree().has_meta("mission_restart"):
		get_tree().remove_meta("mission_restart")
	transfer_paths("aracatiba")
	get_tree().change_scene_to_file("res://scenes/levels/aracatiba.tscn")

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("release_mouse") and not event.is_echo():
		if state == State.JOGANDO:
			set_state(State.PAUSADO)
		elif state == State.PAUSADO:
			set_state(State.JOGANDO)
		elif state == State.SELECAO_PERSONAGEM:
			cancel_character_selection()
		get_viewport().set_input_as_handled()
