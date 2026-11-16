# Upgrade visual 4 — regras, integração e entrega de avaliação

Branch de avaliação: `upgrade-visual-4`. A versão anterior permanece em `main`, tag `fase-1-final` (`3fc476c`). Checkpoint inicial com a normalização local do editor: `d89078f`. O upgrade não foi mesclado na main.

## O que mudou

O projeto existente foi evoluído, preservando cinco fases, metas principais, controles físicos, câmeras, acesso aos coletores/rampas/píer e placares de referência. O Centro foi o piloto de materiais, vitrines, esquadrias, vasos, bancos e respingos de chuva. Ubatiba recebeu cobertura simbólica progressiva no plantio e material de proteção. Ponta Negra ganhou assento/encosto, boias/cintas no barco, espuma junto à água e acabamento dos resíduos flutuantes. Folhas tropicais curvas com folíolos substituem as lâminas simples de palmeiras/samambaias nas fases.

Lucas foi o piloto de articulação adicional de cotovelos e alcance para frente, depois aplicado a Marina, Rafael e Bia. As referências de braços/pernas do controlador e o adaptador GLB foram mantidos. Idle, caminhada, corrida, coleta, plantio, interação e embarque/desembarque têm poses visuais diferenciadas; isso não equivale a um rig deformável ou a animações artísticas externas.

Menu/resultados têm limite de altura e rolagem que acompanha foco. HUD e modais foram validados em 1280×720 e 1920×1080. Foram acrescentados opcionais, estrelas, tentativas, melhor sequência e informações de planejamento, sem retirar os contadores principais.

## Novas decisões ambientais

Q abre o caderno durante a missão. Ele pausa o prazo e as interações; Esc retorna uma única vez. Respostas erradas são registradas como revisões de leitura, sem alterar pontos ou erros da missão principal. As opções têm ordem determinística variável; empates de prioridade são aceitos.

| Fase | Dinâmica | Opcional da fase |
|---|---|---|
| Araçatiba | Duas garrafas têm rótulo de papel removível. Identificar a separação retira a faixa visual; o corpo plástico continua sendo uma das 15 unidades. O rótulo não adiciona coleta/pontos. Consultar a coleta local continua necessário. | Preparar a embalagem composta no caderno |
| Itaipuaçu | Brisa lateral z = origem + sin(tempo × 0,25) × 0,45 m, apenas nos itens que já se moviam. A velocidade rumo ao mar e os prazos não aumentam; item coletado para de se mover. | Cinco destinos corretos antes de qualquer perda |
| Centro | Exposição ilustrativa = arredondamento da soma de 10 × max(0, 7 − distância em metros) para resíduos ainda disponíveis. Os mais próximos pesam mais. Bueiros têm número e indicação de prioridade. Não é previsão de enchentes. | Limpar um dos bueiros de maior exposição no momento da ação |
| Ubatiba | Ler o laudo do ponto mais próximo e distinguir solo exposto, ponto apto e cobertura a preservar. A leitura opcional não substitui E nem as 12 avaliações/8 plantios/3 proteções. | Responder corretamente à leitura do laudo |
| Ponta Negra | HUD/caderno mostram vagas, distância em linha reta ao píer, carga e tempo. Distância não é uma rota garantida; é preciso respeitar margens e acesso original. | Descarregar após transportar pelo menos quatro itens em uma viagem |

Opcionais não são requisitos de vitória e não concedem pontos duplicados. Podem ser concluídos mesmo em uma tentativa que depois termine em derrota; a melhor conclusão opcional permanece registrada. A principal continua exigindo os objetivos originais.

## Estrelas

Uma estrela exige vitória. Três exigem zero erros e, nas fases aquáticas/de praia, zero perdas. Duas usam os seguintes limites inclusivos:

| Fase | Erros máximos para 2 estrelas | Perdas máximas |
|---|---:|---:|
| Araçatiba | 2 | não se aplica |
| Itaipuaçu | 2 | 2 |
| Centro | 2 | não se aplica |
| Ubatiba | 1 | não se aplica |
| Ponta Negra | 2 | 2 |

Uma vitória fora desses limites continua recebendo uma estrela e liberando a próxima fase. Não há nota extra por velocidade, exigência de correr ou bloqueio por estrelas. Revisões do caderno não reduzem a avaliação principal. Melhor estrela e melhor pontuação são preservadas de forma independente.

## Estatísticas e save

Tentativa é registrada ao iniciar ou reiniciar a missão; pausar/retomar não duplica. Vitórias/derrotas encerradas acumulam classificações, erros, perdas, leituras/revisões e melhor sequência de destinos corretos. Tentativas abandonadas contam como tentativas, sem inventar um resultado ou total de ações concluídas. Os totais da campanha de melhores resultados continuam separados do histórico de tentativas.

O JSON permanece versão 2, com campos aditivos `best_stars`, `attempts`, `optional_completed`, `history`. Perfil e preferências continuam em arquivos independentes. Versões 1 e 2 antigas mantêm desbloqueios/resultados; não recebem estrelas ou tentativas históricas fabricadas. O teste usa uma cópia do leitor antigo para comprovar leitura do save ampliado. Ao jogar uma versão antiga, ela poderá ignorar e regravar sem as extensões novas; faça cópia do save atual antes de uma volta definitiva. O backup pré-upgrade contém os saves existentes antes da evolução.

