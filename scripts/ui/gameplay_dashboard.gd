extends Control
## Apresentação somente leitura dos dados das missões. Nenhuma regra ou pontuação aqui.
const Design = preload("res://scripts/ui/eco_theme.gd")
const Icon = preload("res://scripts/ui/eco_icon.gd")
const Config = preload("res://scripts/core/game_config.gd")
var mission: Node3D
var session: RecyclingSession
var inventory_panel: PanelContainer
var last_cargo: int = -1
var status: Label
var prompt: Label
var feedback: Label
var cleaning_bar: ProgressBar
var mission_bar: ProgressBar
var time_value: Label
var score_value: Label
var clean_value: Label
var inventory_value: Label
var inventory_note: Label
var inventory_heading: Label
var context: PanelContainer
var note: Label
var material_counts: Dictionary = {}
var cargo_slots: Array[PanelContainer] = []
var inventory_icon: Control
var controls: Label

func _ready() -> void:
	name = "GameplayDashboard"
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	var spec: Dictionary = mission.definition()
	var goals := rows(panel(Control.PRESET_TOP_LEFT,Vector4(24,24,354,24),14))
	caption(goals,"MISSÃO %02d / 05" % spec.number)
	text(goals,spec.short_name,22)
	var objective := text(goals,spec.objective,13)
	objective.add_theme_color_override("font_color",Design.MUTED)
	mission_bar = bar(goals,4)
	status = text(goals,"",14)
	var materials := HBoxContainer.new()
	materials.add_theme_constant_override("separation",10)
	materials.mouse_filter = Control.MOUSE_FILTER_IGNORE
	goals.add_child(materials)
	if mission.mission_id != "ubatiba":
		for kind: String in (["paper","plastic"] if mission.mission_id == "aracatiba" else Config.MATERIAL_ORDER):
			var count := text(materials,"",12)
			count.add_theme_color_override("font_color",Config.MATERIAL_COLORS[kind].lightened(0.34))
			material_counts[kind] = count
		caption(goals,"Itens disponíveis na área",11)
	controls = caption(goals,"",12)
	var time_rows := rows(panel(Control.PRESET_TOP_RIGHT,Vector4(-292,24,-162,114),12))
	var timer_heading := HBoxContainer.new()
	timer_heading.mouse_filter = Control.MOUSE_FILTER_IGNORE
	time_rows.add_child(timer_heading)
	icon(timer_heading,"time",20)
	caption(timer_heading,"TEMPO",11)
	time_value = text(time_rows,"",30)
	var score_rows := rows(panel(Control.PRESET_TOP_RIGHT,Vector4(-150,24,-24,114),12))
	var score_heading := HBoxContainer.new()
	score_heading.mouse_filter = Control.MOUSE_FILTER_IGNORE
	score_rows.add_child(score_heading)
	icon(score_heading,"score",20)
	caption(score_heading,"PONTOS",11)
	score_value = text(score_rows,"0",30)
	var clean_rows := rows(panel(Control.PRESET_BOTTOM_LEFT,Vector4(24,-114,248,-28),12))
	caption(clean_rows,"RECUPERAÇÃO" if mission.mission_id == "ubatiba" else "LIMPEZA DA ÁREA",11)
	clean_value = text(clean_rows,"0%",24)
	clean_value.add_theme_color_override("font_color",Design.MINT)
	cleaning_bar = bar(clean_rows,5)
	inventory_panel = panel(Control.PRESET_BOTTOM_RIGHT,Vector4(-248,-114,-24,-28),12)
	var inventory_rows := rows(inventory_panel)
	var inventory_header := HBoxContainer.new()
	inventory_header.mouse_filter = Control.MOUSE_FILTER_IGNORE
	inventory_rows.add_child(inventory_header)
	inventory_icon = icon(inventory_header,"boat" if mission.mission_id == "ponta_negra" else "seed" if mission.mission_id == "ubatiba" else "leaf",20)
	inventory_heading = caption(inventory_header,"EM MÃOS",11)
	inventory_value = text(inventory_rows,"Nenhum",18)
	inventory_note = text(inventory_rows,"",12)
	inventory_note.add_theme_color_override("font_color",Design.MUTED)
	if mission.mission_id == "ponta_negra":
		var slots := HBoxContainer.new()
		slots.mouse_filter = Control.MOUSE_FILTER_IGNORE
		inventory_rows.add_child(slots)
		for i in 5:
			var slot := PanelContainer.new()
			slot.custom_minimum_size = Vector2(0,4)
			slot.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			slot.mouse_filter = Control.MOUSE_FILTER_IGNORE
			slots.add_child(slot)
			cargo_slots.append(slot)
	context = panel(Control.PRESET_BOTTOM_WIDE,Vector4(266,-108,-266,-28),12)
	context.name = "ContextPrompt"
	var context_rows := rows(context)
	prompt = text(context_rows,"",16)
	feedback = text(context_rows,"",14)
	note = text(self,spec.note,12)
	note.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	note.offset_left = 24
	note.offset_right = -24
	note.offset_top = -22
	note.offset_bottom = -2
	note.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	note.add_theme_color_override("font_outline_color",Color(0.02,0.06,0.07,0.9))
	note.add_theme_constant_override("outline_size",4)
	session.changed.connect(refresh_values)
	refresh_values()

