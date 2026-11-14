extends RefCounted
static func build() -> Theme:
	var theme := Theme.new()
	theme.default_font_size = 18
	for state: String in ["normal", "hover", "pressed", "disabled", "focus"]:
		var box := StyleBoxFlat.new()
		box.bg_color = {"normal": Color("1c4149"), "hover": Color("2b6260"), "pressed": Color("357e6a"), "disabled": Color("172f38"), "focus": Color(0, 0, 0, 0)}[state]
		box.set_corner_radius_all(8)
		box.content_margin_left = 14
		box.content_margin_right = 14
		box.content_margin_top = 5
		box.content_margin_bottom = 5
		if state == "focus":
			box.set_border_width_all(2)
			box.border_color = Color("b8df87")
		theme.set_stylebox(state, "Button", box)
	theme.set_color("font_color", "Button", Color("e9f4e9"))
	theme.set_color("font_disabled_color", "Button", Color("789195"))
	theme.set_color("font_color", "Label", Color("edf4e9"))
	var track := StyleBoxFlat.new()
	track.bg_color = Color("28484e")
	track.set_corner_radius_all(5)
	var fill := StyleBoxFlat.new()
	fill.bg_color = Color("85c99a")
	fill.set_corner_radius_all(5)
	theme.set_stylebox("background", "ProgressBar", track)
	theme.set_stylebox("fill", "ProgressBar", fill)
	return theme
