class_name PlayerProfile
extends RefCounted
const Catalog = preload("res://scripts/core/character_catalog.gd")
var selected_id: String = Catalog.DEFAULT_ID
var file_path: String
var last_error: Error = OK

func _init(path: String = "user://player_profile.json") -> void:
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
	if data is Dictionary and data.get("version") == 1 and Catalog.valid_id(data.get("selected_character")):
		selected_id = data["selected_character"]

func select_character(id: String) -> bool:
	if not Catalog.valid_id(id):
		last_error = ERR_INVALID_PARAMETER
		return false
	# Grava em temporário no mesmo diretório e substitui somente após flush.
	var temporary := file_path + ".tmp"
	var file := FileAccess.open(temporary, FileAccess.WRITE)
	if file == null:
		last_error = FileAccess.get_open_error()
		return false
	file.store_string(JSON.stringify({"version": 1, "selected_character": id}))
	file.flush()
	last_error = file.get_error()
	file.close()
	if last_error != OK:
		return false
	last_error = DirAccess.rename_absolute(temporary, file_path)
	if last_error != OK:
		return false
	selected_id = id
	return true
