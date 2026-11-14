class_name RecyclingSession
extends Node
## Autoridade dos estados e pontos: o visual nunca decide a recompensa.
signal changed
signal feedback(message: String, positive: bool)
signal presentation_event(event: String)
const Config = preload("res://scripts/core/game_config.gd")
enum WasteState { AVAILABLE, CARRIED, SORTED, DISCARDED_WRONG, LOST, STORED }
@export var is_training: bool = true
@export var retry_wrong: bool = false
@export var loss_message: String = "Um resíduo alcançou o mar. Priorize os itens marcados com → MAR."
var lost_count: int = 0
var active: bool = true
var records: Dictionary = {}
var drains: Dictionary = {}
var drains_cleaned: int = 0
var carried_id: String = ""
var score: int = 0
var collected: int = 0
var correct: int = 0
var errors: int = 0
var streak: int = 0

func register_waste(id: String, material: String) -> bool:
	if id.is_empty() or records.has(id) or not Config.MATERIAL_NAMES.has(material):
		return false
	records[id] = {"material": material, "state": WasteState.AVAILABLE}
	changed.emit()
	return true

func collect(id: String) -> bool:
	if not active or not carried_id.is_empty() or not records.has(id):
		return false
	if records[id]["state"] != WasteState.AVAILABLE:
		return false
	records[id]["state"] = WasteState.CARRIED
	carried_id = id
	collected += 1
	score += Config.POINTS_COLLECT
	presentation_event.emit("collect")
	feedback.emit("Coletado: %s. Leve à lixeira identificada. +%d" % [carried_material_name(), Config.POINTS_COLLECT], true)
	changed.emit()
	return true

func sort_into(material: String) -> bool:
	if not active or carried_id.is_empty() or not Config.MATERIAL_NAMES.has(material):
		return false
	if records[carried_id]["material"] != material:
		errors += 1
		presentation_event.emit("wrong")
		streak = 0
		score = maxi(0, score + Config.POINTS_WRONG)
		var material_name := carried_material_name()
		if is_training or retry_wrong:
			feedback.emit("Ainda não: este item é %s. Procure essa identificação; ele continua com você. %d pontos" % [material_name, Config.POINTS_WRONG], false)
		else:
			records[carried_id]["state"] = WasteState.DISCARDED_WRONG
			carried_id = ""
			feedback.emit("Destino incorreto: era %s. Leia o nome do coletor na próxima tentativa. %d pontos" % [material_name, Config.POINTS_WRONG], false)
		changed.emit()
		return false
	records[carried_id]["state"] = WasteState.SORTED
	carried_id = ""
	correct += 1
	streak += 1
	score += Config.POINTS_CORRECT
	presentation_event.emit("correct")
	var message := "Destino correto! +%d pontos" % Config.POINTS_CORRECT
	if streak % Config.STREAK_LENGTH == 0:
		score += Config.POINTS_STREAK
		presentation_event.emit("bonus")
		message += " • Três acertos seguidos: +%d" % Config.POINTS_STREAK
	if is_training and correct == records.size():
		message += " • Treino concluído! R para recomeçar."
	feedback.emit(message, true)
	changed.emit()
	return true

func carried_material_name() -> String:
	if carried_id.is_empty():
		return "Nenhum"
	return Config.MATERIAL_NAMES[records[carried_id]["material"]]

func cleaning_index() -> int:
	var total: int = records.size() + drains.size()
	return roundi(100.0 * (correct + drains_cleaned) / total) if total > 0 else 0

func mark_lost(id: String) -> bool:
	if not active or not records.has(id) or records[id]["state"] != WasteState.AVAILABLE:
		return false
	records[id]["state"] = WasteState.LOST
	lost_count += 1
	presentation_event.emit("wrong")
	feedback.emit(loss_message, false)
	changed.emit()
	return true

func register_drain(id: String) -> bool:
	if id.is_empty() or drains.has(id):
		return false
	drains[id] = false
	changed.emit()
	return true

func clean_drain(id: String) -> bool:
	if not active or not carried_id.is_empty() or not drains.has(id) or drains[id]:
		return false
	drains[id] = true
	drains_cleaned += 1
	score += Config.POINTS_DRAIN
	presentation_event.emit("drain")
	feedback.emit("Bueiro desobstruído na simulação! +%d. Isso reduz um fator de risco; não garante evitar enchentes." % Config.POINTS_DRAIN, true)
	changed.emit()
	return true
