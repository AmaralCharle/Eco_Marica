# Auditoria técnica — upgrade visual 4

Base: tag `fase-1-final` (`3fc476c`) e checkpoint local `d89078f`. Godot instalado: 4.7.2 Standard, GDScript, Windows 11, i5-12450H, 12 GB RAM, Intel UHD integrada. O editor normalizou parâmetros de projeto equivalentes aos padrões; essa alteração local foi preservada no checkpoint, sem substituí-la pelo arquivo antigo.

## Dependências e estado inicial

Cinco cenas em `scenes/levels`, controlador comum `scripts/levels/aracatiba.gd` e especializações. Sessões separadas de reciclagem/restauração/carga; `guardian.gd` e `boat.gd` concentram física. Visual dos quatro personagens e adaptador GLB já estão separados da cápsula. `WorldPolish` e a passagem por referências fazem decoração sem colisões. HUD, perfis gráficos e áudio sintetizado já existem e serão evoluídos, preservando suas funções.

Persistência de perfil/campanha/preferências em arquivos locais separados. Progresso versão 2 já lê versão 1. A base possuía 727 verificações automatizadas em 19 suítes. Não há GLBs artísticos externos; recursos são procedurais, shaders e WAV originais. Os scripts de captura e screenshots são evidência de estados controlados, não de teste externo.

## Problemas e decisões propostas

| Problema | Impacto | Custo estimado | Prioridade | Solução / validação |
|---|---|---|---|---|
| Folhas de palmeiras achatadas e repetidas | Alto em todas as fases | Baixo/médio, geometria estática | Alta | Folhas curvas e folíolos; capturas e benchmark |
| Personagens ainda rígidos nos cotovelos | Alto na proximidade | Baixo/médio, pivôs visuais | Alta | Articulação adicional dentro do Visual, sem mudar cápsula; testar Lucas antes dos demais |
| Materiais com variação limitada | Médio/alto | Baixo, shaders existentes | Alta | Rugosidade e padrões por superfície; checar compilação nos renderizadores |
| Muitas malhas-fonte ocultas após agrupamento | Memória/carga desnecessárias | Redução esperada | Alta | Liberar apenas fontes decorativas estáticas; preservar nós físicos/animados; comparar RSS e colisões |
| HUD validada principalmente em 720p | Risco de corte ao acrescentar dados | Baixo | Alta | Validar 720p/1080p, mensagens longas e resultados |
| Ausência de estrelas e histórico de tentativas | Pouco incentivo para rejogar | Baixo, dados locais | Alta | Avaliação sem critério de velocidade; melhor estrela independente do melhor score; testes de migração |
| Desafios ambientais pouco variados | Impacto de jogabilidade | Baixo, regras determinísticas | Alta | Decisões opcionais contextualizadas, vento lateral limitado, prioridade por resíduos próximos, planejamento de carga |
| Efeitos/som genéricos | Médio | Baixo com limites de simultaneidade | Média | Feedback original para decisões/conquistas; manter buses e volumes |
| Terreno/água simplificados | Alto, dependente de modelagem | Alto se reconstruir física | Média | Refinar aparência e props, mantendo terreno físico; registrar dependências externas |
| Avisos ObjectDB em encerramentos imediatos | Incerteza sobre referências de áudio | Medir antes de concluir | Alta | Inspeção verbose, ciclo de cenas e memória após aquecimento; não afirmar ausência de vazamentos sem evidência |

## Medição

`tests/profile_upgrade.gd` executa as cinco fases com qualidade Alta, 1280×720, VSync desligado, aquecimento de 40 frames e 150 amostras por fase. Registra FPS médio, p95/pior quadro, carga, RSS/memória privada do processo Windows, VRAM estimada pelo motor, materiais, luzes, colisões, partículas, objetos e primitivas. RSS e VRAM compartilhada não devem ser somadas como se fossem memória física independente.

Resultados iniciais e comparação serão completados após os três processos terminarem. A escolha deve considerar estabilidade de quadros e benefício visual, não apenas média. Um ensaio estático não demonstra 30/60 FPS sustentados em uma partida completa.

## Resultado inicial dos renderizadores

