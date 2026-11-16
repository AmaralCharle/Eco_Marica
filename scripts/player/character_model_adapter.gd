extends Node3D
## Fronteira para GLB importado como PackedScene. Não substitui o CharacterBody3D.
var model: Node3D
var animator: AnimationPlayer
var animation_map: Dictionary = {}
var last_error: String = ""
var current_state: String = ""
var requested_state: String = ""

func _ready() -> void:
	set_process(false)

func mount(scene: PackedScene, adjustment: Transform3D = Transform3D.IDENTITY) -> Node3D:
	var candidate: Node = scene.instantiate()
	if not candidate is Node3D:
		last_error = "O modelo precisa ter raiz Node3D."
		candidate.free()
		return null
	var all_nodes: Array[Node] = [candidate]
	all_nodes.append_array(candidate.find_children("*","",true,false))
	for node in all_nodes:
		if node is CollisionObject3D or node is CollisionShape3D or node is Camera3D:
			last_error = "Use um GLB apenas visual, sem corpos, colisões ou câmeras."
			candidate.free()
			return null
	model = candidate
	var alignment := Node3D.new()
	alignment.name = "Alignment"
	alignment.transform = adjustment
	add_child(alignment)
	alignment.add_child(model)
	var players := model.find_children("*","AnimationPlayer",true,false)
	if not players.is_empty(): animator = players[0]
	last_error = ""
	return model

func request_state(state: String) -> void:
	# O controlador pode emitir locomoção e ação no mesmo tick; prevalece o último.
	requested_state = state
	set_process(true)

func _process(_delta: float) -> void:
	play_state(requested_state)
	set_process(false)

func play_state(state: String) -> bool:
	current_state = state
	if animator == null: return false
	var clip: String = animation_map.get(state,state)
	if not animator.has_animation(clip):
		clip = animation_map.get("idle","idle")
		if not animator.has_animation(clip): return false
	if animator.current_animation != clip: animator.play(clip,0.15)
	return true
