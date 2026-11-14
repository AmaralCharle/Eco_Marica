extends SceneTree
const Profile = preload("res://scripts/core/player_profile.gd")
const Progress = preload("res://scripts/core/mission_progress.gd")
const Mission = preload("res://scripts/levels/aracatiba.gd")
var checks: int = 0
var failures: int = 0
func _initialize() -> void:
	call_deferred("run")
func expect(ok: bool, title: String) -> void:
	checks += 1
	if ok:
		print("PASS: " + title)
	else:
		failures += 1
		push_error("FAIL: " + title)
func frames(count: int = 5) -> void:
	for i in count:
		await physics_frame
		await process_frame
func click(level: Node, prefix: String) -> bool:
	for node in level.get_node("MissionHUD").content.get_children():
		if node is Button and node.text.begins_with(prefix) and not node.disabled:
			node.pressed.emit()
			return true
	return false
func complete(level: Node) -> void:
	for id in level.session.records.keys():
		level.session.collect(id)
		level.session.sort_into(level.session.records[id]["material"])
	for id in level.session.drains.keys():
		level.session.clean_drain(id)
func run() -> void:
	var path := "res://tests/artifacts/campaign_flow_progress.json"
	var profile_path := "res://tests/artifacts/campaign_flow_profile.json"
	var file := FileAccess.open(path, FileAccess.WRITE)
	file.store_string(JSON.stringify({"version": 1, "unlocked_level": 1}))
	file.close()
	Profile.new(profile_path).select_character("marina")
	var level = load("res://scenes/levels/aracatiba.tscn").instantiate()
	level.progress_path = path
	level.profile_path = profile_path
	root.add_child(level)
	current_scene = level
	level.set_physics_process(false)
	await frames()
	expect(not click(level, "Jogar • Resgate"), "Nova campanha bloqueia fase 2 no menu")
	expect(click(level, "Jogar • Operação") and level.state == Mission.State.INSTRUCOES, "Menu inicia instruções de Araçatiba")
	expect(click(level, "Começar missão"), "Botão inicia primeira fase")
	complete(level)
	expect(level.state == Mission.State.VITORIA and level.session.score == 425 and Progress.new(path).unlocked_level == 2, "Araçatiba concluída libera fase 2 no mesmo progresso")
	expect(click(level, "Próxima fase"), "Resultado abre fase 2 pelo botão")
	await frames()
	level = current_scene
	level.set_physics_process(false)
	expect(level.mission_id == "itaipuacu" and level.state == Mission.State.INSTRUCOES and level.player.visual.character_id == "marina", "Itaipuaçu recebe perfil e instruções corretos")
	click(level, "Começar missão")
	complete(level)
	expect(level.state == Mission.State.VITORIA and level.session.score == 520 and Progress.new(path).unlocked_level == 3, "Itaipuaçu concluída libera fase final")
	expect(click(level, "Próxima fase"), "Resultado abre Centro pelo botão")
	await frames()
	level = current_scene
	level.set_physics_process(false)
	expect(level.mission_id == "centro" and level.state == Mission.State.INSTRUCOES and level.profile_path == profile_path, "Centro recebe a mesma campanha e personagem")
	click(level, "Começar missão")
	complete(level)
	expect(level.state == Mission.State.VITORIA and level.session.score == 515 and Progress.new(path).campaign_completed, "Terceira vitória grava campanha concluída")
	expect(click(level, "Ver conclusão") and level.state == Mission.State.FINALIZADO, "Botão de vitória abre encerramento da campanha")
	expect(click(level, "Voltar ao menu"), "Encerramento oferece retorno ao menu")
	await frames()
	level = current_scene
	expect(level.progress.campaign_completed and level.profile.selected_id == "marina" and click(level, "Campanha concluída"), "Menu preserva conclusão e oferece revisão")
	level.queue_free()
	await process_frame
	print("RESULT: %d verificações, %d falhas" % [checks, failures])
	quit(0 if failures == 0 else 1)
