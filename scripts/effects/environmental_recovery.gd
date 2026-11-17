extends Node3D
## Observador de apresentação: jamais escreve pontuação, relógio, saves ou vitória.
signal cinematic_finished
const Garden = preload("res://scripts/effects/recovery_garden.gd")
const Library = preload("res://scripts/effects/asset_library.gd")
const Design = preload("res://scripts/ui/eco_theme.gd")
const DURATION := 6.5
const CAPTIONS = {
	"aracatiba":["Araçatiba · A orla volta a receber encontros","Canteiros e convivência recuperados na simulação."],
	"itaipuacu":["Itaipuaçu · Cuidar da praia é preservar a restinga","Resíduos destinados; vegetação costeira em destaque."],
	"centro":["Centro · Caminhos de drenagem desobstruídos","Reduzir obstruções não garante evitar enchentes."],
	"ubatiba":["Ubatiba · Cada intervenção deixa uma marca","Transformação simbólica: árvores não crescem instantaneamente."],
	"ponta_negra":["Ponta Negra · O canal recebe um novo cuidado","Destino correto dos resíduos e respeito à atividade de pesca."]
}
var mission: Node3D
var gardens: Array[Node3D] = []
var drain_markers: Dictionary = {}
var residents: Array[Node3D] = []
var reaction_labels: Array[Label3D] = []
var stage := 0
var active := false
var played := false
var elapsed := 0.0
var current_progress := 0.0
var notice_left := 0.0
var camera: Camera3D
var previous_camera: Camera3D
var previous_mouse := Input.MOUSE_MODE_VISIBLE
var canvas: CanvasLayer
var cinema_root: Control
var skip_button: Button
var notice: PanelContainer
var notice_text: Label
var from_position := Vector3.ZERO
var to_position := Vector3.ZERO
var focus := Vector3.ZERO
var resident_started := false
var hidden_world_labels: Array[Label3D] = []
var reaction_caption: Label

func _ready() -> void:
	mission = get_parent().get_parent()
	name = "EnvironmentalRecovery"
	build_gardens()
	build_drain_markers()
	if mission.mission_id == "aracatiba": build_residents()
	if mission.mission_id == "ponta_negra": call_deferred("build_fisher_reactions")
	build_interface()
	camera = Camera3D.new()
	camera.name = "RecoveryCamera"
	camera.fov = 65
	add_child(camera)
	mission.session.changed.connect(sync_progress)
	mission.state_changed.connect(on_state_changed)
	sync_progress()

func build_gardens() -> void:
	var locations: Array = {
		"aracatiba":[Vector3(-10.2,0,-12),Vector3(-10.2,0,-1),Vector3(-10.2,0,10)],
		"itaipuacu":[Vector3(9,0,-10),Vector3(9,0,0),Vector3(9,0,10)],
		"centro":[Vector3(-6.1,0.12,-5),Vector3(6.1,0.12,7),Vector3(-6.1,0.12,14)],
		"ubatiba":[Vector3(11.8,0,-9),Vector3(11.8,0,0),Vector3(11.8,0,9)],
		"ponta_negra":[Vector3(12,0,-13),Vector3(12,0,-5),Vector3(12,0,4)]
	}[mission.mission_id]
	for i in locations.size():
		var garden := Garden.new()
		garden.name = "RecoveryGarden%d" % i
		garden.position = locations[i]
		add_child(garden)
		garden.build(i,mission.mission_id in ["itaipuacu","ponta_negra"])
		gardens.append(garden)

func build_drain_markers() -> void:
	if mission.mission_id != "centro": return
	for drain in get_tree().get_nodes_in_group("mission_drains"):
		if not mission.is_ancestor_of(drain): continue
		var marker := Node3D.new()
		marker.position = drain.position+Vector3.UP*0.045
		add_child(marker)
		var material := StandardMaterial3D.new()
		material.albedo_color = Color("a4dfcb")
		material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		for i in 3:
			var arrow := MeshInstance3D.new()
			var mesh := PrismMesh.new()
			mesh.size = Vector3(0.16,0.015,0.28)
			arrow.mesh = mesh
			arrow.material_override = material
			arrow.position = Vector3(-0.32+i*0.32,0,0.65)
			arrow.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
			marker.add_child(arrow)
		marker.hide()
		drain_markers[drain.drain_id] = marker

func build_residents() -> void:
	for i in 2:
		var resident := Node3D.new()
		resident.name = "ReturningResident%d" % i
		resident.position = Vector3(-8.7,0,10+i*2.0)
		add_child(resident)
		var model: Node3D = Library.place(resident,"characters","man",Vector3.ZERO,Vector3(4,1.75,4),PI)
		var animator: AnimationPlayer = model.find_children("*","AnimationPlayer",true,false)[0]
		for clip: String in ["HumanArmature|Man_Walk","HumanArmature|Man_Idle"]:
			animator.get_animation(clip).loop_mode = Animation.LOOP_LINEAR
		resident.set_meta("animator",animator)
		resident.hide()
		residents.append(resident)