func panel(preset: int, offsets: Vector4, padding: int = 14) -> PanelContainer:
	var result := PanelContainer.new()
	result.set_anchors_and_offsets_preset(preset)
	result.offset_left = offsets.x; result.offset_top = offsets.y
	result.offset_right = offsets.z; result.offset_bottom = offsets.w
	result.mouse_filter = Control.MOUSE_FILTER_IGNORE
	result.add_theme_stylebox_override("panel",Design.frame(0.84,padding))
	add_child(result)
	return result

func rows(parent: Node) -> VBoxContainer:
	var result := VBoxContainer.new()
	result.add_theme_constant_override("separation",3)
	result.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(result)
	return result

func text(parent: Node, value: String, size: int) -> Label:
	var result := Label.new()
	result.text = value
	result.autowrap_mode = TextServer.AUTOWRAP_OFF if parent is HBoxContainer else TextServer.AUTOWRAP_WORD_SMART
	result.add_theme_font_size_override("font_size",size)
	result.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(result)
	return result

func caption(parent: Node, value: String, size: int = 12) -> Label:
	var result := text(parent,value,size)
	result.add_theme_color_override("font_color",Design.MUTED)
	return result

func icon(parent: Node, kind: String, size: int) -> Control:
	var result := Icon.new()
	result.kind = kind
	result.custom_minimum_size = Vector2(size,size)
	parent.add_child(result)
	return result

func bar(parent: Node, height: int) -> ProgressBar:
	var result := ProgressBar.new()
	result.custom_minimum_size.y = height
	result.show_percentage = false
	result.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(result)
	return result

func refresh_values() -> void:
	score_value.text = str(session.score)
	cleaning_bar.value = session.cleaning_index()
	clean_value.text = "%d%%" % session.cleaning_index()
	match mission.mission_id:
		"centro":
			status.text = "Destinos %d/15 · Bueiros %d/3\nColetados %d · Erros %d" % [session.correct,session.drains_cleaned,session.collected,session.errors]
			mission_bar.value = (session.correct+session.drains_cleaned)/18.0*100
		"itaipuacu","ponta_negra":
			status.text = "Destinos corretos %d/20\nColetados %d · Perdas %d/5 · Erros %d" % [session.correct,session.collected,session.lost_count,session.errors]
			mission_bar.value = session.correct/20.0*100
		"ubatiba":
			status.text = "Avaliações %d/12 · Plantios %d/8\nProteções %d/3 · Erros %d/4" % [session.assessed,session.planted,session.protected_soil,session.errors]
			mission_bar.value = session.cleaning_index()
		_:
			status.text = "Coletados %d/15 · Destinados %d/15\nAcertos %d (mín. 12) · Erros %d/4" % [session.collected,session.correct+session.errors,session.correct,session.errors]
			mission_bar.value = (session.correct+session.errors)/15.0*100
	var remaining: Dictionary = {"paper":0,"plastic":0,"glass":0,"metal":0}
	for record: Dictionary in session.records.values():
		if record.state == session.WasteState.AVAILABLE: remaining[record.material] += 1
	for kind: String in material_counts:
		material_counts[kind].text = "%s %d" % [Config.MATERIAL_NAMES[kind].capitalize(),remaining[kind]]
	refresh_inventory()

func refresh_inventory() -> void:
	if mission.mission_id == "ubatiba":
		inventory_heading.text = "CUIDADO COM O SOLO"
		inventory_value.text = "E  Inspecionar"
		inventory_note.text = "Prepare · Plante · Proteja"
		return
	inventory_value.text = session.carried_material_name().capitalize()
	if mission.mission_id == "ponta_negra":
		inventory_heading.text = "BARCO" if mission.on_boat else "EM TERRA"
		inventory_note.text = "Carga %d/5 · Em mãos: %s" % [session.boat_inventory.size(),session.carried_material_name().capitalize()]
		inventory_value.text = "Carga %d / 5" % session.boat_inventory.size() if mission.on_boat else session.carried_material_name().capitalize()
		if last_cargo != session.boat_inventory.size():
			last_cargo = session.boat_inventory.size()
			for i in cargo_slots.size():
				var fill := StyleBoxFlat.new()
				fill.bg_color = Design.MINT if i < session.boat_inventory.size() else Color("365256")
				fill.set_corner_radius_all(2)
				cargo_slots[i].add_theme_stylebox_override("panel",fill)
	else:
		inventory_note.text = "Leve ao coletor identificado" if not session.carried_id.is_empty() else "E para recolher um resíduo"

func update_clock() -> void:
	var seconds: int = ceili(mission.remaining)
	controls.text = "W/S acelerar · A/D virar\nE interagir · Esc pausar" if mission.mission_id == "ponta_negra" and mission.on_boat else "WASD mover · Shift correr · Espaço pular\nE interagir · Esc pausar"
	time_value.text = "%02d:%02d" % [seconds/60,seconds%60]
	time_value.add_theme_color_override("font_color",Color("f3aa99") if seconds <= 30 else Design.AMBER if seconds <= 60 else Design.TEXT)
	refresh_inventory()
	# Cresce para cima quando uma mensagem precisa de duas ou mais linhas.
	context.offset_top = -maxf(96,context.get_combined_minimum_size().y+28)
	inventory_panel.offset_top = -maxf(114,inventory_panel.get_combined_minimum_size().y+28)
