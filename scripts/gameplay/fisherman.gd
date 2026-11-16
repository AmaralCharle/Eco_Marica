extends Node3D
## NPC visual: modelo Quaternius CC0, sem corpo físico ou regras de pontuação.
enum Phase { WAIT, PREPARE, THROW, OPEN, RETRIEVE }
const Library = preload("res://scripts/effects/asset_library.gd")
var display_name: String
var greeting: String
var net_anchor: Vector3
var start_delay: float = 6.0
var shirt_color := Color("617c65")
var phase: Phase = Phase.WAIT
var phase_time: float = 0.0
var wait_for: float
var greeting_cooldown: float = 0.0
var dialogue_left: float = 0.0
var dialogue_text: String = ""
var greeting_left: float = 0.0
var warning_left: float = 0.0
var warning_text: String = ""
var animation_state: String = "idle"
var model: Node3D
var animator: AnimationPlayer
var name_label: Label3D
var balloon: Node3D
var dialogue_label: Label3D
var net_visual: Node3D
var preview: Node3D
var bundle: MeshInstance3D
var fisheries: Node3D
var greeted_count: int = 0

func _ready() -> void:
	fisheries = get_parent()
	wait_for = start_delay
	add_to_group("fishermen")
	model = Library.place(self,"characters","man",Vector3.ZERO,Vector3(4,1.8,4),PI)
	for mesh: MeshInstance3D in model.find_children("*","MeshInstance3D",true,false):
		for surface in mesh.mesh.get_surface_count():
			var original: StandardMaterial3D = mesh.mesh.surface_get_material(surface)
			var mat: StandardMaterial3D = original.duplicate()
			if String(mat.resource_name).to_lower() == "shirt": mat.albedo_color = shirt_color
			mat.roughness = 0.9
			mesh.set_surface_override_material(surface,mat)
	animator = model.find_children("*","AnimationPlayer",true,false)[0]
	animator.get_animation("HumanArmature|Man_Idle").loop_mode = Animation.LOOP_LINEAR
	animator.play("HumanArmature|Man_Idle")
	var reach := preload("res://scripts/player/imported_reach.gd").new()
	reach.appearance = self
	model.find_children("*","Skeleton3D",true,false)[0].add_child(reach)
	# Chapéu e tarrafa enrolada autorais, reutilizando materiais leves.
	var straw := StandardMaterial3D.new()
	straw.albedo_color = Color("c7aa74")
	straw.roughness = 0.95
	for part in 2:
		var hat := MeshInstance3D.new()
		var cylinder := CylinderMesh.new()
		cylinder.top_radius = 0.22 if part == 0 else 0.12
		cylinder.bottom_radius = 0.23 if part == 0 else 0.15
		cylinder.height = 0.035 if part == 0 else 0.15
		cylinder.radial_segments = 12
		hat.mesh = cylinder
		hat.material_override = straw
		hat.position.y = 1.77+part*0.075
		add_child(hat)
	bundle = MeshInstance3D.new()
	var coil := TorusMesh.new()
	coil.inner_radius = 0.07
	coil.outer_radius = 0.16
	coil.rings = 12
	coil.ring_segments = 6
	bundle.mesh = coil
	bundle.material_override = straw
	bundle.position = Vector3(0.28,0.67,-0.08)
	bundle.rotation.x = PI/2
	add_child(bundle)
	name_label = label(display_name+" — Pescador",Vector3(0,2.12,0),28)
	name_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	name_label.hide()
	balloon = Node3D.new()
	balloon.position.y = 2.85
	add_child(balloon)
	var panel := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = Vector3(3.5,0.9,0.035)
	panel.mesh = box
	var paper := StandardMaterial3D.new()
	paper.albedo_color = Color("fff3d7")
	paper.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	panel.material_override = paper
	panel.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	balloon.add_child(panel)
	var tail := MeshInstance3D.new()
	var triangle := PrismMesh.new()
	triangle.size = Vector3(0.26,0.20,0.035)
	tail.mesh = triangle
	tail.rotation.z = PI
	tail.position = Vector3(-0.9,-0.50,0)
	tail.material_override = paper
	tail.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	balloon.add_child(tail)
	dialogue_label = Label3D.new()
	dialogue_label.font_size = 32
	dialogue_label.pixel_size = 0.005
	dialogue_label.width = 650
	dialogue_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	dialogue_label.modulate = Color("203b3c")
	dialogue_label.outline_size = 0
	dialogue_label.position.z = 0.035
	balloon.add_child(dialogue_label)
	balloon.hide()
	net_visual = fisheries.create_net(false)
	preview = fisheries.create_net(true)
	net_visual.hide()
	preview.hide()