func build_fisher_reactions() -> void:
	var fisheries := mission.get_node_or_null("Fisheries")
	if fisheries == null: return
	var phrases: Array[String] = ["Valeu, meu patrão!","Boa, camarada!","Opa! Canal bem cuidado!","Valeu pela força, parceiro!"]
	for i in fisheries.fishermen.size():
		var npc: Node3D = fisheries.fishermen[i]
		var label := Label3D.new()
		label.text = phrases[i]
		label.position.y = 2.5
		label.font_size = 34
		label.pixel_size = 0.005
		label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		label.modulate = Color("fff0bc")
		npc.add_child(label)
		label.hide()
		reaction_labels.append(label)

func build_interface() -> void:
	canvas = CanvasLayer.new()
	canvas.layer = 24
	add_child(canvas)
	var notice_center := CenterContainer.new()
	notice_center.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	notice_center.position.y = 24
	canvas.add_child(notice_center)
	notice = PanelContainer.new()
	notice.add_theme_stylebox_override("panel",Design.frame(0.93,12))
	notice.mouse_filter = Control.MOUSE_FILTER_IGNORE
	notice_center.add_child(notice)
	notice_text = Label.new()
	notice_text.add_theme_font_size_override("font_size",16)
	notice.add_child(notice_text)
	notice.hide()
	cinema_root = Control.new()
	cinema_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	canvas.add_child(cinema_root)
	for top: bool in [true,false]:
		var bar := ColorRect.new()
		bar.color = Color("0c2025")
		bar.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE if top else Control.PRESET_BOTTOM_WIDE)
		bar.offset_top = 0 if top else (-160 if mission.mission_id == "ponta_negra" else -120)
		bar.offset_bottom = 80 if top else 0
		cinema_root.add_child(bar)
	var title := Label.new()
	title.text = CAPTIONS[mission.mission_id][0]
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	title.offset_top = 25
	title.offset_bottom = 60
	title.add_theme_font_size_override("font_size",24)
	cinema_root.add_child(title)
	var caption := Label.new()
	caption.text = CAPTIONS[mission.mission_id][1]
	caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	caption.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	caption.offset_top = -145 if mission.mission_id == "ponta_negra" else -105
	caption.offset_bottom = -116 if mission.mission_id == "ponta_negra" else -76
	caption.add_theme_font_size_override("font_size",18)
	cinema_root.add_child(caption)
	if mission.mission_id == "ponta_negra":
		reaction_caption = Label.new()
		reaction_caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		reaction_caption.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
		reaction_caption.offset_top = -112
		reaction_caption.offset_bottom = -82
		reaction_caption.add_theme_font_size_override("font_size",20)
		reaction_caption.add_theme_color_override("font_color",Design.MINT)
		cinema_root.add_child(reaction_caption)
	var button_center := CenterContainer.new()
	button_center.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	button_center.offset_top = -68
	button_center.offset_bottom = -16
	cinema_root.add_child(button_center)
	skip_button = Button.new()
	skip_button.text = "Continuar para o resultado · Espaço / Enter / Esc"
	skip_button.custom_minimum_size = Vector2(470,44)
	skip_button.pressed.connect(stop_cinematic)
	button_center.add_child(skip_button)
	cinema_root.hide()

func sync_progress() -> void:
	var session = mission.session
	# A apresentação acompanha IDs resolvidos inclusive ao restaurar um estado de teste.
	# Itens disponíveis permanecem visíveis; não removemos objetivos para otimização.
	for group: String in ["training_waste","floating_waste"]:
		for item in get_tree().get_nodes_in_group(group):
			if mission.is_ancestor_of(item) and session.records.has(item.waste_id) and session.records[item.waste_id].state != session.WasteState.AVAILABLE:
				item.hide()
	var ratio: float
	match mission.mission_id:
		"centro": ratio = session.drains_cleaned/3.0
		"ubatiba": ratio = session.assessed/12.0
		_: ratio = float(session.correct)/mission.definition().target
	current_progress = clampf(ratio,0,1)
	if mission.state == mission.State.VITORIA: current_progress = 1
	var next_stage := mini(3,int(floor(current_progress*3+0.0001)))
	while stage<next_stage:
		gardens[stage].reveal()
		stage += 1
		notice_left = 3.5
		notice_text.text = "✓ Área em recuperação · %d/3 setores visuais" % stage
	for id: String in drain_markers:
		drain_markers[id].visible = session.drains.get(id,false)
	if mission.mission_id == "centro":
		for drain in get_tree().get_nodes_in_group("mission_drains"):
			if mission.is_ancestor_of(drain) and session.drains.get(drain.drain_id,false) and not drain.cleaned:
				drain.show_cleaned()

