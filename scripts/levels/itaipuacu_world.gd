extends "res://scripts/levels/aracatiba_world.gd"

func _ready() -> void:
	box("Sand", Vector3(0, -0.25, 0), Vector3(25, 0.5, 34), Color("e4cc9e"), true)
	box("WetSand", Vector3(-10.2, 0.01, 0), Vector3(3.5, 0.02, 34), Color("c5bc99"))
	box("Sea", Vector3(-32, -0.16, 0), Vector3(40, 0.12, 90), Color("4aafb9"))
	for x: float in [-14.0, -19.0, -25.0, -33.0]:
		box("Wave", Vector3(x, -0.075, 0), Vector3(0.2, 0.04, 70), Color("b1e6d7"))
	box("ShoreLimit", Vector3(-11.7, 0.2, 0), Vector3(0.2, 0.4, 34), Color("d5d6bc"), true)
	box("DuneLimit", Vector3(12, 0.5, 0), Vector3(0.4, 1, 34), Color("aeaa76"), true)
	for z: float in [-17.0, 17.0]:
		box("Boundary", Vector3(0, 0.5, z), Vector3(24, 1, 0.3), Color("c9b786"), true)
	for z: float in [-14.0, -7.0, 0.0, 7.0, 14.0]:
		palm(Vector3(10.5, 0, z))
		box("Restinga", Vector3(9.5, 0.15, z + 2), Vector3(1.2, 0.3, 1.5), Color("799e78"))
	box("Boat", Vector3(-19, 0.1, -8), Vector3(1.8, 0.45, 3.6), Color("d39b56"))
	box("Mast", Vector3(-19, 1.6, -8), Vector3(0.1, 3, 0.1), Color("eed6ae"))
	label("RESGATE DE ITAIPUAÇU", Vector3(1, 3, -15.5), 48)
	label("→ MAR: priorize os resíduos em movimento", Vector3(1, 2.35, -15.5), 28)
	recovery = Node3D.new()
	recovery.name = "Recovery"
	add_child(recovery)
	for i in 16:
		var mesh := SphereMesh.new()
		mesh.radius = 0.15
		mesh.height = 0.2
		mesh.radial_segments = 6
		mesh.rings = 3
		var mat := StandardMaterial3D.new()
		mat.albedo_color = Color("d8b6dc")
		mesh.material = mat
		var flower := MeshInstance3D.new()
		flower.mesh = mesh
		flower.position = Vector3(8.8 + (i % 2) * 1.2, 0.2, -12 + i * 1.6)
		recovery.add_child(flower)
	recovery.hide()

func recover_area() -> void:
	recovery.show()
	for material in greenery:
		material.albedo_color = Color("379370")
	for node in get_children():
		if node is Label3D and node.text == "RESGATE DE ITAIPUAÇU":
			node.text = "PRAIA CUIDADA • Cada destino importa"
