class_name MissionProgress
extends RefCounted
const IDS: Array[String] = ["aracatiba", "itaipuacu", "centro", "ubatiba", "ponta_negra"]
const METRICS: Array[String] = ["score", "collected", "correct", "errors", "lost", "drains", "assessed", "planted", "protected", "seconds"]
var unlocked_level: int = 1
var campaign_completed: bool = false
var completed_levels: Array[String] = []
var results: Dictionary = {}
var legacy_stats_missing: bool = false
var last_error: Error = OK
var file_path: String
func _init(path: String = "user://mission_progress.json") -> void:
	file_path = path
	if not FileAccess.file_exists(path):
		return
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return
	var parser := JSON.new()
	if parser.parse(file.get_as_text()) != OK or not parser.data is Dictionary:
		return
	var data: Dictionary = parser.data
	if (data.get("version") != 1 and data.get("version") != 2) or not (data.get("unlocked_level") is float or data.get("unlocked_level") is int):
		return
	var n: float = data["unlocked_level"]
	if not is_finite(n) or n != floorf(n) or n < 1 or n > (3 if data["version"] == 1 else 5):
		return
	unlocked_level = int(n)
	for i in range(unlocked_level - 1):
		completed_levels.append(IDS[i])
	if data["version"] == 1:
		# O antigo final de três fases vira desbloqueio da quarta; não inventar estatísticas.
		if unlocked_level == 3 and data.get("campaign_completed") is bool and data["campaign_completed"]:
			unlocked_level = 4
			completed_levels.append("centro")
		legacy_stats_missing = not completed_levels.is_empty()
		return
	if data.get("completed_levels") is Array:
		for id in data["completed_levels"]:
			if id in IDS and not completed_levels.has(id):
				completed_levels.append(id)
	if data.get("results") is Dictionary:
		for id in IDS:
			if not data["results"].get(id) is Dictionary:
				continue
			var record: Dictionary = {}
			for key in METRICS:
				var value = data["results"][id].get(key, 0)
				if (value is float or value is int) and is_finite(float(value)) and value >= 0 and value <= 1000000:
					record[key] = int(value)
			results[id] = record
	campaign_completed = data.get("campaign_completed") is bool and data["campaign_completed"] and completed_levels.has("ponta_negra") and unlocked_level == 5
	legacy_stats_missing = false
	for id in completed_levels:
		if not results.has(id):
			legacy_stats_missing = true
func unlock_next_level(next_level: int = 2) -> bool:
	if next_level < 2 or next_level > 5:
		return false
	unlocked_level = maxi(unlocked_level, next_level)
	return save_progress()
func complete_campaign() -> bool:
	unlocked_level = 5
	campaign_completed = true
	for id in IDS:
		if not completed_levels.has(id):
			completed_levels.append(id)
	return save_progress()
func record_result(id: String, record: Dictionary) -> bool:
	if not IDS.has(id):
		return false
	if not completed_levels.has(id):
		completed_levels.append(id)
	if not results.has(id) or record["score"] > results[id].get("score", -1):
		results[id] = record.duplicate(true)
	unlocked_level = maxi(unlocked_level, mini(5, IDS.find(id) + 2))
	if id == "ponta_negra":
		campaign_completed = true
	legacy_stats_missing = false
	for completed in completed_levels:
		if not results.has(completed):
			legacy_stats_missing = true
	return save_progress()
func total_score() -> int:
	var total: int = 0
	for record in results.values():
		total += int(record.get("score", 0))
	return total
func totals() -> Dictionary:
	var summary: Dictionary = {}
	for key in METRICS:
		summary[key] = 0
		for record in results.values():
			summary[key] += int(record.get(key, 0))
	return summary
func save_progress() -> bool:
	var temporary := file_path + ".tmp"
	var file := FileAccess.open(temporary, FileAccess.WRITE)
	if file == null:
		last_error = FileAccess.get_open_error()
		return false
	file.store_string(JSON.stringify({"version": 2, "unlocked_level": unlocked_level, "campaign_completed": campaign_completed, "completed_levels": completed_levels, "results": results, "legacy_stats_missing": legacy_stats_missing}))
	file.flush()
	last_error = file.get_error()
	file.close()
	if last_error == OK:
		last_error = DirAccess.rename_absolute(temporary, file_path)
	return last_error == OK
