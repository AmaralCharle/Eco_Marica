extends "res://scripts/gameplay/waste.gd"
@export var escape_speed: float = 0.0
var origin_x: float
var float_time: float = 0.0
func _ready() -> void:
	super._ready()
	add_to_group("floating_waste")
	origin_x = position.x
	var float_art := Node3D.new()
	float_art.name = "FloatingArt"
	add_child(float_art)
	for child in get_children():
		if child is MeshInstance3D and child != marker: child.reparent(float_art)
	float_art.position.y = -0.32 if material == "paper" else -0.22 if material == "metal" else -0.13
	float_art.rotation = Vector3(0.10,0,0.12 if material != "paper" else -0.08)
	if escape_speed > 0:
		item_label.text = Config.MATERIAL_NAMES[material] + " • → SAÍDA"
func advance_float(delta: float, session: RecyclingSession) -> void:
	if not session.active or session.records[waste_id]["state"] != RecyclingSession.WasteState.AVAILABLE:
		return
	float_time += maxf(delta, 0)
	position.x = origin_x + sin(float_time * 0.4) * 0.25
	position.z -= escape_speed * maxf(delta, 0)
	if escape_speed > 0 and position.z <= Config.PONTA_EXIT_Z:
		if session.mark_lost(waste_id):
			hide()
