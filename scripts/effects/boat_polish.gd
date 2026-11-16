extends Node3D
var boat: CharacterBody3D
var clock: float = 0.0
var wake: Array[MeshInstance3D] = []
var paddles: Node3D
var oars: Array[Node3D] = []
var rowing_phase: float = 0.0
var rowing_amount: float = 0.0
var passenger_rig: Skeleton3D
var hips_index: int = -1
func _ready() -> void:
	boat = get_parent()
	var art = preload("res://scripts/effects/world_polish.gd").new()
	# Reutiliza apenas fábricas de malha; não adiciona esta instância à árvore.
	var hull := SurfaceTool.new()
	hull.begin(Mesh.PRIMITIVE_TRIANGLES)
	var ring: Array[Vector3] = [Vector3(-0.6, 0.4, 1.2), Vector3(0.6, 0.4, 1.2), Vector3(0.7, 0.4, -0.7), Vector3(0.28, 0.4, -1.3), Vector3(-0.28, 0.4, -1.3), Vector3(-0.7, 0.4, -0.7)]
	for i in ring.size():
		var a := ring[i]
		var b := ring[(i + 1) % ring.size()]
		var bottom_a := Vector3(a.x * 0.65, -0.07, a.z * 0.85)
		var bottom_b := Vector3(b.x * 0.65, -0.07, b.z * 0.85)
		for vertex: Vector3 in [a, b, bottom_a, b, bottom_b, bottom_a, a, Vector3(0, 0.4, 0), b]:
			hull.add_vertex(vertex)
	hull.generate_normals()
	var skin := art.mesh_at(self, hull.commit(), Vector3.ZERO, Color("2c8276"))
	skin.material_override.cull_mode = BaseMaterial3D.CULL_DISABLED
	skin.material_override.roughness = 0.43
	var deck := art.box(self, Vector3(0, 0.42, 0), Vector3(1.12, 0.035, 1.9), Color("ded2a5"))
	deck.material_override = art.textured(6, Color("c8b78c"))
	for side: float in [-1, 1]:
		art.box(self, Vector3(side * 0.66, 0.37, 0), Vector3(0.025, 0.055, 2.05), Color("e5dcb3"))
		var rope := art.cylinder(self, Vector3(side * 0.38, 0.48, -0.75), 0.055, 0.085, Color("baab7e"))
		rope.rotation.x = PI * 0.5
	art.box(self, Vector3(0, 0.67, 1.1), Vector3(0.42, 0.52, 0.34), Color("3b5359"))
	art.box(self,Vector3(0,0.62,-0.42),Vector3(1.05,0.10,0.30),Color("ae9368"))
	art.box(self,Vector3(0,0.79,-0.56),Vector3(1.02,0.30,0.055),Color("bdab82"))
	# Boias e cintas são detalhes visuais, sem novos volumes físicos.
	for side: float in [-1,1]:
		var buoy := MeshInstance3D.new()
		var ring_mesh := TorusMesh.new()
		ring_mesh.inner_radius = 0.15
		ring_mesh.outer_radius = 0.23
		ring_mesh.rings = 20
		ring_mesh.ring_segments = 6
		buoy.mesh = ring_mesh
		buoy.position = Vector3(side*0.69,0.47,-0.25)
		buoy.rotation.z = PI/2
		buoy.material_override = art.surface(Color("d68b50"))
		add_child(buoy)
		art.box(self,Vector3(side*0.72,0.47,-0.25),Vector3(0.055,0.43,0.045),Color("e9dbb4"))
	art.cylinder(self, Vector3(0, 0.27, 1.17), 0.5, 0.06, Color("54727a"))
	var text := Label3D.new()
	text.text = "ECO MARICÁ"
	text.position = Vector3(0, 0.8, 1.28)
	text.font_size = 28
	text.pixel_size = 0.007
	add_child(text)
	for i in 5:
		var ripple := art.ellipsoid(self, Vector3(0, -0.075, 1.5 + i * 0.28), Vector3(0.32, 0.025, 0.13), Color("b4e0d3"))
		wake.append(ripple)
	var library = preload("res://scripts/effects/asset_library.gd")
	if library.enabled("ponta_negra"):
		for mesh: MeshInstance3D in find_children("*","MeshInstance3D",true,false):
			if not mesh in wake: mesh.hide()
		for node in boat.get_children():
			if node is MeshInstance3D: node.hide()
		var imported: Node3D = library.place(self,"watercraft-kit","boat-row-small",Vector3(0,-0.08,0),Vector3(2.8,0.9,2.6),PI)
		var found := imported.find_children("*paddles*","Node3D",true,false)
		if not found.is_empty():
			paddles = found[0]
			split_oars()
	art.free()