| Renderizador | Fase | FPS médio | p95 ms | RSS MiB | Materiais | Luzes | Colisões |
|---|---|---:|---:|---:|---:|---:|---:|
| mobile | aracatiba | 80.06 | 14.53 | 808.7 | 198 | 1 | 43 |
| mobile | itaipuacu | 85.28 | 13.87 | 822.4 | 187 | 1 | 23 |
| mobile | centro | 62.60 | 18.73 | 858.1 | 277 | 1 | 34 |
| mobile | ubatiba | 64.25 | 18.02 | 865.2 | 202 | 1 | 14 |
| mobile | ponta_negra | 68.64 | 16.93 | 863.2 | 210 | 1 | 29 |
| gl_compatibility | aracatiba | 64.51 | 41.10 | 650.5 | 198 | 1 | 43 |
| gl_compatibility | itaipuacu | 63.18 | 38.71 | 666.4 | 187 | 1 | 23 |
| gl_compatibility | centro | 58.34 | 30.90 | 709.3 | 277 | 1 | 34 |
| gl_compatibility | ubatiba | 56.69 | 46.58 | 767.0 | 202 | 1 | 14 |
| gl_compatibility | ponta_negra | 61.59 | 43.68 | 745.5 | 210 | 1 | 29 |
| forward_plus | aracatiba | 45.05 | 27.33 | 1081.9 | 198 | 1 | 43 |
| forward_plus | itaipuacu | 47.40 | 23.54 | 1090.3 | 187 | 1 | 23 |
| forward_plus | centro | 43.60 | 25.63 | 1129.8 | 277 | 1 | 34 |
| forward_plus | ubatiba | 42.53 | 26.99 | 1134.6 | 202 | 1 | 14 |
| forward_plus | ponta_negra | 44.17 | 26.89 | 1138.0 | 210 | 1 | 29 |

Decisão: manter Mobile. Forward+ consumiu aproximadamente 1,08–1,14 GiB de working set e entregou cerca de 43–47 FPS nas vistas, sem benefício artístico que justificasse a troca nesta etapa. Compatibility apresentou piores oscilações (p95 em algumas vistas acima de 30 ms). Mobile manteve aproximadamente 63–85 FPS nas amostras, com working set de cerca de 809–870 MiB. Todos os três processos terminaram com exit 0. Os recursos procedurais/shaders foram carregados nos três; capturas permitem comparar o acabamento. Valores são amostras controladas, não garantia de desempenho mínimo.

## Perfis finais e memória

| Perfil | Fase | FPS médio | p95 ms | RSS MiB | Carga ms |
|---|---|---:|---:|---:|---:|
| 0 | aracatiba | 187.22 | 7.88 | 696.8 | 1027 |
| 0 | itaipuacu | 395.55 | 3.51 | 712.3 | 613 |
| 0 | centro | 217.62 | 8.52 | 752.3 | 1147 |
| 0 | ubatiba | 291.45 | 4.39 | 761.1 | 1927 |
| 0 | ponta_negra | 310.59 | 4.19 | 769.6 | 1621 |
| 1 | aracatiba | 107.15 | 10.83 | 812.8 | 1043 |
| 1 | itaipuacu | 121.53 | 9.41 | 829.0 | 692 |
| 1 | centro | 99.11 | 12.97 | 881.0 | 1252 |
| 1 | ubatiba | 99.98 | 12.07 | 883.7 | 1768 |
| 1 | ponta_negra | 110.43 | 11.26 | 894.7 | 1549 |
| 2 | aracatiba | 77.34 | 14.44 | 812.0 | 993 |
| 2 | itaipuacu | 80.73 | 13.92 | 829.9 | 633 |
| 2 | centro | 61.43 | 17.63 | 878.5 | 1200 |
| 2 | ubatiba | 64.93 | 16.64 | 889.2 | 2018 |
| 2 | ponta_negra | 69.11 | 16.23 | 895.9 | 1547 |

Perfis: 0 Baixo (3D 80%, UI nativa), 1 Médio, 2 Alto. Colisões preservadas: 43/23/34/14/29 por fase na ordem da campanha. Não se promete FPS sustentado em toda partida; estes ensaios não substituem jogo humano, carregamento a frio ou outras aplicações concorrentes. Alto ficou próximo da meta preferencial; Médio oferece maior folga neste notebook.

Quatro ciclos gráficos de carga/descarga das cinco fases: 18 nós remanescentes e zero órfãos a cada ciclo; RSS 889,1 / 900,3 / 896,3 / 897,9 MiB. Não houve crescimento contínuo nem acúmulo de nós nesse ensaio. O encerramento suave aguardou o mixer e terminou sem avisos nesse processo. Em testes headless que usam quit imediato, avisos de AudioStreamWAV/PlaybackWAV ainda podem aparecer. Isso é registrado como limitação da evidência, não escondido nem convertido em afirmação de zero vazamentos.
