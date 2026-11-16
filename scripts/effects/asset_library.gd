extends RefCounted
## Recursos externos somente visuais. Cache compartilhado e normalização em metros.
const BASE := "res://assets/imported/kenney/"
static var scenes: Dictionary = {}
static var bounds_cache: Dictionary = {}
static var enabled_phases: Array[String] = ["centro"]

static func enabled(id: String) -> bool:
	return id in enabled_phases and not OS.get_cmdline_user_args().has("--legacy-art")

static func bounds(node: Node3D) -> AABB:
	var result := AABB()
	var first := true
	for mesh: MeshInstance3D in node.find_children("*", "MeshInstance3D", true, false):
		var transform := Transform3D.IDENTITY
		var current: Node3D = mesh
		while current != node:
			transform = current.transform * transform
			current = current.get_parent() as Node3D
		var box: AABB = transform * mesh.get_aabb()
		result = box if first else result.merge(box)
		first = false
	return result

static func place(parent: Node3D, pack: String, model_name: String, at: Vector3, size: Vector3, angle: float = 0.0, stretch: bool = false) -> Node3D:
	var quaternius := pack == "stylized-nature"
	var path := ("res://assets/imported/quaternius/" if quaternius else BASE) + pack + "/" + model_name + (".gltf" if quaternius else ".glb")
	if not scenes.has(path): scenes[path] = load(path)
	var model: Node3D = scenes[path].instantiate()
	var pivot := Node3D.new()
	pivot.name = "Asset_" + model_name
	pivot.set_meta("asset_source", path)
	pivot.set_meta("asset_author", "Quaternius" if quaternius else "Kenney")
	pivot.set_meta("asset_license", "CC0-1.0")
	parent.add_child(pivot)
	pivot.add_child(model)
	if not bounds_cache.has(path): bounds_cache[path] = bounds(model)
	var box: AABB = bounds_cache[path]
	var ratio := size / box.size.max(Vector3.ONE * 0.001)
	var factor := minf(ratio.x, minf(ratio.y, ratio.z))
	model.scale = ratio if stretch else Vector3.ONE * factor
	model.position = -Vector3(box.get_center().x, box.position.y, box.get_center().z) * model.scale
	pivot.position = at
	pivot.rotation.y = angle
	for mesh: MeshInstance3D in model.find_children("*", "MeshInstance3D", true, false):
		mesh.visibility_range_end = 100.0
		# Copas recortadas têm alto custo nas quatro cascatas; sombras usam proxy opaco.
		if quaternius and model_name.begins_with("CommonTree"):
			mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	if quaternius and model_name.begins_with("CommonTree"):
		var proxy := MeshInstance3D.new()
		var crown := SphereMesh.new()
		crown.radius = 0.8
		crown.height = 1.6
		crown.radial_segments = 8
		crown.rings = 3
		proxy.mesh = crown
		proxy.position.y = box.size.y * factor * 0.70
		proxy.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_SHADOWS_ONLY
		pivot.add_child(proxy)
	return pivot

static func batch(parent: Node3D) -> void:
	# Uma MultiMesh por malha/material, sem duplicar geometria ou gerar colisões.
	var groups: Dictionary = {}
	for mesh: MeshInstance3D in parent.find_children("*", "MeshInstance3D", true, false):
		if not mesh.is_visible_in_tree() or not mesh.mesh: continue
		var key := str(mesh.mesh.get_instance_id()) + "_" + str(mesh.material_override) + "_" + str(mesh.cast_shadow)
		if not groups.has(key): groups[key] = {"mesh":mesh.mesh,"material":mesh.material_override,"shadow":mesh.cast_shadow,"transforms":[]}
		groups[key].transforms.append(parent.global_transform.affine_inverse() * mesh.global_transform)
		mesh.hide()
	for group: Dictionary in groups.values():
		var draw := MultiMeshInstance3D.new()
		draw.name = "AssetBatch"
		var multi := MultiMesh.new()
		multi.transform_format = MultiMesh.TRANSFORM_3D
		multi.mesh = group.mesh
		multi.instance_count = group.transforms.size()
		for i in multi.instance_count: multi.set_instance_transform(i, group.transforms[i])
		draw.multimesh = multi
		draw.material_override = group.material
		draw.cast_shadow = group.shadow
		draw.visibility_range_end = 110.0
		parent.add_child(draw)
