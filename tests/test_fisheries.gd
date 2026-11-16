extends SceneTree
const Fisher = preload("res://scripts/gameplay/fisherman.gd")
var checks := 0
var failures := 0
func _initialize() -> void: call_deferred("run")
func check(ok: bool, title: String) -> void:
	checks += 1
	if not ok: failures += 1; push_error(title)
func frames(count: int = 4) -> void:
	for i in count: await physics_frame; await process_frame
func run() -> void:
	var level = load("res://scenes/levels/ponta_negra.tscn").instantiate()
	level.profile_path = "res://tests/artifacts/fisheries_test_profile.json"
	level.progress_path = "res://tests/artifacts/fisheries_test_progress.json"
	root.add_child(level)
	current_scene = level
	level.set_physics_process(false)
	level.set_state(level.State.JOGANDO)
	level.player.set_physics_process(false)
	level.get_node("Interaction").set_physics_process(false)
	var system: Node3D = level.get_node("Fisheries")
	system.set_physics_process(false)
	await frames()
	check(system.fishermen.size()==4,"Quatro pescadores instanciados")
	var names: Array[String] = []
	var bank := 0
	var bridge := 0
	for npc in system.fishermen:
		names.append(npc.display_name)
		if npc.position.y>3: bridge += 1
		else: bank += 1
		check(not npc.model.find_children("*","Skeleton3D",true,false).is_empty(),npc.display_name+": modelo real sem novo controlador")
	check(names == ["Cacadi","João do Canal","Naldo","Beto da Ponte"] and bank==2 and bridge==2,"Nomes e distribuição solicitados")
	check(system.find_children("*","CollisionObject3D",true,false).is_empty(),"Expansão não adiciona colisões estáticas que bloqueiem caminhos")
	var camera := Camera3D.new()
	level.add_child(camera)
	camera.current = true
	for npc in system.fishermen:
		npc.greeting_cooldown = 0
		npc.phase_time = 0
		npc.wait_for = 1000
		npc.advance(0.01,npc.position+Vector3(5.01,0,0))
		check(npc.greeting_left==0,npc.display_name+": fora de cinco metros não cumprimenta")
		npc.advance(0.01,npc.position+Vector3(5,0,0))
		check(npc.greeting_left==3.0 and npc.greeting in npc.dialogue_text,npc.display_name+": limite inclusivo de cinco metros e fala exata")
		var times: int = npc.greeted_count
		npc.advance(2.99,npc.position+Vector3(0,0,3))
		check(npc.greeting_left>0,npc.display_name+": fala permanece durante três segundos")
		npc.advance(0.02,npc.position+Vector3(0,0,3))
		check(npc.greeting_left==0 and npc.greeted_count==times,npc.display_name+": fala termina sem repetir antes do intervalo")
		npc.advance(16.8,npc.position+Vector3(0,0,3))
		check(npc.greeted_count==times,npc.display_name+": cooldown ainda ativo antes de 20 s")
		npc.advance(0.2,npc.position+Vector3(0,0,3))
		check(npc.greeted_count==times+1,npc.display_name+": novo cumprimento depois de 20 s")
		npc.enter(Fisher.Phase.PREPARE)
		check("Olha a tarrafa!" in npc.dialogue_text and npc.greeting in npc.dialogue_text,npc.display_name+": aviso não apaga cumprimento ainda ativo")
		camera.position = npc.position+Vector3(0,1.05,4)
		camera.look_at(npc.position+Vector3.UP*1.05)
		var point := camera.unproject_position(npc.position+Vector3.UP*1.05)
		check(system.update_focus(camera,point)==npc and npc.name_label.visible,npc.display_name+": nome por foco com linha de visão")
		system.update_focus(camera,Vector2.ZERO)
		check(not npc.name_label.visible,npc.display_name+": nome some ao sair da mira")
	for npc in system.fishermen:
		npc.enter(Fisher.Phase.WAIT)
		npc.wait_for = npc.start_delay
		npc.greeting_cooldown = 9999
	level.player.position = Vector3(15,0,16)
	var max_active := 0
	var visits: Dictionary = {}
	for i in 1800:
		system.advance(0.1)
		max_active = maxi(max_active,system.active_count())
		for npc in system.fishermen: visits[npc.display_name+str(npc.phase)] = true
	check(max_active<=2 and max_active>0,"Ciclos reais respeitam limite simultâneo de tarrafas")
	for npc in system.fishermen:
		for state in [Fisher.Phase.WAIT,Fisher.Phase.PREPARE,Fisher.Phase.THROW,Fisher.Phase.OPEN,Fisher.Phase.RETRIEVE]:
			check(visits.has(npc.display_name+str(state)),npc.display_name+": ciclo visita estado "+str(state))
		check(absf(npc.net_anchor.x)>system.RADIUS+system.BOAT_MARGIN+0.5,"Corredor central livre para contornar")
		check(npc.net_anchor.distance_to(level.get_node("Boat").dock_position)>6,"Píer permanece fora das tarrafas")
	var npc: Node3D = system.fishermen[0]
	var boat: CharacterBody3D = level.get_node("Boat")
	for other in system.fishermen: other.enter(Fisher.Phase.WAIT)
	boat.position = npc.net_anchor+Vector3.UP*0.02
	check(not system.can_cast(npc),"Pescador não lança sob a embarcação")
	npc.enter(Fisher.Phase.PREPARE)
	npc.phase_time = 2.5
	npc.advance(0.01,level.player.position)
	check(npc.phase==Fisher.Phase.WAIT,"Lançamento adiado se barco ocupa o destino")
	boat.position = boat.dock_position
	system.fishermen[1].enter(Fisher.Phase.OPEN)
	system.fishermen[2].enter(Fisher.Phase.OPEN)
	check(not system.can_cast(npc),"Terceira rede simultânea recusada mesmo com ciclos sobrepostos")
	for other in system.fishermen: other.enter(Fisher.Phase.WAIT)
	npc.enter(Fisher.Phase.OPEN)
	boat.position = npc.net_anchor+Vector3(0,0.02,3.8)
	boat.speed = 6
	boat.velocity = Vector3(0,0,-6)
	var points: int = level.session.score
	system.constrain_boat(boat,0.5)
	var predicted := boat.position+boat.velocity*0.5
	check(Vector2(predicted.x-npc.net_anchor.x,predicted.z-npc.net_anchor.z).length()>=system.RADIUS+system.BOAT_MARGIN,"Varredura impede atravessar rede mesmo com passo de meio segundo")
	check(boat.speed<6 and system.feedback_left>0 and level.session.score==points,"Contato reduz velocidade e avisa sem penalizar pontos")
	boat.velocity = Vector3(0,0,3)
	system.constrain_boat(boat,0.1)
	check(boat.velocity.z==3,"Recuo para longe da rede é permitido")
	npc.enter(Fisher.Phase.RETRIEVE)
	boat.velocity = Vector3(0,0,-6)
	system.constrain_boat(boat,0.5)
	check(boat.velocity.z==-6,"Rede recolhendo deixa de bloquear imediatamente")
	npc.enter(Fisher.Phase.OPEN)
	var frozen: float = npc.phase_time
	npc.show_dialog(npc.greeting)
	level.set_state(level.State.PAUSADO)
	system.advance(1)
	check(npc.phase_time==frozen and npc.greeting_left==3 and npc.animator.speed_scale==0,"Pausa congela ciclos, falas e animação")
	level.set_state(level.State.JOGANDO)
	level.player.set_physics_process(false)
	for other in system.fishermen: other.enter(Fisher.Phase.WAIT)
	boat.position = boat.dock_position
	boat.speed = 0
	level.player.position = boat.landing_position
	check(level.try_board(),"Contato integrado: embarque original")
	npc.enter(Fisher.Phase.OPEN)
	boat.position = Vector3(npc.net_anchor.x,0.05,10)
	boat.rotation.y = 0
	Input.action_press("move_forward")
	await frames(120)
	check(boat.position.z>=npc.net_anchor.z+system.RADIUS+system.BOAT_MARGIN-0.04 and system.feedback_left>0,"Controle WASD real para antes da tarrafa")
	npc.enter(Fisher.Phase.RETRIEVE)
	await frames(90)
	Input.action_release("move_forward")
	check(boat.position.z<7.0,"Controle real atravessa a região depois do recolhimento")
	boat.position = boat.dock_position
	boat.speed = 0
	check(level.try_disembark() and level.session.score==points,"Contato integrado preserva desembarque e pontos")
	level.player.set_physics_process(false)
	for id: String in ["lucas","marina","rafael","bia"]:
		level.player.set_character(id)
		level.player.position = boat.landing_position
		check(level.try_board(),id+": embarca sem novo personagem lógico")
		await frames(8)
		boat.set_physics_process(false)
		var visual: Node3D = boat.get_node("Passenger")
		var rig: Skeleton3D = visual.find_children("*","Skeleton3D",true,false)[0]
		var upper := rig.find_bone("UpperLeg.L")
		var lower := rig.find_bone("LowerLeg.L")
		# Godot restaura poses depois dos modificadores: medir no sinal de renderização correto.
		var observed: Dictionary = {}
		rig.get_node("SeatedRowingPose").modification_processed.connect(func():
			observed["knee"] = rig.global_transform*rig.get_bone_global_pose(lower).origin
			observed["hip"] = rig.global_transform*rig.get_bone_global_pose(upper).origin)
		await frames()
		var knee: Vector3 = observed.get("knee",Vector3.ZERO)
		var hip: Vector3 = observed.get("hip",Vector3.ZERO)
		check(visual.seated and absf(knee.y-hip.y)<0.18 and Vector2(knee.x-hip.x,knee.z-hip.z).length()>0.15,id+": coxas horizontais em postura sentada")
		var pelvis := rig.global_transform*rig.get_bone_global_pose(rig.find_bone("Hips")).origin
		check(absf(boat.to_local(pelvis).y-0.48)<0.06,id+": quadril alinhado ao banco")
		var art: Node3D = boat.get_node("BoatArt")
		boat.speed = 3
		var phase: float = art.rowing_phase
		art._process(0.5)
		check(art.oars.size()==2 and art.rowing_phase>phase and visual.rowing_amount>0,id+": dois remos e braços usam ciclo de navegação")
		boat.speed = 0
		art._process(1)
		check(art.rowing_amount==0,id+": remada cessa ao parar")
		check(level.try_disembark() and level.player.visible and not visual.seated,id+": desembarque restaura modo terrestre")
		level.player.set_physics_process(false)
	var audio: Node = root.get_node("GameAudio")
	var hashes: Dictionary = {}
	for id: String in ["aracatiba","itaipuacu","centro","ubatiba","ponta_negra"]:
		var music: AudioStreamWAV = audio.stream_for(id,"music",true)
		check(music.stereo and music.get_length()>30 and music.loop_end==music.data.size()/4,id+": trilha estéreo própria com loop completo")
		hashes[hash(music.data)] = true
		audio.set_context(id,true)
		await create_timer(0.32).timeout
		check(audio.music.playing and audio.music.stream.data==music.data,id+": música correta chega ao player do mixer")
	check(hashes.size()==5,"Cinco gravações distintas, sem reutilizar o mesmo áudio")
	level.queue_free()
	await frames()
	print("RESULT: %d verificações, %d falhas" % [checks,failures])
	quit(0 if failures==0 else 1)
