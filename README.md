# ECO MARICÁ — Guardiões da Cidade

Jogo acadêmico educativo 3D, offline, para Windows. Godot **4.7.2 Standard**, GDScript, renderizador Compatibility. Etapas 1 a 6 implementadas: três missões jogáveis e conclusão de campanha. Polimento e preparação da entrega acadêmica ainda pendentes.

## Executar
1. Abra/importe o `project.godot` desta pasta no Godot 4.7.2.
2. Pressione **F5**; a cena principal é `scenes/levels/aracatiba.tscn`.
3. No menu, use **Escolher personagem** para comparar as quatro prévias 3D e confirme sua escolha. Depois escolha **Jogar • Operação Araçatiba**, leia as instruções e clique em **Começar missão**.
4. Opcionalmente escolha o treino, que preserva as mecânicas da etapa 2. No treino, **M** volta ao menu e **R** reinicia.

## Personagens
- **Lucas:** explorador ambiental, colete verde e mochila.
- **Marina:** guardiã ambiental, uniforme turquesa e cabelo preso.
- **Rafael:** agente ambiental, colete laranja, boné e botas.
- **Bia:** protetora da natureza, jaqueta roxa e cabelo cacheado.

As quatro aparências usam o mesmo controlador, velocidades, pulo, cápsula de colisão, câmera e animações procedurais simples de parado, caminhada, corrida e coleta. Os modelos são provisórios, feitos com primitivas nativas; não usam pacotes externos.

Na seleção, os quatro personagens aparecem juntos. Clique no nome para ver a descrição; use **Girar prévias** para observar os acessórios. **Confirmar** salva a escolha e volta ao menu. **Voltar sem alterar** ou **Esc** cancela a prévia. O personagem confirmado aparece no treino e em Araçatiba, inclusive após reiniciar o jogo.

## Operação Araçatiba
- Explore uma representação fictícia estilizada da orla, com lagoa, ciclovia, vegetação, bancos e três pares de coletores.
- Recolha e destine **15 resíduos** (papel limpo e garrafas plásticas) em **300 segundos**.
- Vença com pelo menos **12 destinos corretos** e no máximo **3 erros**, concluindo todos os itens antes do tempo acabar.
- O **quarto erro** ou o tempo zerado encerra a missão. Na missão, o descarte errado consome o item; no treino, permite corrigir o mesmo item.
- Carregue um item por vez. **E** interage com o alvo próximo destacado; não funciona através de obstáculos.
- **WASD** move, **mouse** gira a câmera, **Shift** corre, **Espaço** pula, **Esc** pausa/retoma. Pausa e instruções suspendem o cronômetro; menus bloqueiam a coleta.
- Resultados mostram pontos, tempo usado, acertos, erros e Índice de Limpeza. Há reinício e retorno ao menu.

## Resgate de Itaipuaçu
Após vencer Araçatiba, use **Próxima fase • Resgate de Itaipuaçu** nos resultados ou o botão correspondente no menu.

- Praia fictícia com mar, areia, restinga e três estações de quatro coletores.
- Meta: **20 destinos corretos em 240 segundos**, com menos de **cinco perdas ao mar**.
- Quatro materiais: papel (azul), plástico (vermelho), vidro (verde) e metal (amarelo), sempre com identificação textual.
- Sete dos 20 resíduos iniciais se movem em direção ao mar. O texto **→ MAR** mostra a estimativa de segundos até a perda. Priorize os menores tempos.
- Coletar interrompe o movimento do item. Pausar com Esc interrompe o relógio e todos os resíduos móveis.
- Descarte incorreto: -5, quebra a sequência e mantém o item em mãos para correção. Não há derrota por quantidade de erros nesta fase.
- Até a quarta perda, um novo item aparece parado na areia, com novo ID. Isso permite alcançar 20 destinos corretos; a perda continua no contador e no índice. A quinta perda encerra a missão sem gerar reposição.
- Vitória concede +100, recupera simbolicamente o cenário e salva o desbloqueio do Centro. O Centro já é jogável após o desbloqueio, pela opção Próxima fase ou pelo menu.
- Partida perfeita: **520 pontos**. Com quatro perdas e 20 acertos, o índice é **83%** (20/24); as perdas não são apagadas.

## Alerta de Tempestade — Centro de Maricá
Após vencer Itaipuaçu, use **Próxima fase • Alerta de Tempestade**, ou inicie pelo menu se já estiver desbloqueado.

- Cidade fictícia com ruas, calçadas, casas, comércios e bueiros.
- Conclua **15 destinos corretos e três bueiros limpos em 180 segundos**. Papel, plástico, vidro e metal.
- Com as mãos livres, aproxime-se de um bueiro e pressione **E**. Cada um concede **+30**, uma única vez; os resíduos visuais sobre a grade desaparecem.
- Erro de classificação permite corrigir, com penalidade e quebra de sequência. Não há limite de erros nessa fase.
- Céu, nuvens, iluminação e chuva se intensificam conforme o tempo diminui. **Esc** congela tempo, chuva e interações.
- Só os resíduos ou só os bueiros não bastam: as duas metas são obrigatórias. Tempo zero causa derrota.
- O Índice de Limpeza inclui as 18 tarefas: 15 destinos e três bueiros. Partida perfeita: **515 pontos**.
- Ao vencer, escolha **Ver conclusão da campanha**. A conclusão é salva e pode ser revista no menu; derrotas posteriores não a apagam.

A limpeza é uma simulação de redução de um fator de risco, não garantia de evitar enchentes. Na vida real, comunique obstruções à prefeitura e evite áreas alagadas. As grades do jogo nunca são abertas; a ação não representa manutenção real de infraestrutura. Fontes oficiais e limites em `docs/escopo_e_creditos.md` e `docs/centro.md`.

