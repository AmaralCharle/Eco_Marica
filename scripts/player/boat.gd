class_name EnvironmentalBoat
extends CharacterBody3D
const Config = preload("res://scripts/core/game_config.gd")
var speed: float = 0.0
var pilot: CharacterBody3D
var dock_position: Vector3 = Vector3(4.8, 0.05, 12)
var landing_position: Vector3 = Vector3(7.2, 0.15, 12)
var active: bool = false
var previous_mask: int = 1
var previous_layer: int = 2
@onready var camera: Camera3D = $CameraPivot/SpringArm3D/Camera3D
@onready var camera_pivot: Node3D = $CameraPivot
var look_target := Vector2(-0.4,0)
var look_current := Vector2(-0.4,0)
func _ready() -> void:
	set_physics_process(false)
	for side: float in [-1, 1]:
		var rail := MeshInstance3D.new()
		var mesh := BoxMesh.new()
		mesh.size = Vector3(0.12, 0.28, 2.5)
		var mat := StandardMaterial3D.new()
		mat.albedo_color = Color("d8bd71")
		mesh.material = mat
		rail.mesh = mesh
		rail.position = Vector3(side * 0.67, 0.5, 0)
		add_child(rail)
	var art := preload("res://scripts/effects/boat_polish.gd").new()
	art.name = "BoatArt"
	add_child(art)
	$Hull.hide()
func embark(player: CharacterBody3D) -> bool:
	if pilot != null or global_position.distance_to(player.global_position) > 3.0:
		return false
	pilot = player
	previous_mask = player.collision_mask
	previous_layer = player.collision_layer
	player.collision_mask = 0
	player.collision_layer = 0
	player.velocity = Vector3.ZERO
	player.set_physics_process(false)
	player.set_process_unhandled_input(false)
	player.hide()
	$Passenger.apply_character(player.visual.character_id)
	$Passenger.show()
	$Passenger.set_animation("embark")
	$Passenger.rotation.x = -0.18
	create_tween().tween_property($Passenger, "rotation:x", 0.0, 0.45)
	$Passenger.get_node("LeftArm").rotation.x = -0.55
	$Passenger.get_node("RightArm").rotation.x = -0.55
	$Passenger.set_seated(true)
	$BoatArt.set_passenger($Passenger)
	preload("res://scripts/player/camera_transition.gd").blend(player.camera_pivot.get_node("SpringArm3D/Camera3D"), camera)
	active = true
	reset_look()
	set_physics_process(true)
	if has_node("/root/GameAudio"):
		get_node("/root/GameAudio").play_event("embark")
	return true
func disembark() -> bool:
	if pilot == null or global_position.distance_to(dock_position) > 2.8 or absf(speed) > 0.6:
		return false
	var player: CharacterBody3D = pilot
	pilot = null
	active = false
	speed = 0
	velocity = Vector3.ZERO
	set_physics_process(false)
	player.position = landing_position
	player.collision_mask = previous_mask
	player.collision_layer = previous_layer
	player.show()
	player.set_physics_process(true)
	player.set_process_unhandled_input(true)
	preload("res://scripts/player/camera_transition.gd").blend(camera, player.camera_pivot.get_node("SpringArm3D/Camera3D"))
	$Passenger.hide()
	$Passenger.set_seated(false)
	player.play_action("disembark")
	if has_node("/root/GameAudio"):
		get_node("/root/GameAudio").play_event("disembark")
	return true
func _physics_process(delta: float) -> void:
	if not active or pilot == null:
		return
	var preferences := get_node_or_null("/root/GameAudio")
	if preferences and preferences.smoothing and DisplayServer.get_name() != "headless":
		look_current.x = lerpf(look_current.x,look_target.x,1-exp(-16*delta))
		look_current.y = lerp_angle(look_current.y,look_target.y,1-exp(-16*delta))
		update_camera_look()
	var throttle: float = Input.get_action_strength("move_forward") - Input.get_action_strength("move_back")
	var target_speed: float = throttle * (Config.BOAT_MAX_SPEED if throttle >= 0 else Config.BOAT_MAX_SPEED * 0.5)
	speed = move_toward(speed, target_speed, (Config.BOAT_ACCELERATION if absf(throttle) > 0 else Config.BOAT_DECELERATION) * delta)
	var steering: float = Input.get_action_strength("move_left") - Input.get_action_strength("move_right")
	rotation.y += steering * Config.BOAT_TURN_SPEED * delta * (0.35 + 0.65 * minf(absf(speed) / Config.BOAT_MAX_SPEED, 1))
	velocity = -global_basis.z * speed
	velocity.y = 0
	var fisheries := get_parent().get_node_or_null("Fisheries")
	if fisheries: fisheries.constrain_boat(self,delta)
	move_and_slide()
	if get_slide_collision_count() > 0:
		speed = move_toward(speed, 0, 6 * delta)
	position.y = 0.05

func apply_look(relative: Vector2) -> void:
	if not active or pilot == null: return
	var preferences := get_node_or_null("/root/GameAudio")
	var sensitivity: float = preferences.sensitivity if preferences else 1.0
	look_target.y -= relative.x*Config.MOUSE_SENSITIVITY*sensitivity
	look_target.x = clampf(look_target.x-relative.y*Config.MOUSE_SENSITIVITY*sensitivity,Config.CAMERA_MIN_PITCH,Config.CAMERA_MAX_PITCH)
	if not preferences or not preferences.smoothing or DisplayServer.get_name() == "headless":
		look_current = look_target
		update_camera_look()

func reset_look() -> void:
	look_target = Vector2(-0.4,0)
	look_current = look_target
	update_camera_look()

func update_camera_look() -> void:
	# O braço de câmera conserva posição/colisão; somente a orientação da lente muda.
	var arm: Node3D = camera.get_parent()
	camera.basis = (camera_pivot.basis*arm.basis).inverse()*Basis.from_euler(Vector3(look_current.x,look_current.y,0))

func _unhandled_input(event: InputEvent) -> void:
	if active and pilot != null and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED and event is InputEventMouseMotion:
		apply_look(event.relative)
		get_viewport().set_input_as_handled()
