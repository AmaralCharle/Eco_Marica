# Upgrade visual 4 — tarefas rastreáveis

Branch: `upgrade-visual-4`. Base aprovada: `3fc476c` (tag `fase-1-final`, publicada). Checkpoint com normalização local do editor: `d89078f`. Main permanece preservada. Fonte do escopo: prompt 4.0 fornecido pelo autor nesta conversa.

| Task | Estado | Escopo / evidência |
|---|---|---|
| 01 Backup, branch e auditoria | validada | ZIP da base, patch da configuração, arquivos locais e saves preservados fora do repositório; branch/tag publicadas |
| 02 Medição e renderizador | validada | `tests/profile_upgrade.gd`, três renderizadores, cinco fases, FPS/p95/carga/RSS/VRAM/inventário |
| 03 HUD e problemas visuais | validada | 720p/1080p, espaço para novas informações, menus e modais |
| 04 Piloto Centro | validada | Materiais, arquitetura, vegetação, tempestade |
| 05 Ubatiba | validada | Ambiente rural e recuperação simbólica |
| 06 Ponta Negra | validada | Água, barco e margens |
| 07 Araçatiba/Itaipuaçu | validada | Coerência entre as cinco fases |
| 08 Personagens/animações | validada | Um modelo primeiro; articulação visual e estados existentes |
| 09 Áudio/efeitos | validada | Complementos originais, volume e sobreposição |
| 10 Decisões ambientais | validada | Composição, vento, prioridade de bueiros, solo e rota |
| 11 Estrelas/opcionais | validada | Critérios numéricos, sem bloquear progressão |
| 12 Estatísticas/resultados | validada | Tentativas e melhores avaliações, migração compatível |
| 13 Perfis/otimização | validada | Baixo/Médio/Alto; cargas e memória |
| 14 Regressão completa | pendente | Cinco fases, saves próprios; revisão gráfica e limites |
| 15 GDD/rastreabilidade/créditos | pendente | Documentar somente o implementado e validado |

## Rollback

A versão anterior continua em `main`/`fase-1-final`. Após salvar o trabalho da branch, parar o jogo com F8 e abrir um checkout de `fase-1-final` ou trocar para `main`; não usar reset/clean. Uma alternativa que mantém os dois projetos é `git worktree add <pasta-vazia> fase-1-final`. Fechar/reabrir o editor no projeto escolhido evita instâncias antigas em execução.

Backup local: pasta `outputs/upgrade-visual-4/backup_pre_upgrade` do chat. Contém ZIP de 62.385.558 bytes da base aprovada, patch da alteração local do editor, cópia dos arquivos não versionados e saves existentes. Os arquivos originais não foram apagados. A evolução dos saves deverá conservar leitura pela versão 2 ou incluir cópia independente antes de qualquer migração incompatível.

### TASK 03

Painéis de menu/resultados agora possuem limite de altura e rolagem que acompanha o foco do teclado, preservando o conteúdo. `test_resolutions.gd`: 110 verificações em 1280×720 e 1920×1080 nas cinco fases; `test_interface.gd`: 226 verificações, sem falhas. Arquivos: `scripts/ui/mission_hud.gd`, `tests/test_resolutions.gd`.

### TASK 04 — validada

Centro piloto: vitrines, esquadrias, bancos, vasos, materiais e 64 respingos limitados por qualidade. Arquivos: upgrade_visuals.gd, world_polish.gd, environment_surface.gdshader, stylized_glass.gdshader, rain_splash.gdshader. Testes: Centro 34 e acesso 14 sem falhas; captura Vulkan de céu claro/tempestade/café sem erros de shader.

### TASK 05 — validada

Ubatiba: cobertura vegetal agrupada aparece progressivamente após plantio, e proteção ganha material de cobertura orgânica. Mantidas avaliações 12/plantios 8/proteções 3. Arquivos: planting_plot.gd e environment_surface.gdshader. Teste Ubatiba: 18 verificações sem falhas. Crescimento é feedback simbólico; arte de terreno e vegetação existente foi preservada.

### TASK 06 — validada

Ponta Negra: assento, encosto, boias e cintas no barco, espuma junto à água e resíduos flutuantes com acabamento e altura visual revistos. Arquivos: boat_polish.gd, floating_waste.gd, waste.gd. Mantidas física, posições lógicas, capacidade e controle. Ponta Negra: 20 verificações sem falhas; captura final ainda será realizada na TASK 14.

