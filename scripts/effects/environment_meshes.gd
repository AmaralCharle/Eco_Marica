extends RefCounted
## Malhas decorativas originais. Sem colisões; não dependem de assets externos.
static func canopy(seed_index: int = 0) -> ArrayMesh:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var rng := RandomNumberGenerator.new()
	rng.seed = 582 + seed_index * 19
	var rings: Array[PackedVector3Array] = []
	for j in 5:
		var ring := PackedVector3Array()
		var y: float = -0.48 + j * 0.24
		var radius: float = [0.16, 0.43, 0.5, 0.40, 0.08][j]
		for i in 9:
			var a := TAU * i / 9.0 + (j % 2) * 0.14
			var r := radius * rng.randf_range(0.84, 1.14)
			ring.append(Vector3(cos(a) * r, y + rng.randf_range(-0.035, 0.035), sin(a) * r))
		rings.append(ring)
	for j in 4:
		for i in 9:
			var next: int = (i + 1) % 9
			for p: Vector3 in [rings[j][i], rings[j + 1][i], rings[j][next], rings[j][next], rings[j + 1][i], rings[j + 1][next]]:
				var shade := clampf(0.87 + (p.y + 0.5) * 0.20, 0.85, 1.08)
				st.set_color(Color(shade, shade, shade, clampf(p.y + 0.6, 0.1, 1.0)))
				st.add_vertex(p)
	for i in 9:
		for p: Vector3 in [Vector3(0,0.5,0), rings[4][(i+1)%9], rings[4][i], Vector3(0,-0.5,0),rings[0][i],rings[0][(i+1)%9]]:
			st.set_color(Color(1,1,1,0.8))
			st.add_vertex(p)
	return finish(st)

static func palm_fronds() -> ArrayMesh:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for side: float in [-1, 1]:
		for i in 6:
			var t: float = i / 6.0
			var u: float = (i + 1) / 6.0
			var a := Vector3(side * t * 2.0, sin(t * PI) * 0.23 - t * t * 0.62, 0)
			var b := Vector3(side * u * 2.0, sin(u * PI) * 0.23 - u * u * 0.62, 0)
			var width: float = sin((t + 0.05) * PI) * 0.37
			var tip := (a + b) * 0.5
			for sign_value: float in [-1, 1]:
				for p: Vector3 in [a, b, tip + Vector3(-side * 0.08, -0.055, width * sign_value)]:
					st.set_color(Color(0.90 + t * 0.13, 0.90 + t * 0.13, 0.90 + t * 0.13, t))
					st.add_vertex(p)
	return finish(st)

static func tuft() -> ArrayMesh:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for i in 5:
		var a: float = i * 2.4
		var root := Vector3(cos(a) * 0.045, 0, sin(a) * 0.045)
		for p: Vector3 in [root + Vector3(-0.035, 0, 0), root + Vector3(0.035, 0, 0), Vector3(cos(a) * 0.15, 0.24 + (i % 3) * 0.055, sin(a) * 0.15)]:
			st.set_color(Color(0.9 + p.y * 0.4, 0.9 + p.y * 0.4, 0.9 + p.y * 0.4, p.y * 2.0))
			st.add_vertex(p)
	return finish(st)

static func beveled_box(size: Vector3, bevel: float = 0.05) -> ArrayMesh:
	var x := size.x * 0.5
	var z := size.z * 0.5
	var b := minf(bevel, minf(x, z) * 0.6)
	var ring: Array[Vector2] = [Vector2(-x+b,-z), Vector2(x-b,-z), Vector2(x,-z+b), Vector2(x,z-b), Vector2(x-b,z), Vector2(-x+b,z), Vector2(-x,z-b), Vector2(-x,-z+b)]
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for i in 8:
		var p := ring[i]
		var q := ring[(i + 1) % 8]
		var a := Vector3(p.x, -size.y * 0.5, p.y)
		var c := Vector3(q.x, -size.y * 0.5, q.y)
		var top_a := a + Vector3.UP * size.y
		var top_c := c + Vector3.UP * size.y
		for v: Vector3 in [a, top_a, c, c, top_a, top_c, Vector3(0,size.y*0.5,0),top_c,top_a,Vector3(0,-size.y*0.5,0),a,c]:
			st.add_vertex(v)
	return finish(st)

static func leaf() -> ArrayMesh:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var root := Vector3.ZERO
	var tip := Vector3(0, 0.03, 0.43)
	var ridge := Vector3(0, 0.075, 0.20)
	for side: float in [-1, 1]:
		var edge := Vector3(side * 0.105, 0, 0.18)
		for p: Vector3 in [root, ridge, edge, edge, ridge, tip]:
			st.set_color(Color(1,1,1,p.z))
			st.add_vertex(p)
	return finish(st)

static func trail(width: float, length: float) -> ArrayMesh:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for i in 36:
		var z: float = -length * 0.5 + length * i / 36.0
		var next_z: float = z + length / 36.0
		var x: float = sin(z * 0.22) * 0.32
		var next_x: float = sin(next_z * 0.22) * 0.32
		var w: float = width * 0.5 + sin(z * 1.2) * 0.10
		var next_w: float = width * 0.5 + sin(next_z * 1.2) * 0.10
		var a := Vector3(x - w, 0.012, z)
		var b := Vector3(x + w, 0.012, z)
		var c := Vector3(next_x - next_w, 0.012, next_z)
		var d := Vector3(next_x + next_w, 0.012, next_z)
		for p: Vector3 in [a,c,b,b,c,d]: st.add_vertex(p)
	return finish(st)

static func ground_patch(index: int) -> ArrayMesh:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for i in 12:
		var a: float = TAU * i / 12.0
		var b: float = TAU * (i + 1) / 12.0
		var p := Vector3(cos(a), 0, sin(a)) * (0.8 + sin(i * 1.7 + index) * 0.15)
		var q := Vector3(cos(b), 0, sin(b)) * (0.8 + sin((i+1) * 1.7 + index) * 0.15)
		for v: Vector3 in [Vector3.ZERO,q,p]: st.add_vertex(v)
	return finish(st)

static func landform() -> SphereMesh:
	var mesh := SphereMesh.new()
	mesh.radius = 0.5
	mesh.height = 1.0
	mesh.radial_segments = 18
	mesh.rings = 8
	return mesh

static func finish(st: SurfaceTool) -> ArrayMesh:
	st.generate_normals()
	var mesh := st.commit()
	var arrays := mesh.surface_get_arrays(0)
	var vertices: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
	var indices := PackedInt32Array()
	for i in range(0, vertices.size(), 3):
		indices.append_array(PackedInt32Array([i, i + 2, i + 1]))
	arrays[Mesh.ARRAY_INDEX] = indices
	var normals: PackedVector3Array = arrays[Mesh.ARRAY_NORMAL]
	for i in normals.size(): normals[i] = -normals[i]
	arrays[Mesh.ARRAY_NORMAL] = normals
	var corrected := ArrayMesh.new()
	corrected.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	return corrected
