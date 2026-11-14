class_name MissionDefinitions
extends RefCounted
const Config = preload("res://scripts/core/game_config.gd")
static func get_mission(id: String) -> Dictionary:
	if id == "centro":
		return {"id": id, "number": 3, "title": "ALERTA DE TEMPESTADE", "short_name": "Centro de Maricá", "duration": Config.CENTRO_DURATION, "target": Config.CENTRO_TARGET, "next_name": "Conclusão da campanha", "scene": "res://scenes/levels/centro.tscn", "objective": "15 destinos corretos • 3 bueiros • 180 segundos", "note": "Ação simulada • Reduzir obstruções não garante evitar enchentes. Evite áreas alagadas."}
	if id == "itaipuacu":
		return {"id": id, "number": 2, "title": "RESGATE DE ITAIPUAÇU", "short_name": "Itaipuaçu", "duration": Config.ITAIPUACU_DURATION, "target": Config.ITAIPUACU_TARGET, "next_name": "Centro de Maricá", "scene": "res://scenes/levels/itaipuacu.tscn", "objective": "20 destinos corretos • Menos de 5 perdas ao mar", "note": "Papel, plástico, vidro e metal • Situação fictícia • Consulte a coleta local."}
	return {"id": "aracatiba", "number": 1, "title": "OPERAÇÃO ARAÇATIBA", "short_name": "Araçatiba", "duration": Config.ARACATIBA_DURATION, "target": Config.ARACATIBA_WASTE, "next_name": "Itaipuaçu", "scene": "res://scenes/levels/aracatiba.tscn", "objective": "Colete 15 • Acerte pelo menos 12 • Até 3 erros", "note": "Papel limpo e garrafas plásticas • Situação fictícia • Consulte a coleta local."}