func _process(delta: float) -> void:
	if boat.pilot != null and not boat.active:
		return
	clock += delta
	rotation.z = sin(clock * 1.6) * 0.018
	position.y = sin(clock * 2) * 0.018
	rowing_amount = move_toward(rowing_amount,clampf(absf(boat.speed)/3.0,0,1) if boat.active else 0.0,delta*3)
	if rowing_amount>0.03: rowing_phase += delta*3.0
	for oar in oars:
		var side: float = oar.get_meta("side")
		oar.rotation.y = side*sin(rowing_phase)*0.24*rowing_amount
		oar.rotation.z = side*maxf(0,cos(rowing_phase))*0.14*rowing_amount
	if paddles and oars.is_empty(): paddles.rotation.x = sin(rowing_phase)*0.10*rowing_amount
	if boat.pilot != null:
		boat.get_node("Passenger").set_seated(true,rowing_phase,rowing_amount)
		align_passenger()
	for i in wake.size():
		wake[i].visible = boat.active and absf(boat.speed) > 0.6
		wake[i].position.x = sin(clock * 5 + i * 2) * 0.35
		wake[i].scale.x = 1.0 + fposmod(clock * 2 + i, 1.0)

func set_passenger(passenger: Node3D) -> void:
	var rigs := passenger.find_children("*","Skeleton3D",true,false)
	passenger_rig = rigs[0] if not rigs.is_empty() else null
	hips_index = passenger_rig.find_bone("Hips") if passenger_rig else -1
	align_passenger()

func align_passenger() -> void:
	var passenger: Node3D = boat.get_node("Passenger")
	if is_instance_valid(passenger_rig) and hips_index>=0:
		var hips := passenger_rig.global_transform*passenger_rig.get_bone_global_pose(hips_index).origin
		var offset := boat.to_local(hips)-passenger.position
		passenger.position = Vector3(0,0.48,0.35)-offset
	else:
		passenger.position = Vector3(0,-0.06,0.35)

func split_oars() -> void:
	if not paddles is MeshInstance3D: return
	var original: MeshInstance3D = paddles
	for side: float in [-1,1]:
		var pivot := Node3D.new()
		pivot.name = "RowingOarLeft" if side<0 else "RowingOarRight"
		pivot.set_meta("side",side)
		var hinge := Vector3(side*0.62,0.35,0)
		original.get_parent().add_child(pivot)
		pivot.transform = original.transform*Transform3D(Basis.IDENTITY,hinge)
		var builder := SurfaceTool.new()
		builder.begin(Mesh.PRIMITIVE_TRIANGLES)
		for surface in original.mesh.get_surface_count():
			var arrays := original.mesh.surface_get_arrays(surface)
			var vertices: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
			var normals: PackedVector3Array = arrays[Mesh.ARRAY_NORMAL]
			var uv: PackedVector2Array = arrays[Mesh.ARRAY_TEX_UV]
			var indices: PackedInt32Array = arrays[Mesh.ARRAY_INDEX]
			if indices.is_empty():
				for i in vertices.size(): indices.append(i)
			for i in range(0,indices.size(),3):
				var center := (vertices[indices[i]]+vertices[indices[i+1]]+vertices[indices[i+2]])/3
				if center.x*side<0: continue
				for j in 3:
					var index := indices[i+j]
					if normals.size()>index: builder.set_normal(normals[index])
					if uv.size()>index: builder.set_uv(uv[index])
					builder.add_vertex(vertices[index]-hinge)
		var mesh := MeshInstance3D.new()
		mesh.mesh = builder.commit()
		mesh.material_override = original.mesh.surface_get_material(0)
		pivot.add_child(mesh)
		oars.append(pivot)
	original.hide()
