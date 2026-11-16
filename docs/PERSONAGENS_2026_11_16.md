# Personagens — polimento visual de 16/11/2026

## Execução

Lucas foi reconstruído primeiro e revisado em estúdio (frente, costas e rosto). Os testes iniciais de fundação e Araçatiba passaram com 16 + 32 verificações. Em seguida, a construção comum foi aplicada a Marina, Rafael e Bia, com cabelos, equipamentos e cores próprios. Não foram alterados controles, cápsula, câmera, velocidade, metas, pontuação, interação ou fluxo das fases.

## O que melhorou

| Área | Resultado |
|---|---|
| Silhueta e corpo | Tronco, quadril, mangas, antebraços, mãos e pernas conectados; proporções consistentes e pés assentados; quatro pontos de articulação originais preservados |
| Cabeça | Forma própria de bochechas, queixo e crânio, com pescoço e orelhas integrados |
| Rosto | Sobrancelhas curvas, nariz com ponte e ponta, sorriso curvo e coloração suave das bochechas por vértices |
| Olhos | Pálpebras, branco, íris, pupilas e brilho; piscar discreto durante a apresentação ativa |
| Cabelo | Massa capilar contínua e mechas; coque e laterais para Marina; boné para Rafael; cachos, volume e presilha para Bia |
| Roupas | Camisa, painéis do colete/jaqueta, gola, bolsos com abas, fecho, cinto, costuras, tênis com cadarços/sola e botas de Rafael |
| Materiais | Paletas por identidade, cores de apoio creme/oliva, rugosidade diferenciada de pele, tecido, cabelo, calçados e pequenos metais |
| Equipamentos | Mochilas com bolsos e alças, folha da marca, garrafa de Lucas, caderno/bolsa de campo de Marina, rádio/equipamento de Rafael e bolsa transversal de Bia |

Lucas mantém colete verde e mochila de campo. Marina mantém turquesa e cabelo preso. Rafael mantém laranja, boné e botas. Bia mantém roxo e cabelo cacheado. Não foram atribuídos poderes ou diferenças de velocidade às aparências.

As prévias usam o mesmo modelo do jogador e passageiro, com luz principal, preenchimento suave, sombras e MSAA 8×. Olhos ficam abertos nas prévias paradas; giro opcional permite movimento. As prévias estáticas continuam renderizando sob demanda.

## Estrutura e GLB

- `character_appearance.gd`: construção e identidade visual, sem corpos físicos; conserva os pivôs esperados pelo controlador.
- `character_geometry.gd`: superfícies contínuas, detalhes e agrupamento por material em cada parte articulada. O rosto animado permanece separado.
- `character_model_adapter.gd`: montagem opcional de PackedScene/GLB, ajuste independente do rig e mapeamento de animações. Mantém fallback procedural quando o modelo é incompatível.
- `assets/models/characters/README.md` e `docs/MODELOS_GLB.md`: local e contrato para modelos futuros. Não há GLB externo incluído.

O controlador `guardian.gd`, a cena física `guardian.tscn` e o controlador do barco ficaram intactos. As animações procedurais existentes continuam atingindo os mesmos pivôs; os modelos opcionais recebem os estados de apresentação por uma API separada.

## Gráficos

A qualidade Alta foi ativada nas preferências locais, preservando volumes, câmera, perfil e campanha. Ela também passa a ser o padrão para instalações sem preferência salva. As opções Baixa/Média continuam disponíveis.

Alta: MSAA 8×, sombras direcionais de 4096, quatro cascatas e filtro suave, vegetação extra já existente. O renderizador Forward Mobile/Vulkan foi preservado. Os ajustes melhoram contornos e acabamento; não geram automaticamente modelagem ou animações.

Benchmark gráfico final, Intel UHD Graphics, 1280 × 720, qualidade Alta, VSync desativado, 180 quadros por vista após aquecimento:

