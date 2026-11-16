# Interface e HUD — 16/11/2026

Polimento incremental aplicado às cinco fases do ECO MARICÁ, em Godot 4.7.2 Standard, Forward Mobile/Vulkan e resolução de referência 1280 × 720. O projeto continua em desenvolvimento; esta etapa não prepara a entrega acadêmica nem a exportação.

## Apresentação

- Identidade compartilhada: verde profundo, verde claro para ações principais e progresso, âmbar para atenção/foco. Painéis arredondados, transparência moderada, borda discreta e sombra curta. Não foi adicionado desfoque de tela.
- Tipografia de sistema (Segoe UI, com alternativas Noto Sans/Arial e fallback do motor), números de tempo/pontos maiores e títulos, subtítulos e notas em níveis distintos. Nenhum arquivo de fonte foi copiado ou redistribuído.
- Ícones desenhados por código para tempo, pontuação, localidades, barco, plantio, pausa e conclusão. A indicação textual acompanha os ícones; estados de bloqueio e conclusão não dependem apenas de cor.
- Botões primários, secundários, discretos e cartões com foco visível. Entrada suave de 0,18 s nos conteúdos de menu; não altera o relógio ou os estados de missão.

## HUD nas cinco fases

Objetivos e progresso no canto superior esquerdo; cronômetro e pontos em cartões separados à direita. Limpeza/recuperação no canto inferior esquerdo; inventário e carga à direita; interação e feedback na faixa central inferior. O centro da câmera permanece livre.

Permanecem disponíveis: coleta, destinos, acertos/erros, perdas, materiais disponíveis, bueiros, avaliações, plantios, proteções, item em mãos, carga, limpeza, pontuação, prazo, comandos e avisos educativos pertinentes. A HUD lê os dados das sessões existentes; não calcula recompensas nem decide vitórias.

| Fase | Apresentação específica |
|---|---|
| Araçatiba | Coletados/destinados, mínimo de 12 acertos, limite de erros, papel/plástico disponíveis e item transportado |
| Itaipuaçu | Destinos de 20, perdas de cinco, erros, quatro materiais e inventário |
| Centro | Destinos de 15, três bueiros, coleta, erros e quatro materiais |
| Ubatiba | Avaliações de 12, plantios de oito, proteções de três, erros e recuperação; inspeção com todas as ações originais |
| Ponta Negra | Destinos de 20, perdas/erros, cinco marcas de carga e valor numérico; comandos mudam entre terra e barco |

O tempo recebe destaque âmbar nos últimos 60 segundos e tom quente nos últimos 30. Mensagens negativas têm a palavra ATENÇÃO, além da cor; as positivas usam confirmação. Feedback fica sete segundos durante a ação e cresce para cima se precisar de mais linhas. Pausa interrompe sua duração junto com o jogo. Avisos educativos ficam no rodapé.

## Telas

Menu e seleção de fases integrados: marca, ação Continuar, personagem ativo, treino, configurações e cinco cartões com descrição e estado (atual, disponível, bloqueada ou concluída). Bloqueios continuam seguindo o progresso real.

Seleção de personagens: quatro prévias maiores, destaque da escolha, descrição, giro opcional, confirmação e retorno sem alteração. O viewport renderiza uma vez enquanto as prévias estão paradas; rotação opcional o mantém ativo. Falha ao gravar permanece explícita.

Pausa: resumo de tempo/pontos/limpeza, continuidade destacada, configurações, reinício e retorno. Configurações compartilham o tema, têm trilhos de volume visíveis e rótulos em português.

Vitória e derrota: motivo, três indicadores principais e resultados específicos de cada missão. Próxima fase/repetição recebem prioridade, sem ocultar erros, perdas ou avisos de gravação. Ao ver a área recuperada, a HUD sai para deixar a cena livre e o botão Mostrar resultados permanece acessível.

