extends "res://scripts/gameplay/waste.gd"
@export var drift_speed: float = 0.0
@export var sea_line: float = -11.5

func advance_drift(delta: float, session: RecyclingSession) -> void:
	if drift_speed <= 0 or not session.active or not session.records.has(waste_id):
		return
	if session.records[waste_id]["state"] != RecyclingSession.WasteState.AVAILABLE:
		return
	position.x -= drift_speed * maxf(delta, 0.0)
	item_label.text = Config.MATERIAL_NAMES[material] + "\n→ MAR • %ds" % ceili(seconds_to_sea())
	if position.x <= sea_line:
		if session.mark_lost(waste_id):
			hide()

func seconds_to_sea() -> float:
	return maxf(0.0, position.x - sea_line) / drift_speed if drift_speed > 0 else INF
