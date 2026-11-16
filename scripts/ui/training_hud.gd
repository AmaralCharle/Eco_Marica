extends CanvasLayer
var session: RecyclingSession
var status: Label
var prompt: Label
var message: Label
var message_time: float = 0.0

func _ready() -> void:
	session = get_parent().get_node("Session")
	var top := PanelContainer.new()
	top.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	top.offset_left = -345
	top.offset_right = -16
	top.offset_top = 16
	top.mouse_filter = Control.MOUSE_FILTER_IGNORE
	top.add_theme_stylebox_override("panel", panel_style())
	add_child(top)
	status = make_label(15)
	top.add_child(status)
	var bottom := PanelContainer.new()
	bottom.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	bottom.offset_left = 266
	bottom.offset_right = -266
	bottom.offset_top = -148
	bottom.offset_bottom = -16
	bottom.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bottom.add_theme_stylebox_override("panel", panel_style())
	add_child(bottom)
	var rows := VBoxContainer.new()
	rows.add_theme_constant_override("separation", 8)
	bottom.add_child(rows)
	prompt = make_label(17)
	rows.add_child(prompt)
	message = make_label(14)
	rows.add_child(message)
	var note := make_label(12)
	note.text = "Treino: papel limpo e garrafas plásticas • Na vida real, consulte as regras da coleta local. R: recomeçar • M: menu"
	rows.add_child(note)
	session.changed.connect(update_status)
	session.feedback.connect(show_feedback)
	get_parent().get_node("Interaction").prompt_changed.connect(update_prompt)
	update_status()

func make_label(size: int) -> Label:
	var label := Label.new()
	label.add_theme_font_size_override("font_size", size)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return label

func panel_style() -> StyleBoxFlat:
	return preload("res://scripts/ui/eco_theme.gd").frame(0.84,14)

func update_status() -> void:
	status.text = "TREINO DE CLASSIFICAÇÃO\nPontos: %d   •   Erros: %d\nColetados: %d/%d   •   Corretos: %d/%d\nLimpeza: %d%%\nEm mãos: %s" % [session.score, session.errors, session.collected, session.records.size(), session.correct, session.records.size(), session.cleaning_index(), session.carried_material_name()]

func update_prompt(text: String) -> void:
	prompt.text = text

func show_feedback(text: String, positive: bool) -> void:
	message.text = ("CERTO • " if positive else "ATENÇÃO • ") + text
	message.modulate = Color("a4efc5") if positive else Color("ffd29a")
	message_time = 7.0

func _process(delta: float) -> void:
	message_time = maxf(0.0, message_time - delta)
	if is_zero_approx(message_time):
		message.text = "Cada coleta: +5 • Destino correto: +10 • Erro: -5 • Três acertos seguidos: +20"
