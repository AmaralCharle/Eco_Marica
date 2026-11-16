extends SceneTree
const Visual = preload("res://scenes/player/character_visual.tscn")
var prefix: String = "after"
var stage: Node3D
var camera: Camera3D
var model: Node3D
var samples: Array[Dictionary] = []
func _initialize() -> void:
	if OS.get_cmdline_user_args().size(): prefix = OS.get_cmdline_user_args()[0]
	call_deferred("run")
func snap(label: String) -> void:
	await create_timer(0.2).timeout
	await RenderingServer.frame_post_draw
	var error := root.get_texture().get_image().save_png("res://tests/artifacts/character_%s_%s.png" % [prefix,label])
	print("CAPTURE: ",label," ",error_string(error))
func measure(id: String) -> void:
	for i in 20: await process_frame
	var start := Time.get_ticks_usec()
	var calls := 0.0
	for i in 90:
		await process_frame
		calls += Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME)
	samples.append({"id":id,"fps":90.0*1000000/(Time.get_ticks_usec()-start),"draw_calls":calls/90.0,"primitives":Performance.get_monitor(Performance.RENDER_TOTAL_PRIMITIVES_IN_FRAME)})
func run() -> void:
	root.size = Vector2i(1280,720)
	root.msaa_3d = Viewport.MSAA_4X
	stage = Node3D.new()
	root.add_child(stage)
	current_scene = stage
	var environment := WorldEnvironment.new()
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color("a8c4c0")
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color("d5e6e6")
	env.ambient_light_energy = 0.55
	env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	environment.environment = env
	stage.add_child(environment)
	var light := DirectionalLight3D.new()
	light.rotation_degrees = Vector3(-38,150,0)
	light.light_energy = 1.5
	light.shadow_enabled = true
	stage.add_child(light)
	var fill := DirectionalLight3D.new()
	fill.rotation_degrees = Vector3(-20,-45,0)
	fill.light_color = Color("b9dded")
	fill.light_energy = 0.45
	stage.add_child(fill)
	var floor_mesh := MeshInstance3D.new()
	var ground := BoxMesh.new()
	ground.size = Vector3(200,0.05,200)
	var ground_mat := StandardMaterial3D.new()
	ground_mat.albedo_color = Color("7c9c94")
	ground.material = ground_mat
	floor_mesh.mesh = ground
	floor_mesh.position.y = -0.025
	stage.add_child(floor_mesh)
	camera = Camera3D.new()
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.size = 2.45
	stage.add_child(camera)
	model = Visual.instantiate()
	if model.has_method("set_face_animation"): model.set_face_animation(false)
	stage.add_child(model)
	for id: String in (["lucas"] if prefix != "after" else ["lucas","marina","rafael","bia"]):
		model.apply_character(id)
		camera.position = Vector3(-2.0,1.9,-5)
		camera.look_at(Vector3(0,1.02,0))
		await snap(id+"_front")
		await measure(id)
		camera.position = Vector3(2.1,1.8,5)
		camera.look_at(Vector3(0,1.0,0))
		await snap(id+"_back")
		camera.size = 0.85
		camera.position = Vector3(-0.5,1.75,-4)
		camera.look_at(Vector3(0,1.68,0))
		await snap(id+"_face")
		camera.size = 2.45
	var file := FileAccess.open("res://tests/artifacts/character_"+prefix+"_benchmark.json",FileAccess.WRITE)
	file.store_string(JSON.stringify({"renderer":"mobile","resolution":"1280x720","msaa":"4x","samples":samples},"\t"))
	file.close()
	stage.queue_free()
	await process_frame
	quit()
