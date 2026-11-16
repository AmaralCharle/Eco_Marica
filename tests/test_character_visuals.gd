extends SceneTree
const Visual = preload("res://scenes/player/character_visual.tscn")
const Geo = preload("res://scripts/player/character_geometry.gd")
var checks := 0
var failures := 0
func _initialize() -> void:
	call_deferred("run")
func check(ok: bool, text: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(text)
func frames(n: int = 4) -> void:
	for i in n: await process_frame
func packed_fixture(kind: String = "visual") -> PackedScene:
	var node: Node = Node3D.new() if kind != "2d" else Node.new()
	node.name = "ImportedRoot"
	if kind == "visual":
		var art := MeshInstance3D.new()
		art.name = "Art"
		art.mesh = BoxMesh.new()
		node.add_child(art)
		art.owner = node
		var animator := AnimationPlayer.new()
		animator.name = "RigClips"
		node.add_child(animator)
		animator.owner = node
		var library := AnimationLibrary.new()
		for title: String in ["Wait","Stride","Harvest"]:
			var clip := Animation.new()
			clip.length = 2.0
			var track := clip.add_track(Animation.TYPE_VALUE)
			clip.track_set_path(track,NodePath("Art:rotation:y"))
			clip.track_insert_key(track,0.0,0.0)
			clip.track_insert_key(track,2.0,0.5)
			library.add_animation(title,clip)
		animator.add_animation_library("",library)
	elif kind == "physics":
		var body := StaticBody3D.new()
		node.add_child(body)
		body.owner = node
	elif kind == "camera":
		var camera := Camera3D.new()
		node.add_child(camera)
		camera.owner = node
	var result := PackedScene.new()
	result.pack(node)
	node.free()
	return result
func run() -> void:
	# A face precisa ter normais para fora e dados de cor finitos.
	var shape := Geo.loft([Vector4(-1,1,1,0),Vector4(1,1,1,0)])
	var arrays := shape.surface_get_arrays(0)
	var normals_ok := true
	for i in arrays[Mesh.ARRAY_VERTEX].size():
		var point: Vector3 = arrays[Mesh.ARRAY_VERTEX][i]
		var normal: Vector3 = arrays[Mesh.ARRAY_NORMAL][i]
		if normal.dot(Vector3(point.x,0,point.z)) < -0.01: normals_ok = false
	check(normals_ok,"Normais das superfícies apontam para fora")
	var visual = Visual.instantiate()
	root.add_child(visual)
	await frames()
	var pivots: Array[Node] = [visual.get_node("LeftLeg"),visual.get_node("RightLeg"),visual.get_node("LeftArm"),visual.get_node("RightArm")]
	for id: String in ["lucas","marina","rafael","bia"]:
		visual.apply_character(id)
		await frames()
		var signature := visual.find_children("*","MeshInstance3D",true,false).size()
		visual.apply_character(id)
		await frames()
		check(visual.find_children("*","MeshInstance3D",true,false).size() == signature,"Troca não acumula superfícies: "+id)
		check(signature <= 65,"Orçamento de superfícies articuladas: "+id)
		check(visual.find_children("*","CollisionObject3D",true,false).is_empty() and visual.find_children("*","Camera3D",true,false).is_empty(),"Visual sem física ou câmera: "+id)
		check(visual.eyes.size() == 2 and visual.get_node("Head").get_child_count() > 2,"Rosto e olhos presentes: "+id)
		var same := true
		for i in pivots.size():
			if visual.get_node(["LeftLeg","RightLeg","LeftArm","RightArm"][i]) != pivots[i]: same = false
		check(same,"Pontos de animação permanecem os mesmos objetos: "+id)
		var valid := true
		var bounds := AABB()
		for instance: MeshInstance3D in visual.find_children("*","MeshInstance3D",true,false):
			bounds = bounds.merge((visual.global_transform.affine_inverse()*instance.global_transform)*instance.get_aabb())
			if instance.mesh.get_surface_count() == 0: valid = false
		check(valid and bounds.position.y >= -0.01 and bounds.end.y < 2.2 and bounds.size.x < 1.05,"Silhueta finita e dentro do envelope visual: "+id)
		visual.set_face_animation(true)
		visual.blink_clock = 4.66
		visual._process(0.01)
		check(visual.eyes[0].scale.y < 0.2,"Piscar só afeta olhos: "+id)
		visual.set_face_animation(false)
		check(visual.eyes[0].scale.y == 1.0,"Prévia estática mantém olhos abertos: "+id)
		check(visual.forearms.size() == 2,"Dois cotovelos visuais: "+id)
		visual.set_face_animation(true)
		for state: String in ["idle","walk","run","collect","plant","interact","embark","disembark"]:
			visual.set_animation(state)
			visual._process(0.1)
			check(visual.forearms[0].rotation.is_finite() and visual.forearms[0].rotation.x >= 0.0 and visual.forearms[0].rotation.x < 1.0,"Articulação estável "+id+" / "+state)
	# A montagem importada altera somente o visual, mantendo pivôs para o controlador.
	visual.external_animations = {"idle":"Wait","walk":"Stride","collect":"Harvest"}
	var adjustment := Transform3D(Basis(Vector3.UP,PI).scaled(Vector3.ONE*0.8),Vector3(0,0.1,0))
	var imported: Node3D = visual.attach_external_model(packed_fixture(),adjustment)
	var adapter = visual.get_node("ExternalModel")
	check(imported != null and imported.get_parent().transform == adjustment,"GLB usa alinhamento independente dos ossos animados")
	check(not visual.parts.Head.visible and not visual.parts.Backpack.visible,"Importação oculta todos os componentes procedurais")
	visual.set_animation("walk")
	await frames()
	check(adapter.animator.current_animation == "Stride","Mapeamento encontra AnimationPlayer com nome arbitrário")
	visual.set_animation("idle")
	visual.set_animation("collect")
	await frames()
	check(adapter.animator.current_animation == "Harvest","Ação prevalece sobre locomoção no mesmo tick")
	var elapsed: float = adapter.animator.current_animation_position
	for i in 6:
		visual.set_animation("idle")
		visual.set_animation("collect")
		await frames(2)
	check(adapter.animator.current_animation_position > elapsed,"Ação consecutiva não reinicia o clipe a cada tick")
	visual.set_animation("jump")
	await frames()
	check(adapter.animator.current_animation == "Wait","Clipe ausente usa idle disponível")
	visual.attach_external_model()
	await frames()
	check(visual.get_node_or_null("ExternalModel") == null and visual.parts.Head.visible,"Remover GLB restaura o visual procedural")
	for kind: String in ["2d","physics","camera"]:
		check(visual.attach_external_model(packed_fixture(kind)) == null and not visual.external_error.is_empty() and visual.parts.Head.visible,"Importação incompatível conserva fallback: "+kind)
	visual.external_models = {"marina":packed_fixture()}
	visual.apply_character("marina")
	check(visual.get_node_or_null("ExternalModel") != null,"Modelo opcional selecionado por identidade")
	visual.apply_character("lucas")
	check(visual.get_node_or_null("ExternalModel") == null and visual.parts.Head.visible,"Identidade sem GLB usa procedural completo")
	visual.queue_free()
	await frames()
	# O modo Alto e os modos econômicos seguem disponíveis na fase real.
	var scene = load("res://scenes/levels/aracatiba.tscn").instantiate()
	scene.profile_path = "res://tests/artifacts/visual_quality_profile.json"
	scene.progress_path = "res://tests/artifacts/visual_quality_progress.json"
	root.add_child(scene)
	current_scene = scene
	scene.set_physics_process(false)
	await frames()
	var collision: Node = scene.player.get_node("CollisionShape3D")
	var camera: Node = scene.player.camera_pivot
	var preferences := root.get_node("GameAudio")
	for quality in 3:
		preferences.quality = quality
		scene.get_node("Presentation/WorldPolish").apply_quality()
		check(scene.player.get_node("CollisionShape3D") == collision and scene.player.camera_pivot == camera,"Qualidade mantém corpo e câmera: "+str(quality))
	check(root.msaa_3d == Viewport.MSAA_8X and scene.get_node("Sun").directional_shadow_mode == DirectionalLight3D.SHADOW_PARALLEL_4_SPLITS,"Alto ativa MSAA 8x e quatro cascatas de sombra")
	scene.queue_free()
	await frames()
	scene = load("res://scenes/levels/ponta_negra.tscn").instantiate()
	scene.profile_path = "res://tests/artifacts/visual_quality_profile.json"
	scene.progress_path = "res://tests/artifacts/visual_quality_progress.json"
	root.add_child(scene)
	current_scene = scene
	scene.set_physics_process(false)
	scene.set_state(scene.State.JOGANDO)
	for id: String in ["lucas","marina","rafael","bia"]:
		scene.player.set_character(id)
		scene.player.position = scene.get_node("Boat").landing_position
		var boarded: bool = scene.try_board()
		var passenger = scene.get_node("Boat/Passenger")
		check(boarded and passenger.character_id == id and passenger.visible and not scene.player.visible,"Passageiro usa a mesma identidade aprimorada: "+id)
		check(scene.try_disembark() and scene.player.visible,"Desembarque restaura controlador e aparência: "+id)
	scene.queue_free()
	await frames()
	print("RESULT: %d verificações, %d falhas" % [checks,failures])
	quit(0 if failures == 0 else 1)
