extends Node3D
var recovery: Node3D
var greenery: Array[StandardMaterial3D] = []

func _ready() -> void:
	box("Grass", Vector3(0, -0.25, 0), Vector3(28, 0.5, 36), Color("91b67b"), true)
	box("Walkway", Vector3(0, 0.025, 0), Vector3(7, 0.05, 35), Color("e5d2ab"))
	box("CycleLane", Vector3(6, 0.035, 0), Vector3(1.6, 0.07, 35), Color("c97c66"))
	box("Lagoon", Vector3(-25, -0.3, 0), Vector3(23, 0.15, 70), Color("47abbc"))
	box("FarBank", Vector3(-39, -0.15, 0), Vector3(4, 0.4, 70), Color("648f71"))
	for z: float in [-15.0, -9.0, -3.0, 3.0, 9.0, 15.0]:
		box("CycleMark", Vector3(6, 0.078, z), Vector3(0.09, 0.01, 1.8), Color("ffe7ad"))
		palm(Vector3(-10, 0, z))
		palm(Vector3(10, 0, z + 1))
		bench(Vector3(-7.5, 0, z))
		box("RailPost", Vector3(-13, 0.55, z), Vector3(0.18, 1.1, 0.18), Color("b19772"), true)
	box("LakeRail", Vector3(-13, 0.65, 0), Vector3(0.16, 0.2, 36), Color("cfb78a"), true)
	for x: float in [-14.0, 14.0]:
		box("Boundary", Vector3(x, 0.5, 0), Vector3(0.3, 1, 36), Color("59866b"), true)
	for z: float in [-18.0, 18.0]:
		box("Boundary", Vector3(0, 0.5, z), Vector3(28, 1, 0.3), Color("59866b"), true)
	label("OPERAÇÃO ARAÇATIBA", Vector3(0, 3.3, -16), 52)
	label("Representação fictícia • Cuide da orla", Vector3(0, 2.7, -16), 32)
	recovery = Node3D.new()
	recovery.name = "Recovery"
	add_child(recovery)
	for i in 20:
		var flower := MeshInstance3D.new()
		var mesh := SphereMesh.new()
		mesh.radius = 0.17
		mesh.height = 0.22
		mesh.radial_segments = 6
		mesh.rings = 3
		var mat := StandardMaterial3D.new()
		mat.albedo_color = Color("ffd384") if i % 2 == 0 else Color("d8b4e6")
		mesh.material = mat
		flower.mesh = mesh
		flower.position = Vector3(-5.3 if i % 2 == 0 else 8.2, 0.2, -14 + i * 1.4)
		recovery.add_child(flower)
	recovery.hide()

func box(title: String, pos: Vector3, size: Vector3, color: Color, solid: bool = false) -> Node3D:
	var node: Node3D = StaticBody3D.new() if solid else Node3D.new()
	node.name = title
	node.set_meta("kind", title)
	node.position = pos
	var mesh := BoxMesh.new()
	mesh.size = size
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 1.0
	mesh.material = material
	var visual := MeshInstance3D.new()
	visual.mesh = mesh
	node.add_child(visual)
	if solid:
		var shape := BoxShape3D.new()
		shape.size = size
		var collision := CollisionShape3D.new()
		collision.shape = shape
		node.add_child(collision)
	add_child(node)
	return node

func palm(pos: Vector3) -> void:
	box("Trunk", pos + Vector3(0, 1.4, 0), Vector3(0.35, 2.8, 0.35), Color("96704f"), true)
	for angle: float in [0.0, PI / 3, PI * 2 / 3]:
		var leaf := box("PalmLeaf", pos + Vector3(0, 2.95, 0), Vector3(3.8, 0.22, 0.65), Color("628762"))
		leaf.rotation.y = angle
		greenery.append(leaf.get_child(0).mesh.material)

func bench(pos: Vector3) -> void:
	box("BenchSeat", pos + Vector3(0, 0.55, 0), Vector3(0.8, 0.18, 1.9), Color("b58150"), true)
	box("BenchBack", pos + Vector3(-0.35, 0.95, 0), Vector3(0.12, 0.75, 1.9), Color("b58150"), true)
	for z: float in [-0.65, 0.65]:
		box("BenchLeg", pos + Vector3(0, 0.25, z), Vector3(0.55, 0.5, 0.12), Color("40595c"))

func label(text: String, pos: Vector3, size: int) -> void:
	var sign := Label3D.new()
	sign.text = text
	sign.position = pos
	sign.font_size = size
	sign.pixel_size = 0.007
	add_child(sign)

func recover_area() -> void:
	recovery.show()
	for material in greenery:
		material.albedo_color = Color("38976c")
	label("ORLA CUIDADA • Obrigado, guardião!", Vector3(-4, 2.4, 3), 40)
