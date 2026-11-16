extends RefCounted
## Malhas de apresentação. Eixos: Y para cima, frente em -Z. Sem física.
static func loft(rings: Array, segments: int = 16, flat: bool = false) -> ArrayMesh:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	# Cada anel: altura, raio X, raio Z, deslocamento Z.
	for j in rings.size()-1:
		for i in segments:
			var a := TAU*i/segments
			var b := TAU*(i+1)/segments
			var r: Vector4 = rings[j]
			var s: Vector4 = rings[j+1]
			var p := Vector3(cos(a)*r.y,r.x,sin(a)*r.z+r.w)
			var q := Vector3(cos(b)*r.y,r.x,sin(b)*r.z+r.w)
			var u := Vector3(cos(a)*s.y,s.x,sin(a)*s.z+s.w)
			var v := Vector3(cos(b)*s.y,s.x,sin(b)*s.z+s.w)
			for point: Vector3 in [p,u,q,q,u,v]: st.add_vertex(point)
	for end in [0,rings.size()-1]:
		var r: Vector4 = rings[end]
		for i in segments:
			var a := TAU*i/segments
			var b := TAU*(i+1)/segments
			var points := [Vector3(0,r.x,r.w),Vector3(cos(a)*r.y,r.x,sin(a)*r.z+r.w),Vector3(cos(b)*r.y,r.x,sin(b)*r.z+r.w)]
			if end == 0: points.reverse()
			for point: Vector3 in points: st.add_vertex(point)
	if not flat: st.index()
	st.generate_normals()
	return reversed(st.commit())

static func hair_cap() -> ArrayMesh:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var rings: Array[PackedVector3Array] = []
	for j in 5:
		var row := PackedVector3Array()
		for i in 24:
			var a := TAU*i/24
			var t := j/4.0
			var base := 1.72 + maxf(0,-sin(a))*0.14
			var radius: float = [1.01,1.05,0.97,0.76,0.025][j]
			row.append(Vector3(cos(a)*0.282*radius,lerpf(base,2.005,t),sin(a)*0.248*radius+0.018))
		rings.append(row)
	for j in 4:
		for i in 24:
			var k := (i+1)%24
			for p: Vector3 in [rings[j][i],rings[j+1][i],rings[j][k],rings[j][k],rings[j+1][i],rings[j+1][k]]: st.add_vertex(p)
	st.index()
	st.generate_normals()
	return reversed(st.commit())

static func tube(points: Array[Vector3], radius: float, segments: int = 6) -> ArrayMesh:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for j in points.size()-1:
		var direction := (points[j+1]-points[j]).normalized()
		var side := direction.cross(Vector3.FORWARD).normalized()
		if side.length_squared() < 0.1: side = direction.cross(Vector3.UP).normalized()
		var up := direction.cross(side).normalized()
		for i in segments:
			var a := TAU*i/segments
			var b := TAU*(i+1)/segments
			var n := (side*cos(a)+up*sin(a))*radius
			var m := (side*cos(b)+up*sin(b))*radius
			for p: Vector3 in [points[j]+n,points[j+1]+n,points[j]+m,points[j]+m,points[j+1]+n,points[j+1]+m]: st.add_vertex(p)
	st.index()
	st.generate_normals()
	return reversed(st.commit())

static func leaf() -> ArrayMesh:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var points: Array[Vector3] = [Vector3(-0.055,-0.04,0),Vector3(0,0.065,-0.006),Vector3(0.058,0.09,0),Vector3(0.04,-0.025,0)]
	for i in [0,1,2,0,2,3]: st.add_vertex(points[i])
	st.generate_normals()
	return reversed(st.commit())

static func reversed(source: ArrayMesh) -> ArrayMesh:
	var arrays := source.surface_get_arrays(0)
	var indices: PackedInt32Array = arrays[Mesh.ARRAY_INDEX] if arrays[Mesh.ARRAY_INDEX] != null else PackedInt32Array()
	if indices.is_empty():
		for i in arrays[Mesh.ARRAY_VERTEX].size(): indices.append(i)
	for i in range(0,indices.size(),3):
		var swap := indices[i+1]
		indices[i+1] = indices[i+2]
		indices[i+2] = swap
	arrays[Mesh.ARRAY_INDEX] = indices
	var normals: PackedVector3Array = arrays[Mesh.ARRAY_NORMAL]
	for i in normals.size(): normals[i] = -normals[i]
	arrays[Mesh.ARRAY_NORMAL] = normals
	var result := ArrayMesh.new()
	result.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES,arrays)
	return result

static func tint_cheeks(source: ArrayMesh) -> ArrayMesh:
	var arrays := source.surface_get_arrays(0)
	var colors := PackedColorArray()
	for point: Vector3 in arrays[Mesh.ARRAY_VERTEX]:
		var distance := Vector2(absf(point.x)-0.175,point.y-1.61).length()
		var weight := clampf(1.0-distance/0.11,0,1)*0.35 if point.z < -0.12 else 0.0
		colors.append(Color.WHITE.lerp(Color(1,0.72,0.66),weight))
	arrays[Mesh.ARRAY_COLOR] = colors
	var result := ArrayMesh.new()
	result.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES,arrays)
	return result

static func batch(parent: Node3D) -> void:
	var groups: Dictionary = {}
	for node in parent.find_children("*","MeshInstance3D",true,false):
		var skip := false
		var ancestor: Node = node
		while ancestor != parent:
			if ancestor.has_meta("dynamic_visual"): skip = true; break
			ancestor = ancestor.get_parent()
		if skip: continue
		var mesh: Mesh = node.mesh
		var surface: Material = node.material_override
		if surface == null: surface = mesh.surface_get_material(0)
		var key: int = surface.get_instance_id()
		if not groups.has(key):
			var builder := SurfaceTool.new()
			builder.begin(Mesh.PRIMITIVE_TRIANGLES)
			groups[key] = {"builder":builder,"material":surface}
		groups[key].builder.append_from(mesh,0,parent.global_transform.affine_inverse()*node.global_transform)
		node.get_parent().remove_child(node)
		node.queue_free()
	for group: Dictionary in groups.values():
		var result := MeshInstance3D.new()
		result.name = "Surface"
		result.mesh = group.builder.commit()
		result.material_override = group.material
		parent.add_child(result)
