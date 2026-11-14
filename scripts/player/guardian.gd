class_name GuardianController
extends CharacterBody3D
## Controlador único para as quatro aparências: mesmas velocidades e colisão.
const Profile = preload("res://scripts/core/player_profile.gd")
@export var profile_path: String = "user://player_profile.json"
const Config = preload("res://scripts/core/game_config.gd")
@onready var camera_pivot: Node3D = $CameraPivot
@onready var visual: Node3D = $Visual
@onready var left_leg: Node3D = $Visual/LeftLeg
@onready var right_leg: Node3D = $Visual/RightLeg
@onready var left_arm: Node3D = $Visual/LeftArm
@onready var right_arm: Node3D = $Visual/RightArm
var gait: float = 0.0
var collection_time: float = 0.0
var footstep_time: float = 0.0
var look_target: Vector2
var action_kind: String = "collect"

func _ready() -> void:
	set_character(Profile.new(profile_path).selected_id)
	Config.ensure_input_actions()
	look_target = Vector2(camera_pivot.rotation.x, camera_pivot.rotation.y)
	if DisplayServer.get_name() != "headless":
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func set_character(id: String) -> void:
	visual.apply_character(id)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("release_mouse"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if DisplayServer.get_name() != "headless":
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	elif event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		apply_look(event.relative)

func play_collect() -> void:
	play_action("collect")

func play_action(action: String) -> void:
	action_kind = action
	collection_time = 0.4

func apply_look(relative: Vector2) -> void:
	var preferences := get_node_or_null("/root/GameAudio")
	var sensitivity: float = preferences.sensitivity if preferences else 1.0
	look_target.y -= relative.x * Config.MOUSE_SENSITIVITY * sensitivity
	look_target.x = clampf(look_target.x - relative.y * Config.MOUSE_SENSITIVITY * sensitivity, Config.CAMERA_MIN_PITCH, Config.CAMERA_MAX_PITCH)
	# Limites são aplicados imediatamente; interpolação só atua entre valores válidos.
	if not preferences or not preferences.smoothing or DisplayServer.get_name() == "headless":
		camera_pivot.rotation.x = look_target.x
		camera_pivot.rotation.y = look_target.y

func _physics_process(delta: float) -> void:
	var preferences := get_node_or_null("/root/GameAudio")
	if preferences and preferences.smoothing and DisplayServer.get_name() != "headless":
		camera_pivot.rotation.x = lerpf(camera_pivot.rotation.x, look_target.x, 1.0 - exp(-16.0 * delta))
		camera_pivot.rotation.y = lerp_angle(camera_pivot.rotation.y, look_target.y, 1.0 - exp(-16.0 * delta))
	if not is_on_floor():
		velocity.y -= Config.GRAVITY * delta
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = Config.JUMP_SPEED
	var input := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction := Basis(Vector3.UP, camera_pivot.rotation.y) * Vector3(input.x, 0.0, input.y)
	var speed: float = Config.RUN_SPEED if Input.is_action_pressed("sprint") else Config.WALK_SPEED
	velocity.x = direction.x * speed
	velocity.z = direction.z * speed
	move_and_slide()
	if is_on_floor() and Vector2(velocity.x, velocity.z).length() > 0.4 and visible:
		footstep_time += delta
		if footstep_time >= (0.27 if speed == Config.RUN_SPEED else 0.42):
			footstep_time = 0.0
			var level: Variant = get_parent().get("mission_id")
			var surface := "sand" if level == "itaipuacu" else "soil" if level == "ubatiba" else "pavement"
			if preferences:
				preferences.play_event("step_" + surface, 0.97 + randf() * 0.06)
	else:
		footstep_time = 0.0
	if direction.length_squared() > 0.01:
		visual.rotation.y = lerp_angle(visual.rotation.y, atan2(-direction.x, -direction.z), minf(delta * 12.0, 1.0))
		gait += delta * (13.0 if Input.is_action_pressed("sprint") else 8.0)
	var swing: float = sin(gait) * 0.5 if direction.length_squared() > 0.01 and is_on_floor() else 0.0
	visual.set_animation("jump" if not is_on_floor() else "run" if direction.length_squared() > 0.01 and speed == Config.RUN_SPEED else "walk" if direction.length_squared() > 0.01 else "idle")
	left_leg.rotation.x = swing
	right_leg.rotation.x = -swing
	left_arm.rotation.x = -swing * 0.7
	right_arm.rotation.x = swing * 0.7
	if not is_on_floor():
		left_arm.rotation.x = -0.35
		right_arm.rotation.x = -0.35

	collection_time = maxf(0.0, collection_time - delta)
	if collection_time > 0.0:
		visual.set_animation(action_kind)
		var reach := sin((0.4 - collection_time) / 0.4 * PI) * -1.0
		left_arm.rotation.x = reach
		right_arm.rotation.x = reach
	visual.rotation.x = sin((0.4 - collection_time) / 0.4 * PI) * 0.18 if collection_time > 0 and action_kind == "plant" else 0.0
	visual.position.y = sin(Time.get_ticks_msec() * 0.002) * 0.012 if direction.is_zero_approx() and is_on_floor() else 0.0
