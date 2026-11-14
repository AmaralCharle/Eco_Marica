extends SceneTree
const Progress = preload("res://scripts/core/mission_progress.gd")
var failures := 0
var checks := 0
func _initialize() -> void:
	call_deferred("run")
func check(ok: bool, title: String) -> void:
	checks += 1
	if ok:
		print("PASS: ", title)
	else:
		failures += 1
		push_error(title)
func run() -> void:
	var path := "res://tests/artifacts/progress_extension.json"
	var file := FileAccess.open(path, FileAccess.WRITE)
	file.store_string('{"version":1,"unlocked_level":3,"campaign_completed":true}')
	file.close()
	var progress := Progress.new(path)
	check(progress.unlocked_level == 4 and progress.completed_levels.size() == 3 and progress.total_score() == 0 and not progress.campaign_completed, "Migra final de três fases sem fabricar resultados")
	check(progress.record_result("ubatiba", {"score":365,"planted":8,"protected":3,"assessed":12}), "Grava resultado real da quarta fase")
	check(Progress.new(path).unlocked_level == 5 and not Progress.new(path).campaign_completed, "Nova gravação versão 2 preserva migração e libera quinta")
	progress.record_result("ubatiba", {"score":100,"planted":8})
	check(progress.total_score() == 365, "Repetição pior não aumenta nem rebaixa soma")
	progress.record_result("ponta_negra", {"score":520,"correct":20,"lost":0})
	check(progress.campaign_completed and Progress.new(path).campaign_completed and progress.total_score() == 885, "Conclusão soma apenas resultados realmente registrados")
	check(progress.legacy_stats_missing, "Final informa ausência de estatísticas antigas")
	check(not progress.record_result("unknown", {"score":999}), "Missão desconhecida não entra no placar")
	var loaded := Progress.new(path)
	check(loaded.totals()["planted"] == 8 and loaded.totals()["correct"] == 20, "Estatísticas recarregadas não duplicam ações")
	print("RESULT: %d verificações, %d falhas" % [checks, failures])
	quit(0 if failures == 0 else 1)
