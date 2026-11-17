extends "res://scripts/levels/aracatiba_world.gd"
var water_time: float = 0.0
var ripples: Array[Node3D] = []
func _ready() -> void:
	box("Land", Vector3(13, -0.3, 0), Vector3(10, 0.6, 40), Color("88ab7d"), true)
	box("WestBank", Vector3(-11, -0.3, 0), Vector3(6, 0.6, 40), Color("76a27a"), true)
	box("Channel", Vector3(0, -0.22, 0), Vector3(16, 0.1, 40), Color("54aeb7"))
	var pier := box("Pier", Vector3(8, -0.125, 12), Vector3(4, 0.25, 4), Color("b5946e"), true)
	# O collider continua até x=10; o tablado visível termina no gramado em x=8.
	# Duas superfícies em y=0 entre x=8 e x=10 causavam z-fighting ao caminhar.
	var deck: MeshInstance3D = pier.get_child(0)
	deck.mesh.size.x = 2.0
	deck.position.x = -1.0
	box("Bridge", Vector3(0, 3.45, -1), Vector3(18, 0.35, 2.4), Color("c4b38c"), true)
	for side: float in [-1, 1]:
		box("BridgePost", Vector3(side * 7, 1.6, -1), Vector3(0.3, 3.2, 0.35), Color("a18b6b"), true)
		var nav := box("NavigationBank", Vector3(side * 7.8, 0.8, 0), Vector3(0.3, 1.6, 40), Color("668c71"), true)
		nav.collision_layer = 16
		nav.get_child(0).hide()
	for z: float in [-19, 19]:
		var limit := box("NavigationLimit", Vector3(0, 0.8, z), Vector3(16, 1.6, 0.3), Color("6a9b84"), true)
		limit.collision_layer = 16
	for z: float in [-14, -6, 2, 10, 18]:
		palm(Vector3(17, 0, z))
		palm(Vector3(-10, 0, z))
	for z: float in [-5, 18]:
		var barrier := box("WalkingWaterLimit", Vector3(8, 0.8, z), Vector3(0.15, 1.6, 30 if z < 0 else 8), Color.WHITE, true)
		barrier.collision_layer = 8
		barrier.get_child(0).hide()
	var pier_limit := box("PierEdge", Vector3(6, 0.8, 12), Vector3(0.1, 1.6, 4), Color.WHITE, true)
	pier_limit.collision_layer = 8
	pier_limit.get_child(0).hide()
	for i in 9:
		ripples.append(box("Ripple", Vector3(-6 + (i % 3) * 6, -0.15, -16 + i * 4), Vector3(1.8, 0.02, 0.06), Color("a1d4cc")))
	label("PONTA NEGRA • OPERAÇÃO ÁGUAS LIMPAS", Vector3(11, 3.1, 7), 30)
	label("PÍER • E para embarcar perto do barco", Vector3(7.5, 2.4, 12), 27)
	label("ZONA DE SAÍDA • Perdas contam ao cruzar", Vector3(0, 2, -17.2), 24)
	recovery = Node3D.new()
	recovery.name = "Recovery"
	add_child(recovery)
	recovery.hide()
func advance_water(delta: float) -> void:
	water_time += maxf(delta, 0)
	for i in ripples.size():
		ripples[i].position.x = -6 + (i % 3) * 6 + sin(water_time * 0.5 + i) * 0.3
func recover_area() -> void:
	recovery.show()
	label("CINCO LOCAIS • UMA JORNADA DE CUIDADO", Vector3(12, 3.5, 4), 28)
