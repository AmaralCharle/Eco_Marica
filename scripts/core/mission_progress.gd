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
const Rating = preload("res://scripts/core/performance_rating.gd")
var best_stars: Dictionary = {}
var attempts: Dictionary = {}
var optional_completed: Dictionary = {}
var history: Dictionary = {}
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
	load_extensions(data)

func unlock_next_level(next_level: int = 2) -> bool:
	if next_level < 2 or next_level > 5:
		return false
	unlocked_level = maxi(unlocked_level, next_level)
	return save_progress()

func load_extensions(data: Dictionary) -> void:
	for id in IDS:
		var stars = data.get("best_stars",{}).get(id,0) if data.get("best_stars",{}) is Dictionary else 0
		if (stars is int or stars is float) and is_finite(stars) and stars == floorf(stars) and stars >= 0 and stars <= 3: best_stars[id] = int(stars)
		var count = data.get("attempts",{}).get(id,0) if data.get("attempts",{}) is Dictionary else 0
		if (count is int or count is float) and is_finite(count) and count == floorf(count) and count >= 0 and count <= 1000000: attempts[id] = int(count)
		var optional_data = data.get("optional_completed",{})
		if optional_data is Dictionary and optional_data.get(id,false) is bool and optional_data.get(id,false): optional_completed[id] = true
		var history_data = data.get("history",{})
		if history_data is Dictionary and history_data.get(id) is Dictionary:
			var entry: Dictionary = {}
			for key in ["correct","errors","lost","decisions","decision_errors","wins","defeats","best_streak"]:
				var value = history_data[id].get(key,0)
				if (value is int or value is float) and is_finite(value) and value == floorf(value) and value >= 0 and value <= 1000000: entry[key] = int(value)
			history[id] = entry

func register_attempt(id: String) -> bool:
	if id not in IDS: return false
	attempts[id] = mini(1000000,int(attempts.get(id,0))+1)
	return save_progress()

func note_outcome(id: String, record: Dictionary, won: bool, optional: bool = false, decisions: int = 0, decision_errors: int = 0) -> int:
	if id not in IDS: return 0
	var stars: int = Rating.calculate(id,record,won)
	best_stars[id] = maxi(int(best_stars.get(id,0)),stars)
	if optional: optional_completed[id] = true
	var entry: Dictionary = history.get(id,{}).duplicate()
	for key in ["correct","errors","lost"]: entry[key] = mini(1000000,int(entry.get(key,0))+int(record.get(key,0)))
	entry["decisions"] = mini(1000000,int(entry.get("decisions",0))+decisions)
	entry["decision_errors"] = mini(1000000,int(entry.get("decision_errors",0))+decision_errors)
	var outcome := "wins" if won else "defeats"
	entry[outcome] = mini(1000000,int(entry.get(outcome,0))+1)
	entry["best_streak"] = maxi(int(entry.get("best_streak",0)),int(record.get("best_streak",0)))
	history[id] = entry
	return stars

func stars_total() -> int:
	var total := 0
	for value in best_stars.values(): total += int(value)
	return total
func attempts_total() -> int:
	var total := 0
	for value in attempts.values(): total += int(value)
	return total
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
	file.store_string(JSON.stringify({"version": 2, "unlocked_level": unlocked_level, "campaign_completed": campaign_completed, "completed_levels": completed_levels, "results": results, "legacy_stats_missing": legacy_stats_missing, "best_stars": best_stars, "attempts": attempts, "optional_completed": optional_completed, "history": history}))
	file.flush()
	last_error = file.get_error()
	file.close()
	if last_error == OK:
		last_error = DirAccess.rename_absolute(temporary, file_path)
	return last_error == OK
