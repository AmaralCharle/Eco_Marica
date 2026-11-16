extends SceneTree
const Visual = preload("res://scenes/player/character_visual.tscn")
func _initialize() -> void: call_deferred("run")
func run() -> void:
	root.size = Vector2i(1280,720)
	root.msaa_3d = Viewport.MSAA_4X
	var stage := Node3D.new()
	root.add_child(stage)
	var environment := WorldEnvironment.new()
	environment.environment = Environment.new()
	environment.environment.background_mode = Environment.BG_COLOR
	environment.environment.background_color = Color("91b4b0")
	environment.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.environment.ambient_light_color = Color("dae6ec")
	environment.environment.ambient_light_energy = 0.45
	stage.add_child(environment)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-42,-30,0)
	sun.shadow_enabled = true
	stage.add_child(sun)
	var floor_node := MeshInstance3D.new()
	var plane := PlaneMesh.new()
	plane.size = Vector2(16,12)
	floor_node.mesh = plane
	var material := StandardMaterial3D.new()
	material.albedo_color = Color("b2c3a4")
	floor_node.material_override = material
	stage.add_child(floor_node)
	for i in 4:
		var visual = Visual.instantiate()
		visual.character_id = ["lucas","marina","rafael","bia"][i]
		visual.position.x = 2.7-i*1.8
		stage.add_child(visual)
		var label := Label3D.new()
		label.text = ["Lucas","Marina","Rafael","Bia"][i]
		label.font_size = 46
		label.pixel_size = 0.005
		label.position = visual.position+Vector3(0,2.25,0)
		label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		stage.add_child(label)
	var camera := Camera3D.new()
	camera.position = Vector3(0,2.5,-8.0)
	camera.fov = 36
	stage.add_child(camera)
	camera.look_at(Vector3(0,1.0,0))
	camera.current = true
	for i in 40: await process_frame
	await RenderingServer.frame_post_draw
	print("CAPTURE: portraits ",error_string(root.get_texture().get_image().save_png("res://tests/artifacts/assets_characters_front.png")))
	await root.get_node("GameAudio").request_quit()