func on_state_changed() -> void:
	if active and mission.state != mission.State.VITORIA: stop_cinematic()
	if mission.state != mission.State.VITORIA: return
	sync_progress()
	return_residents()
	# Os testes de regras podem iniciar a tomada explicitamente, sem auto-interferência.
	if DisplayServer.get_name() != "headless" and not OS.get_cmdline_user_args().has("--no-recovery-cinema"):
		call_deferred("start_cinematic")

func return_residents() -> void:
	if resident_started: return
	resident_started = true
	for resident in residents:
		resident.show()
		var animator: AnimationPlayer = resident.get_meta("animator")
		animator.play("HumanArmature|Man_Walk",0.2)
		var walk := create_tween()
		walk.tween_property(resident,"position:z",resident.position.z-3.0,4.0)
		walk.tween_callback(func(): animator.play("HumanArmature|Man_Idle",0.2))

func start_cinematic() -> bool:
	if active or played or mission.state != mission.State.VITORIA: return false
	played = true
	active = true
	elapsed = 0
	previous_camera = get_viewport().get_camera_3d()
	previous_mouse = Input.mouse_mode
	var shots: Dictionary = {
		"aracatiba":[Vector3(-1,5,17),Vector3(-1,4.2,5),Vector3(-8.5,0.8,2)],
		"itaipuacu":[Vector3(-4,8,17),Vector3(-8,6,5),Vector3(2,1,0)],
		"centro":[Vector3(10,9,17),Vector3(7,6,4),Vector3(0,0.7,-1)],
		"ubatiba":[Vector3(12,10,18),Vector3(9,7,8),Vector3(0,0.9,-3)],
		"ponta_negra":[Vector3(2,8,17),Vector3(-4,6,5),Vector3(0,1,-2)]
	}
	from_position = shots[mission.mission_id][0]
	to_position = shots[mission.mission_id][1]
	focus = shots[mission.mission_id][2]
	if mission.mission_id == "ponta_negra":
		var boat_position: Vector3 = mission.get_node("Boat").position
		from_position = boat_position+Vector3(-7,6,8)
		to_position = boat_position+Vector3(-9,5,0)
		focus = boat_position+Vector3(0,0.8,-5)
	camera.position = from_position
	camera.look_at(focus)
	camera.current = true
	for label: Label3D in mission.get_node("World").find_children("*","Label3D",true,false):
		if label.is_visible_in_tree():
			hidden_world_labels.append(label)
			label.hide()
	mission.get_node("MissionHUD").set_cinematic_active(true)
	cinema_root.show()
	skip_button.grab_focus()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	return true

func stop_cinematic() -> void:
	if not active: return
	active = false
	cinema_root.hide()
	if is_instance_valid(previous_camera): previous_camera.current = true
	else: camera.current = false
	mission.get_node("MissionHUD").set_cinematic_active(false)
	Input.mouse_mode = previous_mouse if mission.state == mission.State.JOGANDO else Input.MOUSE_MODE_VISIBLE
	for label in reaction_labels: label.hide()
	for label in hidden_world_labels:
		if is_instance_valid(label): label.show()
	hidden_world_labels.clear()
	cinematic_finished.emit()

func _input(event: InputEvent) -> void:
	if active and event is InputEventKey and event.pressed and not event.echo and event.keycode in [KEY_ESCAPE,KEY_SPACE,KEY_ENTER,KEY_KP_ENTER]:
		stop_cinematic()
		get_viewport().set_input_as_handled()

func _process(delta: float) -> void:
	notice_left = maxf(0,notice_left-delta)
	notice.visible = notice_left>0 and mission.state == mission.State.JOGANDO
	if not active: return
	elapsed = minf(DURATION,elapsed+maxf(delta,0))
	var t := elapsed/DURATION
	t = t*t*(3-2*t)
	camera.position = from_position.lerp(to_position,t)
	camera.look_at(focus)
	var fisheries := mission.get_node_or_null("Fisheries")
	if fisheries:
		for npc in fisheries.fishermen: npc.balloon.hide()
	var reaction_index := mini(3,int(elapsed/1.6))
	for i in reaction_labels.size(): reaction_labels[i].visible = reaction_index==i
	if reaction_caption and fisheries and reaction_labels.size()>reaction_index:
		reaction_caption.text = fisheries.fishermen[reaction_index].display_name+": “"+reaction_labels[reaction_index].text+"”"
	if elapsed>=DURATION: stop_cinematic()
