extends Node
## Som/efeitos observam eventos; não calculam pontos nem alteram colisões.
var mission: Node3D
var audio: Node
var thunder_time: float = 0.0
var last_state: int = -1

func _ready() -> void:
	mission = get_parent()
	audio = get_node("/root/GameAudio")
	mission.session.presentation_event.connect(on_event)
	var polish := preload("res://scripts/effects/world_polish.gd").new()
	add_child(polish)
	add_child(preload("res://scripts/effects/environmental_recovery.gd").new())

func on_event(event: String) -> void:
	audio.play_event(event)
	if event in ["soil", "plant", "drain", "correct", "wrong", "collect", "unload"]:
		if event in ["soil", "plant", "drain"]:
			mission.player.play_action("plant" if event == "plant" else "interact")
		burst(event)

func burst(event: String) -> void:
	var origin: Vector3 = mission.player.global_position + Vector3.UP * 0.6
	if mission.mission_id == "ponta_negra" and mission.on_boat:
		origin = mission.get_node("Boat").global_position + Vector3.UP
	var group := Node3D.new()
	mission.add_child(group)
	group.global_position = origin
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color("ffb46d") if event == "wrong" else Color("80f4b6")
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for i in [3,5,7][audio.quality]:
		var particle := MeshInstance3D.new()
		var mesh := SphereMesh.new()
		mesh.radius = 0.045
		mesh.height = 0.09
		mesh.radial_segments = 6
		mesh.rings = 3
		mesh.material = mat
		particle.mesh = mesh
		group.add_child(particle)
		var angle: float = TAU * i / 7.0
		var tween := group.create_tween().set_parallel(true)
		tween.tween_property(particle, "position", Vector3(cos(angle) * 0.65, 0.5, sin(angle) * 0.65), 0.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tween.tween_property(particle, "scale", Vector3.ZERO, 0.5)
	var lifetime := group.create_tween()
	lifetime.tween_interval(0.6)
	lifetime.tween_callback(group.queue_free)

func _process(delta: float) -> void:
	var playing: bool = mission.session.active
	if mission.mission_id == "centro":
		var intensity: float = mission.get_node("World").storm_intensity
		audio.set_rain((intensity - 0.35) / 0.65 if playing else 0.0)
		if playing and intensity > 0.55:
			thunder_time += delta
			if thunder_time >= 23.0:
				thunder_time = 0.0
				audio.play_event("thunder")
	if mission.mission_id == "ponta_negra":
		var boat := mission.get_node("Boat")
		# A embarcação atual é a remo; a ambiência de água permanece sem motor fictício.
		audio.set_engine(false, boat.speed)
	if last_state != mission.state:
		last_state = mission.state
		if mission.state == mission.State.VITORIA:
			burst("correct")

func _exit_tree() -> void:
	if is_instance_valid(audio):
		audio.set_engine(false)
		audio.set_rain(0)
