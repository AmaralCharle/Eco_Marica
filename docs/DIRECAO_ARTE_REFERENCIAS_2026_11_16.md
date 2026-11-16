# Direção de arte a partir das referências — 16/11/2026

## Referências utilizadas

Esta passagem usa as seis imagens já fornecidas pelo autor: aventura urbana sustentável, reflorestamento em Ubatiba, Revenge of the Savage Planet, Reef by Barji, personagem de Isla Wanderleaf e a cena tropical low-poly do Arthub. Nenhum novo conjunto de imagens foi anexado nesta solicitação.

As imagens serviram de inspiração para paleta, camadas de vegetação, luz, materiais e composição. Não foram copiadas, usadas como texturas, convertidas em modelos ou redistribuídas com o projeto. Os cenários continuam fictícios e não constituem reprodução geográfica de Maricá.

## O que foi adaptado

| Referência / aspecto | Adaptação no jogo |
|---|---|
| Cena urbana: árvores enquadrando a rua, fachadas, toldos, ponto de fuga | Copas maiores, jardineiras e flores, requadros comerciais, mesas do café e um marco cívico fictício fora da área jogável |
| Ubatiba: camadas de floresta, solo, riacho e instrumentos de campo | Vegetação de borda mais densa, arbustos floridos, variação da grama, relevo assimétrico, riacho visível entre margens e carrinho de campo |
| Aventura tropical e low-poly: volumes legíveis, cores e profundidade | Paleta comum de verdes, creme, madeira e terracota; céu e névoa para separar fundo e primeiro plano; massas de vegetação com variação |
| Reef: água limpa e leitura dos resíduos | Água turquesa com variações de superfície, brilho fragmentado e bordas mais claras, mantendo os materiais de coleta identificáveis |
| Personagem de Isla Wanderleaf: integração ao ambiente | Mantida a apresentação dos quatro personagens da etapa anterior, com cenários e cores compatíveis; nenhuma alteração no controlador ou nos modelos nesta passagem |

## Centro de Maricá

- Árvores com copas mais volumosas e galhos conectados ao tronco, produzindo enquadramento superior e sombras mais naturais.
- Jardineiras, arbustos e flores nos recuos; detalhes de portas, janelas e fachadas; pequenas mesas junto ao café.
- Marco cívico com relógio no fundo da rua para reforçar o ponto de fuga. É uma construção fictícia, decorativa e fora do percurso.
- Céu procedural que muda do azul para tons frios conforme a intensidade da tempestade existente. Luz e preenchimento são ajustados continuamente para evitar alternância com o acabamento antigo.
- Asfalto continua acompanhando a umidade da chuva. Todos os 15 resíduos, três bueiros, coletores e acessos permanecem no lugar.

## Ubatiba

- Mais vegetação no primeiro plano e nas bordas: árvores, arbustos com flores, grama com variação de cor e camada florestal de fundo.
- Relevo de fundo com vales e volumes assimétricos, substituindo os morros elipsoidais muito repetidos. Terreno visual de continuação sob a vegetação exterior.
- A superfície visual do solo abre espaço para o riacho, com água abaixo da margem e pedras/plantas ao redor. O chão físico original permanece intacto.
- Carrinho de campo com pequenas mudas em área lateral sem pontos de missão; cerca e abrigo rural existentes integrados à vegetação.
- Os 12 pontos, áreas de demonstração, objetivos de avaliação/plantio/proteção e caminhos originais foram preservados.

## Ponta Negra

- Arbustos, árvores, flores, pedras e continuação das margens criam camadas ao longo do canal. Abrigo costeiro lateral acrescenta escala ao cenário.
- Canal visualmente prolongado para evitar um corte abrupto no horizonte; a zona de perdas e os limites de navegação continuam exatamente como antes.
- Água em superfície subdividida, com ondulação visual de pequena amplitude, normais animadas, brilho e coloração dependente da vista. Bordas mais claras sugerem margem rasa.
- Altura visual da água e base do casco ajustadas para aproximar barco e linha d’água. Corpo físico, convés, passageiro, câmera e navegação permanecem iguais.
- Acesso ao píer e distância dos coletores preservados.

## Coerência entre as cinco fases

Araçatiba e Itaipuaçu recebem o mesmo acabamento de copas, água, relevo de fundo e paleta, além de agrupamentos de vegetação em áreas seguras. Mantêm sua identidade de orla/praia e não receberam novas tarefas.

