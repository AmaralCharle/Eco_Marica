extends SceneTree
var checks := 0
var failures := 0
func _initialize() -> void: call_deferred("run")
func check(ok: bool, title: String) -> void:
	checks += 1
	if not ok: failures += 1; push_error(title)
func frames(n: int) -> void:
	for i in n: await physics_frame; await process_frame
func capture(tag: String) -> void:
	if not "--capture" in OS.get_cmdline_user_args(): return
	await create_timer(0.4).timeout
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://tests/artifacts/ponta_fix_"+tag+".png")
func run() -> void:
	var level = load("res://scenes/levels/ponta_negra.tscn").instantiate()
	level.profile_path = "user://test_ponta_water_profile.json"
	level.progress_path = "user://test_ponta_water_progress.json"
	root.add_child(level)
	current_scene = level
	level.set_physics_process(false)
	level.set_state(level.State.JOGANDO)
	await frames(4)
	var pier: StaticBody3D = level.get_node("World/Pier")
	var deck: MeshInstance3D = pier.get_child(0)
	var land: Node3D = level.get_node("World/Land")
	var deck_right: float = deck.global_position.x+deck.mesh.size.x*0.5
	var land_left: float = land.position.x-land.get_child(0).mesh.size.x*0.5
	check(deck_right<=land_left,"Tablado não sobrepõe a superfície do gramado")
	check(pier.get_child(1).shape.size==Vector3(4,0.25,4),"Collider original do píer preservado")
	level.player.position = Vector3(11,0.1,12)
	level.player.velocity = Vector3.ZERO
	Input.action_press("move_left")
	var low := INF
	var high := -INF
	for i in 50:
		await frames(1)
		level.advance_time(1.0/60)
		if i>15:
			low = minf(low,level.player.position.y)
			high = maxf(high,level.player.position.y)
	Input.action_release("move_left")
	check(level.player.position.x<8 and high-low<0.01 and level.state==level.State.JOGANDO,"Caminhada cruza gramado/píer sem oscilar altura nem perder")
	if "--capture" in OS.get_cmdline_user_args():
		var camera := Camera3D.new()
		level.add_child(camera)
		camera.current = true
		camera.position = Vector3(12,3.5,17)
		camera.look_at(Vector3(7.7,0,12))
		await capture("pier_bank")
		camera.position = Vector3(6,2.2,16)
		camera.look_at(Vector3(8.2,0,12))
		await capture("pier_reverse")
	check(level.try_board(),"Embarque continua acessível depois da travessia")
	level.player.position = Vector3(0,-1,0)
	level.get_node("Boat").position = Vector3(0,0.05,4)
	level.advance_time(0.1)
	check(level.on_boat and level.state==level.State.JOGANDO,"Navegar não causa derrota pela posição do jogador oculto")
	level.get_node("Boat").position = level.get_node("Boat").dock_position
	level.get_node("Boat").speed = 0
	check(level.try_disembark(),"Desembarque preservado")
	level.player.set_physics_process(false)
	for point: Vector3 in [Vector3(11,0,12),Vector3(7,0,12),Vector3(0,3.625,-1),Vector3(-10,0,0),Vector3(0,1,4)]:
		level.player.position = point
		level.advance_time(0)
		check(level.state==level.State.JOGANDO,"Margens, píer, ponte e salto acima da água seguros: "+str(point))
	level.set_state(level.State.PAUSADO)
	level.player.position = Vector3(0,-0.1,4)
	level.advance_time(1)
	check(level.state==level.State.PAUSADO,"Pausa não dispara derrota")
	level.set_state(level.State.JOGANDO)
	level.player.position = Vector3(0,2,4)
	level.player.velocity = Vector3.ZERO
	for i in 100:
		await frames(1)
		level.advance_time(1.0/60)
		if level.state==level.State.DERROTA: break
	check(level.state==level.State.DERROTA and "caiu na água" in level.result_reason,"Queda física real no canal termina em game over")
	check(not level.session.active and not level.player.is_physics_processing(),"Derrota interrompe controles e interações")
	var reason: String = level.result_reason
	level.advance_time(400)
	check(level.result_reason==reason and level.state==level.State.DERROTA,"Resultado da queda não é sobrescrito pelo cronômetro")
	await capture("water_game_over")
	level.queue_free()
	await frames(4)
	print("RESULT: %d verificações, %d falhas" % [checks,failures])
	if "--capture" in OS.get_cmdline_user_args():
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		await root.get_node("GameAudio").request_quit()
		return
	quit(0 if failures==0 else 1)
