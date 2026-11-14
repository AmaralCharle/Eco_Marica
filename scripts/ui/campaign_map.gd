extends Control
var completed: Array[String] = []
var revealed: float = 0.0:
	set(value):
		revealed = value
		queue_redraw()
const POSITIONS: Array[Vector2] = [Vector2(80, 110), Vector2(220, 140), Vector2(350, 75), Vector2(480, 35), Vector2(620, 115)]
func _ready() -> void:
	custom_minimum_size = Vector2(710, 180)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	create_tween().tween_property(self, "revealed", 5.0, 1.4)
func _draw() -> void:
	draw_colored_polygon(PackedVector2Array([Vector2(15, 30), Vector2(380, 5), Vector2(690, 60), Vector2(650, 170), Vector2(30, 160)]), Color("355c4d"))
	for i in range(4):
		draw_line(POSITIONS[i], POSITIONS[i+1], Color("add5c0"), 3)
	for i in mini(5, ceili(revealed)):
		var id: String = ["aracatiba", "itaipuacu", "centro", "ubatiba", "ponta_negra"][i]
		draw_circle(POSITIONS[i], 10, Color("86e0ac") if completed.has(id) else Color("667879"))
		draw_string(ThemeDB.fallback_font, POSITIONS[i] + Vector2(-45, 28), ["Araçatiba", "Itaipuaçu", "Centro", "Ubatiba", "Ponta Negra"][i], HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color.WHITE)
