class_name GameConfig
extends RefCounted
## Regras compartilhadas e parâmetros das missões implementadas.
const WALK_SPEED: float = 4.0
const RUN_SPEED: float = 7.0
const JUMP_SPEED: float = 6.5
const GRAVITY: float = 20.0
const MOUSE_SENSITIVITY: float = 0.003
const CAMERA_MIN_PITCH: float = -0.9
const CAMERA_MAX_PITCH: float = 0.25

const ARACATIBA_DURATION: float = 300.0
const ARACATIBA_WASTE: int = 15
const ARACATIBA_MIN_CORRECT: int = 12
const ARACATIBA_ERROR_LIMIT: int = 4
const ITAIPUACU_DURATION: float = 240.0
const ITAIPUACU_TARGET: int = 20
const ITAIPUACU_LOSS_LIMIT: int = 5
const ITAIPUACU_DRIFT_SPEED: float = 0.06
const ITAIPUACU_DRIFT_INCREMENT: float = 0.01
const ITAIPUACU_SEA_LINE: float = -11.5
const MATERIAL_ORDER: Array[String] = ["paper", "plastic", "glass", "metal"]
const CENTRO_DURATION: float = 180.0
const CENTRO_TARGET: int = 15
const CENTRO_DRAINS: int = 3
const POINTS_DRAIN: int = 30
const STORM_RAIN_THRESHOLD: float = 0.35
const STORM_RAIN_COUNT: int = 160
const UBATIBA_DURATION: float = 300.0
const UBATIBA_PLOTS: int = 12
const UBATIBA_PLANTS: int = 8
const UBATIBA_PROTECTION: int = 3
const UBATIBA_ERROR_LIMIT: int = 4
const PLANT_POINTS: Dictionary = {"prepare": 5, "plant": 20, "protect": 15, "preserve": 5}
const PONTA_DURATION: float = 360.0
const PONTA_TARGET: int = 20
const PONTA_CAPACITY: int = 5
const PONTA_LOSS_LIMIT: int = 5
const BOAT_MAX_SPEED: float = 6.0
const BOAT_ACCELERATION: float = 3.0
const BOAT_DECELERATION: float = 4.0
const BOAT_TURN_SPEED: float = 1.5
const PONTA_EXIT_Z: float = -17.0
const POINTS_MISSION: int = 100
const INTERACTION_DISTANCE: float = 2.2
const POINTS_COLLECT: int = 5
const POINTS_CORRECT: int = 10
const POINTS_WRONG: int = -5
const STREAK_LENGTH: int = 3
const POINTS_STREAK: int = 20
const MATERIAL_NAMES: Dictionary = {"paper": "PAPEL", "plastic": "PLÁSTICO", "glass": "VIDRO", "metal": "METAL"}
const MATERIAL_COLORS: Dictionary = {"paper": Color("408bd6"), "plastic": Color("dc625d"), "glass": Color("4ba274"), "metal": Color("e2bd41")}

static func ensure_input_actions() -> void:
	var bindings: Dictionary = {
		"move_forward": KEY_W, "move_back": KEY_S,
		"move_left": KEY_A, "move_right": KEY_D,
		"return_menu": KEY_M, "interact": KEY_E, "restart_training": KEY_R, "sprint": KEY_SHIFT, "jump": KEY_SPACE, "release_mouse": KEY_ESCAPE,"field_notes":KEY_Q
	}
	for action: String in bindings:
		if not InputMap.has_action(action):
			InputMap.add_action(action)
		var event := InputEventKey.new()
		event.physical_keycode = bindings[action]
		if not InputMap.action_has_event(action, event):
			InputMap.action_add_event(action, event)
