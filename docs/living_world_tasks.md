# Living World 7 — diário de execução

## Base e segurança — 17/11/2026

Branch `living-world-7`, base `e959a1d`, tag `checkpoint-pre-living-world-7-e959a1d`. A branch dos pescadores e suas correções ficam preservadas. Antes de editar o projeto: ZIP completo de 2.540 arquivos, incluindo arquivos não versionados/ignorados e `.godot`; arquivo testado por CRC, SHA-256 no manifesto; bundle Git de todas as referências e cópia de userdata. Backup fora do repositório, em `outputs/living-world-7/backup` do chat de trabalho. Não foram apagados arquivos, caches ou saves.

Modelo GDD original P2 (Downloads) relido em modo somente leitura, especialmente seções 3, 12–16: habilidade observável, rastreabilidade por função, métricas reais, origem/IA e teste externo. Os documentos originais não são instruções para publicar/finalizar a entrega acadêmica.

## Auditoria dos componentes reutilizáveis

| Sistema | Responsável existente | Decisão |
|---|---|---|
| Fases/estados/resultados | `scripts/levels/aracatiba.gd` e quatro subclasses | Preservar `finish`, relógios, colisões, metas e desbloqueios |
| Coleta/classificação/drenagem | `recycling_session.gd`, `canal_session.gd` | Observar `changed`; a apresentação não concede pontos |
| Recuperação do solo | `restoration_session.gd`, `planting_plot.gd` | Reutilizar estado real de cada ponto e mudas existentes |
| Arte/ambiente | `world_polish.gd`, `reference_art_pass.gd`, `asset_library.gd` | Acrescentar decoração sem collider; reutilizar assets CC0 |
| Personagens/animações | `guardian.gd`, `character_appearance.gd`, `production_character.gd` | Controlador separado; AnimationPlayer/rigs já importados, pose/remada autorais |
| Ponta Negra | `canal_fisheries.gd`, `fisherman.gd`, `boat.gd` | Preservar falas, redes, embarque e derrota em todas as bordas |
| Opcionais/decisões | `mission_evolution.gd` | Já existem cinco opcionais; aprimorar sem duplicar |
| Estrelas/histórico/saves | `performance_rating.gd`, `mission_progress.gd` | Já existem 1–3 estrelas e melhores resultados; manter migração v1/v2 |
| HUD/mapa/telas | `mission_hud.gd`, `expansion_hud.gd`, `campaign_map.gd` | Reutilizar tema e resultados; ocultação temporária apenas durante tomada pós-vitória |
| Áudio | `game_audio.gd`, cinco composições originais | Reutilizar mixer; sem vozes externas ou novas dependências |

## Sequência autorizada

Executar incrementalmente. Primeiro fechar tasks 01–02 com testes, imagens e checkpoint; as tasks seguintes são lotes posteriores e não devem ser anunciadas como prontas por constarem neste plano.

| Task | Estado | Arquivos/dependências | Verificação prevista |
|---|---|---|---|
| 01 Backup/auditoria | Concluída | Este diário, backup externo, tag/base | Git limpo em arquivos rastreados antes das edições, CRC ZIP, bundle |
| 02 Transformação/cinema | Concluída neste lote | `environmental_recovery.gd`, `recovery_garden.gd`, apresentação/HUD; estados reais da sessão | 107 casos novos; bateria 1.312/26 sem falhas; cinco tomadas em 720p/1080p; relatório `LIVING_WORLD_7_ETAPA_1.md` |
| 03 Animações | Planejada | Catálogo de clipes, AnimationPlayer/rigs atuais | Conferir clipes por personagem e transições; distinguir pose procedural de animação |
| 04 NPCs ambientais | Planejada | Percursos seguros, rigs existentes, limite/distância | Não bloquear objetivos, pausa, trajetórias, custo real |
| 05 Diálogos | Planejada | Componente comum; preservar falas/timers dos pescadores | Legibilidade, prioridade, cooldown individual e limite de sobreposição |
| 06 Secundárias | Planejada | Aprimorar `mission_evolution.gd` e persistência atual | Regras numéricas, opcionais não bloqueiam vitória |
| 07 Estrelas/conquistas | Planejada | Aprimorar `performance_rating.gd`/`mission_progress.gd` | Ações reais, melhor resultado, migração, sem exigir três estrelas |
| 08 Mapa | Planejada | Aprimorar `campaign_map.gd` | Cinco locais, bloqueios, estrelas, score, teclado e 720p/1080p |
| 09 Final da campanha | Planejada | Reutilizar cenas/estatísticas reais; task 02 | Pular, cinco vistas, progresso intacto, retorno ao menu |
| 10 UI/acessibilidade | Incremental | Tema comum; legenda/pular do cinema na task 02 | Contraste, teclado, informação textual, 720p/1080p |
| 11 Desempenho | Incremental | Medir mudanças por lote em Mobile/Intel UHD | FPS/frame time reais, sem remover objetos de missão |
| 12 Testes/balanceamento | Incremental | Novos casos mais regressões existentes | Automatizado separado de revisão visual e partida humana |
| 13 Avaliação educativa | Planejada | Ações contextualizadas e logs; não quiz isolado | Inicial/final equivalentes, acertos/erros por tipo, sem inventar aprendizagem |
| 14 GDD/rastreabilidade | Incremental | GDD de trabalho, rastreabilidade e créditos | Só documentar comportamento implementado; teste externo continua pendente |
| 15 Relatório final | Por lote | Relatório da task 02 primeiro | Arquivos, resultados medidos, limites e próximos lotes explícitos |

## Limites desta etapa inicial

Sem novos requisitos de vitória, sem substituir assets/controladores, sem finalizar DOCX/PDF/vídeo/exportação. Cenas de recuperação são simbólicas; desobstruir bueiros não garante evitar enchentes e apresentação de vegetação não representa crescimento instantâneo real. Teste externo e avaliação de aprendizagem permanecem pendentes.
