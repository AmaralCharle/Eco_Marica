# Rastreabilidade — Campanha de cinco fases

O GDD fornecido é um modelo. A documentação desta versão descreve somente a fundação implementada. As seções indicam onde registrar o conteúdo no GDD final.

| Mecânica | Seção GDD | Arquivo | Classe / função | Estado | Evidência |
|---|---|---|---|---|---|
| Movimento e corrida | 6, 12, 13 | scripts/player/guardian.gd | GuardianController._physics_process | Implementado | tests/test_foundation.gd |
| Pulo e gravidade | 6, 12, 13 | scripts/player/guardian.gd | GuardianController._physics_process | Implementado | tests/test_foundation.gd |
| Câmera em terceira pessoa | 4, 6, 12 | scenes/player/guardian.tscn; scripts/player/guardian.gd | CameraPivot, SpringArm3D; _unhandled_input | Implementado | captura visual; interação humana pendente |
| Colisões | 6, 12, 13 | scenes/player/guardian.tscn; scripts/levels/foundation.gd | CollisionShape3D; box | Implementado | tests/test_foundation.gd |
| Parâmetros centralizados | 7, 12, 13 | scripts/core/game_config.gd | GameConfig | Implementado | testes de velocidades |
| Animações procedurais compartilhadas | 9, 11, 12 | scripts/player/guardian.gd; scripts/gameplay/interaction.gd | _physics_process, play_collect; interact | Implementado | Coleta e movimento para cada aparência em test_characters.gd; teste humano de fluidez pendente |
| Identificação única e estado do resíduo | 5, 6, 12, 13 | scripts/gameplay/recycling_session.gd | RecyclingSession.register_waste, collect, sort_into | Implementado | tests/test_recycling.gd: IDs vazios/duplicados, recoleta e descarte repetido |
| Interação E com alcance e linha de visão | 6, 12, 13 | scripts/gameplay/interaction.gd | RecyclingInteraction.refresh_target, has_line_of_sight, interact | Implementado | Entrada E simulada, distância e parede |
| Coleta de um item por vez | 5, 6, 13 | scripts/gameplay/recycling_session.gd | collect, carried_id | Implementado | Coleta duplicada/dois itens rejeitada |
| Classificação e correção após erro | 5, 6, 13 | scripts/gameplay/recycling_session.gd | sort_into | Implementado | Integração com ambas as lixeiras |
| Pontos, piso zero, bônus a cada três acertos | 6, 7, 13 | scripts/core/game_config.gd; scripts/gameplay/recycling_session.gd | POINTS_*, STREAK_LENGTH; sort_into | Implementado | Placar exato, sequência, erro interrompe bônus |
| Lixeiras com cor e identificação textual | 2, 11, 13 | scripts/gameplay/recycling_bin.gd; scenes/objects/recycling_bin.tscn | TrainingBin._ready, set_highlight | Implementado | Capturas recycling_initial/wrong/correct |
| Feedback e HUD contextual | 6, 11, 13 | scripts/ui/training_hud.gd | update_status, show_feedback, update_prompt | Implementado | HUD automatizado; capturas de acerto/erro |
| Índice de Limpeza | 3, 6, 13 | scripts/gameplay/recycling_session.gd | cleaning_index | Implementado no treino | 0%, 50%, 100% e ciclo completo |
| Reinício da área de treino | 6, 12, 13 | scripts/levels/foundation.gd | _unhandled_input | Implementado | R recarrega a cena e zera sessão |
| Operação Araçatiba e distribuição de 15 itens | 6, 9, 10, 13 | scenes/levels/aracatiba.tscn; scripts/levels/aracatiba.gd; scripts/levels/aracatiba_world.gd | spawn_objects; cenário procedural | Implementado | test_aracatiba.gd; capturas |
| Cronômetro de 300 segundos | 6, 7, 13 | scripts/core/game_config.gd; scripts/levels/aracatiba.gd | ARACATIBA_DURATION; advance_time | Implementado | Pausa/menu; limite zero; vitória em 299,9 s simulados |
| Vitória, derrota e bônus único | 6, 13 | scripts/levels/aracatiba.gd | evaluate_objectives; finish | Implementado | Limite 12 acertos/3 erros, quarto erro, 360/425 pontos |
| Erro consome item na missão | 5, 6, 13 | scripts/gameplay/recycling_session.gd | is_training; sort_into; DISCARDED_WRONG | Implementado | Quarto erro; item não pode ser recoletado; regressão treino |
| Menu, instruções, pausa e resultados | 6, 11, 13 | scripts/levels/aracatiba.gd; scripts/ui/mission_hud.gd | State; set_state; update_screen | Implementado, menus básicos | Entrada Esc; reinício; sete capturas |
| Recuperação visual simbólica | 9, 10, 11, 13 | scripts/levels/aracatiba_world.gd | recover_area | Implementado | Visibilidade Recovery e captura de área recuperada |
| Desbloqueio local de Itaipuaçu | 7, 12, 13 | scripts/core/mission_progress.gd | MissionProgress; unlock_next_level | Implementado somente o desbloqueio | Gravação, releitura, corrupção e preservação após derrota |
| Fase 2: praia, objetivos e quatro materiais | 5, 6, 7, 9, 10, 13 | scenes/levels/itaipuacu.tscn; scripts/levels/itaipuacu.gd; scripts/levels/itaipuacu_world.gd | spawn_objects; evaluate_objectives | Implementado | test_itaipuacu.gd; nove capturas |
| Resíduos móveis e indicador → MAR | 5, 6, 7, 13 | scripts/gameplay/drifting_waste.gd; scenes/objects/drifting_waste.tscn | advance_drift; seconds_to_sea | Implementado | Delta, pausa e interrupção após coleta |
| Perda única, limite de cinco e reposição | 5, 6, 7, 13 | scripts/gameplay/recycling_session.gd; scripts/levels/itaipuacu.gd | mark_lost; evaluate_objectives; spawn_waste | Implementado | Quatro perdas ainda permitem vitória; quinta derrota sem reposição |
| Vidro, metal e classificação corrigível | 5, 6, 11, 13 | scripts/core/game_config.gd; scripts/gameplay/waste.gd; scripts/gameplay/recycling_bin.gd; scripts/gameplay/recycling_session.gd | MATERIAL_*; retry_wrong; sort_into | Implementado | Cinco resíduos de cada material; ciclo integrado de 20 destinos |
| Transições entre fases e preservação de perfil | 6, 7, 12, 13 | scripts/levels/aracatiba.gd; scripts/core/mission_definitions.gd | open_level; transfer_paths; definition | Implementado | Bloqueio, entrada nas instruções, reinício e retorno ao menu |
| Progresso até o desbloqueio da fase 3 | 7, 12, 13 | scripts/core/mission_progress.gd | unlock_next_level | Implementado | Releitura até nível 3; repetição de fase não rebaixa progresso |
| Centro: 15 destinos e três bueiros em 180s | 5, 6, 7, 9, 10, 13 | scenes/levels/centro.tscn; scripts/levels/centro.gd | spawn_objects; advance_time; evaluate_objectives | Implementado | test_centro.gd, testes de metas independentes e ciclo integrado |
| Limpeza única de bueiros por E | 5, 6, 13 | scripts/gameplay/storm_drain.gd; scripts/gameplay/recycling_session.gd; scripts/gameplay/interaction.gd | show_cleaned; register_drain; clean_drain; interact | Implementado | ID inválido/duplicado, mãos livres, +30 único, entrada E e visual |
| Tempestade progressiva | 7, 9, 11, 13 | scripts/levels/centro_world.gd | advance_storm; build_rain; weather_text | Implementado | Intensidade 0,5; chuva visível; pausa congela céu/gotas/tempo; capturas |
| Índice combinando resíduos e bueiros | 3, 6, 13 | scripts/gameplay/recycling_session.gd | cleaning_index | Implementado | Só resíduos 83%; só bueiros 17%; ambos 100% |
| Final de campanha e estado FINALIZADO | 6, 7, 11, 12, 13 | scripts/levels/aracatiba.gd; scripts/ui/mission_hud.gd | show_campaign_completion; update_screen | Implementado | test_campaign.gd, fluxo das três fases pelos botões |
| Persistência da conclusão | 7, 12, 13 | scripts/core/mission_progress.gd | complete_campaign; save_progress | Implementado | Releitura, derrota posterior, repetição de fase e validação de booleano |
| Mensagem de redução de risco e limites da simulação | 1, 3, 8, 15, 16 | scripts/ui/mission_hud.gd; scripts/core/mission_definitions.gd; docs/escopo_e_creditos.md | Instruções, HUD e conclusão | Implementado | Capturas e referência oficial; impacto educativo ainda não medido |
| Quatro aparências com mesma física | 6, 9, 11, 12 | scripts/core/character_catalog.gd; scripts/player/character_appearance.gd; scenes/player/character_visual.tscn | CharacterCatalog; CharacterAppearance.apply_character | Implementado com modelos provisórios | Quatro identidades, movimento/corrida/pulo/cápsula e acessórios sem duplicação |
| Seleção com quatro prévias 3D | 6, 9, 11, 12 | scripts/ui/character_selection.gd; scripts/ui/mission_hud.gd | CharacterSelection; build_preview; choose; update_screen | Implementado | Confirmação de cada ID, cancelamento e seis capturas |
| Estado SELECAO_PERSONAGEM | 6, 12, 13 | scripts/levels/aracatiba.gd | show_character_selection; confirm_character; cancel_character_selection | Implementado | Tempo/interação suspensos, Esc cancela sem salvar |
| Perfil local e recuperação da escolha | 6, 12, 13 | scripts/core/player_profile.gd; scripts/player/guardian.gd; scripts/levels/aracatiba.gd | PlayerProfile; select_character; set_character | Implementado | ID inválido, ausência/corrupção, releitura, falha de escrita, aplicação no treino e missão |
| Salvamento completo (pontuação/melhores resultados/áudio/campanha) | 6, 12, 13 | — | — | Parcial: personagem, desbloqueios e conclusão salvos; pontuação/melhores resultados/áudio pendentes | Etapas futuras |

