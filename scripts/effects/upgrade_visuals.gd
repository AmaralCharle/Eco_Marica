extends Node3D
## Acabamento 4.0. Nenhum collider ou objetivo é criado aqui.
var art: Node3D
var splashes: MultiMeshInstance3D
var splash_material: ShaderMaterial
func _ready() -> void:
	name = "VisualUpgrade4"
	art = get_parent()
	if art.mission.mission_id == "centro": urban()
func urban() -> void:
	if not art.AssetLibrary.enabled(art.mission.mission_id): legacy_facades()
	build_splashes()

func legacy_facades() -> void:
	var glass := ShaderMaterial.new()
	glass.shader = preload("res://assets/materials/stylized_glass.gdshader")
	for side: float in [-1,1]:
		for i in 4:
			var z := -13.0+i*8
			for offset: float in [-1.5,1.5]:
				var window: MeshInstance3D = art.box(art,Vector3(side*8.30,2.70,z+offset),Vector3(0.035,0.91,0.94),Color.WHITE)
				window.material_override = glass
				for dz: float in [-0.49,0,0.49]: art.box(art,Vector3(side*8.26,2.70,z+offset+dz),Vector3(0.045,0.95,0.035),Color("d6cbb0"))
			art.box(art,Vector3(side*8.40,3.45,z),Vector3(0.28,0.10,5.65),Color("ddcdb0"))
			art.box(art,Vector3(side*8.40,0.32,z),Vector3(0.14,0.07,5.50),Color("947e66"))
			if i%2 == 0:
				for dz: float in [-1.65,1.65]:
					var pot: MeshInstance3D = art.cylinder(art,Vector3(side*7.75,0.34,z+dz),0.43,0.20,Color("b87c58"))
					art.fern(pot.position+Vector3.UP*0.20,i)
		for z: float in [-8,8]:
			art.box(art,Vector3(side*7.50,0.48,z),Vector3(0.55,0.10,1.5),Color("ae875b"))
			art.box(art,Vector3(side*7.78,0.77,z),Vector3(0.08,0.55,1.5),Color("ae875b"))
			for off: float in [-0.55,0.55]: art.cylinder(art,Vector3(side*7.5,0.25,z+off),0.5,0.04,Color("455d56"))
func build_splashes() -> void:
	splashes = MultiMeshInstance3D.new()
	splashes.name = "RainSplashes"
	var ring := TorusMesh.new()
	ring.inner_radius = 0.10
	ring.outer_radius = 0.115
	ring.rings = 12
	ring.ring_segments = 4
	var multi := MultiMesh.new()
	multi.transform_format = MultiMesh.TRANSFORM_3D
	multi.mesh = ring
	multi.instance_count = 64
	var rng := RandomNumberGenerator.new()
	rng.seed = 4104
	for i in 64: multi.set_instance_transform(i,Transform3D(Basis.IDENTITY,Vector3(rng.randf_range(-3.7,3.7),0.062,rng.randf_range(-18,18))))
	splashes.multimesh = multi
	splash_material = ShaderMaterial.new()
	splash_material.shader = preload("res://assets/materials/rain_splash.gdshader")
	splashes.material_override = splash_material
	splashes.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(splashes)
func _process(_delta: float) -> void:
	if splashes:
		var quality: int = art.settings.quality
		splashes.visible = quality > 0 and art.world.storm_intensity > 0.55
		splashes.multimesh.visible_instance_count = [0,24,64][quality]
		splash_material.set_shader_parameter("rain_amount",art.world.storm_intensity)
