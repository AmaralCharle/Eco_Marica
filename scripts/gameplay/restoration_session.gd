extends "res://scripts/gameplay/recycling_session.gd"
var plots: Dictionary = {}
var assessed: int = 0
var planted: int = 0
var protected_soil: int = 0

func register_plot(id: String, apt: bool, exposed: bool, reason: String) -> bool:
	if id.is_empty() or plots.has(id):
		return false
	plots[id] = {"apt": apt, "exposed": exposed, "reason": reason, "inspected": false, "prepared": false, "planted": false, "protected": false, "preserved": false}
	return true

func inspect(id: String) -> bool:
	if not active or not plots.has(id):
		return false
	plots[id]["inspected"] = true
	changed.emit()
	return true

func resolved(plot: Dictionary) -> bool:
	return (plot["planted"] and (not plot["exposed"] or plot["protected"])) if plot["apt"] else plot["preserved"]

func act(id: String, action: String) -> bool:
	if not active or not plots.has(id) or action not in ["prepare", "plant", "protect", "preserve", "exotic"]:
		return false
	var plot: Dictionary = plots[id]
	if not plot["inspected"] or resolved(plot):
		return false
	var field: String = {"prepare": "prepared", "plant": "planted", "protect": "protected", "preserve": "preserved"}.get(action, "")
	if not field.is_empty() and plot[field]:
		return false
	var appropriate: bool = (action == "prepare" and plot["apt"]) or (action == "plant" and plot["apt"] and plot["prepared"]) or (action == "protect" and plot["apt"] and plot["exposed"] and plot["planted"]) or (action == "preserve" and not plot["apt"])
	if not appropriate:
		errors += 1
		score = maxi(0, score + Config.POINTS_WRONG)
		feedback.emit("Decisão inadequada. " + plot["reason"] + " Prepare antes de plantar; proteja o solo exposto após o plantio.", false)
		changed.emit()
		return false
	plot[field] = true
	if action == "plant":
		planted += 1
	if action == "protect":
		protected_soil += 1
	score += Config.PLANT_POINTS[action]
	assessed = 0
	for value in plots.values():
		if resolved(value):
			assessed += 1
	feedback.emit({"prepare": "Ponto preparado sem remover a vegetação existente.", "plant": "Muda nativa adequada ao ponto simulado plantada.", "protect": "Cobertura aplicada ao solo exposto: proteção complementar, não garantia de estabilidade.", "preserve": "Vegetação/área não apta preservada. Nem todo ponto deve receber plantio."}[action], true)
	changed.emit()
	return true

func cleaning_index() -> int:
	return roundi(100.0 * (assessed + planted + protected_soil) / (Config.UBATIBA_PLOTS + Config.UBATIBA_PLANTS + Config.UBATIBA_PROTECTION))
