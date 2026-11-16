extends Node3D
@export var plot_id: String = ""
@export var apt: bool = true
@export var exposed: bool = false
@export var reason: String = ""
var sapling: Node3D
var cover: MeshInstance3D
var label: Label3D
var ground_material: ShaderMaterial
func _ready() -> void:
	add_to_group("planting_plots")
	cover = MeshInstance3D.new()
	var patch := CylinderMesh.new()
	patch.top_radius = 0.77
	patch.bottom_radius = 0.79
	patch.height = 0.045
	patch.radial_segments = 15
	cover.mesh = patch
	ground_material = ShaderMaterial.new()
	ground_material.shader = preload("res://assets/materials/environment_surface.gdshader")
	ground_material.set_shader_parameter("base_color", Color("b3966c") if exposed else Color("73915a"))
	ground_material.set_shader_parameter("surface_type", 1 if exposed else 0)
	cover.material_override = ground_material
	add_child(cover)
	sapling = Node3D.new()
	add_child(sapling)
	block(sapling, Vector3(0, 0.35, 0), Vector3(0.08, 0.7, 0.08), Color("8a6647"))
	for i in 5:
		var leaf := MeshInstance3D.new()
		var mesh := preload("res://scripts/effects/environment_meshes.gd").leaf()
		var mat := StandardMaterial3D.new()
		mat.albedo_color = Color("58a768") if i % 2 == 0 else Color("35875a")
		mat.cull_mode = BaseMaterial3D.CULL_DISABLED
		leaf.material_override = mat
		leaf.mesh = mesh
		leaf.scale = Vector3.ONE * 0.9
		leaf.position = Vector3(cos(i * 2.4) * 0.16, 0.55 + i * 0.1, sin(i * 2.4) * 0.16)
		leaf.rotation = Vector3(0.2, -i * 2.4, 0.25)
		sapling.add_child(leaf)
	sapling.visible = not apt
	label = Label3D.new()
	label.text = "PONTO " + plot_id.trim_prefix("ubatiba_") + (" • Solo exposto" if exposed else " • Inspecione")
	label.position.y = 1.45
	label.font_size = 30
	label.pixel_size = 0.0045
	label.visibility_range_end = 16.0
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	add_child(label)
func block(parent: Node, pos: Vector3, size: Vector3, color: Color) -> MeshInstance3D:
	var item := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = size
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mesh.material = mat
	item.mesh = mesh
	item.position = pos
	parent.add_child(item)
	return item
func set_highlight(active: bool) -> void:
	label.modulate = Color("ffe29a") if active else Color.WHITE
func update_plot(data: Dictionary) -> void:
	if data["planted"] and not sapling.visible:
		sapling.scale = Vector3.ONE * 0.1
		create_tween().tween_property(sapling, "scale", Vector3.ONE, 0.35)
	sapling.visible = data["planted"] or not apt
	if data["protected"]:
		ground_material.set_shader_parameter("base_color", Color("7c9560"))
	label.text = "PONTO " + plot_id.trim_prefix("ubatiba_") + (" • Avaliado" if (data["preserved"] or (data["planted"] and (not exposed or data["protected"]))) else " • Em recuperação")
