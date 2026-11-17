# Living World 7 — primeiro lote: transformação ambiental e cinema

## Entrega incremental

Tasks 01–02 implementadas. As tasks 03–09 e 13 ainda são planejadas; UI, desempenho, testes e documentação foram tratados para este lote. O diário `living_world_tasks.md` diferencia o que existe do que continua pendente. Não há nova campanha, avaliação externa, novas conquistas ou pacote completo de animações nesta entrega.

Base preservada: `ponta-negra-pescadores` em `e959a1d`. Nova branch `living-world-7`; checkpoint `checkpoint-pre-living-world-7-e959a1d`. Antes da primeira edição foram salvos bundle Git, ZIP completo com 2.540 arquivos (inclusive os 230 não versionados detectados, ignorados e cache/editor), manifesto com SHA-256 e userdata. CRC do ZIP conferido. Backup externo em `outputs/living-world-7/backup` do chat; não foi enviado ao GitHub por conter estado local e saves. Não houve reset, clean ou exclusão de arquivos.

## Transformações por fase

| Fase | Ações reais que ativam setores visuais | Apresentação acrescentada |
|---|---|---|
| Araçatiba | 5, 10 e 15 destinos corretos; vitória válida também conclui o terceiro setor | Três canteiros com cobertura, bordas, arbustos e flores; dois moradores retornam caminhando à faixa de convivência após vitória |
| Itaipuaçu | 7, 14 e 20 destinos corretos | Três canteiros costeiros na faixa preservada; tomada da praia sem resíduos já resolvidos |
| Centro | 1, 2 e 3 bueiros desobstruídos | Três canteiros, indicação visual junto às grelhas; detritos do bueiro removidos conforme o estado da sessão; visão ampla da rua após vitória |
| Ubatiba | 4, 8 e 12 pontos avaliados corretamente | Três setores de cobertura/jardim; mudas e proteção dos pontos continuam usando os modelos e estados já existentes; tomada mostra a recuperação simbólica |
| Ponta Negra | 7, 14 e 20 destinos corretos | Canteiros nas margens, canal sem resíduos resolvidos, panorâmica em torno do barco e quatro reações curtas dos pescadores |

Cada canteiro aparece progressivamente em 1,2 s. O aviso “Área em recuperação · N/3 setores visuais” dura 3,5 s e não substitui objetivos/tempo/placar. É um indicador da apresentação, não uma medição ambiental real. A vitória legítima completa a apresentação; isso não altera a meta original de Araçatiba de pelo menos 12 acertos entre 15 itens destinados.

O observador oculta resíduos cujo ID já está em estado diferente de AVAILABLE. Não oculta itens disponíveis para facilitar vitória ou elevar FPS. Os próprios sistemas de coleta/descarte já fazem essa retirada durante a interação normal; a apresentação também mantém coerência quando os testes acionam a sessão diretamente.

No Centro, `show_cleaned()` usa o estado real do bueiro; setas junto à grelha complementam a identificação textual já existente. Não é simulação hidrológica. A legenda final diz explicitamente que reduzir obstruções não garante evitar enchentes.

Em Ubatiba, nenhuma árvore é simulada crescendo biologicamente em segundos. A legenda identifica a transformação simbólica. As oito mudas, três proteções e quatro preservações continuam pertencendo à sessão de restauração existente.

Os dois moradores de Araçatiba usam Walk e Idle reais do modelo Man CC0, com percurso decorativo de três metros em quatro segundos, seguido de espera. Não têm colisão, pathfinding, diálogo ou rotina completa: isso é a preparação visual da task 02, não a conclusão da task 04. Não há animação de sentar nesta alteração.

## Tomada pós-vitória

- Uma tomada por tentativa, **6,5 segundos**, com Camera3D e interpolação suave de posição, mantendo um ponto de observação por fase. Ponta Negra usa a posição efetiva do barco.
- Só começa automaticamente depois de VITORIA. Coleta, controle e relógio já estão encerrados pelo fluxo original. Não interrompe exploração, saltos, risco na água, pausa ou derrota.
- Botão visível e focável; **Espaço, Enter ou Esc** permitem continuar. A câmera anterior, resultados e foco de teclado retornam ao terminar/pular. Não muda inventário, score, estatísticas, estrelas, desbloqueios ou arquivos de save.
- As placas 3D do mundo ficam temporariamente ocultas para reduzir ruído visual na tomada e são restauradas ao sair. A HUD funcional continua íntegra; só a apresentação do resultado aguarda a sequência.
- Em Ponta Negra, um pescador reage por vez; a fala também aparece como legenda 2D com nome para continuar legível quando o NPC está distante/fora do quadro. Os cumprimentos de 5 m/3 s/20 s e as tarrafas durante a missão não foram alterados. Sem vozes novas.
- As cinco trilhas e mixer continuam existentes; não foi introduzida trilha externa. Headless não dispara cinema automaticamente para não interferir nos testes antigos de regras; a suíte específica o inicia explicitamente. No renderizador real, a própria ativação automática é testada.

## Arquitetura e arquivos

| Arquivo | Responsabilidade |
|---|---|
| `scripts/effects/environmental_recovery.gd` | Observar sessão/estados; marcos, indicadores, bueiros, moradores, câmera, legendas e reações |
| `scripts/effects/recovery_garden.gd` | Construir canteiro decorativo e revelar sua geometria progressivamente; recursos agrupados em MultiMesh |
| `scripts/effects/mission_presentation.gd` | Montar o observador depois da camada artística existente |
| `scripts/ui/mission_hud.gd` | Ocultar/restaurar resultados durante a tomada, sem criar estado lógico novo |
| `tests/test_living_recovery.gd` | Exercitar ações reais nas cinco sessões, marcos, segurança, câmera, saída e persistência; modo de captura |
| `tests/profile_living_recovery.gd` | Medição gráfica isolada das cinco tomadas em estados sintéticos de recuperação |
| `docs/living_world_tasks.md`, este relatório, GDD/rastreabilidade/créditos/README | Escopo, regras, origem e limites |