Resultados efetivos e limitações em `validacao.md`. A presença de um teste nesta tabela não significa aprovação antes de executá-lo.

Etapa 2: 35 verificações aprovadas; regressão da fundação: 16 aprovadas. Teste humano continua pendente. Ver `validacao.md`.


Etapa 3: `test_aracatiba.gd` passou em 32 verificações; regressões: 16 da fundação e 35 da reciclagem. Total: 83. Parâmetros da missão em `GameConfig`: ARACATIBA_DURATION, ARACATIBA_WASTE, ARACATIBA_MIN_CORRECT, ARACATIBA_ERROR_LIMIT e POINTS_MISSION. Regras detalhadas em `aracatiba.md`. Salvamento completo da campanha permanece parcial.


Etapa 4: 49 verificações de personagens, perfil e seleção aprovadas; regressão: 16 + 35 + 32. Total: **132 verificações**. A câmera e a cápsula permanecem no controlador compartilhado; a prévia instancia somente `character_visual.tscn`, sem física e sem captura do mouse. Detalhes em `personagens.md`.


Etapa 5: `test_itaipuacu.gd` passou em 47 verificações; regressão 16 + 35 + 32 + 49. Total **179**. Parâmetros em `GameConfig`: ITAIPUACU_DURATION, ITAIPUACU_TARGET, ITAIPUACU_LOSS_LIMIT, ITAIPUACU_DRIFT_SPEED, ITAIPUACU_DRIFT_INCREMENT e ITAIPUACU_SEA_LINE. O script de Itaipuaçu herda estados, perfil, transições e resultados do controlador de Araçatiba, sobrescrevendo cenário/objetos, tempo/deslocamento e condições de missão. A interface recebe nome e metas pela definição da missão.