Nomes dos coletores e resíduos continuam disponíveis, com escala visual menor para reduzir a sobreposição de textos no cenário. HUD, informações de missão e destaque de interação permanecem funcionais.

## Integração e desempenho

A passagem é decorativa. Nenhuma cena foi recriada, nenhum objetivo reposicionado e nenhum corpo físico adicionado. Novos agrupamentos de vegetação respeitam distância mínima de 2,2 m dos pontos de interação existentes. Partes estáticas são agrupadas por material; grama usa MultiMesh e varia com Baixa/Média/Alta. Árvores de fundo e partes secundárias das copas dispensam sombras adicionais.

Mantidos Godot 4.7.2, Forward Mobile/Vulkan, resolução 1280 × 720 e qualidade Alta da etapa anterior (MSAA 8×, sombras de 4096). As extensões do horizonte são cenográficas e não ampliam o mapa jogável.

| Fase | FPS médio | p95 do quadro |
|---|---:|---:|
| Araçatiba | 81,77 | 14,30 ms |
| Itaipuaçu | 101,71 | 11,54 ms |
| Centro com tempestade | 82,29 | 13,33 ms |
| Ubatiba | 83,05 | 13,18 ms |
| Ponta Negra | 90,41 | 12,55 ms |

Medição em vistas controladas, 180 quadros após aquecimento, VSync desativado, Intel UHD Graphics. Não representa partida humana completa nem garante FPS mínimo. A maior densidade adiciona trabalho de renderização; a vegetação distante sem sombras e o agrupamento de malhas limitam esse custo. Qualidades menores continuam disponíveis.

## Validação

**727 verificações em 19 suítes, sem falhas.** Nova suíte `test_art_direction.gd`: 66 verificações de afastamento dos objetivos, identificação de coletores, vegetação agrupada, céu, continuidade da luz durante a tempestade, solo/água e preservação dos pontos de plantio. As suítes existentes verificam a identidade, dimensões e posição das colisões antes/depois da decoração, acesso aos coletores/rampas/píer, personagens e campanha completa.

Revisão gráfica: cinco vistas de gameplay, menu/seleção e seis vistas adicionais (Centro claro/tempestade/café, riacho, carrinho e barco). Câmeras de detalhe são de revisão; a câmera do jogo não foi alterada. Estados e saves de teste são separados dos saves do jogador. Logs finais sem ERROR/SCRIPT ERROR; alguns encerramentos ainda registram avisos ObjectDB de referências, já observados em etapas anteriores.

## Limitações e próximos assets

A aproximação maior depende de uma etapa de modelagem e texturização artística. Os recursos atuais continuam procedurais e simplificados.

| Prioridade | Assets que mais ajudariam |
|---|---|
| 1 | Kit modular de fachadas comerciais, esquadrias, toldos, telhados e mobiliário urbano com proporções e UVs consistentes |
| 2 | Árvores e plantas estilizadas de diferentes portes, com espécies identificadas e revisão de adequação ambiental, LODs e copas bem modeladas |
| 3 | Terreno artístico e texturas de solo, trilha, pedras e margens; integração física e revisão dos percursos antes de mudar o relevo jogável |
| 4 | Píer, ponte, barco, cordas e acessórios costeiros modelados, preservando os pontos de montagem e volumes físicos |
| 5 | Mapas de fluxo/profundidade e máscaras de margem para água mais específica de cada local; materiais e reflexos avaliados no renderizador escolhido |

A água atual usa brilho e sugestão de cor do céu; não espelha os objetos da cena nem simula fluidos/profundidade real. A floresta continua formada por massas low-poly, e o terreno transitável mantém a base física original. Não há tráfego ou multidões ambientando a cidade. Uma biblioteca de props e modelos artísticos dará um salto maior que aumentar apenas efeitos de renderização. Qualquer asset externo deve ter licença e crédito verificados.

## Arquivos

Implementação: `scripts/effects/world_polish.gd`, novos `reference_art_pass.gd` e `art_direction_meshes.gd`, `scripts/effects/boat_polish.gd`, `assets/materials/water.gdshader`.

Verificação: novos `tests/test_art_direction.gd` e `tests/capture_art_direction.gd`, evidências `tests/artifacts/art_reference_*` e `art_detail_*`, logs e resumo de validação. Documentação: este relatório, README, GDD de trabalho, créditos, continuidade e validação.

O projeto permanece aberto para novas ideias. Esta passagem não prepara GDD final, vídeo ou exportação acadêmica.
