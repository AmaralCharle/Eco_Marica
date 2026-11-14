extends SceneTree
var checks: int = 0
var failures: int = 0
var events: Array[String] = []
func _initialize() -> void:
	call_deferred("run")
func expect(ok: bool, title: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(title)
func frames(count: int) -> void:
	for i in count:
		await process_frame
		await physics_frame
func run() -> void:
	var audio := root.get_node("GameAudio")
	var original: String = audio.settings_path
	audio.settings_path = "res://tests/artifacts/audio_settings.cfg"
	for bus: String in audio.BUSES:
		expect(AudioServer.get_bus_index(bus) >= 0, "Barramento " + bus)
	audio.set_volume("Music", 0.23)
	audio.set_volume("Master", 0)
	expect(AudioServer.is_bus_mute(0), "Zero silencia master")
	audio.set_volume("Master", 0.8)
	audio.set_volume("Music", 0.9, false)
	audio.load_settings()
	expect(is_equal_approx(audio.volumes.Music, 0.23), "Persistência real de volume")
	audio.played.connect(func(event: String): events.append(event))
	var scene = load("res://scenes/levels/aracatiba.tscn").instantiate()
	scene.progress_path = "res://tests/artifacts/audio_progress.json"
	scene.profile_path = "res://tests/artifacts/audio_profile.json"
	root.add_child(scene)
	current_scene = scene
	await frames(3)
	scene.set_physics_process(false)
	scene.show_instructions()
	scene.start_mission()
	scene.session.collect("aracatiba_00")
	scene.session.sort_into("plastic")
	expect(events.has("start") and events.has("collect") and events.has("wrong"), "Eventos reais da missão chegam ao mixer")
	var size: int = events.size()
	scene.set_state(scene.State.PAUSADO)
	scene.session.collect("aracatiba_01")
	expect(events.size() == size, "Ação bloqueada não emite efeito")
	for id: String in ["menu", "aracatiba", "itaipuacu", "centro", "ubatiba", "ponta_negra"]:
		var stream = audio.stream_for(id, "music", true)
		expect(stream != null and stream.data.size() > 100000 and stream.loop_mode == AudioStreamWAV.LOOP_FORWARD, "Trilha válida: " + id)
	audio.set_engine(true, 6)
	expect(audio.engine.playing and audio.engine.pitch_scale > 1, "Motor responde à aceleração")
	audio.set_engine(false)
	expect(not audio.engine.playing, "Motor para ao desativar")
	# Captura o mix verdadeiro no barramento SFX, inclusive em driver Dummy.
	var record := AudioEffectRecord.new()
	var bus: int = AudioServer.get_bus_index("SFX")
	AudioServer.add_bus_effect(bus, record)
	record.set_recording_active(true)
	audio.play_event("victory")
	await create_timer(0.8).timeout
	record.set_recording_active(false)
	var captured := record.get_recording()
	var peak: int = 0
	if captured:
		for i in range(0, captured.data.size(), 2):
			peak = maxi(peak, absi(captured.data.decode_s16(i)))
	expect(peak > 100 and peak < 32767, "Mix reproduz amostras não silenciosas sem saturar")
	if captured:
		captured.save_to_wav("res://tests/artifacts/audio_mix.wav")
	AudioServer.remove_bus_effect(bus, AudioServer.get_bus_effect_count(bus) - 1)
	scene.queue_free()
	await process_frame
	audio.settings_path = original
	audio.volumes = {"Master": 0.8, "Music": 0.35, "Ambience": 0.55, "SFX": 0.7}
	audio.load_settings()
	print("RESULT: %d verificações, %d falhas" % [checks, failures])
	quit(0 if failures == 0 else 1)
