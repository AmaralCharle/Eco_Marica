class_name CharacterAppearance
extends Node3D
## Visual compartilhado entre jogador e prévias; nenhuma colisão ou habilidade aqui.
const Catalog = preload("res://scripts/core/character_catalog.gd")
@export var character_id: String = "lucas"
var parts: Dictionary = {}
var decorations: Node3D
var outfit: StandardMaterial3D
var skin: StandardMaterial3D
var hair: StandardMaterial3D
var pants: StandardMaterial3D

func _ready() -> void:
	outfit = material(Color.WHITE)
	skin = material(Color.WHITE)
	hair = material(Color.WHITE)
	pants = material(Color.WHITE)
	box(self, "Torso", Vector3(0, 1.1, 0), Vector3(0.6, 0.65, 0.32), outfit)
	sphere(self, "Head", Vector3(0, 1.64, 0), 0.235, skin)
	var pack := box(self, "Backpack", Vector3(0, 1.13, 0.26), Vector3(0.42, 0.48, 0.22), pants)
	parts["Backpack"] = pack
	for side: float in [-1.0, 1.0]:
		var leg := Node3D.new()
		leg.name = "LeftLeg" if side < 0 else "RightLeg"
		leg.position = Vector3(side * 0.16, 0.7, 0)
		add_child(leg)
		box(leg, "Mesh", Vector3(0, -0.3, 0), Vector3(0.22, 0.6, 0.24), pants)
		box(leg, "Shoe", Vector3(0, -0.57, -0.045), Vector3(0.25, 0.15, 0.34), pants)
		var arm := Node3D.new()
		arm.name = "LeftArm" if side < 0 else "RightArm"
		arm.position = Vector3(side * 0.43, 1.4, 0)
		add_child(arm)
		box(arm, "Mesh", Vector3(0, -0.24, 0), Vector3(0.19, 0.44, 0.23), outfit)
		sphere(arm, "Hand", Vector3(0, -0.51, 0), 0.105, skin)
		box(self, "Eye", Vector3(side * 0.08, 1.68, -0.214), Vector3(0.05, 0.055, 0.035), material(Color("202c34")))
	box(self, "Zipper", Vector3(0, 1.15, -0.17), Vector3(0.025, 0.58, 0.025), material(Color("f0e8c6")))
	decorations = Node3D.new()
	decorations.name = "Details"
	add_child(decorations)
	apply_character(character_id)

func apply_character(id: String) -> void:
	character_id = id if Catalog.valid_id(id) else Catalog.DEFAULT_ID
	if outfit == null:
		return
	var data := Catalog.get_character(character_id)
	outfit.albedo_color = data["outfit"]
	skin.albedo_color = data["skin"]
	hair.albedo_color = data["hair"]
	pants.albedo_color = data["pants"]
	parts["Backpack"].visible = character_id == "lucas"
	for node in decorations.get_children():
		decorations.remove_child(node)
		node.queue_free()
	for limb: String in ["LeftLeg", "RightLeg"]:
		for child in get_node(limb).get_children():
			if child.name.begins_with("BootCuff"):
				get_node(limb).remove_child(child)
				child.queue_free()
	match character_id:
		"lucas":
			box(decorations, "ShortHair", Vector3(0, 1.84, 0.015), Vector3(0.4, 0.14, 0.37), hair)
			for side: float in [-1.0, 1.0]:
				box(decorations, "Pocket", Vector3(side * 0.17, 1.05, -0.19), Vector3(0.19, 0.2, 0.07), pants)
		"marina":
			box(decorations, "TiedHair", Vector3(0, 1.82, 0.035), Vector3(0.4, 0.16, 0.36), hair)
			sphere(decorations, "Bun", Vector3(0, 1.74, 0.25), 0.16, hair)
			box(decorations, "Belt", Vector3(0, 0.82, -0.01), Vector3(0.62, 0.09, 0.35), pants)
		"rafael":
			box(decorations, "Cap", Vector3(0, 1.87, 0), Vector3(0.47, 0.18, 0.44), outfit)
			box(decorations, "CapVisor", Vector3(0, 1.83, -0.28), Vector3(0.49, 0.055, 0.27), outfit)
			for side: float in [-1.0, 1.0]:
				box(decorations, "Reflector", Vector3(side * 0.19, 1.12, -0.18), Vector3(0.07, 0.56, 0.035), material(Color("f4e4b0")))
				box(get_node("LeftLeg") if side < 0 else get_node("RightLeg"), "BootCuff", Vector3(0, -0.5, 0), Vector3(0.26, 0.22, 0.28), pants)
		"bia":
			for i in 9:
				var angle := TAU * i / 9.0
				sphere(decorations, "Curl", Vector3(cos(angle) * 0.22, 1.88 + sin(angle) * 0.09, 0.055 + sin(angle) * 0.12), 0.115, hair)
			box(decorations, "JacketHem", Vector3(0, 0.79, 0), Vector3(0.65, 0.1, 0.36), outfit)
	# Acessórios de botas não alteram a cápsula; removidos ao trocar para outro visual.
	if character_id != "rafael":
		for limb: String in ["LeftLeg", "RightLeg"]:
			for child in get_node(limb).get_children():
				if child.name.begins_with("BootCuff"):
					get_node(limb).remove_child(child)
					child.queue_free()

func material(color: Color) -> StandardMaterial3D:
	var result := StandardMaterial3D.new()
	result.albedo_color = color
	result.roughness = 1.0
	return result

func box(parent: Node, title: String, pos: Vector3, size: Vector3, surface: Material) -> MeshInstance3D:
	var mesh := BoxMesh.new()
	mesh.size = size
	mesh.material = surface
	return add_mesh(parent, title, pos, mesh)

func sphere(parent: Node, title: String, pos: Vector3, radius: float, surface: Material) -> MeshInstance3D:
	var mesh := SphereMesh.new()
	mesh.radius = radius
	mesh.height = radius * 2
	mesh.radial_segments = 8
	mesh.rings = 4
	mesh.material = surface
	return add_mesh(parent, title, pos, mesh)

func add_mesh(parent: Node, title: String, pos: Vector3, mesh: Mesh) -> MeshInstance3D:
	var node := MeshInstance3D.new()
	node.name = title
	node.position = pos
	node.mesh = mesh
	parent.add_child(node)
	return node
