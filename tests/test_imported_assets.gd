extends SceneTree
const Library = preload("res://scripts/effects/asset_library.gd")
var checks := 0
var failures := 0
var used: Dictionary = {}
func _initialize() -> void: call_deferred("run")
func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok: failures += 1; push_error(message)
func frames(count: int = 4) -> void:
	for i in count: await process_frame
func note(path: String, phase: String) -> void:
	if not used.has(path): used[path] = []
	if not phase in used[path]: used[path].append(phase)
func run() -> void:
	for id: String in ["centro","ubatiba","ponta_negra","aracatiba","itaipuacu"]:
		var level = load("res://scenes/levels/"+id+".tscn").instantiate()
		level.profile_path = "res://tests/artifacts/assets_test_profile.json"
		level.progress_path = "res://tests/artifacts/assets_test_progress.json"
		root.add_child(level)
		current_scene = level
		level.set_physics_process(false)
		level.set_state(level.State.JOGANDO)
		await frames()
		var art: Node3D = level.get_node("Presentation/WorldPolish")
		var imported: Node3D = art.get_node("ImportedArt")
		var originals := imported.find_children("*","MeshInstance3D",true,false)
		var drawn := 0
		for batch: MultiMeshInstance3D in imported.find_children("*","MultiMeshInstance3D",true,false):
			if batch.visible: drawn += batch.multimesh.instance_count
		check(drawn > 0 and drawn == originals.size(),id+": agrupamento preserva TODAS as malhas, incluindo folhas filhas")
		check(imported.find_children("*","CollisionObject3D",true,false).is_empty() and imported.find_children("*","Camera3D",true,false).is_empty(),id+": modelos estáticos não introduzem física/câmeras")
		for node in level.find_children("*","Node3D",true,false):
			if node.has_meta("asset_source"): note(node.get_meta("asset_source"),id)
		for mat in art.materials.values():
			if mat is ShaderMaterial and mat.get_shader_parameter("use_pbr") == true:
				for parameter in ["pbr_color","pbr_roughness","pbr_normal"]:
					var texture: Texture2D = mat.get_shader_parameter(parameter)
					check(texture != null and texture.get_width()<=1024 and texture.get_height()<=1024,id+": PBR presente limitado a 1K")
					if texture: note(texture.resource_path,id)
		if id != "centro":
			var sky: PanoramaSkyMaterial = level.get_node("WorldEnvironment").environment.sky.sky_material
			check(sky.panorama != null and sky.panorama.get_width()<=1024,id+": panorama 1K efetivamente ativo")
			note(sky.panorama.resource_path,id)
		var birds: Node3D = art.get_node("AmbientBirds")
		birds._process(0.2)
		check(birds.birds.size()==4 and birds.find_children("*","CollisionObject3D",true,false).is_empty(),id+": aves sem obstáculos e quantidade limitada")
		var time: float = birds.clock
		level.set_state(level.State.PAUSADO)
		birds._process(0.2)
		check(birds.clock==time and not birds.voice.playing,id+": pausa congela voo e pios")
		level.set_state(level.State.JOGANDO)
		if id == "centro":
			level.get_node("World").advance_storm(0.9,0)
			birds._process(0.2)
			check(not birds.birds[0].visible,"Centro: aves recolhem durante tempestade")
		if id == "aracatiba":
			for character: String in ["lucas","marina","rafael","bia"]:
				level.player.set_character(character)
				await frames()
				var visual: Node3D = level.player.visual
				var adapter: Node3D = visual.get_node("ExternalModel")
				var rig: Skeleton3D = adapter.model.find_children("*","Skeleton3D",true,false)[0]
				check(not visual.parts.Head.visible and rig.get_bone_count()>15,character+": modelo real rigado substitui geometria provisória")
				check(not adapter.model.find_children("IdentityEquipment","Node3D",true,false).is_empty(),character+": equipamento de identidade acompanha osso do tronco")
				for state: String in ["idle","walk","run","jump","collect","plant","boat"]:
					visual.set_animation(state)
					await frames()
					check(adapter.animator.has_animation(adapter.animator.current_animation) and rig.get_bone_global_pose(0).origin.is_finite(),character+": estado visual válido "+state)
				var source: String = adapter.model.get_meta("asset_source")
				note(source,id)
				level.set_state(level.State.PAUSADO)
				await frames()
				check(adapter.animator.speed_scale==0,character+": rig pausa sem mexer no controlador")
				level.set_state(level.State.JOGANDO)
				await frames()
				check(adapter.animator.speed_scale==1,character+": rig retoma")
		if id == "ponta_negra":
			var roots_on_land := true
			for node: Node3D in imported.get_children():
				if node.has_meta("asset_source") and "CommonTree" in str(node.get_meta("asset_source")) and absf(node.position.x)<9.5: roots_on_land = false
			check(roots_on_land,"Árvores de fundo permanecem nas margens, sem raízes no canal")
			var boat: Node3D = level.get_node("Boat")
			var old_shape: Shape3D = boat.get_node("Collision").shape
			level.player.position = boat.landing_position
			check(level.try_board(),"Barco importado embarca")
			await frames()
			check(boat.get_node("Passenger").has_node("ExternalModel"),"Passageiro importado aparece no barco")
			check(boat.get_node("Collision").shape==old_shape and level.try_disembark(),"Barco mantém shape original e desembarque")
		level.queue_free()
		await frames()
	var file := FileAccess.open("res://tests/artifacts/asset_integration_report.json",FileAccess.WRITE)
	file.store_string(JSON.stringify({"used":used,"checks":checks,"failures":failures},"\t"))
	file.close()
	print("RESULT: %d verificações, %d falhas" % [checks,failures])
	quit(0 if failures==0 else 1)
