extends RefCounted
const Shapes = preload("res://scripts/effects/environment_meshes.gd")
## Relevo de fundo, sem colisões: picos assimétricos e vales em vez de elipsoides.
static func ridge(seed_index: int = 0) -> ArrayMesh:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for z in 12:
		for x in 24:
			for corner: Vector2i in [Vector2i(0,0),Vector2i(0,1),Vector2i(1,0),Vector2i(1,0),Vector2i(0,1),Vector2i(1,1)]:
				var u := (x+corner.x)/24.0-0.5
				var v := (z+corner.y)/12.0-0.5
				var envelope := pow(maxf(0.0,1.0-pow(u*2,2)),0.65)*maxf(0,1.0-pow(v*2,2))
				var peaks := 0.67+0.12*sin(u*6.5+seed_index*1.7)+0.055*cos(u*11-v*3+seed_index)
				var height := envelope*peaks
				var shade := 0.84+height*0.21+sin(u*17+v*9)*0.025
				st.set_color(Color(shade,shade,shade,1))
				st.add_vertex(Vector3(u,height,v))
	return Shapes.finish(st)

static func rural_ground() -> ArrayMesh:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	# Só a pele visual abre o riacho; o chão físico original continua intacto.
	for span: Vector2 in [Vector2(-16,-13.75),Vector2(-12.25,16)]:
		for p: Vector3 in [Vector3(span.x,0.25,-20),Vector3(span.x,0.25,20),Vector3(span.y,0.25,-20),Vector3(span.y,0.25,-20),Vector3(span.x,0.25,20),Vector3(span.y,0.25,20)]:
			st.add_vertex(p)
	return Shapes.finish(st)

static func blossom() -> ArrayMesh:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for i in 5:
		var a := TAU*i/5
		var center := Vector3(cos(a)*0.08,0.015,sin(a)*0.08)
		var tip := Vector3(cos(a)*0.17,0.035,sin(a)*0.17)
		var side := Vector3(-sin(a),0,cos(a))*0.055
		for p: Vector3 in [Vector3.ZERO,center+side,tip,Vector3.ZERO,tip,center-side]: st.add_vertex(p)
	return Shapes.finish(st)
