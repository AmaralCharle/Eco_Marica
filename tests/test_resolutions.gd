extends SceneTree
var checks := 0
var failures := 0
func _initialize() -> void: call_deferred("run")
func frames() -> void:
	for i in 8: await process_frame
func check(ok: bool,title: String) -> void:
	checks += 1
	if not ok: failures += 1; push_error(title)
func fits(control: Control) -> bool:
	return Rect2(Vector2.ZERO,root.get_visible_rect().size+Vector2.ONE).encloses(control.get_global_rect())
func run() -> void:
	for resolution: Vector2i in [Vector2i(1280,720),Vector2i(1920,1080)]:
		root.size = resolution
		for id: String in ["aracatiba","itaipuacu","centro","ubatiba","ponta_negra"]:
			var level = load("res://scenes/levels/"+id+".tscn").instantiate()
			level.profile_path = "res://tests/artifacts/resolution_profile.json"
			level.progress_path = "res://tests/artifacts/resolution_progress.json"
			root.add_child(level)
			current_scene = level
			level.set_physics_process(false)
			await frames()
			var hud = level.get_node("MissionHUD")
			check(fits(hud.menu_card),"Menu "+id+str(resolution))
			level.set_state(level.State.JOGANDO)
			level.player.set_physics_process(false)
			await frames()
			for panel in hud.dashboard.get_children():
				if panel is PanelContainer: check(fits(panel),"HUD "+id+str(resolution))
			for state in [level.State.PAUSADO,level.State.VITORIA,level.State.DERROTA]:
				level.result_reason = "Resultado de teste de layout com todas as informações e aviso de gravação."
				level.save_ok = false
				level.set_state(state)
				await frames()
				check(fits(hud.menu_card),"Modal "+id+str(state)+str(resolution))
			check(hud.menu_scroll.follow_focus,"Rolagem acompanha navegação por teclado")
			level.queue_free()
			await process_frame
	print("RESULT: %d verificações, %d falhas" % [checks,failures])
	quit(0 if failures == 0 else 1)
