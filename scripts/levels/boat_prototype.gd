extends "res://scripts/levels/aracatiba_world.gd"
func _ready() -> void:
	box("Land", Vector3(12, -0.3, 0), Vector3(8, 0.6, 38), Color("87ad7c"), true)
	box("Pier", Vector3(8, -0.125, 12), Vector3(4, 0.25, 4), Color("b6946b"), true)
	box("Water", Vector3(0, -0.22, 0), Vector3(16, 0.1, 38), Color("53adb8"))
	for x: float in [-8, 8]:
		box("Bank", Vector3(x, 0.7, 0), Vector3(0.3, 1.4, 38), Color("688c67"), true)
	for z: float in [-19, 19]:
		box("Limit", Vector3(0, 0.7, z), Vector3(16, 1.4, 0.3), Color("729e7f"), true)
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		if $Boat.pilot == null:
			$Boat.embark($Player)
		else:
			$Boat.disembark()