func label(text: String, pos: Vector3, size: int) -> Label3D:
	var node := Label3D.new()
	node.text = text
	node.position = pos
	node.font_size = size
	node.pixel_size = 0.005
	add_child(node)
	return node

func show_dialog(text: String) -> void:
	if text == greeting: greeting_left = 3.0
	else: warning_left = 3.0; warning_text = text
	refresh_dialog()

func refresh_dialog() -> void:
	dialogue_left = maxf(greeting_left,warning_left)
	dialogue_text = warning_text if warning_left>0 else ""
	if greeting_left>0: dialogue_text += ("\n" if not dialogue_text.is_empty() else "")+greeting
	dialogue_label.text = dialogue_text
	balloon.visible = dialogue_left>0

func enter(next: Phase) -> void:
	phase = next
	phase_time = 0.0
	animation_state = "interact" if phase in [Phase.PREPARE,Phase.THROW,Phase.RETRIEVE] else "idle"
	if phase == Phase.PREPARE: show_dialog("Olha a tarrafa!")
	if phase == Phase.WAIT: wait_for = 34.5

func advance(delta: float, visitor: Vector3) -> void:
	if delta <= 0: return
	greeting_cooldown = maxf(0,greeting_cooldown-delta)
	greeting_left = maxf(0,greeting_left-delta)
	warning_left = maxf(0,warning_left-delta)
	refresh_dialog()
	if visitor.distance_to(global_position) <= 5.0 and greeting_cooldown <= 0:
		show_dialog(greeting)
		greeting_cooldown = 20.0
		greeted_count += 1
	phase_time += delta
	match phase:
		Phase.WAIT:
			if phase_time >= wait_for: enter(Phase.PREPARE)
		Phase.PREPARE:
			if phase_time >= 2.5:
				if fisheries.can_cast(self): enter(Phase.THROW)
				else: enter(Phase.WAIT); wait_for = 4.0
		Phase.THROW:
			if phase_time >= 0.8:
				enter(Phase.OPEN if fisheries.can_cast(self) else Phase.RETRIEVE)
		Phase.OPEN:
			if phase_time >= 5.0: enter(Phase.RETRIEVE)
		Phase.RETRIEVE:
			if phase_time >= 1.2: enter(Phase.WAIT)
	update_net()

func update_net() -> void:
	preview.visible = phase == Phase.PREPARE
	preview.global_position = net_anchor
	net_visual.visible = phase in [Phase.THROW,Phase.OPEN,Phase.RETRIEVE]
	bundle.visible = not net_visual.visible
	var origin := global_position+Vector3.UP*1.0
	if phase == Phase.THROW:
		var t := clampf(phase_time/0.8,0,1)
		net_visual.global_position = origin.lerp(net_anchor,t)+Vector3.UP*sin(t*PI)*1.4
		net_visual.scale = Vector3.ONE*lerpf(0.12,1.0,t)
	elif phase == Phase.RETRIEVE:
		var t := clampf(phase_time/1.2,0,1)
		net_visual.global_position = net_anchor.lerp(origin,t)
		net_visual.scale = Vector3.ONE*lerpf(1.0,0.12,t)
	else:
		net_visual.global_position = net_anchor
		net_visual.scale = Vector3.ONE

func face_balloon(camera: Camera3D) -> void:
	if camera and balloon.visible and camera.global_position.distance_to(balloon.global_position)>0.01:
		var direction := camera.global_position-balloon.global_position
		balloon.look_at(camera.global_position,Vector3.FORWARD if direction.cross(Vector3.UP).length_squared()<0.001 else Vector3.UP,true)