### TASK 07 — validada

Araçatiba e Itaipuaçu compartilham os materiais do piloto e novas folhas de palmeira com folíolos curvos, também usadas em samambaias. A malha tem cor/vento graduais e mantém troncos/colisões. Arquivo: environment_meshes.gd. Testes: Araçatiba 32 e Itaipuaçu 47, sem falhas.

### TASK 08 — validada

Lucas recebeu cotovelos primeiro, com 57 verificações e captura de ação/corrida/barco. Depois Marina, Rafael e Bia receberam o mesmo padrão, mantendo pivôs externos e controlador. Estados idle/walk/run/collect/plant/interact/embark/disembark exercitados; suporte GLB preservado. Arquivos: character_appearance.gd e test_character_visuals.gd. Validação final da tarefa: 93 verificações de visual e 49 de personagens sem erros de script.

### TASK 09 — validada

Áudio existente inspecionado: mixer por buses, pool de 12 vozes e volume preservados. Três feedbacks originais curtos (decision/optional/stars) gerados por generate_upgrade_audio.py, prontos para integrar nas tarefas seguintes. Streams de efeitos terminados são liberados; fechamento pelo menu/janela aguarda o mixer. Teste áudio 17 verificações sem falhas. Avisos de encerramento imediato dos testes ainda serão auditados em memória na TASK 13; não se declara ausência irrestrita de vazamentos.

### TASK 10 — validada

Decisões por Q com tempo pausado e erros separados da missão principal. Araçatiba: partes removíveis de duas embalagens, sem alterar a meta de quinze. Itaipuaçu: vento lateral determinístico até 0,45 m, sem acelerar ida ao mar. Centro: prioridade por resíduos disponíveis num raio de 7 m, empates aceitos. Ubatiba: leitura do laudo do ponto mais próximo. Ponta: distância ao píer e vagas para planejar lotes. Arquivos: mission_evolution.gd, aracatiba.gd, game_config.gd, gameplay_dashboard.gd, drifting_waste.gd. Testes: evolução 47, campanha 18, resoluções 110 sem falhas; placares originais da campanha preservados.

### TASK 11 — validada

Estrelas: vitória garante 1; 2 com até 2 erros e até 2 perdas (Ubatiba até 1 erro); 3 sem erros/perdas. Tempo adicional e decisões opcionais não reduzem nota; estrelas não bloqueiam fases. Melhor nota independente do score; objetivos opcionais persistidos. Schema permanece versão 2 com campos aditivos. Arquivos: performance_rating.gd, mission_progress.gd, aracatiba.gd, recycling_session.gd, phase_card.gd, mission_hud.gd. Testes: ratings 33, migração 8, campanha 18; fixture com leitor antigo comprova leitura do save no rollback.

### TASK 12 — validada

Resultados mostram nota por estrelas, precisão de reciclagem (quando há descartes), melhor sequência, tentativas e opcional da rodada; Ubatiba distingue leituras/revisões opcionais. Campanha mostra estrelas de 15, opcionais de 5 e tentativas acumuladas. Instruções explicitam limites numéricos e ausência de nota por velocidade. Tentativas contam no início, pausas não duplicam e resultados são idempotentes. Testes ratings 36, interface 226, resoluções 110, campanha 18 sem falhas. Arquivos: mission_hud.gd, expansion_hud.gd e test_ratings.gd; dados já adicionados na TASK 11.

### TASK 13 — validada

Fontes decorativas estáticas liberadas depois do agrupamento; nós físicos/animados mantidos. Baixo usa 3D a 80%, menos chuva/respingos/partículas/vegetação e preserva HUD/objetivos; Médio/Alto nativos. Três perfis medidos nas cinco fases por profile_upgrade.gd. Alto: 61,43–80,73 FPS médios nas vistas. Quatro ciclos gráficos das cinco fases: 18 nós após descarregar e zero órfãos em todos; RSS 889–900 MiB sem crescimento contínuo. Fechamento suave sem avisos no ensaio; testes com quit imediato podem manter avisos AudioStreamWAV, sem declarar prova universal de ausência de vazamentos. Bueiros receberam números legíveis e estado de prioridade. Testes focados: evolução 57, Centro 34, ambiente 22 sem falhas.
