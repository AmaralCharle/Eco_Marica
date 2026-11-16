extends SceneTree
var prefix: String
func _initialize() -> void: call_deferred("run")
func snap(title: String) -> void:
	await create_timer(0.40).timeout
	await RenderingServer.frame_post_draw
	var error := root.get_texture().get_image().save_png("res://tests/artifacts/"+prefix+"_"+title+".png")
	print("CAPTURE: ",prefix," ",title," ",error_string(error))
func run() -> void:
	root.get_node("GameAudio").quality = 2
	for resolution: Vector2i in [Vector2i(1280,720),Vector2i(1920,1080)]:
		root.size = resolution
		prefix = "assets_campaign_%d" % resolution.y
		var progress_path := "res://tests/artifacts/"+prefix+"_progress.json"
		var file := FileAccess.open(progress_path,FileAccess.WRITE)
		file.store_string('{"version":2,"unlocked_level":5}')
		file.close()
		for id: String in ["aracatiba","itaipuacu","centro","ubatiba","ponta_negra"]:
			var level = load("res://scenes/levels/"+id+".tscn").instantiate()
			level.profile_path = "res://tests/artifacts/assets_campaign_capture_profile.json"
			level.progress_path = progress_path
			root.add_child(level)
			current_scene = level
			level.set_physics_process(false)
			if id == "aracatiba": await snap("menu")
			level.show_instructions()
			level.start_mission()
			level.player.set_physics_process(false)
			if id == "centro": level.get_node("World").advance_storm(0.85,0)
			await snap(id+"_gameplay")
			level.evolution.open_notebook()
			await snap(id+"_notebook")
			level.evolution.answer(level.evolution.question.correct)
			level.player.set_physics_process(false)
			if id == "ubatiba":
				for point in get_nodes_in_group("planting_plots"):
					level.inspect_point(point)
					if point.apt:
						level.choose_action("prepare")
						level.choose_action("plant")
						if point.exposed: level.choose_action("protect")
					else: level.choose_action("preserve")
					level.close_inspection()
					level.player.set_physics_process(false)
			elif id == "ponta_negra":
				var items := get_nodes_in_group("floating_waste")
				var boat = level.get_node("Boat")
				for batch in 4:
					level.player.position = boat.landing_position
					if not level.try_board(): quit(1); return
					boat.set_physics_process(false)
					for i in range(batch*5,batch*5+5):
						boat.position = items[i].position+Vector3(0,0,1.5)
						level.boat_interact()
					if batch == 0:
						await create_timer(0.55).timeout
						await snap("boat_full")
					boat.position = boat.dock_position
					boat.speed = 0
					if not level.try_disembark(): quit(1); return
					level.player.set_physics_process(false)
					while not level.session.carried_id.is_empty(): level.session.sort_into(level.session.records[level.session.carried_id].material)
			else:
				if id == "centro":
					while not level.evolution.priorities().is_empty():
						var drain = level.evolution.priorities()[0].node
						level.session.clean_drain(drain.drain_id)
						drain.show_cleaned()
				for key in level.session.records.keys():
					level.session.collect(key)
					level.session.sort_into(level.session.records[key].material)
			if level.state != level.State.VITORIA or level.result_rating != 3:
				push_error("Resultado real da captura não atingiu vitória perfeita: "+id)
				quit(1)
				return
			await snap(id+"_victory")
			if id == "ponta_negra":
				level.show_campaign_completion()
				await create_timer(1.5).timeout
				await snap("campaign")
			level.queue_free()
			await process_frame
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	root.get_node("GameAudio").request_quit()