Etapa 6: 34 verificações do Centro e 13 do fluxo completo de campanha; regressões 16 + 35 + 32 + 49 + 47. Total: **226 verificações aprovadas**. Parâmetros `GameConfig`: CENTRO_DURATION, CENTRO_TARGET, CENTRO_DRAINS, POINTS_DRAIN, STORM_RAIN_THRESHOLD e STORM_RAIN_COUNT. O palco da chuva usa MultiMesh; não foi medida uma meta de FPS nesta etapa.


## Expansão e correção de acesso
| Mecânica | Seções GDD | Arquivo e função | Estado | Evidência |
|---|---|---|---|---|
| Coletores em nível da rua/rampas | 6, 10, 13 | scripts/levels/centro.gd: spawn_objects; scripts/levels/centro_world.gd: _ready | Corrigido | test_centro_access.gd: 14 verificações |
| 12 avaliações de terreno | 5, 6, 13 | scripts/gameplay/restoration_session.gd: inspect, resolved, act | Implementado | test_ubatiba.gd |
| Oito plantios e três proteções | 5, 6, 7, 13 | scripts/levels/ubatiba.gd: evaluate_objectives; scripts/gameplay/planting_plot.gd: update_plot | Implementado | Teste de metas/visual; capturas Ubatiba |
| Preservação de pontos não aptos e limite de erros | 5, 6, 8, 13 | scripts/gameplay/restoration_session.gd: act; scripts/levels/ubatiba.gd: evaluate_objectives | Implementado | Quarta decisão incorreta, repetição sem pontos |
| Inspeção contextual | 6, 11, 13 | scripts/gameplay/planting_interaction.gd: interact; scripts/ui/expansion_hud.gd: refresh_inspection | Implementado | E, informações do solo e ações |
| Barco e câmera separados | 6, 10, 12, 13 | scripts/player/boat.gd: embark, disembark, _physics_process | Implementado | test_boat.gd; test_ponta_access.gd |
| Carga de cinco e descarga | 6, 13 | scripts/gameplay/canal_session.gd: store_from_boat, take_next_to_hand; scripts/levels/ponta_negra.gd: auto_unload | Implementado | test_ponta_negra.gd: quatro viagens e sexto item rejeitado |
| Saídas efetivas e reposição controlada | 6, 7, 13 | scripts/gameplay/floating_waste.gd: advance_float; scripts/levels/ponta_negra.gd: evaluate_objectives | Implementado | Sem perda antes da linha; quinta derrota; vitória após quatro |
| Migração de três para cinco fases | 7, 12, 13 | scripts/core/mission_progress.gd: _init, record_result, save_progress | Implementado | test_progress_extension.gd e test_campaign.gd |
| Encerramento, mapa e estatísticas | 6, 11, 13 | scripts/ui/mission_hud.gd: update_screen; scripts/ui/campaign_map.gd: _draw; scripts/core/mission_progress.gd: totals | Implementado | Teste de cinco fases e captura ponta_finale.png |

