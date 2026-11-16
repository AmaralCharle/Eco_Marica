# Upgrade visual 4 — tarefas rastreáveis

Branch: `upgrade-visual-4`. Base aprovada: `3fc476c` (tag `fase-1-final`, publicada). Checkpoint com normalização local do editor: `d89078f`. Main permanece preservada. Fonte do escopo: prompt 4.0 fornecido pelo autor nesta conversa.

| Task | Estado | Escopo / evidência |
|---|---|---|
| 01 Backup, branch e auditoria | validada | ZIP da base, patch da configuração, arquivos locais e saves preservados fora do repositório; branch/tag publicadas |
| 02 Medição e renderizador | validada | `tests/profile_upgrade.gd`, três renderizadores, cinco fases, FPS/p95/carga/RSS/VRAM/inventário |
| 03 HUD e problemas visuais | validada | 720p/1080p, espaço para novas informações, menus e modais |
| 04 Piloto Centro | validada | Materiais, arquitetura, vegetação, tempestade |
| 05 Ubatiba | pendente | Ambiente rural e recuperação simbólica |
| 06 Ponta Negra | pendente | Água, barco e margens |
| 07 Araçatiba/Itaipuaçu | pendente | Coerência entre as cinco fases |
| 08 Personagens/animações | pendente | Um modelo primeiro; articulação visual e estados existentes |
| 09 Áudio/efeitos | pendente | Complementos originais, volume e sobreposição |
| 10 Decisões ambientais | pendente | Composição, vento, prioridade de bueiros, solo e rota |
| 11 Estrelas/opcionais | pendente | Critérios numéricos, sem bloquear progressão |
| 12 Estatísticas/resultados | pendente | Tentativas e melhores avaliações, migração compatível |
| 13 Perfis/otimização | pendente | Baixo/Médio/Alto; cargas e memória |
| 14 Regressão completa | pendente | Cinco fases, saves próprios; revisão gráfica e limites |
| 15 GDD/rastreabilidade/créditos | pendente | Documentar somente o implementado e validado |

## Rollback

A versão anterior continua em `main`/`fase-1-final`. Após salvar o trabalho da branch, parar o jogo com F8 e abrir um checkout de `fase-1-final` ou trocar para `main`; não usar reset/clean. Uma alternativa que mantém os dois projetos é `git worktree add <pasta-vazia> fase-1-final`. Fechar/reabrir o editor no projeto escolhido evita instâncias antigas em execução.

Backup local: pasta `outputs/upgrade-visual-4/backup_pre_upgrade` do chat. Contém ZIP de 62.385.558 bytes da base aprovada, patch da alteração local do editor, cópia dos arquivos não versionados e saves existentes. Os arquivos originais não foram apagados. A evolução dos saves deverá conservar leitura pela versão 2 ou incluir cópia independente antes de qualquer migração incompatível.

### TASK 03

Painéis de menu/resultados agora possuem limite de altura e rolagem que acompanha o foco do teclado, preservando o conteúdo. `test_resolutions.gd`: 110 verificações em 1280×720 e 1920×1080 nas cinco fases; `test_interface.gd`: 226 verificações, sem falhas. Arquivos: `scripts/ui/mission_hud.gd`, `tests/test_resolutions.gd`.

### TASK 04 — validada

Centro piloto: vitrines, esquadrias, bancos, vasos, materiais e 64 respingos limitados por qualidade. Arquivos: upgrade_visuals.gd, world_polish.gd, environment_surface.gdshader, stylized_glass.gdshader, rain_splash.gdshader. Testes: Centro 34 e acesso 14 sem falhas; captura Vulkan de céu claro/tempestade/café sem erros de shader.