## Renderização, desempenho e memória

Foram medidos Mobile, Compatibility e Forward+ na branch, sem trocar permanentemente o renderizador. Mobile foi mantido: aproximadamente 63–85 FPS nas amostras iniciais; Forward+ ficou em cerca de 43–47, com maior working set; Compatibility oscilou mais no p95. Não houve benefício visual suficiente para justificar a troca no notebook.

Perfis finais: Baixo usa 3D a 80%, UI nativa, sem sombras e menos decoração/efeitos; Médio usa 3D nativo/MSAA 2× e sombras próximas; Alto usa 3D nativo/MSAA 8×, sombras de 4096, quatro cascatas e mais vegetação/efeitos. Alvos e mecânicas permanecem disponíveis em todos. Fontes decorativas estáticas são liberadas após o agrupamento; nós físicos e animados são preservados.

As vistas finais Alto ficaram em aproximadamente 61–81 FPS médios, em 1280×720 na Intel UHD; cargas de cena de cerca de 0,6–2,0 s depois de iniciar o motor. Detalhes por fase/perfil e p95 em `visual_upgrade_audit.md` e `tests/artifacts/upgrade_final_*.json`. Inicialização do motor, primeira importação, cache frio, bateria/temperatura e outras aplicações não estão cobertos por essas medidas. 1080p foi validado para layout, sem promessa de 60 FPS nessa resolução.

Quatro ciclos gráficos das cinco fases retornaram a 18 nós e zero órfãos, com RSS entre 889 e 900 MiB, sem crescimento contínuo. O fechamento suave aguardou o mixer e terminou sem avisos nesse ensaio. Alguns testes headless com quit imediato ainda podem registrar avisos de AudioStreamWAV/PlaybackWAV. Não se declara prova universal de ausência de vazamentos ou 30/60 FPS mínimos durante uma partida humana completa.

## Rastreabilidade

| Recurso | Arquivo / função | Evidência |
|---|---|---|
| Caderno e opcionais | `mission_evolution.gd`: make_question, open_notebook, answer, on_changed | test_evolution, capturas upgrade_*_notebook |
| Composição removível | Mesmo script: prepare_compounds | Dois exemplos e meta de 15 preservados |
| Vento limitado | `drifting_waste.gd`: advance_drift | Prazo até o mar preservado; coleta interrompe vento |
| Prioridades de bueiro | `mission_evolution.gd`: exposure, priorities; `storm_drain.gd`: set_highlight | Ranking usa distância real e mantém identificação |
| Estrelas | `performance_rating.gd`: calculate | test_ratings, limites inclusivos e sem critério de velocidade |
| Persistência/histórico | `mission_progress.gd`: load_extensions, register_attempt, note_outcome | Leitor antigo, migração e notas independentes do score |
| Integração ao resultado | `aracatiba.gd`: begin_attempt, finish; `mission_hud.gd`: build_results/build_finale | Campanha completa e resultados idempotentes |
| Cotovelos | `character_appearance.gd`: build_elbows, _process | Piloto Lucas, quatro identidades, 93 verificações visuais |
| Centro e respingos | `upgrade_visuals.gd`, shaders stylized_glass/rain_splash | Captura e testes de acesso |
| Recuperação simbólica | `planting_plot.gd`: update_plot | Objetivos 12/8/3 e cobertura visual |
| Barco e resíduos | `boat_polish.gd`, `floating_waste.gd` | Testes de embarque, descarga e física |
| Perfis e memória | `world_polish.gd`: apply_quality/merge_instances; `game_audio.gd`: request_quit | Profile_upgrade e check_memory_cycles |
| Feedback original | `generate_upgrade_audio.py`, três WAV | Sem amostras externas; mixer e controles preservados |

## Validação e limites de entrega

Resultado final executado: 968 verificações em 22 suítes, zero falhas e nenhuma mensagem ERROR/SCRIPT ERROR nos logs finais. Resumo: `tests/artifacts/validation_summary.json`. A captura final percorre as cinco fases e obtém vitórias/3 estrelas por ações de sessão e navegação, em dois tamanhos de janela. São dados automatizados de teste, com tempo/reposicionamento controlados; não são estatísticas do autor nem teste externo com alunos.

Antes de aprovar a experiência, jogar as cinco fases com mouse/teclado, conferir a dificuldade do vento e barco, ler o caderno em 720p/1080p, ouvir a mixagem com fones/alto-falantes, testar saves reais copiados e realizar uma sessão longa para observar temperatura e fluidez. Esses testes humanos não foram inventados.

GLBs com topologia/rigs/animações artísticos, fachadas e props modelados, vegetação por espécie e texturas autorais ainda são dependências externas para um salto artístico maior. Nenhum modelo de origem desconhecida foi importado. O projeto continua procedural, com estrutura GLB preparada. Esta etapa não produz a entrega acadêmica final DOCX/PDF, vídeo ou exportação Windows.

## Origem dos recursos

Malhas, shaders e três novos WAV são originais do projeto, produzidos com assistência Codex. Os sons usam síntese matemática, não samples comerciais. Os 34 sons anteriores permanecem, totalizando 37 WAV. Não foram incorporadas imagens das referências, modelos protegidos ou assets de origem desconhecida. Créditos e uso de IA em `ASSETS_E_CREDITOS.md`.