A expansão substitui o antigo encerramento no Centro; somente a quinta fase conclui a campanha. Seções 1–16 e regras atuais estão em `GDD_5_FASES.md`. Total da execução final: 306 verificações em 13 suítes. Detalhes e limitações em `validacao.md`.

## Upgrade 4

A extensão das regras e sua ligação a funções reais está na tabela de `VISUAL_UPGRADE_4.md`: caderno/decisões, vento, prioridade, estrelas, histórico, poses, perfis e áudio. `visual_upgrade_tasks.md` registra checkpoints e testes por tarefa. Não houve novos testes externos com alunos.


## Asset Revolution

A apresentação externa é rastreada em ASSET_REVOLUTION.md (tabela código/evidência), catalogo_assets.md e asset_manifest.json. Dados observados dentro do jogo: tests/artifacts/asset_integration_report.json. Mecânicas e placares existentes preservados; aves e novos modelos não alteram GDD lógico.

## Ponta Negra — pescadores e cinco músicas

Mapeamento código/regras/evidências em PONTA_NEGRA_PESCADORES.md. fisherman's phases e canal_fisheries acrescentam ambientação/obstáculo temporário; nenhum requisito de vitória, score ou save muda. Teste test_fisheries.gd cobre 122 limites e integrações, inclusive teclado real contra a rede e clipes no mixer. Fonte/partitura das trilhas em compose_phase_music.py e trilhas_originais.json. As poses são medidas no sinal do modificador, não fora do processamento do esqueleto.

## Living World 7 — tasks 01–02

`environmental_recovery.gd:sync_progress` liga marcos reais a setores decorativos; `start_cinematic/stop_cinematic/_input` ligam vitória a tomada de 6,5 s e saída antecipada. `recovery_garden.gd:build/reveal` constrói/revela geometria. `mission_hud.gd:set_cinematic_active` preserva resultados/controles. Evidências: `test_living_recovery.gd` (107 casos), capturas `living_720_*`/`living_1080_*`, perfil `living_performance.json`. Não há novo estado de save, critério de vitória ou bônus visual. Demais tasks do prompt permanecem explicitamente no diário `living_world_tasks.md`.
