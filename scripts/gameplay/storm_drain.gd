extends Node3D
@export var drain_id: String = ""
var debris: Node3D
var label: Label3D
var cleaned: bool = false

func _ready() -> void:
	add_to_group("mission_drains")
	debris = Node3D.new()
	add_child(debris)
	for i in 7:
		var grid := MeshInstance3D.new()
		var bar := BoxMesh.new()
		bar.size = Vector3(0.07, 0.04, 0.85)
		var mat := StandardMaterial3D.new()
		mat.albedo_color = Color("31464b")
		bar.material = mat
		grid.mesh = bar
		grid.position = Vector3(-0.36 + i * 0.12, 0.04, 0)
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
	label.text = "BUEIRO • Obstruído"
	label.position.y = 0.85
	label.font_size = 34
	label.pixel_size = 0.006
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	add_child(label)

func set_highlight(active: bool) -> void:
	if not cleaned:
		label.text = ("[E] " if active else "") + "BUEIRO • Obstruído"

func show_cleaned() -> void:
	cleaned = true
	debris.hide()
	label.text = "BUEIRO • Limpo"
	label.modulate = Color("9aebbe")
