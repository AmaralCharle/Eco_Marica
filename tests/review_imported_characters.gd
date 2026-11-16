extends SceneTree
const Library = preload("res://scripts/effects/asset_library.gd")
func _initialize() -> void: call_deferred("run")
func run() -> void:
	root.size = Vector2i(1280,720)
	var stage := Node3D.new()
	root.add_child(stage)
	var env := WorldEnvironment.new()
	env.environment = Environment.new()
	env.environment.background_mode = Environment.BG_COLOR
	env.environment.background_color = Color("91b7ba")
	env.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.environment.ambient_light_color = Color.WHITE
	env.environment.ambient_light_energy = 0.5
	stage.add_child(env)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-40,-30,0)
	stage.add_child(sun)
	for i in 4:
		var names := ["man","woman_casual","worker","woman"]
		var raw: Node3D = load("res://assets/imported/quaternius/characters/"+names[i]+".glb").instantiate()
		print(names[i]," bounds: ",Library.bounds(raw))
		raw.free()
		var model := Library.place(stage,"characters",names[i],Vector3(-3+i*2,0,0),Vector3(4,1.85,4))
		var players := model.find_children("*","AnimationPlayer",true,false)
		if not players.is_empty():
			print(names[i],": ",players[0].get_animation_list())
			for clip: String in players[0].get_animation_list():
				if clip.ends_with("_Idle") or clip.ends_with("|Idle"): players[0].play(clip); break
		var label := Label3D.new()
		label.text = names[i]
		label.font_size = 32
		label.position = Vector3(-3+i*2,-0.25,0)
		stage.add_child(label)
	var camera := Camera3D.new()
	camera.position = Vector3(0,2.7,10)
	camera.fov = 45
	stage.add_child(camera)
	camera.look_at(Vector3(0,0.9,0))
	camera.current = true
	for i in 30: await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://tests/artifacts/assets_quaternius_candidates.png")
	await root.get_node("GameAudio").request_quit()
