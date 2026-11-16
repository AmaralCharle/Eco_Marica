# Medições e comparação — Asset Revolution

Intel UHD, Mobile/Vulkan, 1280×720. Vistas automatizadas com câmera, tempo e entradas controlados. Média não garante FPS mínimo numa partida humana. Before foi medido antes da integração. MSAA inicial 8×; Alto final 4×: compara perfis completos, não isola apenas o custo dos assets.

| Fase | Antes Alto FPS / p95 | Depois Alto FPS / p95 | Depois Médio FPS / p95 | Depois Baixo FPS / p95 |
|---|---|---|---|---|
| centro | 66.71 / 17.32 ms | 55.53 / 20.48 ms | 67.19 / 17.95 ms | 127.17 / 9.79 ms |
| ubatiba | 65.91 / 17.69 ms | 52.91 / 21.55 ms | 63.55 / 19.28 ms | 112.18 / 11.47 ms |
| ponta_negra | 68.14 / 17.86 ms | 65.89 / 17.89 ms | 75.62 / 16.89 ms | 141.44 / 9.09 ms |
| aracatiba | 81.97 / 14.44 ms | 76.76 / 14.77 ms | 77.75 / 15.93 ms | 165.98 / 8.02 ms |
| itaipuacu | 81.56 / 14.33 ms | 79.65 / 14.72 ms | 87.29 / 14.61 ms | 191.08 / 7.17 ms |

## Custos do perfil Alto

| Fase | Draw calls antes → depois | Primitivas renderizadas antes → depois | RSS depois | VRAM depois | Carga depois |
|---|---|---|---|---|---|
| aracatiba | 325 → 239 | 215500 → 106075 | 848.6 MiB | 220.2 MiB | 1069 ms |
| itaipuacu | 297 → 263 | 189112 → 98379 | 864.7 MiB | 215.0 MiB | 453 ms |
| centro | 540 → 377 | 243906 → 101198 | 888.4 MiB | 225.6 MiB | 591 ms |
| ubatiba | 368 → 237 | 534712 → 266115 | 895.8 MiB | 216.7 MiB | 800 ms |
| ponta_negra | 372 → 256 | 469252 → 204480 | 905.0 MiB | 218.8 MiB | 678 ms |

## Memória — quatro ciclos das cinco fases

| Ciclo | RSS | Nós após descarregar | Órfãos |
|---|---|---|---|
| 1 | 900.8 MiB | 18 | 0 |
| 2 | 895.5 MiB | 18 | 0 |
| 3 | 882.4 MiB | 18 | 0 |
| 4 | 896.9 MiB | 18 | 0 |

Sem crescimento contínuo nessas quatro amostras. Não comprova ausência universal de vazamentos. Cargas medidas com motor já iniciado; primeira importação, cache frio, bateria/temperatura e outras aplicações não foram isolados. Pré-visualizações 3D de downloads foram fechadas antes dos perfis finais. Alguns testes headless com encerramento imediato ainda apresentam avisos de áudio.

## Evidências visuais

Antes: `assets_before_*.png`. Depois: `assets_final_2_*.png`. Campanha: 36 capturas `assets_campaign_*.png` em 720p/1080p. Detalhes: seis capturas `assets_detail_*.png`; personagens: 12 poses `assets_motion_*.png` e galeria `assets_characters_front.png`. Estados de campanha são simulação controlada com saves próprios; não são estatísticas reais do jogador nem teste externo.