## Pontuação e limpeza
- Coleta única: +5; destino correto: +10; incorreto: -5; mínimo zero.
- Cada bloco de três acertos consecutivos: +20. Um erro interrompe a sequência.
- Vitória na missão: +100 uma única vez. Partida perfeita: 425 pontos.
- Índice: destinos corretos / total de resíduos; no Centro, soma também os três bueiros no numerador e denominador. Em Araçatiba, uma vitória com 12 acertos e 3 erros mostra **80%**, sem apagar os erros pela transformação visual. Em Itaipuaçu, o denominador inclui os itens novos de reposição e as perdas permanecem contabilizadas.

## Progresso local
Ao vencer Araçatiba ou Itaipuaçu, o respectivo desbloqueio da próxima área é gravado em `user://mission_progress.json` com versão e validação de conteúdo. Arquivos ausentes/corrompidos usam o padrão seguro. Derrota não apaga desbloqueios e repetir uma fase anterior não rebaixa o progresso. A leitura continua compatível com o arquivo versão 1 já existente. Se a gravação falhar, os resultados avisam.

**As três fases são jogáveis, respeitando os desbloqueios.** A conclusão da campanha fica no campo `campaign_completed` do arquivo de progresso, preservando compatibilidade com os arquivos anteriores da versão 1. O desbloqueio continua em `user://mission_progress.json`; a escolha do personagem fica em **`user://player_profile.json`**, também versionado e validado, com gravação em temporário antes da substituição. Arquivo ausente/corrompido usa Lucas. Uma falha ao gravar mantém a escolha anterior e mostra aviso na seleção. Os dois arquivos são independentes; escolher personagem não apaga fases desbloqueadas. Melhores pontuações e áudio ainda pertencem às próximas etapas. Não há servidor ou banco externo.

## Testes por PowerShell
Execute da raiz do projeto (ajuste o caminho do motor se necessário):

```powershell
& 'C:\Users\CHARLE\Downloads\Godot\Godot_v4.7.2-stable_win64_console.exe' --headless --path . --import
& 'C:\Users\CHARLE\Downloads\Godot\Godot_v4.7.2-stable_win64_console.exe' --headless --path . --script res://tests/test_foundation.gd
& 'C:\Users\CHARLE\Downloads\Godot\Godot_v4.7.2-stable_win64_console.exe' --headless --path . --script res://tests/test_recycling.gd
& 'C:\Users\CHARLE\Downloads\Godot\Godot_v4.7.2-stable_win64_console.exe' --headless --path . --script res://tests/test_aracatiba.gd
& 'C:\Users\CHARLE\Downloads\Godot\Godot_v4.7.2-stable_win64_console.exe' --headless --path . --script res://tests/test_characters.gd
& 'C:\Users\CHARLE\Downloads\Godot\Godot_v4.7.2-stable_win64_console.exe' --headless --path . --script res://tests/test_itaipuacu.gd
& 'C:\Users\CHARLE\Downloads\Godot\Godot_v4.7.2-stable_win64_console.exe' --headless --path . --script res://tests/test_centro.gd
& 'C:\Users\CHARLE\Downloads\Godot\Godot_v4.7.2-stable_win64_console.exe' --headless --path . --script res://tests/test_campaign.gd
& 'C:\Users\CHARLE\Downloads\Godot\Godot_v4.7.2-stable_win64_console.exe' --path . --script res://tests/capture_aracatiba.gd
& 'C:\Users\CHARLE\Downloads\Godot\Godot_v4.7.2-stable_win64_console.exe' --path . --script res://tests/capture_characters.gd
& 'C:\Users\CHARLE\Downloads\Godot\Godot_v4.7.2-stable_win64_console.exe' --path . --script res://tests/capture_itaipuacu.gd
& 'C:\Users\CHARLE\Downloads\Godot\Godot_v4.7.2-stable_win64_console.exe' --path . --script res://tests/capture_centro.gd
```

226 verificações aprovadas na validação da etapa 6: 179 das etapas anteriores, 34 do Centro e 13 do fluxo completo de campanha. Testes da missão e dos personagens usam arquivos de progresso/perfil próprios em `tests/artifacts/`; não desbloqueiam fases no salvamento do jogador. As capturas usam estados simulados, não são evidência de uma partida humana. Detalhes e limites em `docs/validacao.md`.

## Organização
- `scenes/player`, `scripts/player`: controlador compartilhado e visual reutilizado nas quatro aparências e prévias.
- `scenes/levels`, `scripts/levels`: treino, missão, cenário e estados.
- `scenes/objects`, `scripts/gameplay`: resíduos, coletores, sessão e interação.
- `scripts/core`: regras, entradas, catálogo de personagens, perfil e desbloqueio local.
- `scripts/ui`: HUD e telas da missão.
- `tests`: testes no motor, capturas e evidências.
- `docs`: rastreabilidade, regras, créditos e validação.
- `.godot`: cache gerado; não versionar nem entregar.

## Fontes e limitações
Materiais identificados por nome e código de cores CONAMA 275/2001; fontes registradas em `docs/escopo_e_creditos.md`. Fora do jogo, consulte as regras de coleta local. Cenário fictício; não descreve condições atuais de Maricá. Arte e personagem feitos com primitivas; áudio, modelos finais, polimento, salvamento de melhores resultados, avaliação com pessoa externa e exportação Windows ainda pendentes.

## Repositório de destino
https://github.com/AmaralCharle/Eco_Marica.git

## Próxima etapa
Etapa 7 — Polimento: sons, ajuste de volume, melhorias de interface e aparência, salvamento de pontuação/melhores resultados, otimização e correções. Depois, preparar GDD final, teste externo, vídeo e exportação Windows.