Conclusão: percurso animado das cinco localidades, totais dos melhores resultados, ações de plantio/proteção/bueiros e retorno/repetição. O mapa continua esquemático e as estatísticas continuam sendo ações simuladas. O treino recebeu o mesmo acabamento e uma faixa inferior mais estreita.

## Arquivos de implementação

Todos em `scripts/ui`:

| Arquivo | Mudança |
|---|---|
| `eco_theme.gd` | Paleta, fonte, painéis, variações de botão, barras e sliders |
| `eco_icon.gd` (novo) | Ícones vetoriais nativos |
| `gameplay_dashboard.gd` (novo) | Componentes e leitura dos indicadores das cinco fases |
| `phase_card.gd` (novo) | Cartões de localidades e estado do progresso |
| `mission_hud.gd` | Composição principal, menu, pausa, resultados e conclusão |
| `expansion_hud.gd` | Integração da HUD comum com instruções e inspeção das fases 4/5 |
| `character_selection.gd` | Layout das prévias, seleção e ações |
| `campaign_map.gd` | Percurso final escalável na área disponível |
| `settings_panel.gd` | Modal coerente com o tema e rótulos localizados |
| `training_hud.gd` | Acabamento e composição do treino |

Testes: `tests/test_interface.gd` (novo) e `tests/test_campaign.gd` (busca recursiva dos botões, agora aninhados nos cartões; mesmos objetivos e valores esperados). Documentação: README, GDD de trabalho, créditos, continuidade, validação e este relatório. Logs/capturas ficam em `tests/artifacts`.

Nenhum script de mecânica, controlador, colisão, objetivo, save ou cenário foi alterado nesta etapa.

## Verificação

- Executor `tests/run_all.ps1`: **604 verificações em 17 suítes, sem falhas**. A suíte nova possui 226 verificações; a campanha integrada continua concluindo as cinco fases com 2345 pontos e 70 destinos corretos nos cenários automatizados.
- Passagem gráfica pelo Godot/Vulkan: **260 verificações, zero falhas**, incluindo 34 capturas em 1280 × 720. Estados: instruções/gameplay/pausa/vitória/derrota nas cinco fases, menu novo e concluído, quatro personagens, falha de gravação, configurações, inspeção, barco cheio, conclusão e treino.
- Verificados limites dos painéis/botões, leitura dos materiais sem letras empilhadas, dados após coleta/destinação, carga cheia, mensagens longas, pausa, bloqueios, prévia sem gravação prematura e reabertura dos resultados.
- Capturas `ui_*.png` são estados de teste. Resultados com motivo “Prévia de interface” e avisos de gravação são casos deliberados de revisão; não representam a campanha do jogador ou um defeito constatado no seu save. Os testes usam caminhos próprios.
- Logs finais não contêm ERROR/SCRIPT ERROR. Algumas suítes headless ainda registram avisos ObjectDB de referências no encerramento, já observados anteriormente. A revisão gráfica final terminou sem esses avisos.

Para reproduzir capturas: executar o Godot com `--path . --script res://tests/test_interface.gd -- --capture-ui` a partir do projeto. Para a suíte completa: `./tests/run_all.ps1` no PowerShell.

## Impacto e limites

A hierarquia visual facilita encontrar prazo, pontuação e próxima tarefa sem procurar em um bloco único de texto. Carga e item em mãos ficam distinguíveis; o feedback deixa de competir permanentemente com os objetivos. Menus e resultados passam a compartilhar o mesmo acabamento e ordem de ações.

Os elementos são Control/StyleBox e desenho vetorial nativos, sem novas texturas, render targets de pós-processamento ou dependências. Não foi feita nova medição de FPS sustentados ou de tempo de GPU; não se promete ganho de desempenho. A validação de layout se refere a 1280 × 720; telas menores, fontes alternativas e acessibilidade adicional ainda precisam de avaliação própria. Retratos ilustrados, ícones artísticos dedicados e revisão tipográfica podem ser uma etapa futura. A avaliação humana de conforto e legibilidade ainda é útil antes de decidir novos ajustes.
