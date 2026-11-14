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
	# Tampa, abertura e base decorativas; o volume físico continua idêntico.
	for part: Dictionary in [
		{"size": Vector3(0.94, 0.12, 0.94), "position": Vector3(0, 1.15, 0), "color": Config.MATERIAL_COLORS[material].darkened(0.16)},
		{"size": Vector3(0.61, 0.025, 0.42), "position": Vector3(0, 1.22, 0), "color": Color("17383d")},
		{"size": Vector3(0.9, 0.12, 0.9), "position": Vector3(0, 0.06, 0), "color": Color("34545a")}
	]:
		var detail := MeshInstance3D.new()
		var block := BoxMesh.new()
		block.size = part.size
		var mat := StandardMaterial3D.new()
		mat.albedo_color = part.color
		block.material = mat
		detail.mesh = block
		detail.position = part.position
		add_child(detail)
	var symbol := Label3D.new()
	symbol.text = "♻"
	symbol.position = Vector3(0, 0.67, -0.432)
	symbol.font_size = 75
	symbol.pixel_size = 0.006
	add_child(symbol)
	label = Label3D.new()
	label.text = Config.MATERIAL_NAMES[material]
	label.position.y = 1.6
	label.font_size = 48
	label.pixel_size = 0.006
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	add_child(label)

func set_highlight(active: bool) -> void:
	label.text = ("[E] " if active else "") + Config.MATERIAL_NAMES[material]
