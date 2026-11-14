class_name TrainingBin
extends Node3D
const Config = preload("res://scripts/core/game_config.gd")
@export_enum("paper", "plastic", "glass", "metal") var material: String = "paper"
var label: Label3D

func _ready() -> void:
	add_to_group("training_bins")
	var body := StaticBody3D.new()
	var shape := BoxShape3D.new()
	shape.size = Vector3(0.85, 1.15, 0.85)
	var collision := CollisionShape3D.new()
	collision.shape = shape
	collision.position.y = 0.575
	body.add_child(collision)
	add_child(body)
	var mesh := BoxMesh.new()
	mesh.size = shape.size
	var appearance := StandardMaterial3D.new()
	appearance.albedo_color = Config.MATERIAL_COLORS[material]
	mesh.material = appearance
	var model := MeshInstance3D.new()
	model.mesh = mesh
	model.position.y = 0.575
	add_child(model)
	label = Label3D.new()
	label.text = Config.MATERIAL_NAMES[material]
	label.position.y = 1.6
	label.font_size = 48
	label.pixel_size = 0.006
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	add_child(label)

func set_highlight(active: bool) -> void:
	label.text = ("[E] " if active else "") + Config.MATERIAL_NAMES[material]
