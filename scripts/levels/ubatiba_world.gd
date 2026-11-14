extends "res://scripts/levels/aracatiba_world.gd"
var demo_time: float = 0.0
var demo_drops: Array[Node3D] = []
func _ready() -> void:
	box("Ground", Vector3(0, -0.25, 0), Vector3(32, 0.5, 40), Color("8eae75"), true)
	box("Trail", Vector3(0, 0.01, 0), Vector3(3, 0.02, 36), Color("c6a371"))
	box("Stream", Vector3(-13, 0.02, 0), Vector3(1.5, 0.04, 36), Color("64b9bb"))
	for side: float in [-1, 1]:
		box("Boundary", Vector3(side * 15.5, 0.7, 0), Vector3(0.3, 1.4, 40), Color("5d8b66"), true)
		for z: float in [-17, -7, 3, 13]:
			palm(Vector3(side * 10, 0, z))
			var hill := box("SoftHill", Vector3(side * 20, 1, z), Vector3(9, 4, 10), Color("719263"))
			hill.rotation.z = side * 0.2
	for z: float in [-19.5, 19.5]:
		box("Boundary", Vector3(0, 0.5, z), Vector3(32, 1, 0.3), Color("729266"), true)
	label("UBATIBA • RAÍZES DA VIDA", Vector3(0, 3, -18), 42)
	label("Exposto / protegido • Demonstração simplificada", Vector3(0, 2.8, 15), 28)
	for side: float in [-1, 1]:
		box("DemoSoil", Vector3(side * 3, 0.05, 14), Vector3(3, 0.1, 2), Color("ad8656") if side < 0 else Color("4c966c"))
		for i in 8:
			var drop := box("DemoRain", Vector3(side * 3 - 0.8 + i * 0.22, 2 + i * 0.12, 14), Vector3(0.025, 0.22, 0.025), Color("91c3da"))
			demo_drops.append(drop)
		for i in 4:
			box("RunoffIllustration", Vector3(side * 3 - 0.8 + i * 0.5, 0.12, 14.5), Vector3(0.12 if side < 0 else 0.05, 0.025, 0.8 if side < 0 else 0.25), Color("a37850") if side < 0 else Color("a0c9a1"))
	recovery = Node3D.new()
	recovery.name = "Recovery"
	add_child(recovery)
	recovery.hide()
func advance_demo(delta: float) -> void:
	demo_time += maxf(delta, 0)
	for i in demo_drops.size():
		demo_drops[i].position.y = 0.3 + fposmod(2.5 - demo_time * 2 + i * 0.19, 2.5)
func recover_area() -> void:
	recovery.show()
	label("RECUPERAÇÃO LOCAL • Não elimina riscos de deslizamento", Vector3(0, 2.4, -17), 28)
