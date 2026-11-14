class_name CharacterCatalog
extends RefCounted
const DEFAULT_ID: String = "lucas"
const IDS: Array[String] = ["lucas", "marina", "rafael", "bia"]
const CHARACTERS: Dictionary = {
	"lucas": {"name": "Lucas", "role": "Explorador ambiental", "detail": "Colete verde e mochila de aventura.", "outfit": Color("39976b"), "skin": Color("ba855e"), "hair": Color("4a3025"), "pants": Color("263e4c")},
	"marina": {"name": "Marina", "role": "Guardiã ambiental", "detail": "Uniforme turquesa e cabelo preso.", "outfit": Color("29abb2"), "skin": Color("d9a075"), "hair": Color("482f29"), "pants": Color("27455b")},
	"rafael": {"name": "Rafael", "role": "Agente ambiental", "detail": "Colete laranja, boné e botas.", "outfit": Color("df8c38"), "skin": Color("915c3d"), "hair": Color("252329"), "pants": Color("3c4951")},
	"bia": {"name": "Bia", "role": "Protetora da natureza", "detail": "Jaqueta roxa e cabelo cacheado.", "outfit": Color("9a67c3"), "skin": Color("8b533b"), "hair": Color("30252d"), "pants": Color("34425a")}
}
static func valid_id(value: Variant) -> bool:
	return value is String and CHARACTERS.has(value)
static func get_character(id: String) -> Dictionary:
	return CHARACTERS[id if valid_id(id) else DEFAULT_ID]
