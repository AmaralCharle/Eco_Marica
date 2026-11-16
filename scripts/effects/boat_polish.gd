extends Node3D
var boat: CharacterBody3D
var clock: float = 0.0
var wake: Array[MeshInstance3D] = []
func _ready() -> void:
	boat = get_parent()
	var art = preload("res://scripts/effects/world_polish.gd").new()
	# Reutiliza apenas fábricas de malha; não adiciona esta instância à árvore.
	var hull := SurfaceTool.new()
	hull.begin(Mesh.PRIMITIVE_TRIANGLES)
	var ring: Array[Vector3] = [Vector3(-0.6, 0.4, 1.2), Vector3(0.6, 0.4, 1.2), Vector3(0.7, 0.4, -0.7), Vector3(0.28, 0.4, -1.3), Vector3(-0.28, 0.4, -1.3), Vector3(-0.7, 0.4, -0.7)]
	for i in ring.size():
		var a := ring[i]
		var b := ring[(i + 1) % ring.size()]
		var bottom_a := Vector3(a.x * 0.65, 0.03, a.z * 0.85)
		var bottom_b := Vector3(b.x * 0.65, 0.03, b.z * 0.85)
		for vertex: Vector3 in [a, b, bottom_a, b, bottom_b, bottom_a, a, Vector3(0, 0.4, 0), b]:
			hull.add_vertex(vertex)
	hull.generate_normals()
	var skin := art.mesh_at(self, hull.commit(), Vector3.ZERO, Color("2c8276"))
	skin.material_override.cull_mode = BaseMaterial3D.CULL_DISABLED
	skin.material_override.roughness = 0.43
	var deck := art.box(self, Vector3(0, 0.42, 0), Vector3(1.12, 0.035, 1.9), Color("ded2a5"))
	deck.material_override = art.textured(6, Color("c8b78c"))
	for side: float in [-1, 1]:
		art.box(self, Vector3(side * 0.66, 0.37, 0), Vector3(0.025, 0.055, 2.05), Color("e5dcb3"))
		var rope := art.cylinder(self, Vector3(side * 0.38, 0.48, -0.75), 0.055, 0.085, Color("baab7e"))
		rope.rotation.x = PI * 0.5
	art.box(self, Vector3(0, 0.67, 1.1), Vector3(0.42, 0.52, 0.34), Color("3b5359"))
	art.cylinder(self, Vector3(0, 0.27, 1.17), 0.5, 0.06, Color("54727a"))
	var text := Label3D.new()
	text.text = "ECO MARICÁ"
	text.position = Vector3(0, 0.8, 1.28)
	text.font_size = 28
	text.pixel_size = 0.007
	add_child(text)
	for i in 5:
		var ripple := art.ellipsoid(self, Vector3(0, 0.02, 1.5 + i * 0.28), Vector3(0.15, 0.035, 0.18), Color("b4e0d3"))
		wake.append(ripple)
	art.free()

func _process(delta: float) -> void:
	if boat.pilot != null and not boat.active:
		return
	clock += delta
	rotation.z = sin(clock * 1.6) * 0.018
	position.y = sin(clock * 2) * 0.018
	for i in wake.size():
		wake[i].visible = boat.active and absf(boat.speed) > 0.6
		wake[i].position.x = sin(clock * 5 + i * 2) * 0.35
		wake[i].scale.x = 1.0 + fposmod(clock * 2 + i, 1.0)
