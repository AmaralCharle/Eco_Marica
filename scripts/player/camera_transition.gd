extends RefCounted
## Interpola só o transform visual; controlador e corpo continuam independentes.
static func blend(source: Camera3D, destination: Camera3D) -> void:
	var start := source.global_transform
	var local: Transform3D = destination.get_meta("blend_local", destination.transform)
	var target: Transform3D = destination.get_parent().global_transform * local
	if destination.has_meta("blend_tween"):
		var previous: Tween = destination.get_meta("blend_tween")
		if previous and previous.is_valid():
			previous.kill()
	destination.set_as_top_level(true)
	destination.set_meta("blend_local", local)
	destination.global_transform = start
	destination.current = true
	var tween := destination.create_tween()
	destination.set_meta("blend_tween", tween)
	tween.tween_property(destination, "global_transform", target, 0.45).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_callback(func():
		destination.set_as_top_level(false)
		destination.transform = local
		destination.remove_meta("blend_tween")
		destination.remove_meta("blend_local")
	)