| Fase | FPS médio | p95 do quadro |
|---|---:|---:|
| Araçatiba | 76,80 | 15,25 ms |
| Itaipuaçu | 82,97 | 14,37 ms |
| Centro com tempestade | 66,12 | 17,89 ms |
| Ubatiba | 77,27 | 15,29 ms |
| Ponta Negra | 80,87 | 15,56 ms |

São vistas controladas, não medição de partida humana completa ou garantia de FPS mínimo. O perfil Alto agora custa mais que o perfil anterior com MSAA 4× e duas cascatas; a máquina manteve as médias acima nas amostras observadas. A medição de estúdio usa MSAA 4× e VSync, limitada a aproximadamente 60 FPS; serve para revisão visual e contagem de desenho, não para comparar capacidade máxima. Grupos por material limitam as partes renderizadas: a suíte verifica até 65 MeshInstance3D por modelo, mesmo com o detalhamento adicional.

## Verificação

- **661 verificações em 18 suítes, sem falhas**, pelo executor `tests/run_all.ps1`.
- Nova suíte `test_character_visuals.gd`: 57 verificações de normais, envelope visual, limites de superfícies, trocas sem acúmulo, pivôs estáveis, piscar/prévia, montagem/alinhamento/remoção de modelo externo, nomes de animação e fallback, qualidade e quatro passageiros de barco.
- A suíte anterior de personagens continua passando 49 verificações, incluindo caminhada/corrida/pulo/colisão e coleta dos quatro. Campanha integrada de cinco fases continua com os mesmos 2345 pontos e 70 destinos nos testes automatizados.
- Revisão gráfica: 12 vistas finais de estúdio, 12 capturas de corrida/ação/barco e sete capturas das fases/menu/seleção. O antes e a validação intermediária de Lucas foram preservados separadamente.
- Logs gráficos finais sem ERROR/SCRIPT ERROR. Algumas suítes headless ainda têm avisos ObjectDB no encerramento, já observados em etapas anteriores. Logs e resumo em `tests/artifacts`.

Capturas de ações são poses produzidas pelo controlador em cenas de teste, com congelamento para inspeção. As amostras de GLB são PackedScenes sintéticas equivalentes ao ponto de montagem; nenhum asset GLB artístico real foi importado. Testes usam caminhos próprios e não concluem a campanha do jogador.

## Arquivos alterados

Implementação: `scripts/player/character_appearance.gd`, novos `character_geometry.gd` e `character_model_adapter.gd`; `scripts/core/character_catalog.gd`, `scripts/core/game_audio.gd`, `scripts/effects/world_polish.gd`, `scripts/ui/character_selection.gd` e `project.godot`.

Verificação: novo `tests/test_character_visuals.gd`, `tests/capture_character_polish.gd`, `tests/capture_character_motion.gd`; capturas, logs e medições em `tests/artifacts`.

Documentação: este relatório, `MODELOS_GLB.md`, pasta de modelos opcionais, README, GDD de trabalho, créditos, continuidade e validação. Nenhum documento acadêmico final ou exportação Windows foi preparado nesta etapa.

## Limitações e assets externos

Os modelos são low-poly procedurais. As articulações continuam sendo transformações de partes inteiras; não há deformação por esqueleto, cotovelos/dedos articulados, blendshapes, cabelo simulado, roupa dinâmica ou animação facial além do piscar. Detalhes muito pequenos perdem leitura na câmera normal, por isso foram priorizados volumes, cores e equipamentos visíveis.

O próximo salto depende de GLBs com topologia artística, UVs/texturas coerentes, rig compatível e animações próprias de caminhada, corrida, salto, coleta, plantio e embarque. Retratos e expressões desenhados também dependem de uma etapa artística adicional. Qualquer asset externo precisa ter licença e crédito verificados. Nenhum modelo, textura ou fonte foi baixado nesta etapa; a construção atual usa código e recursos nativos com assistência Codex.
