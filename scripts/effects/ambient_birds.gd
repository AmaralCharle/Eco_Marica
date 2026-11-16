extends Node3D
## Bird (AssetQuest, CC0): corpo original estático, asas/voo leves autorais.
const Library = preload("res://scripts/effects/asset_library.gd")
var art: Node3D
var birds: Array[Node3D] = []
var wings: Array[Node3D] = []
var clock: float = 0.0
var call_in: float = 14.0
var voice: AudioStreamPlayer3D
var center: Vector3
func _ready() -> void:
	name = "AmbientBirds"
	art = get_parent()
	center = {"aracatiba":Vector3(-14,6,-5),"itaipuacu":Vector3(-8,7,-4),"centro":Vector3(0,8,-8),"ubatiba":Vector3(-9,6,-5),"ponta_negra":Vector3(0,6,-5)}[art.mission.mission_id]
	var source: PackedScene = preload("res://assets/imported/assetquest/bird.glb")
	var wing_mesh := SurfaceTool.new()
	wing_mesh.begin(Mesh.PRIMITIVE_TRIANGLES)
	var points: Array[Vector3] = [Vector3.ZERO,Vector3(0.40,0.01,0.10),Vector3(0.29,0,0.23),Vector3(0.12,0,0.19)]
	for index in [0,1,2,0,2,3]: wing_mesh.add_vertex(points[index])
	wing_mesh.generate_normals()
	var shape := wing_mesh.commit()
	var material := StandardMaterial3D.new()
	material.albedo_color = Color("639ea1")
	material.roughness = 0.9
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	for i in 4:
		var bird := Node3D.new()
		bird.name = "Bird"
		bird.set_meta("asset_source","res://assets/imported/assetquest/bird.glb")
		add_child(bird)
		var model: Node3D = source.instantiate()
		bird.add_child(model)
		var bounds := Library.bounds(model)
		model.scale = Vector3.ONE * (0.35/maxf(bounds.size.x,maxf(bounds.size.y,bounds.size.z)))
		model.position = -bounds.get_center()*model.scale
		for mesh: MeshInstance3D in model.find_children("*","MeshInstance3D",true,false): mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		birds.append(bird)
		for side: float in [-1,1]:
			var pivot := Node3D.new()
			pivot.position = Vector3(side*0.06,0.02,0)
			pivot.set_meta("side",side)
			bird.add_child(pivot)
			var wing := MeshInstance3D.new()
			wing.mesh = shape
			wing.material_override = material
			wing.scale.x = side
			wing.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
			pivot.add_child(wing)
			wings.append(pivot)
	voice = AudioStreamPlayer3D.new()
	voice.stream = preload("res://assets/sounds/bird_call.wav")
	voice.bus = "Ambience"
	voice.max_distance = 35
	voice.unit_size = 8
	voice.volume_db = -18
	voice.position = center
	add_child(voice)

func _process(delta: float) -> void:
	var camera := get_viewport().get_camera_3d()
	var active: bool = art.mission.state == art.mission.State.JOGANDO and camera != null and camera.global_position.distance_to(to_global(center)) < 65
	if art.mission.mission_id == "centro" and art.world.storm_intensity > 0.5: active = false
	var count: int = [1,2,4][art.settings.quality] if active else 0
	for i in birds.size(): birds[i].visible = i < count
	if not active:
		voice.stop()
		return
	clock += delta
	for i in count:
		var t := clock*0.19+i*0.17
		birds[i].position = center+Vector3(cos(t)*5+i*0.55,sin(t*1.7+i)*0.45+i*0.23,sin(t)*9+i*0.6)
		birds[i].rotation.y = atan2(-sin(t)*5,cos(t)*9)
		for wing in [wings[i*2],wings[i*2+1]]: wing.rotation.z = sin(clock*8+i)*0.55*float(wing.get_meta("side"))
	call_in -= delta
	if call_in <= 0:
		voice.pitch_scale = 0.92+0.04*(int(clock)%5)
		voice.play()
		call_in = 18.0+float(int(clock)%11)
