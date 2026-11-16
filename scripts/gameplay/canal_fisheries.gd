extends Node3D
## Ciclos e contato analítico: nenhum collider novo, resíduo ou placar alterado.
const Fisher = preload("res://scripts/gameplay/fisherman.gd")
const RADIUS: float = 1.25
const BOAT_MARGIN: float = 1.45
var mission: Node3D
var fishermen: Array[Node3D] = []
var feedback_left: float = 0.0
var focused: Node3D
var enabled: bool = true
func _ready() -> void:
	mission = get_parent()
	var data := [
		["Cacadi","OPAAAA! Fala, meu patrão! Cuidado com a tarrafa!",Vector3(8.65,0.02,5.2),Vector3(5.1,0.03,5.2),Color("587f6c")],
		["João do Canal","Aê, meu camarada! Hoje o peixe tá esperto!",Vector3(-8.65,0.02,-8),Vector3(-5.1,0.03,-8),Color("a27c4e")],
		["Naldo","Opa! Dá uma segurada aí que vou jogar a rede!",Vector3(-3.2,3.625,-0.7),Vector3(-3.7,0.03,3.3),Color("517c91")],
		["Beto da Ponte","Fala, parceiro! Passa pelo cantinho que tô pescando!",Vector3(3.2,3.625,-0.7),Vector3(3.7,0.03,-5.2),Color("966959")]
	]
	for i in data.size():
		var npc := Fisher.new()
		npc.name = "Fisherman%d" % i
		npc.display_name = data[i][0]
		npc.greeting = data[i][1]
		npc.position = data[i][2]
		npc.net_anchor = data[i][3]
		npc.shirt_color = data[i][4]
		npc.start_delay = 6.0+i*11.0
		var direction: Vector3 = npc.net_anchor-npc.position
		npc.rotation.y = atan2(-direction.x,-direction.z)
		add_child(npc)
		fishermen.append(npc)

func create_net(announcement: bool) -> Node3D:
	var node := Node3D.new()
	node.name = "NetPreview" if announcement else "CastNet"
	add_child(node)
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color("efb450") if announcement else Color("f3e2af")
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	var lines := ImmediateMesh.new()
	lines.surface_begin(Mesh.PRIMITIVE_LINES,mat)
	for ring in (1 if announcement else 5):
		var radius := RADIUS if announcement else RADIUS*(ring+1)/5.0
		for i in 40:
			lines.surface_add_vertex(Vector3(cos(i*TAU/40)*radius,0.02,sin(i*TAU/40)*radius))
			lines.surface_add_vertex(Vector3(cos((i+1)*TAU/40)*radius,0.02,sin((i+1)*TAU/40)*radius))
	if not announcement:
		for i in 16:
			lines.surface_add_vertex(Vector3.ZERO)
			lines.surface_add_vertex(Vector3(cos(i*TAU/16)*RADIUS,0.02,sin(i*TAU/16)*RADIUS))
	lines.surface_end()
	var mesh := MeshInstance3D.new()
	mesh.mesh = lines
	mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	node.add_child(mesh)
	var edge := MeshInstance3D.new()
	var ring_mesh := TorusMesh.new()
	ring_mesh.inner_radius = RADIUS-0.025
	ring_mesh.outer_radius = RADIUS+0.025
	ring_mesh.rings = 32
	ring_mesh.ring_segments = 4
	edge.mesh = ring_mesh
	edge.material_override = mat
	edge.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	node.add_child(edge)
	return node

func active_count() -> int:
	var total := 0
	for npc in fishermen:
		if npc.phase == Fisher.Phase.OPEN: total += 1
	return total

func can_cast(npc: Node3D) -> bool:
	if not enabled or active_count()>=2: return false
	var boat: Node3D = mission.get_node("Boat")
	return Vector2(boat.position.x-npc.net_anchor.x,boat.position.z-npc.net_anchor.z).length()>RADIUS+BOAT_MARGIN+0.5

func advance(delta: float) -> void:
	var playing: bool = enabled and mission.state == mission.State.JOGANDO
	for npc in fishermen: npc.animator.speed_scale = 1.0 if playing else 0.0
	if not playing: return
	feedback_left = maxf(0,feedback_left-delta)
	var visitor: Vector3 = mission.get_node("Boat").global_position if mission.on_boat else mission.player.global_position
	for npc in fishermen: npc.advance(maxf(delta,0),visitor)

func _physics_process(delta: float) -> void: advance(delta)
func _process(_delta: float) -> void:
	var camera := get_viewport().get_camera_3d()
	for npc in fishermen: npc.face_balloon(camera)

func update_focus(camera: Camera3D, point: Vector2) -> Node3D:
	for npc in fishermen: npc.name_label.hide()
	focused = null
	if camera == null or mission.state != mission.State.JOGANDO: return null
	var origin := camera.project_ray_origin(point)
	var direction := camera.project_ray_normal(point)
	var closest := 35.0
	for npc in fishermen:
		var target: Vector3 = npc.global_position+Vector3.UP*1.05
		var t := (target-origin).dot(direction)
		if t < 0 or t >= closest or (origin+direction*t).distance_to(target)>0.6: continue
		var ray := PhysicsRayQueryParameters3D.create(origin,target,17)
		if not get_world_3d().direct_space_state.intersect_ray(ray).is_empty(): continue
		focused = npc
		closest = t
	if focused: focused.name_label.show()
	return focused

func constrain_boat(boat: CharacterBody3D, delta: float) -> void:
	if not enabled or delta <= 0 or mission.state != mission.State.JOGANDO: return
	var radius := RADIUS+BOAT_MARGIN
	for npc in fishermen:
		if npc.phase != Fisher.Phase.OPEN: continue
		var p := Vector2(boat.position.x-npc.net_anchor.x,boat.position.z-npc.net_anchor.z)
		var movement := Vector2(boat.velocity.x,boat.velocity.z)*delta
		if movement.length_squared()<0.000001: continue
		if p.length()<radius:
			# Entrada artificial/limítrofe nunca prende o jogador: a saída é liberada.
			if movement.dot(p)>=0: continue
			var outward := p.normalized() if p.length()>0.01 else Vector2.RIGHT
			boat.velocity = Vector3(outward.x,0,outward.y)*0.8
			boat.speed = 0
			feedback_left = 1.8
			continue
		var a := movement.length_squared()
		var b := 2*p.dot(movement)
		var c := p.length_squared()-radius*radius
		var discriminant := b*b-4*a*c
		if discriminant < 0: continue
		var hit := (-b-sqrt(discriminant))/(2*a)
		if hit < 0 or hit > 1: continue
		boat.velocity *= maxf(0,hit-0.02)
		boat.speed = move_toward(boat.speed,0,8*delta)
		feedback_left = 1.8
