extends Button
const Design = preload("res://scripts/ui/eco_theme.gd")
const Icon = preload("res://scripts/ui/eco_icon.gd")
var spec: Dictionary
var accessible: bool = false
var completed: bool = false
var current: bool = false
var rating: int = 0
func _ready() -> void:
	name = "Phase_"+spec.id
	theme_type_variation = "CardButton"
	custom_minimum_size.y = 76
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	disabled = not accessible
	set_meta("action_text",("Jogar • " if accessible else "Bloqueada • ")+spec.title)
	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for side: String in ["left","right"]: margin.add_theme_constant_override("margin_"+side,14)
	for side: String in ["top","bottom"]: margin.add_theme_constant_override("margin_"+side,8)
	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(margin)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation",14)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	margin.add_child(row)
	var icon := Icon.new()
	icon.kind = "lock" if not accessible else {"aracatiba":"leaf","itaipuacu":"water","centro":"city","ubatiba":"seed","ponta_negra":"boat"}[spec.id]
	icon.color = Color("7f9594") if not accessible else Design.MINT
	icon.custom_minimum_size = Vector2(38,38)
	row.add_child(icon)
	var words := VBoxContainer.new()
	words.mouse_filter = Control.MOUSE_FILTER_IGNORE
	words.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	words.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_child(words)
	var top := Label.new()
	top.text = "%02d   %s" % [spec.number,spec.short_name]
	top.add_theme_font_size_override("font_size",18)
	top.mouse_filter = Control.MOUSE_FILTER_IGNORE
	words.add_child(top)
	var description := Label.new()
	description.text = {"aracatiba":"Coleta e classificação na orla","itaipuacu":"Resgate antes de chegar ao mar","centro":"Resíduos e drenagem sob chuva","ubatiba":"Inspecione, plante e preserve","ponta_negra":"Navegue, recolha e classifique"}[spec.id]
	description.add_theme_font_size_override("font_size",13)
	description.add_theme_color_override("font_color",Design.MUTED)
	description.mouse_filter = Control.MOUSE_FILTER_IGNORE
	words.add_child(description)
	var state := Label.new()
	state.text = "CONCLUÍDA" if completed else "BLOQUEADA" if not accessible else "ATUAL" if current else "JOGAR  ›"
	if rating > 0: state.text = preload("res://scripts/core/performance_rating.gd").symbols(rating)
	state.add_theme_font_size_override("font_size",11)
	state.add_theme_color_override("font_color",Design.MINT if accessible else Color("7f9594"))
	state.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	state.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(state)
	if not accessible: words.modulate = Color(0.7,0.78,0.78,1)
