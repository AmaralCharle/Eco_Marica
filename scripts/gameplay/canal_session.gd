extends "res://scripts/gameplay/recycling_session.gd"
var boat_inventory: Array[String] = []
func store_from_boat(id: String) -> bool:
	if not active or boat_inventory.size() >= Config.PONTA_CAPACITY or not records.has(id) or records[id]["state"] != WasteState.AVAILABLE:
		return false
	records[id]["state"] = WasteState.STORED
	boat_inventory.append(id)
	collected += 1
	score += Config.POINTS_COLLECT
	presentation_event.emit("collect")
	feedback.emit("Recolhido para a carga: %d/5. %s" % [boat_inventory.size(), "Barco cheio: retorne ao píer." if boat_inventory.size() == 5 else "Continue a coleta ou retorne ao píer."], true)
	changed.emit()
	return true
func take_next_to_hand() -> bool:
	if not active or not carried_id.is_empty() or boat_inventory.is_empty():
		return false
	carried_id = boat_inventory.pop_front()
	records[carried_id]["state"] = WasteState.CARRIED
	presentation_event.emit("unload")
	feedback.emit("Descarga: em mãos %s. Classifique; o próximo item da carga virá em seguida." % carried_material_name(), true)
	changed.emit()
	return true
