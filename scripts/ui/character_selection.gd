class_name CharacterSelection
extends VBoxContainer
signal confirmed(character_id: String)
signal back_requested
const Catalog = preload("res://scripts/core/character_catalog.gd")
const VisualScene = preload("res://scenes/player/character_visual.tscn")
var pending_id: String = Catalog.DEFAULT_ID
var avatars: Dictionary = {}
var platforms: Dictionary = {}
var choice_buttons: Dictionary = {}
var description: Label
var confirm_button: Button
var error_label: Label
var rotating: bool = false
var preview: SubViewport
const Design = preload("res://scripts/ui/eco_theme.gd")

func _ready() -> void:
	add_theme_constant_override("separation", 8)
	var title := Label.new()
	title.text = "ESCOLHA SEU GUARDIÃO"
	title.add_theme_font_size_override("font_size", 27)
	add_child(title)
	var subtitle := Label.new()
	subtitle.text = "Quatro identidades • Mesmos controles, velocidade e habilidades"
	subtitle.add_theme_font_size_override("font_size", 14)
	subtitle.add_theme_color_override("font_color",Design.MUTED)
	add_child(subtitle)
	build_preview()
	var choices := HBoxContainer.new()
	choices.add_theme_constant_override("separation", 10)
	add_child(choices)
	for id in Catalog.IDS:
		var button := Button.new()
		button.text = Catalog.get_character(id)["name"]
		button.toggle_mode = true
		button.custom_minimum_size.y = 38
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.add_theme_font_size_override("font_size", 19)
		button.pressed.connect(choose.bind(id))
		choices.add_child(button)
		choice_buttons[id] = button
	description = Label.new()
	description.custom_minimum_size.y = 44
	description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	description.add_theme_font_size_override("font_size", 16)
	add_child(description)
	var rotate_button := Button.new()
	rotate_button.text = "Girar prévias • Ligar / desligar"
	rotate_button.custom_minimum_size.y = 38
	rotate_button.theme_type_variation = "QuietButton"
	rotate_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	rotate_button.pressed.connect(func():
		rotating = not rotating
		preview.render_target_update_mode = SubViewport.UPDATE_ALWAYS if rotating else SubViewport.UPDATE_ONCE
	)
	var actions := HBoxContainer.new()
	actions.add_theme_constant_override("separation",10)
	add_child(actions)
	actions.add_child(rotate_button)
	error_label = Label.new()
	error_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	error_label.modulate = Color("ffd29a")
	error_label.hide()
	add_child(error_label)
	confirm_button = Button.new()
	confirm_button.custom_minimum_size.y = 43
	confirm_button.theme_type_variation = "PrimaryButton"
	confirm_button.add_theme_font_size_override("font_size", 19)
	confirm_button.pressed.connect(func(): confirmed.emit(pending_id))
	add_child(confirm_button)
	var back := Button.new()
	back.text = "Voltar sem alterar"
	back.custom_minimum_size.y = 40
	back.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	back.add_theme_font_size_override("font_size", 18)
	back.pressed.connect(func(): back_requested.emit())
	actions.add_child(back)
	choose(pending_id)

func build_preview() -> void:
	var container := SubViewportContainer.new()
	container.custom_minimum_size = Vector2(0, 248)
	container.stretch = true
	container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(container)
	var viewport := SubViewport.new()
	preview = viewport
	viewport.name = "CharacterPreview"
	viewport.size = Vector2i(1000, 300)
	viewport.own_world_3d = true
	viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
	viewport.msaa_3d = Viewport.MSAA_2X
	container.add_child(viewport)
	var environment := WorldEnvironment.new()
	var settings := Environment.new()
	settings.background_mode = Environment.BG_COLOR
	settings.background_color = Color("18343b")
	settings.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	settings.ambient_light_color = Color("d1e9f1")
	settings.ambient_light_energy = 0.75
	environment.environment = settings
	viewport.add_child(environment)
	var light := DirectionalLight3D.new()
	light.rotation_degrees = Vector3(-45, -30, 0)
	light.light_energy = 1.0
	viewport.add_child(light)
	var camera := Camera3D.new()
	camera.position = Vector3(0, 1.8, 5)
	camera.fov = 32
	viewport.add_child(camera)
	camera.look_at(Vector3(0, 1.0, 0))
	camera.current = true
	for i in Catalog.IDS.size():
		var id: String = Catalog.IDS[i]
		var model := VisualScene.instantiate()
		model.character_id = id
		model.position.x = -3.15 + i * 2.1
		model.rotation.y = PI + 0.18
		viewport.add_child(model)
		avatars[id] = model
		var platform := MeshInstance3D.new()
		var mesh := CylinderMesh.new()
		mesh.top_radius = 0.65
		mesh.bottom_radius = 0.7
		mesh.height = 0.12
		mesh.radial_segments = 16
		var mat := StandardMaterial3D.new()
		mat.albedo_color = Color("284752")
		mesh.material = mat
		platform.mesh = mesh
		platform.position = Vector3(model.position.x, -0.06, 0)
		viewport.add_child(platform)
		platforms[id] = platform

func choose(id: String) -> void:
	pending_id = id if Catalog.valid_id(id) else Catalog.DEFAULT_ID
	if description == null:
		return
	var data := Catalog.get_character(pending_id)
	description.text = "%s • %s\n%s" % [data["name"], data["role"], data["detail"]]
	confirm_button.text = "Confirmar " + data["name"]
	error_label.hide()
	for candidate in Catalog.IDS:
		choice_buttons[candidate].set_pressed_no_signal(candidate == pending_id)
		choice_buttons[candidate].theme_type_variation = "PrimaryButton" if candidate == pending_id else "Button"
		avatars[candidate].scale = Vector3.ONE * (1.03 if candidate == pending_id else 1.0)
		platforms[candidate].mesh.material.albedo_color = Color("6dc698") if candidate == pending_id else Color("284752")
	preview.render_target_update_mode = SubViewport.UPDATE_ALWAYS if rotating else SubViewport.UPDATE_ONCE

func show_save_error() -> void:
	error_label.text = "Não foi possível salvar a escolha. A seleção anterior foi mantida; tente novamente."
	error_label.show()

func _process(delta: float) -> void:
	if rotating:
		for model in avatars.values():
			model.rotation.y += delta * 0.65
