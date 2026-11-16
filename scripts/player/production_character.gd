extends RefCounted
## Modelos CC0 com o próprio rig. Não retargeta esqueletos diferentes.
const Library = preload("res://scripts/effects/asset_library.gd")
const Catalog = preload("res://scripts/core/character_catalog.gd")
static var validated_ids: Array[String] = ["lucas", "marina", "rafael", "bia"]
static var cache: Dictionary = {}

static func mount(appearance: Node3D) -> void:
	var id: String = appearance.character_id
	if not id in validated_ids or OS.get_cmdline_user_args().has("--legacy-art"): return
	var filename: String = {"lucas":"man","marina":"woman_casual","rafael":"worker","bia":"woman"}[id]
	var path := "res://assets/imported/quaternius/characters/"+filename+".glb"
	if not ResourceLoader.exists(path):
		appearance.external_error = "Modelo indisponível; apresentação procedural preservada."
		return
	if not cache.has(path):
		var scene: PackedScene = load(path)
		var model: Node3D = scene.instantiate()
		var bounds := Library.bounds(model)
		var scale := 1.88/bounds.size.y
		var basis := Basis(Vector3.UP,PI).scaled(Vector3.ONE*scale)
		var offset := basis * -Vector3(bounds.get_center().x,bounds.position.y,bounds.get_center().z)
		cache[path] = {"scene":scene,"adjustment":Transform3D(basis,offset)}
		model.free()
	var prefix := "CharacterArmature|" if id == "rafael" else "HumanArmature|"+ ("Man_" if id == "lucas" else "Female_")
	var idle := prefix+"Idle"
	var saved_map: Dictionary = appearance.external_animations
	appearance.external_animations = {"idle":idle,"walk":prefix+"Walk","run":prefix+"Run","jump":idle if id == "rafael" else prefix+"Jump","collect":prefix+"Interact" if id == "rafael" else idle,"plant":idle,"interact":prefix+"Interact" if id == "rafael" else idle,"boat":idle,"embark":idle,"disembark":idle}
	var model: Node3D = appearance.attach_external_model(cache[path].scene,cache[path].adjustment)
	appearance.external_animations = saved_map
	if model == null: return
	model.set_meta("asset_source",path)
	model.set_meta("asset_author","Quaternius")
	model.set_meta("asset_license","CC0-1.0")
	var palette: Dictionary = Catalog.get_character(id)
	for mesh: MeshInstance3D in model.find_children("*","MeshInstance3D",true,false):
		for surface in mesh.mesh.get_surface_count():
			var original: StandardMaterial3D = mesh.mesh.surface_get_material(surface)
			if original == null: continue
			var material: StandardMaterial3D = original.duplicate()
			var title := String(original.resource_name).to_lower()
			if title == "skin": material.albedo_color = palette.skin
			elif title in ["shirt","jacket","lightjacket","worker_vest"]: material.albedo_color = palette.outfit.lightened(0.12) if title == "lightjacket" else palette.outfit
			elif title in ["hair","hairbase","eyebrows","moustache"]: material.albedo_color = palette.hair
			elif title == "pants": material.albedo_color = palette.pants
			material.roughness = 0.84
			material.metallic = 0.0
			mesh.set_surface_override_material(surface,material)
	var skeletons := model.find_children("*","Skeleton3D",true,false)
	if not skeletons.is_empty():
		var skeleton: Skeleton3D = skeletons[0]
		var reach := preload("res://scripts/player/imported_reach.gd").new()
		reach.name = "EnvironmentalReach"
		reach.appearance = appearance
		skeleton.add_child(reach)
		var rowing := preload("res://scripts/player/seated_rowing_pose.gd").new()
		rowing.name = "SeatedRowingPose"
		rowing.appearance = appearance
		skeleton.add_child(rowing)
		var attachment := BoneAttachment3D.new()
		attachment.name = "EcoEquipment"
		attachment.bone_name = "Torso"
		var bone := skeleton.find_bone("Torso")
		if bone >= 0:
			skeleton.add_child(attachment)
			var gear: Node3D = appearance.parts.Backpack.duplicate()
			gear.name = "IdentityEquipment"
			gear.show()
			attachment.add_child(gear)
			gear.transform = (skeleton.global_transform*skeleton.get_bone_global_rest(bone)).affine_inverse()*appearance.global_transform
	var adapter: Node3D = appearance.get_node("ExternalModel")
	adapter.set_meta("production_character",true)
	if adapter.animator:
		for title: String in adapter.animator.get_animation_list():
			if title.ends_with("Idle") or title.ends_with("Walk") or title.ends_with("Run") or title.ends_with("Sitting"):
				adapter.animator.get_animation(title).loop_mode = Animation.LOOP_LINEAR
	adapter.animator.speed_scale = 1.0 if appearance.animate_face else 0.0
