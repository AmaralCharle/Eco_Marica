class_name TrainingWaste
extends Node3D
const Config = preload("res://scripts/core/game_config.gd")
@export var waste_id: String = ""
@export_enum("paper", "plastic", "glass", "metal") var material: String = "paper"
var marker: MeshInstance3D
var item_label: Label3D

func _ready() -> void:
	add_to_group("training_waste")
	var mesh: PrimitiveMesh
	match material:
		"paper":
			var paper := BoxMesh.new()
			paper.size = Vector3(0.55, 0.08, 0.4)
			mesh = paper
		"plastic", "glass", "metal":
			var container := CylinderMesh.new()
			container.top_radius = 0.08 if material == "plastic" else 0.18
			container.bottom_radius = 0.15 if material == "plastic" else 0.18
			container.height = 0.32 if material == "metal" else 0.45
			container.radial_segments = 8
			mesh = container
		_:
			mesh = BoxMesh.new()
	var appearance := StandardMaterial3D.new()
	appearance.albedo_color = {"paper": Color("f1ebd4"), "plastic": Color("8cd8c6"), "glass": Color("b2c8a5"), "metal": Color("aebdc6")}.get(material, Color.WHITE)
	appearance.metallic = 0.35 if material == "metal" else 0.0
	mesh.material = appearance
	var model := MeshInstance3D.new()
	model.mesh = mesh
	model.position.y = 0.28
	add_child(model)
	if material != "paper":
		var detail := MeshInstance3D.new()
		var cap := CylinderMesh.new()
		cap.top_radius = 0.07 if material != "metal" else 0.16
		cap.bottom_radius = cap.top_radius
		cap.height = 0.1 if material != "metal" else 0.025
		cap.radial_segments = 10
		var mat := StandardMaterial3D.new()
		mat.albedo_color = Color("4c8ca1") if material == "plastic" else Color("d7dbbf")
		mat.metallic = 0.5 if material == "metal" else 0.0
		cap.material = mat
		detail.mesh = cap
		detail.position.y = 0.53 if material != "metal" else 0.45
		add_child(detail)
	item_label = Label3D.new()
	item_label.text = {"paper": "Papel limpo", "plastic": "Garrafa plástica", "glass": "Frasco de vidro", "metal": "Lata de metal"}.get(material, material)
	item_label.position.y = 0.85
	item_label.font_size = 36
	item_label.pixel_size = 0.006
	item_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	item_label.visibility_range_end = 12.0
	add_child(item_label)
	var ring := TorusMesh.new()
	ring.inner_radius = 0.4
	ring.outer_radius = 0.48
	var highlight := StandardMaterial3D.new()
	highlight.albedo_color = Color("ffe29a")
	ring.material = highlight
	marker = MeshInstance3D.new()
	marker.mesh = ring
	marker.position.y = 0.06
	marker.visible = false
	add_child(marker)

func set_highlight(active: bool) -> void:
	marker.visible = active
