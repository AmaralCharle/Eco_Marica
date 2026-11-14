extends CanvasLayer
## Modal reutilizável aberto somente sobre menu ou pausa.
func _ready() -> void:
	layer = 20
	var dim := ColorRect.new()
	dim.color = Color(0.01, 0.035, 0.045, 0.96)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(dim)
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dim.add_child(center)
	var rows := VBoxContainer.new()
	rows.custom_minimum_size.x = 560
	rows.add_theme_constant_override("separation", 14)
	center.add_child(rows)
	var audio := get_node("/root/GameAudio")
	text(rows, "CONFIGURAÇÕES", 28)
	for bus: String in audio.BUSES:
		var caption := text(rows, bus + " • %d%%" % roundi(audio.volumes[bus] * 100))
		var slider := HSlider.new()
		slider.min_value = 0
		slider.max_value = 1
		slider.step = 0.01
		slider.value = audio.volumes[bus]
		rows.add_child(slider)
		slider.value_changed.connect(func(value: float):
			audio.set_volume(bus, value)
			caption.text = bus + " • %d%%" % roundi(value * 100)
		)
	text(rows, "Sensibilidade da câmera")
	var mouse := HSlider.new()
	mouse.min_value = 0.25
	mouse.max_value = 2.5
	mouse.step = 0.05
	mouse.value = audio.sensitivity
	rows.add_child(mouse)
	mouse.value_changed.connect(func(value: float): audio.sensitivity = value; audio.save_settings())
	var smooth := CheckButton.new()
	smooth.text = "Suavização da câmera"
	smooth.button_pressed = audio.smoothing
	rows.add_child(smooth)
	smooth.toggled.connect(func(value: bool): audio.smoothing = value; audio.save_settings())
	var quality := OptionButton.new()
	for title: String in ["Baixo • sem sombras", "Médio • sombras próximas", "Alto • sombras e vegetação extra"]:
		quality.add_item(title)
	quality.select(audio.quality)
	rows.add_child(quality)
	quality.item_selected.connect(func(index: int): audio.quality = index; audio.save_settings())
	var message := text(rows, "Preferências locais • o progresso da campanha é preservado", 15)
	audio.preferences_changed.connect(func(): message.text = "Preferências salvas" if audio.last_save_ok else "Não foi possível salvar as preferências")
	var close := Button.new()
	close.text = "Voltar"
	close.custom_minimum_size.y = 40
	close.pressed.connect(queue_free)
	rows.add_child(close)
	close.grab_focus()

func text(parent: Node, value: String, size: int = 18) -> Label:
	var label := Label.new()
	label.text = value
	label.add_theme_font_size_override("font_size", size)
	parent.add_child(label)
	return label

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("release_mouse") and not event.is_echo():
		get_viewport().set_input_as_handled()
		queue_free()
