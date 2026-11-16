extends SceneTree
const Rating = preload("res://scripts/core/performance_rating.gd")
const Progress = preload("res://scripts/core/mission_progress.gd")
var checks := 0
var failures := 0
func _initialize() -> void: call_deferred("run")
func check(ok: bool,title: String) -> void:
	checks += 1
	if not ok: failures += 1; push_error(title)
func write(path: String,data: Dictionary) -> void:
	var file := FileAccess.open(path,FileAccess.WRITE)
	file.store_string(JSON.stringify(data))
	file.close()
func run() -> void:
	for id: String in Progress.IDS:
		check(Rating.calculate(id,{"errors":0,"lost":0},false) == 0,"Derrota não ganha estrelas "+id)
		check(Rating.calculate(id,{"errors":0,"lost":0,"seconds":1},true) == 3 and Rating.calculate(id,{"errors":0,"lost":0,"seconds":299},true) == 3,"Velocidade não altera estrelas "+id)
		check(Rating.calculate(id,{"errors":Rating.TWO_STAR_ERRORS[id],"lost":0},true) == 2,"Limite inclusivo de duas estrelas "+id)
		check(Rating.calculate(id,{"errors":Rating.TWO_STAR_ERRORS[id]+1,"lost":0},true) == 1,"Conclusão garante uma estrela "+id)
	for id: String in ["itaipuacu","ponta_negra"]:
		check(Rating.calculate(id,{"errors":0,"lost":2},true) == 2 and Rating.calculate(id,{"errors":0,"lost":4},true) == 1,"Perdas influenciam avaliação sem bloquear vitória "+id)
	var path := "res://tests/artifacts/ratings_progress.json"
	write(path,{"version":2,"unlocked_level":1})
	var progress := Progress.new(path)
	check(progress.best_stars.get("aracatiba",0) == 0,"Save anterior não recebe estrelas fabricadas")
	check(progress.register_attempt("aracatiba"),"Tentativa gravada")
	var record := {"score":500,"errors":3,"correct":12,"best_streak":4}
	progress.note_outcome("aracatiba",record,true,true,2,1)
	progress.record_result("aracatiba",record)
	progress.register_attempt("aracatiba")
	record = {"score":400,"errors":0,"correct":15,"best_streak":15}
	progress.note_outcome("aracatiba",record,true,false,1,0)
	progress.record_result("aracatiba",record)
	var loaded := Progress.new(path)
	check(loaded.results.aracatiba.score == 500 and loaded.best_stars.aracatiba == 3,"Melhor estrela independe do melhor placar")
	check(loaded.attempts.aracatiba == 2 and loaded.history.aracatiba.wins == 2,"Tentativas e vitórias persistem")
	check(loaded.history.aracatiba.correct == 27 and loaded.history.aracatiba.errors == 3 and loaded.history.aracatiba.best_streak == 15,"Totais reais e melhor sequência persistem")
	check(loaded.optional_completed.aracatiba and loaded.history.aracatiba.decision_errors == 1,"Opcional mantém a melhor conclusão e erros de leitura separados")
	check(loaded.unlocked_level == 2,"Estrelas não bloqueiam próxima fase")
	loaded.note_outcome("aracatiba",{"score":0,"correct":2,"errors":4},false)
	loaded.save_progress()
	loaded = Progress.new(path)
	check(loaded.history.aracatiba.defeats == 1 and loaded.best_stars.aracatiba == 3,"Derrota não apaga classificação anterior")
	var legacy = preload("res://tests/fixtures/legacy_progress.gd").new(path)
	check(legacy.unlocked_level == 2 and legacy.total_score() == 500,"Código antigo lê o mesmo save para rollback")
	write(path,{"version":1,"unlocked_level":3,"campaign_completed":true})
	loaded = Progress.new(path)
	check(loaded.unlocked_level == 4 and loaded.best_stars.is_empty(),"Migração v1 mantém avanço sem inventar avaliação")
	write(path,{"version":2,"unlocked_level":1,"best_stars":{"aracatiba":99},"attempts":{"aracatiba":-2},"optional_completed":{"aracatiba":1},"history":{"aracatiba":{"wins":-1}}})
	loaded = Progress.new(path)
	check(loaded.best_stars.get("aracatiba",0) == 0 and loaded.attempts.get("aracatiba",0) == 0 and not loaded.optional_completed.has("aracatiba"),"Extensões inválidas são rejeitadas")
	write(path,{"version":2,"unlocked_level":1})
	var level = load("res://scenes/levels/aracatiba.tscn").instantiate()
	level.progress_path = path
	level.profile_path = "res://tests/artifacts/ratings_profile.json"
	root.add_child(level)
	current_scene = level
	level.set_physics_process(false)
	level.show_instructions()
	level.start_mission()
	check(level.progress.attempts.aracatiba == 1,"Início registra uma tentativa")
	for i in 4:
		level.set_state(level.State.PAUSADO)
		level.set_state(level.State.JOGANDO)
	check(level.progress.attempts.aracatiba == 1,"Pausa e retomada não duplicam tentativas")
	level.finish(false,"Fim de teste")
	level.finish(false,"Repetição inválida")
	check(level.progress.history.aracatiba.defeats == 1 and level.progress.unlocked_level == 1,"Resultado idempotente não libera fase na derrota")
	level.queue_free()
	await process_frame
	print("RESULT: %d verificações, %d falhas" % [checks,failures])
	quit(0 if failures == 0 else 1)
