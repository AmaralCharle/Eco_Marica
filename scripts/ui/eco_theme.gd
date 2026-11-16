extends RefCounted
const INK := Color("142d32")
const TEXT := Color("eef3e9")
const MUTED := Color("b3c6c2")
const MINT := Color("a4d9b1")
const AMBER := Color("efd192")
static func frame(alpha: float = 0.88, padding: int = 18) -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = Color(0.055, 0.12, 0.14, alpha)
	box.set_corner_radius_all(16)
	box.set_border_width_all(1)
	box.border_color = Color(0.73, 0.85, 0.80, 0.14)
	box.content_margin_left = padding
	box.content_margin_right = padding
	box.content_margin_top = padding
	box.content_margin_bottom = padding
	box.shadow_color = Color(0.01, 0.025, 0.025, 0.16)
	box.shadow_size = 8
	box.shadow_offset = Vector2(0, 3)
	return box
static func build() -> Theme:
	var theme := Theme.new()
	var font := SystemFont.new()
	font.font_names = PackedStringArray(["Segoe UI", "Noto Sans", "Arial"])
	theme.default_font = font
	theme.default_font_size = 17
	for variation: String in ["Button", "PrimaryButton", "QuietButton", "CardButton"]:
		if variation != "Button": theme.set_type_variation(variation, "Button")
		for state: String in ["normal", "hover", "pressed", "disabled", "focus"]:
			var box := frame(0.9, 12)
			box.set_corner_radius_all(10)
			box.content_margin_top = 8
			box.content_margin_bottom = 8
			box.shadow_size = 0
			box.bg_color = {"normal": Color("24464b"), "hover": Color("365e5d"), "pressed": Color("467269"), "disabled": Color("1c333a"), "focus": Color(0,0,0,0)}[state]
			if variation == "PrimaryButton" and state != "focus":
				box.bg_color = {"normal": MINT, "hover": Color("b9e6c0"), "pressed": Color("8dc99f"), "disabled": Color("536c64")}[state]
			if variation == "QuietButton" and state == "normal": box.bg_color = Color(0.15,0.28,0.29,0.3)
			if variation == "CardButton" and state == "normal": box.bg_color = Color(0.14,0.25,0.27,0.72)
			if state == "focus":
				box.set_border_width_all(2)
				box.border_color = AMBER
			theme.set_stylebox(state, variation, box)
		for state: String in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color"]:
			theme.set_color(state, variation, INK if variation == "PrimaryButton" else TEXT)
		theme.set_color("font_disabled_color", variation, Color("849a98"))
	theme.set_color("font_color", "Label", TEXT)
	theme.set_stylebox("panel", "PanelContainer", frame())
	var track := StyleBoxFlat.new()
	track.bg_color = Color("365256")
	track.set_corner_radius_all(4)
	var fill := StyleBoxFlat.new()
	fill.bg_color = MINT
	fill.set_corner_radius_all(4)
	theme.set_stylebox("background", "ProgressBar", track)
	theme.set_stylebox("fill", "ProgressBar", fill)
	var slider_track := track.duplicate()
	slider_track.content_margin_top = 2
	slider_track.content_margin_bottom = 2
	var slider_fill := fill.duplicate()
	slider_fill.content_margin_top = 2
	slider_fill.content_margin_bottom = 2
	theme.set_stylebox("slider", "HSlider", slider_track)
	theme.set_stylebox("grabber_area", "HSlider", slider_fill)
	theme.set_stylebox("grabber_area_highlight", "HSlider", slider_fill)
	return theme