Nenhuma cena-base ou controlador foi reescrito. Jardim, moradores e marcadores não acrescentam CollisionObject3D. Câmera cinematográfica usa a renderização atual Mobile. As malhas botânicas são agrupadas e não projetam sombras extras; só dois novos rigs animados, exclusivos de Araçatiba e visíveis após vitória. Não há consultas de navegação ou IA por frame.

## Testes e revisão

Bateria completa: **1.312 verificações em 26 suítes, zero falhas**. Inclui as correções recentes de queda em todas as bordas de Ponta Negra. A suíte nova tem **107 verificações** e foi reexecutada após os ajustes de legenda; também passou no renderizador real em 1280×720 e 1920×1080, com ativação automática e dez capturas ao todo.

Cobertura nova: cinco carregamentos, marcos por ações corretas, sincronização idempotente, geometria sem colisão, resíduos resolvidos ocultos, detritos dos bueiros retirados, derrota sem cinema, missão ativa sem cinema, movimento real da câmera, botão dentro do viewport, legendas, pular, evento Esc real no pipeline de entrada, restauração de câmera/HUD, término natural e save/placar/relógio inalterados. Dados de sessão e conclusões dos testes são simulados; não são resultados de participantes.

Durante a revisão foram corrigidos: tipagem explícita de arrays na suíte; coerência visual dos resíduos quando a sessão é acionada diretamente; enquadramento da área de convivência; legendas dos pescadores para leitura à distância; identificação da resolução física das capturas sem confundir o canvas lógico de 720p com janela de 1080p. O Windows limitava a área cliente da janela a 1920×1055; a execução final 1080p usa fullscreen. Os cabeçalhos PNG foram conferidos: cinco imagens 1280×720 e cinco 1920×1080, com hashes no manifesto.

Alguns testes headless com saída imediata mantêm avisos ObjectDB já conhecidos. Capturas usam encerramento suave. Não se declara ausência universal de vazamentos. Revisão gráfica automatizada/capturas não substitui partida humana nem avaliação de aprendizagem.

## Desempenho

Medições efetivas estão em `tests/artifacts/living_performance.json` e `.log`: Intel UHD, Mobile/Vulkan, Alto, janela 1280×720. Cada tomada é medida isoladamente após 90 frames de aquecimento em estado sintético; sem testes concorrentes. O cronômetro e as ações não representam uma partida real nesse ensaio.

| Fase | Frames medidos | FPS médio | p95 | Pior frame | VRAM |
|---|---|---|---|---|---|
| Araçatiba | 390 | 59,99 | 17,55 ms | 18,58 ms | 220,8 MiB |
| Itaipuaçu | 391 | 59,85 | 18,07 ms | 29,40 ms | 215,7 MiB |
| Centro | 360 | 55,52 | 21,74 ms | 28,77 ms | 226,3 MiB |
| Ubatiba | 337 | 51,70 | 26,20 ms | 34,19 ms | 217,4 MiB |
| Ponta Negra | 391 | 60,00 | 17,99 ms | 25,78 ms | 220,1 MiB |

Ubatiba teve o maior custo e um frame acima de 33,3 ms; não se promete mínimo estável de 30 FPS em todos os frames ou 60 FPS fixos. Também não se extrapola esta medição para 1080p, bateria/temperatura, primeira importação ou partida prolongada. A revisão de 1080p verificou apresentação e controles, sem benchmark de desempenho nessa resolução.

## Como conferir

F8/F5, iniciar uma fase e concluir suas ações. Observar os três marcos de recuperação ao longo da missão e a tomada após vencer. Usar o botão, Espaço/Enter/Esc para pular; os resultados devem voltar. Em Araçatiba, olhar a faixa de bancos da orla; no Centro, conferir grelhas limpas; em Ponta Negra, conferir legendas e o barco. Cair na água a pé ainda deve perder, sem cinema de vitória.

Para reproduzir os testes: executar `tests/run_all.ps1`. Para as capturas: Godot com `--script res://tests/test_living_recovery.gd -- --capture`; `--resolution 1280x720` ou `--fullscreen --resolution 1920x1080`. Para medir: `--script res://tests/profile_living_recovery.gd`. Arquivos de teste usam caminhos isolados, sem editar o progresso real.

## Limites e próximos lotes

As melhorias são incrementais, com os assets atuais. Bordas distantes e limites das malhas de paisagem/água ainda podem aparecer em panorâmicas; o cenário não foi reconstruído como mundo aberto. Não há novos clipes de arremesso, animações faciais, IK de contato, rotina completa de moradores ou pré/pós-avaliação educativa neste lote. Não foram duplicados estrelas/opcionais/mapa. Próxima tarefa do diário: auditar e aprimorar animações reais dos quatro personagens, distinguindo clipes existentes de poses procedurais; depois NPCs/diálogos e demais sistemas. Teste externo, DOCX/PDF final, vídeo e exportação continuam pendentes.

Assets reutilizados: Nature Kit de Kenney e Man de Quaternius, ambos CC0 conforme catálogo/manifesto existente. Canteiros, código, cinematografia e textos novos foram elaborados com assistência Codex/IA. Sem downloads novos e sem atribuir animações ou falas a terceiros. A revisão humana do autor é a próxima validação da apresentação.
