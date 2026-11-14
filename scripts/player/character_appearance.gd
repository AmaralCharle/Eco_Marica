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
var animation_state: String = "idle"

func _ready() -> void:
	outfit = material(Color.WHITE)
	skin = material(Color.WHITE)
	hair = material(Color.WHITE)
	pants = material(Color.WHITE)
	rounded(self, "Torso", Vector3(0, 1.1, 0), Vector3(0.62, 0.73, 0.36), outfit)
	rounded(self, "Head", Vector3(0, 1.65, -0.012), Vector3(0.48, 0.56, 0.45), skin)
	var pack := rounded(self, "Backpack", Vector3(0, 1.13, 0.26), Vector3(0.45, 0.52, 0.27), pants)
	parts["Backpack"] = pack
	for side: float in [-1.0, 1.0]:
		var leg := Node3D.new()
		leg.name = "LeftLeg" if side < 0 else "RightLeg"
		leg.position = Vector3(side * 0.16, 0.7, 0)
		add_child(leg)
		rounded(leg, "Mesh", Vector3(0, -0.3, 0), Vector3(0.24, 0.65, 0.25), pants)
		rounded(leg, "Shoe", Vector3(0, -0.57, -0.045), Vector3(0.27, 0.2, 0.37), material(Color("31484b")))
		box(leg, "Sole", Vector3(0, -0.64, -0.045), Vector3(0.25, 0.035, 0.32), material(Color("e3d9b8")))
		var arm := Node3D.new()
		arm.name = "LeftArm" if side < 0 else "RightArm"
		arm.position = Vector3(side * 0.43, 1.4, 0)
		add_child(arm)
		rounded(arm, "Mesh", Vector3(0, -0.18, 0), Vector3(0.23, 0.32, 0.26), outfit)
		rounded(arm, "Forearm", Vector3(0, -0.37, 0), Vector3(0.15, 0.26, 0.18), skin)
		sphere(arm, "Hand", Vector3(0, -0.51, 0), 0.105, skin)
		rounded(self, "EyeWhite", Vector3(side * 0.085, 1.69, -0.217), Vector3(0.103, 0.117, 0.032), material(Color("fff5df")))
		rounded(self, "Eye", Vector3(side * 0.085, 1.69, -0.235), Vector3(0.057, 0.078, 0.024), material(Color("32463b")))
		sphere(self, "EyeGlint", Vector3(side * 0.085 - 0.01, 1.709, -0.25), 0.012, material(Color.WHITE))
		var brow := rounded(self, "Eyebrow", Vector3(side * 0.085, 1.78, -0.2), Vector3(0.11, 0.027, 0.04), hair)
		brow.rotation.z = side * 0.13
		sphere(self, "Ear", Vector3(side * 0.235, 1.65, -0.005), 0.06, skin)
		box(self, "PackStrap", Vector3(side * 0.2, 1.15, -0.17), Vector3(0.048, 0.49, 0.032), pants)
	rounded(self, "Nose", Vector3(0, 1.624, -0.239), Vector3(0.07, 0.083, 0.083), skin)
	rounded(self, "Smile", Vector3(0, 1.556, -0.217), Vector3(0.105, 0.027, 0.025), material(Color("965843")))
	rounded(self, "EcoBadge", Vector3(0.16, 1.25, -0.19), Vector3(0.08, 0.11, 0.018), material(Color("b7d86b")))
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
			rounded(decorations, "ShortHair", Vector3(0, 1.87, 0.02), Vector3(0.49, 0.24, 0.45), hair)
			for i in 4:
				var lock := rounded(decorations, "HairLock", Vector3(-0.15 + i * 0.085, 1.87 - i * 0.015, -0.17), Vector3(0.18, 0.18, 0.15), hair)
				lock.rotation.z = -0.4
			for side: float in [-1.0, 1.0]:
				box(decorations, "Pocket", Vector3(side * 0.17, 1.05, -0.19), Vector3(0.19, 0.2, 0.07), pants)
		"marina":
			rounded(decorations, "TiedHair", Vector3(0, 1.87, 0.035), Vector3(0.48, 0.23, 0.44), hair)
			sphere(decorations, "Bun", Vector3(0, 1.74, 0.25), 0.16, hair)
			for side: float in [-1, 1]:
				rounded(decorations, "SideLock", Vector3(side * 0.2, 1.77, -0.01), Vector3(0.11, 0.26, 0.32), hair)
			box(decorations, "Belt", Vector3(0, 0.82, -0.01), Vector3(0.62, 0.09, 0.35), pants)
			rounded(decorations, "FieldPouch", Vector3(0.33, 0.96, 0.04), Vector3(0.18, 0.24, 0.21), pants)
		"rafael":
			rounded(decorations, "Cap", Vector3(0, 1.9, 0), Vector3(0.5, 0.25, 0.47), outfit)
			rounded(decorations, "CapVisor", Vector3(0, 1.83, -0.28), Vector3(0.49, 0.055, 0.27), outfit)
			for side: float in [-1.0, 1.0]:
				box(decorations, "Reflector", Vector3(side * 0.19, 1.12, -0.18), Vector3(0.07, 0.56, 0.035), material(Color("f4e4b0")))
				box(get_node("LeftLeg") if side < 0 else get_node("RightLeg"), "BootCuff", Vector3(0, -0.5, 0), Vector3(0.26, 0.22, 0.28), pants)
		"bia":
			for i in 9:
				var angle := TAU * i / 9.0
				sphere(decorations, "Curl", Vector3(cos(angle) * 0.22, 1.88 + sin(angle) * 0.09, 0.055 + sin(angle) * 0.12), 0.115, hair)
			box(decorations, "JacketHem", Vector3(0, 0.79, 0), Vector3(0.65, 0.1, 0.36), outfit)
			rounded(decorations, "Satchel", Vector3(-0.32, 0.95, 0.08), Vector3(0.24, 0.31, 0.21), pants)
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
	result.roughness = 0.83
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
	mesh.radial_segments = 12
	mesh.rings = 6
	mesh.material = surface
	return add_mesh(parent, title, pos, mesh)

func rounded(parent: Node, title: String, pos: Vector3, size: Vector3, surface: Material) -> MeshInstance3D:
	var node := sphere(parent, title, pos, 0.5, surface)
	node.scale = size
	return node

## Integração opcional. Um GLB importado vira PackedScene; o rig mantém sua própria AnimationTree.
## Chamar sem modelo restaura os componentes procedurais. Não altera o corpo físico.
func attach_external_model(model: PackedScene = null) -> Node3D:
	var existing := get_node_or_null("ExternalModel")
	if existing:
		remove_child(existing)
		existing.queue_free()
	for child in get_children():
		if child is Node3D:
			child.visible = model == null
	if model == null:
		apply_character(character_id)
		return null
	var instance: Node3D = model.instantiate() as Node3D
	if instance == null:
		attach_external_model()
		return null
	instance.name = "ExternalModel"
	add_child(instance)
	return instance

func set_animation(state: String) -> void:
	if animation_state == state:
		return
	animation_state = state
	var external := get_node_or_null("ExternalModel")
	if external:
		var animator := external.find_child("AnimationPlayer", true, false) as AnimationPlayer
		if animator and animator.has_animation(state):
			animator.play(state, 0.15)

func add_mesh(parent: Node, title: String, pos: Vector3, mesh: Mesh) -> MeshInstance3D:
	var node := MeshInstance3D.new()
	node.name = title
	node.position = pos
	node.mesh = mesh
	parent.add_child(node)
	return node
