class_name MissionProgress
extends RefCounted
## Desbloqueios e conclusão local da campanha. Resultados completos virão depois.
var unlocked_level: int = 1
var campaign_completed: bool = false
var last_error: Error = OK
var file_path: String

func _init(path: String = "user://mission_progress.json") -> void:
	file_path = path
	if not FileAccess.file_exists(file_path):
		return
	var file := FileAccess.open(file_path, FileAccess.READ)
	if file == null:
		last_error = FileAccess.get_open_error()
		return
	var parser := JSON.new()
	if parser.parse(file.get_as_text()) != OK:
		return
	var data = parser.data
	if data is Dictionary and data.get("version") == 1 and data.get("unlocked_level") is float:
		var value: float = data["unlocked_level"]
		if is_finite(value) and value == floorf(value) and value >= 1 and value <= 3:
			unlocked_level = int(value)
			if unlocked_level == 3 and data.get("campaign_completed") is bool:
				campaign_completed = data["campaign_completed"]

func unlock_next_level(next_level: int = 2) -> bool:
	if next_level < 2 or next_level > 3:
		last_error = ERR_INVALID_PARAMETER
		return false
	unlocked_level = maxi(unlocked_level, next_level)
	return save_progress()

func complete_campaign() -> bool:
	unlocked_level = 3
	campaign_completed = true
	return save_progress()

func save_progress() -> bool:
	var file := FileAccess.open(file_path, FileAccess.WRITE)
	if file == null:
		last_error = FileAccess.get_open_error()
		return false
	file.store_string(JSON.stringify({"version": 1, "unlocked_level": unlocked_level, "campaign_completed": campaign_completed}))
	file.flush()
	last_error = file.get_error()
	return last_error == OK
