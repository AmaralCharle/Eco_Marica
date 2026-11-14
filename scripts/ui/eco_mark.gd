extends Control
func _ready() -> void:
	custom_minimum_size = Vector2(52, 52)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
func _draw() -> void:
	draw_circle(Vector2(26, 26), 25, Color("3e7e66"))
	var points := PackedVector2Array([Vector2(14, 36), Vector2(14, 23), Vector2(25, 13), Vector2(40, 10), Vector2(36, 27), Vector2(24, 35)])
	draw_colored_polygon(points, Color("b7de81"))
	draw_line(Vector2(12, 40), Vector2(32, 19), Color("eff5cf"), 2.5, true)
