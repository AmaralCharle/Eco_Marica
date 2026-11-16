extends Node
## Mixer central; preferências separadas do perfil e da campanha.
signal played(event: String)
signal preferences_changed
const BUSES := ["Master", "Music", "Ambience", "SFX"]
var settings_path: String = "user://eco_settings.cfg"
var volumes: Dictionary = {"Master": 0.8, "Music": 0.35, "Ambience": 0.55, "SFX": 0.7}
var sensitivity: float = 1.0
var smoothing: bool = true
var quality: int = 2
var streams: Dictionary = {}
var music: AudioStreamPlayer
var ambience: AudioStreamPlayer
var rain: AudioStreamPlayer
var engine: AudioStreamPlayer
var pool: Array[AudioStreamPlayer] = []
var context: String = ""
var music_tween: Tween
var hover_at: int = 0
var last_save_ok: bool = true
var ui_theme: Theme
var shutting_down: bool = false

func _ready() -> void:
	ui_theme = preload("res://scripts/ui/eco_theme.gd").build()
	for bus: String in BUSES:
		if AudioServer.get_bus_index(bus) < 0:
			AudioServer.add_bus()
			AudioServer.set_bus_name(AudioServer.bus_count - 1, bus)
		if bus != "Master":
			AudioServer.set_bus_send(AudioServer.get_bus_index(bus), "Master")
	load_settings()
	get_tree().auto_accept_quit = false
	get_tree().root.close_requested.connect(request_quit)
	music = make_player("Music")
	ambience = make_player("Ambience")
	rain = make_player("Ambience")
	engine = make_player("SFX")
	for i in 12:
		pool.append(make_player("SFX"))
	get_tree().node_added.connect(attach_button)

func make_player(bus: String) -> AudioStreamPlayer:
	var player := AudioStreamPlayer.new()
	player.bus = bus
	add_child(player)
	player.finished.connect(func(): player.stream = null)
	return player

func request_quit() -> void:
	if shutting_down: return
	shutting_down = true
	if music_tween and music_tween.is_valid(): music_tween.kill()
	for player in get_children():
		if player is AudioStreamPlayer:
			player.stop()
			player.stream = null
	streams.clear()
	# Dá ao mixer tempo para liberar playbacks antes de encerrar a aplicação.
	await get_tree().create_timer(0.12).timeout
	get_tree().quit()

func stream_for(event: String, folder: String = "sounds", loop: bool = false) -> AudioStreamWAV:
	var key := folder + "/" + event + ("_loop" if loop else "")
	if not streams.has(key):
		var path := "res://assets/%s/%s.wav" % [folder, event]
		if not ResourceLoader.exists(path):
			return null
		var sound: AudioStreamWAV = load(path).duplicate()
		if loop:
			sound.loop_mode = AudioStreamWAV.LOOP_FORWARD
			sound.loop_begin = 0
			sound.loop_end = sound.data.size() / (4 if sound.stereo else 2)
		streams[key] = sound
	return streams[key]

func play_event(event: String, pitch: float = 1.0) -> void:
	var sound := stream_for(event)
	if sound == null:
		return
	for player in pool:
		if not player.playing:
			player.stream = sound
			player.pitch_scale = pitch
			player.volume_db = -7.0 if event.begins_with("step_") else -2.0
			player.play()
			played.emit(event)
			return

func attach_button(node: Node) -> void:
	if node is Control and not node.get_parent() is Control:
		node.theme = ui_theme
	if node is BaseButton:
		node.mouse_entered.connect(func():
			if not node.disabled and Time.get_ticks_msec() - hover_at > 90:
				hover_at = Time.get_ticks_msec()
				play_event("hover")
		)
		node.pressed.connect(func(): play_event("confirm"))

func set_context(id: String, playing: bool) -> void:
	var next: String = id if playing else "menu"
	if context == next:
		return
	context = next
	if music_tween and music_tween.is_valid():
		music_tween.kill()
	music_tween = create_tween()
	music_tween.tween_property(music, "volume_db", -55.0, 0.25)
	music_tween.tween_callback(func():
		music.stream = stream_for(next, "music", true)
		music.play()
		ambience.stop()
		if playing:
			ambience.stream = stream_for(id, "sounds", true)
			ambience.volume_db = -9.0
			ambience.play()
	)
	music_tween.tween_property(music, "volume_db", -5.0 if playing else -2.0, 0.65)
	if not playing:
		rain.stop()
		engine.stop()

func set_rain(amount: float) -> void:
	if amount <= 0.01:
		rain.stop()
		return
	if not rain.playing:
		rain.stream = stream_for("rain", "sounds", true)
		rain.play()
	rain.volume_db = linear_to_db(clampf(amount, 0.001, 1.0)) - 13.0

func set_engine(enabled: bool, speed: float = 0.0) -> void:
	if not enabled:
		engine.stop()
		return
	if not engine.playing:
		engine.stream = stream_for("engine", "sounds", true)
		engine.play()
	engine.pitch_scale = lerpf(0.8, 1.6, clampf(absf(speed) / 6.0, 0, 1))
	engine.volume_db = lerpf(-19.0, -10.0, clampf(absf(speed) / 6.0, 0, 1))

func set_volume(bus: String, value: float, persist: bool = true) -> void:
	if not volumes.has(bus) or not is_finite(value):
		return
	volumes[bus] = clampf(value, 0, 1)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(bus), linear_to_db(maxf(volumes[bus], 0.0001)))
	AudioServer.set_bus_mute(AudioServer.get_bus_index(bus), volumes[bus] <= 0.0)
	if persist:
		save_settings()

func load_settings() -> void:
	var config := ConfigFile.new()
	if config.load(settings_path) == OK:
		for bus: String in BUSES:
			var value = config.get_value("audio", bus, volumes[bus])
			if (value is float or value is int) and is_finite(float(value)):
				volumes[bus] = clampf(float(value), 0, 1)
		var mouse = config.get_value("camera", "sensitivity", 1.0)
		if (mouse is float or mouse is int) and is_finite(float(mouse)):
			sensitivity = clampf(float(mouse), 0.25, 2.5)
		var smooth = config.get_value("camera", "smoothing", true)
		smoothing = smooth if smooth is bool else true
		var detail = config.get_value("graphics", "quality", 2)
		quality = clampi(detail, 0, 2) if detail is int else 2
	for bus: String in BUSES:
		set_volume(bus, volumes[bus], false)

func save_settings() -> bool:
	var config := ConfigFile.new()
	for bus: String in BUSES:
		config.set_value("audio", bus, volumes[bus])
	config.set_value("camera", "sensitivity", sensitivity)
	config.set_value("camera", "smoothing", smoothing)
	config.set_value("graphics", "quality", quality)
	last_save_ok = config.save(settings_path) == OK
	preferences_changed.emit()
	return last_save_ok

func _exit_tree() -> void:
	if music_tween and music_tween.is_valid():
		music_tween.kill()
	for player in get_children():
		if player is AudioStreamPlayer:
			player.stop()
			player.stream = null
	streams.clear()
