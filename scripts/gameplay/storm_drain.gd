extends Node3D
@export var drain_id: String = ""
var debris: Node3D
var label: Label3D
var cleaned: bool = false
var priority_hint: String = "Obstruído"
var display_number: int = 1
var highlighted: bool = false

func _ready() -> void:
	display_number = drain_id.get_slice("_",2).to_int()+1
	add_to_group("mission_drains")
	debris = Node3D.new()
	add_child(debris)
	var frame := MeshInstance3D.new()
	frame.mesh = preload("res://scripts/effects/environment_meshes.gd").beveled_box(Vector3(1.0, 0.045, 1.0), 0.065)
	var metal := StandardMaterial3D.new()
	metal.albedo_color = Color("687975")
	metal.metallic = 0.45
	metal.roughness = 0.66
	frame.material_override = metal
	frame.position.y = 0.055
	add_child(frame)
	var recess := MeshInstance3D.new()
	var recess_mesh := BoxMesh.new()
	recess_mesh.size = Vector3(0.87, 0.008, 0.87)
	var dark := StandardMaterial3D.new()
	dark.albedo_color = Color("233d40")
	recess_mesh.material = dark
	recess.mesh = recess_mesh
	recess.position.y = 0.081
	add_child(recess)
	for i in 7:
		var grid := MeshInstance3D.new()
		var bar := BoxMesh.new()
		bar.size = Vector3(0.07, 0.04, 0.85)
		var mat := StandardMaterial3D.new()
		mat.albedo_color = Color("31464b")
		bar.material = mat
		grid.mesh = bar
		grid.position = Vector3(-0.36 + i * 0.12, 0.095, 0)
		add_child(grid)
	for i in 4:
		var item := MeshInstance3D.new()
		var mesh := BoxMesh.new()
		mesh.size = Vector3(0.25, 0.11, 0.22)
		var mat := StandardMaterial3D.new()
		mat.albedo_color = Color("b7955b") if i % 2 == 0 else Color("9bc3b8")
		mesh.material = mat
		item.mesh = mesh
		item.position = Vector3(-0.26 + i * 0.17, 0.13, -0.2 + (i % 2) * 0.32)
		debris.add_child(item)
	label = Label3D.new()
	label.text = "BUEIRO %d • Obstruído" % display_number
	label.position.y = 0.85
	label.font_size = 34
	label.pixel_size = 0.006
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	add_child(label)

func set_highlight(active: bool) -> void:
	highlighted = active
	if not cleaned:
		label.text = ("[E] " if active else "") + "BUEIRO %d • %s" % [display_number,priority_hint]

func show_cleaned() -> void:
	cleaned = true
	debris.hide()
	label.text = "BUEIRO %d • Limpo" % display_number
	label.modulate = Color("9aebbe")
