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

func _ready() -> void:
	set_character(Profile.new(profile_path).selected_id)
	Config.ensure_input_actions()
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
	collection_time = 0.4

func apply_look(relative: Vector2) -> void:
	camera_pivot.rotation.y -= relative.x * Config.MOUSE_SENSITIVITY
	camera_pivot.rotation.x = clampf(camera_pivot.rotation.x - relative.y * Config.MOUSE_SENSITIVITY, Config.CAMERA_MIN_PITCH, Config.CAMERA_MAX_PITCH)

func _physics_process(delta: float) -> void:
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
	if direction.length_squared() > 0.01:
		visual.rotation.y = lerp_angle(visual.rotation.y, atan2(-direction.x, -direction.z), minf(delta * 12.0, 1.0))
		gait += delta * (13.0 if Input.is_action_pressed("sprint") else 8.0)
	var swing: float = sin(gait) * 0.5 if direction.length_squared() > 0.01 and is_on_floor() else 0.0
	left_leg.rotation.x = swing
	right_leg.rotation.x = -swing
	left_arm.rotation.x = -swing * 0.7
	right_arm.rotation.x = swing * 0.7

	collection_time = maxf(0.0, collection_time - delta)
	if collection_time > 0.0:
		var reach := sin((0.4 - collection_time) / 0.4 * PI) * -1.0
		left_arm.rotation.x = reach
		right_arm.rotation.x = reach
	visual.position.y = sin(Time.get_ticks_msec() * 0.002) * 0.012 if direction.is_zero_approx() and is_on_floor() else 0.0
