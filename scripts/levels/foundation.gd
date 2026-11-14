extends Node3D
## Área de treino das etapas 1 e 2; ainda não é a missão Araçatiba.
func _ready() -> void:
	box("Ground", Vector3(0, -0.25, 0), Vector3(26, 0.5, 26), Color("80ae75"), true)
	box("Promenade", Vector3(0, 0.015, 0), Vector3(7, 0.03, 24), Color("e6d5ab"), false)
	box("CycleLane", Vector3(4.2, 0.02, 0), Vector3(1.4, 0.04, 24), Color("cb7965"), false)
	box("Lake", Vector3(-21, -0.35, 0), Vector3(15, 0.15, 44), Color("44b9c6"), false)
	box("TestWall", Vector3(0, 1, -7), Vector3(5, 2, 0.6), Color("e5b65e"), true)
	for side: float in [-1.0, 1.0]:
		box("BoundaryX", Vector3(side * 13, 0.55, 0), Vector3(0.4, 1.1, 26), Color("437c64"), true)
		box("BoundaryZ", Vector3(0, 0.55, side * 13), Vector3(26, 1.1, 0.4), Color("437c64"), true)
	for z: float in [-9.0, -3.0, 3.0, 9.0]:
		for x: float in [-9.0, 9.0]:
			box("Trunk", Vector3(x, 0.9, z), Vector3(0.45, 1.8, 0.45), Color("896044"), true)
			box("Canopy", Vector3(x, 2.55, z), Vector3(2.3, 2, 2.3), Color("39866b"), false)
		box("Bench", Vector3(6.5, 0.5, z), Vector3(1, 1, 2), Color("b88451"), true)
	var label := Label3D.new()
	label.text = "TREINO DE CLASSIFICAÇÃO\nPapel e plástico • Aprenda fazendo"
	label.position = Vector3(0, 3.1, -7)
	label.font_size = 48
	label.pixel_size = 0.007
	add_child(label)
	spawn_recycling_training()

func box(title: String, pos: Vector3, size: Vector3, color: Color, solid: bool) -> void:
	var node: Node3D = StaticBody3D.new() if solid else Node3D.new()
	node.name = title
	node.position = pos
	var mesh := BoxMesh.new()
	mesh.size = size
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 1.0
	mesh.material = material
	var instance := MeshInstance3D.new()
	instance.mesh = mesh
	node.add_child(instance)
	if solid:
		var collision := CollisionShape3D.new()
		var shape := BoxShape3D.new()
		shape.size = size
		collision.shape = shape
		node.add_child(collision)
	add_child(node)

func spawn_recycling_training() -> void:
	var waste_scene := preload("res://scenes/objects/waste.tscn")
	var bin_scene := preload("res://scenes/objects/recycling_bin.tscn")
	var points: Array[Vector3] = [Vector3(-1.1, 0, 2.5), Vector3(1.1, 0, 0.5), Vector3(-1.1, 0, -1.5), Vector3(1.1, 0, -3.5), Vector3(-4.6, 0, 2), Vector3(-4.6, 0, -2)]
	for i in points.size():
		var waste := waste_scene.instantiate()
		waste.waste_id = "training_%02d" % i
		waste.material = "paper" if i % 2 == 0 else "plastic"
		waste.position = points[i]
		$Session.register_waste(waste.waste_id, waste.material)
		add_child(waste)
	for i in 2:
		var bin := bin_scene.instantiate()
		bin.material = "paper" if i == 0 else "plastic"
		bin.position = Vector3(-3.5, 0, -1.5 - i * 3.0)
		add_child(bin)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("return_menu") and not event.is_echo():
		get_tree().change_scene_to_file("res://scenes/levels/aracatiba.tscn")
	if event.is_action_pressed("restart_training") and not event.is_echo():
		get_tree().reload_current_scene()
