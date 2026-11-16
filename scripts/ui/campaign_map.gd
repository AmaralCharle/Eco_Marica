extends Control
var completed: Array[String] = []
var revealed: float = 0.0:
	set(value):
		revealed = value
		queue_redraw()
func _ready() -> void:
	custom_minimum_size = Vector2(710,150)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	create_tween().tween_property(self,"revealed",5.0,1.4)
func _draw() -> void:
	var positions: Array[Vector2] = []
	for i in 5:
		positions.append(Vector2(50+i*(size.x-100)/4.0,[75.0,92.0,55.0,37.0,77.0][i]))
	var land := PackedVector2Array([Vector2(12,42),Vector2(size.x*0.40,8),Vector2(size.x-12,35),Vector2(size.x-26,126),Vector2(14,119)])
	draw_colored_polygon(land,Color(0.36,0.57,0.46,0.17))
	for i in 4:
		draw_line(positions[i],positions[i+1],Color("496563"),2,true)
		if revealed > i+1:
			draw_line(positions[i],positions[i].lerp(positions[i+1],clampf(revealed-i-1,0,1)),Color("a4d9b1"),2.5,true)
	for i in mini(5,ceili(revealed)):
		var id: String = ["aracatiba","itaipuacu","centro","ubatiba","ponta_negra"][i]
		var color := Color("a4d9b1") if completed.has(id) else Color("66837a")
		draw_circle(positions[i],16,Color(0.64,0.85,0.69,0.12))
		draw_circle(positions[i],10,color)
		draw_string(get_theme_default_font(),positions[i]+Vector2(-5,5),str(i+1),HORIZONTAL_ALIGNMENT_LEFT,-1,13,Color("173d37"))
		draw_string(get_theme_default_font(),positions[i]+Vector2(-48,31),["Araçatiba","Itaipuaçu","Centro","Ubatiba","Ponta Negra"][i],HORIZONTAL_ALIGNMENT_CENTER,96,14,Color("eef3e9"))
