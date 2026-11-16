extends Control
## Ícones vetoriais originais, sem fontes ou texturas externas.
var kind: String = "leaf"
var color: Color = Color("a4d9b1")
func _ready() -> void:
	if custom_minimum_size == Vector2.ZERO: custom_minimum_size = Vector2(28,28)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
func _draw() -> void:
	var s: float = minf(size.x,size.y)/32.0
	draw_set_transform((size-Vector2.ONE*32*s)*0.5,0,Vector2.ONE*s)
	match kind:
		"time":
			draw_arc(Vector2(16,17),10,0,TAU,32,color,1.8,true)
			draw_line(Vector2(16,17),Vector2(16,10),color,1.8,true)
			draw_line(Vector2(16,17),Vector2(21,19),color,1.8,true)
			draw_line(Vector2(12,3),Vector2(20,3),color,2,true)
		"score":
			var points := PackedVector2Array()
			for i in 10:
				var a: float = -PI*0.5+i*TAU/10
				points.append(Vector2(16,16)+Vector2(cos(a),sin(a))*(11 if i%2==0 else 5))
			points.append(points[0]); draw_polyline(points,color,1.8,true)
		"city":
			draw_rect(Rect2(5,10,10,17),color,false,1.8)
			draw_rect(Rect2(18,5,9,22),color,false,1.8)
			for y: float in [11,16,21]: draw_line(Vector2(21,y),Vector2(24,y),color,1.8,true)
			for y: float in [15,20]: draw_line(Vector2(8,y),Vector2(12,y),color,1.8,true)
		"boat":
			draw_polyline(PackedVector2Array([Vector2(4,17),Vector2(8,25),Vector2(24,25),Vector2(28,17),Vector2(4,17)]),color,1.8,true)
			draw_line(Vector2(16,5),Vector2(16,17),color,1.8,true)
			draw_line(Vector2(8,12),Vector2(16,7),color,1.8,true)
		"water":
			for y: float in [9,16,23]:
				var points := PackedVector2Array()
				for i in 25: points.append(Vector2(4+i,y+sin(i*0.36)*1.8))
				draw_polyline(points,color,1.6,true)
		"seed":
			draw_line(Vector2(16,27),Vector2(16,13),color,1.8,true)
			draw_colored_polygon(PackedVector2Array([Vector2(16,17),Vector2(6,15),Vector2(5,7),Vector2(13,9)]),color)
			draw_colored_polygon(PackedVector2Array([Vector2(16,13),Vector2(18,5),Vector2(27,4),Vector2(24,12)]),color)
		"check":
			draw_arc(Vector2(16,16),12,0,TAU,32,color,1.8,true)
			draw_polyline(PackedVector2Array([Vector2(9,16),Vector2(14,21),Vector2(23,11)]),color,2,true)
		"lock":
			draw_rect(Rect2(7,14,18,13),color,false,1.8)
			draw_arc(Vector2(16,13),6,PI,TAU,18,color,1.8,true)
		"pause":
			draw_rect(Rect2(9,6,4,21),color); draw_rect(Rect2(19,6,4,21),color)
		_:
			draw_colored_polygon(PackedVector2Array([Vector2(7,24),Vector2(8,13),Vector2(17,6),Vector2(27,4),Vector2(24,18),Vector2(15,25)]),color)
			draw_line(Vector2(5,28),Vector2(21,11),Color("173c39"),1.5,true)
