# Validação — histórico das etapas

16/11/2026 — cenários: 378 verificações em 16 suítes aprovadas. Novo teste de preservação física da camada decorativa e comparação gráfica antes/depois; ver `CENARIOS_2026_11_16.md`. As referências anteriores abaixo são históricas.

Estado mais recente: polimento audiovisual 3.0, **356 verificações em 15 suítes, sem falhas**. Renderizador padrão Forward Mobile/Vulkan, qualidade ajustável, áudio e opções implementados. Medições reais, capturas, avisos de encerramento e limitações em `POLIMENTO.md`; resumo final em `tests/artifacts/validation_summary.json`. As seções abaixo mantêm o histórico das versões anteriores.

Data: 14/11/2026. Godot 4.7.2.stable.official.ed1daf0bf, Windows 11 64 bits. Renderização gráfica observada: Intel UHD Graphics, OpenGL 3.3, modo Compatibility.

## Executado
- Importação headless do projeto: retorno 0, sem erros de parser reportados.
- `tests/test_foundation.gd`: retorno 0, **16 verificações, 0 falhas**. Carregamento da cena, repouso e bloqueio do chão, deslocamento por W, velocidade de caminhada, distância/velocidade de corrida, velocidade diagonal normalizada, pulo, retorno ao chão, parede, movimento relativo à câmera, limite lateral, dois limites de inclinação e câmera ativa.
- Inicialização pela cena principal configurada (`--headless --quit-after 60`): retorno 0, sem erros reportados.
- Captura gráfica `tests/capture_foundation.gd`: retorno 0; imagem inspecionada. Personagem, caminho, obstáculos e painel de controles visíveis, sem texto cortado na resolução testada (1280 × 720).

Evidências: `tests/artifacts/foundation-test.log`, `foundation-startup.log`, `foundation-visual.log` e `foundation.png`.

## Ajustes durante a validação
O primeiro percurso de teste da borda lateral encontrou um banco antes de chegar à borda. O percurso foi deslocado para uma faixa livre, mantendo os obstáculos do cenário. O painel de controles foi compactado após inspeção visual. O conjunto final de testes foi executado novamente e aprovado.

## Limites desta evidência
Os testes exercitam entradas de movimento simuladas e física real. Os limites matemáticos da câmera são automatizados; sensação dos controles, captura/liberação física do mouse, transição visual das animações e comportamento visual do SpringArm próximo a todos os obstáculos ainda exigem teste humano. Captura estática não mede fluidez. Não foram medidos FPS sustentados nem feita exportação Windows. Não houve teste de usabilidade com pessoa externa.

Na etapa 1 ainda não havia coleta, classificação, pontuação, missões ou salvamento; esses sistemas não são declarados como testados ou implementados. Não foram geradas evidências de impacto educativo.


## Etapa 2 — 14/11/2026
- Importação headless concluída, código 0. Um erro de inferência de tipo no novo script de teste foi corrigido antes da execução aprovada.
- `test_recycling.gd`: **35 verificações, 0 falhas**, código 0. Inclui modelo de pontuação, estados/IDs, coleta única, carregamento de um item, descarte correto/incorreto, penalidade com piso zero, bônus não sobreposto, quebra de sequência, limpeza, entrada E, HUD, alcance, obstáculo, ciclo completo de seis itens e reinício com R. Sessão integrada: seis destinos corretos, um erro, 125 pontos e 100% de limpeza.
- Regressão `test_foundation.gd`: **16 verificações, 0 falhas**, código 0. Total nesta etapa: **51 verificações aprovadas**.
- `capture_recycling.gd`: renderização OpenGL/Intel UHD Graphics, quatro capturas, código 0. Estados inicial, carregando, erro e acerto inspecionados; HUD legível em 1280 × 720. O script valida os contadores dos estados de erro/acerto antes de salvar as imagens correspondentes.
- Evidências: `tests/artifacts/recycling-test.log`, `foundation-test.log`, `recycling-visual.log` e `recycling_*.png`.

Ainda pendentes: teste humano de conforto/descoberta dos controles, pessoa externa, métricas de impacto, FPS sustentados, missões cronometradas, exportação Windows e salvamento. A conclusão do treino não é a vitória da missão Araçatiba. Sons e animação de coleta continuam pendentes; feedback atual é visual/textual.


## Etapa 3 — Operação Araçatiba — 14/11/2026
- Importação e inicialização da cena principal: código 0, sem erros de parser.
- `test_aracatiba.gd`: **32 verificações, 0 falhas**, código 0. Menu/instruções sem consumo de tempo, coleta bloqueada antes de começar, início, pausa por Esc, retomada, derrota no zero, bloqueio após resultado, até três erros, quarto erro, item consumido após erro, último item obrigatório, vitória 12/3, índice de 80%, 360 pontos, recuperação visual, gravação e releitura de desbloqueio, bônus sem duplicação, vitória antes do limite, partida perfeita com 425 pontos, derrota preservando progresso, reinício limpo, retorno ao menu, ciclo integrado de 15 itens e cinco tipos de arquivo inválido.
- O ciclo integrado usa reposicionamento automatizado perto de cada objeto e coletor, com a interação e linha de visão reais; não demonstra navegação autônoma nem substitui o percurso humano.
- As verificações de tempo usam `advance_time`, o mesmo método invocado por `_physics_process`, com passos determinísticos; não foi necessário aguardar cinco minutos de relógio real.
- Regressão final: `test_foundation.gd` **16/16**, `test_recycling.gd` **35/35**, todos com código 0 e sem erros nos registros finais. **Total: 83 verificações aprovadas.**
- `capture_aracatiba.gd`: sete capturas OpenGL/Intel UHD Graphics, código 0: menu, instruções, partida, pausa, vitória, recuperação e derrota. Todas inspecionadas em 1280 × 720, sem texto cortado nos painéis.
- Durante a primeira validação, mensagens do motor apontaram foco de controle durante troca de cena e parse de JSON inválido. Corrigidos com guarda de presença na árvore e parser que trata o retorno de erro. A execução final não apresentou essas mensagens.
- Evidências: `tests/artifacts/aracatiba-test.log`, `aracatiba-visual.log`, `aracatiba_*.png`, logs de regressão. Arquivos de progresso dos testes são próprios em `tests/artifacts/`, separados do `user://mission_progress.json` do jogador.

Limites atuais: arte provisória com primitivas, sem sons, sem escolha dos quatro personagens, sem fases 2/3 jogáveis. A recuperação é uma transformação simbólica (flores, vegetação e placa), não uma medida do ambiente real. Persistência salva somente o desbloqueio. Ainda faltam teste externo com perfil registrado e métricas reais de aprendizagem, avaliação de dificuldade por pessoa, desempenho sustentado, vídeo e exportação. Resultados de capturas e testes automatizados não são resultados de participantes humanos.


## Etapa 4 — Personagens e seleção — 14/11/2026
- Importação e inicialização da cena principal: retorno 0, sem erros de parser reportados.
- `test_characters.gd`: **49 verificações, 0 falhas**, retorno 0. Catálogo de quatro identidades, perfil ausente, gravação e releitura dos quatro IDs (incluindo substituição de arquivo existente), ID inválido, cinco estruturas de perfil inválidas, falha de escrita, criação das quatro prévias, prévia sem gravação, cancelamento, tempo e interações suspensos, confirmação dos quatro personagens, preservação do desbloqueio de fase, recuperação em nova instância, Esc cancelando e aviso de falha na interface.
- O teste carrega o perfil salvo no treino e mede, com física real, caminhada 4 m/s, corrida 7 m/s, pulo e retorno ao chão para cada aparência. A cápsula mantém raio 0,32 m. Verifica animação procedural de coleta, acessórios sem duplicação após troca repetida e fallback visual para Lucas.
- Regressão final: fundação **16/16**, reciclagem **35/35**, Araçatiba **32/32**, todos com retorno 0. **Total final: 132 verificações aprovadas**, sem erros nos registros finais.
- `capture_characters.gd`: seis capturas, retorno 0, OpenGL/Intel UHD Graphics. Menu, prévia selecionando Lucas/Marina/Rafael/Bia e Bia em Araçatiba. Todas inspecionadas em 1280 × 720; nomes alinhados às prévias, descrições e confirmação legíveis.
- Evidências: `tests/artifacts/characters-test.log`, `characters-visual.log`, `characters_*.png` e logs de regressão. Perfis e progresso de teste usam caminhos próprios em `tests/artifacts/`, sem gravar os arquivos do jogador em `user://`.

Limitações: personagens construídos com primitivas, com animações procedurais simples; não há rig ou modelos artísticos finais. Não foram desenvolvidas as fases 2 e 3. A compatibilidade atual foi exercitada no treino e em Araçatiba; a validação nas fases futuras só poderá ocorrer após criá-las. A rotação opcional das prévias e a sensação de movimento ainda devem ser avaliadas manualmente. Teste com pessoa externa, métricas de aprendizagem, áudio, melhores resultados, vídeo e exportação continuam pendentes.


## Etapa 5 — Resgate de Itaipuaçu — 14/11/2026
- Importação e inicialização headless da cena da fase 2: retorno 0, sem erros de parser.
- `test_itaipuacu.gd`: **47 verificações, 0 falhas**, retorno 0. Bloqueio antes de Araçatiba; 20 itens, cinco de cada material; 12 coletores; personagem aplicado; sete resíduos móveis; delta; menu/pausa congelando objetos e tempo; indicador textual; coleta interrompendo movimento; impossibilidade de perder item carregado; erro corrigível; quatro perdas com reposição única; perda/recoleta duplicada rejeitada; vitória ainda possível após quatro perdas; índice 20/24 = 83%; gravação/releitura do nível 3; bônus único; recuperação visual; bloqueio pós-resultado; quinta perda e tempo zero; partida perfeita 520 pontos; reinício; transição preservando perfil/caminhos e progresso; ciclo integrado de 20 destinos e progresso monotônico.
- A primeira execução detectou sobreposição entre um resíduo e o coletor da estação central. A estação foi reposicionada e o ciclo integrado com os 20 itens passou.
- Regressão final: fundação 16/16, reciclagem 35/35, Araçatiba 32/32 e personagens 49/49. **Total: 179 verificações aprovadas**, todos com retorno 0 e sem erros nos registros finais.
- `capture_itaipuacu.gd`: nove capturas, retorno 0, OpenGL/Intel UHD Graphics. Menu, instruções, partida, risco após avanço simulado, pausa, erro de classificação, vitória, recuperação e derrota. Todas inspecionadas em 1280 × 720. Capturas de estados simulados, não uma sessão humana.
- Os testes de deslocamento usam o mesmo `advance_time`/`advance_drift` da física em passos controlados. O ciclo integrado reposiciona o jogador perto dos objetos e coletores; não comprova percurso humano completo nem balanceamento dos 240 segundos.
- Evidências: `tests/artifacts/itaipuacu-test.log`, `itaipuacu-visual.log`, `itaipuacu_*.png` e logs das quatro regressões. Perfis e progresso de testes ficam em `tests/artifacts/`, sem desbloquear fases no salvamento real do jogador.

Ainda pendentes: avaliação humana de dificuldade/priorização, teste externo com perfil registrado e métricas reais de aprendizagem, ritmo de partida, arte final, áudio, Centro de Maricá, persistência completa, vídeo e exportação Windows. O mar usa deslocamento programado simples, não simulação física de correntes.


## Etapa 6 — Alerta de Tempestade e campanha — 14/11/2026
- Importação e inicialização da cena Centro: retorno 0, sem erros de parser reportados.
- `test_centro.gd`: **34 verificações, 0 falhas**, retorno 0. Bloqueio antes da fase 2, 15 itens/três bueiros, personagem aplicado, IDs de bueiro inválidos/duplicados, limpeza bloqueada no menu, tempestade/tempo suspensos, intensidade 0,5 com chuva, pausa congelando céu/gotas/tempo, mãos livres, correção após erro, +30 único, tempo zero, ações travadas após resultado, metas independentes não vencem, índices 83%/17%/100%, partida perfeita de 515 pontos, recuperação simbólica, campanha salva/recarregada, bônus único, estado FINALIZADO, revisão no menu, derrota/repetição preservando conclusão, reinício limpo, entrada E e alteração visual, ciclo integrado de 15 resíduos e três bueiros, validação do booleano de conclusão.
- `test_campaign.gd`: **13 verificações, 0 falhas**, retorno 0. Fluxo de um perfil novo pelas três missões: menu, instruções, começo, vitória, botões Próxima fase, manutenção do personagem/caminhos, conclusão, retorno e revisão no menu. As ações de classificação são simuladas diretamente na sessão; isso verifica a integração e não substitui uma partida humana.
- Regressões finais: fundação 16/16, reciclagem 35/35, Araçatiba 32/32, personagens 49/49 e Itaipuaçu 47/47. **Total: 226 verificações aprovadas**, todos com retorno 0, sem erros nos registros finais.
- `capture_centro.gd`: onze capturas, retorno 0, OpenGL/Intel UHD Graphics. Menu, instruções, partida, chuva, bueiro antes/depois da limpeza, pausa, vitória, conclusão e derrota. Todas inspecionadas em 1280 × 720; textos de controles e resultados legíveis.
- Evidências: `tests/artifacts/centro-test.log`, `campaign-test.log`, `centro-visual.log`, `centro_*.png` e logs das regressões. Testes/capturas usam arquivos próprios em `tests/artifacts/`, não completam a campanha do jogador em `user://`.

Limites: avanço de tempo controlado e reposicionamento perto dos objetos nos testes integrados. Não houve partida humana completa cronometrada, teste externo com perfil/métricas de aprendizagem, medição de FPS sustentados ou validação da dificuldade dos 180 segundos. A chuva é um efeito simples; não há simulação hidrológica ou previsão meteorológica. Áudio, polimento e salvamento de melhores resultados seguem para a etapa 7; GDD final, vídeo, validação externa e exportação Windows ainda pendentes.


## Correção do Centro e expansão — execução atual
Checkpoint de preservação: 6ea7e11. Resultado do executor `tests/run_all.ps1`: **306 verificações, zero suítes com falha**, em 13 suítes, com inspeção de códigos de saída e ausência de `ERROR`/`SCRIPT ERROR` nos logs finais. Resumo derivado dos logs: `tests/artifacts/validation_summary.json`.

Suítes e contagens: Araçatiba 32; barco isolado 9; campanha cinco fases 18; acesso Centro 14; Centro 34; personagens 49; fundação 16; Itaipuaçu 47; acesso Ponta Negra 6; Ponta Negra 20; migração/estatísticas 8; reciclagem 35; Ubatiba 18.

Ubatiba: inspeção antes de ação, preparo, plantio, proteção, preservação, duplicação bloqueada, quarta decisão incorreta, prazo de 300s, vitória 12/8/3 e migração de final antigo. Testes corrigiram leitura de versões numéricas em JSON e limpeza de painel ao trocar inspeção.

Barco: teste isolado de aceleração/velocidade/rotação/desaceleração/colisão/embarque/desembarque. Na fase real: caminhada ao píer sem pular, pausa de barco e resíduos, passagem sob ponte, margem e limite terrestre. Integração: cinco itens, sexto rejeitado, quatro viagens, descarga/classificação, perdas apenas após cruzamento, quinto escape e vitória ainda possível com quatro perdas/reposição. Um teste de reposição ajustou a aproximação para selecionar o objeto desejado entre vizinhos próximos; não foram apagados objetos para fazê-lo passar.

Campanha: cinco fases por botões de próxima fase, personagem e caminhos preservados, placares 425/520/515/365/520 em estados simulados sem erro, soma 2345 e 70 destinos corretos. Essas são saídas do teste, não estatísticas de jogadores externos. Repetir resultado pior não aumenta acumulado. Saves antigos não recebem dados fabricados.

Verificação gráfica: quatro capturas de Ubatiba (instruções, terreno, inspeção e vitória) e sete de Ponta Negra (instruções, margem, barco, carga cheia, descarga, vitória e final). Renderizador real Compatibility/OpenGL, Intel UHD Graphics, 1280 × 720. Painéis inspecionados; modelos e efeitos são provisórios. Os estados são automatizados e não constituem uma partida manual.

Limitações preservadas: tempo e reposicionamento controlados em parte dos testes; sem avaliação externa, medições de aprendizagem ou FPS sustentados. Balanceamento dos prazos e conforto da navegação ainda precisam de partida humana. Áudio/volume e polimento foram deliberadamente deixados para a próxima etapa, conforme solicitado. GDD de trabalho em Markdown atualizado; versão final DOCX/PDF, vídeo e exportação Windows ainda não preparados.

## Interface — 16/11/2026

604 verificações em 17 suítes, sem falhas. `test_interface.gd` acrescenta 226 verificações de dados visíveis, limites de layout, bloqueios, personagens, pausa, inspeção, carga cheia e resultados nas cinco fases. Revisão gráfica Forward Mobile/Vulkan: 260 verificações, 34 capturas 1280 × 720, sem falhas. Capturas são estados automatizados, incluindo avisos de gravação deliberados; não constituem teste externo. Detalhes e limites em `INTERFACE_2026_11_16.md`; logs e `validation_summary.json` em `tests/artifacts`.

## Personagens — 16/11/2026

661 verificações em 18 suítes, sem falhas. A nova `test_character_visuals.gd` acrescenta 57 verificações da geometria, fronteira GLB sintética, animações mapeadas, fallback, qualidade e quatro passageiros. A suíte anterior mantém seus 49 casos de perfil e física dos quatro personagens. Revisão gráfica e limites em `PERSONAGENS_2026_11_16.md`; benchmark de vistas controladas Alto/MSAA 8×: 66,12–82,97 FPS médios em 1280 × 720. Não representa uma partida humana completa.

## Direção de arte por referências — 16/11/2026

727 verificações em 19 suítes, sem falhas. `test_art_direction.gd` acrescenta 66 casos de preservação de áreas de interação e identificação, vegetação, céu, riacho/canal e atualização contínua da luz na tempestade. Testes físicos e de campanha anteriores mantidos. Capturas e benchmark Alto/1280 × 720 em `art_reference_*` e `art_detail_*`; relatório e limites em `DIRECAO_ARTE_REFERENCIAS_2026_11_16.md`. Vistas controladas e poses de revisão não substituem partida humana ou teste externo.

## Upgrade visual 4 — 16/11/2026

Execução final: **968 verificações em 22 suítes, zero falhas**, sem ERROR/SCRIPT ERROR nos logs conferidos pelo executor. Inclui decisões opcionais nas cinco fases, atalhos Q/Esc, estrelas, persistência compatível, campanha clássica, física, personagens e layouts 720p/1080p. `capture_upgrade.gd` produziu 36 capturas; uma simulação controlada completou cinco vitórias, 15 estrelas e cinco opcionais. Esses dados não pertencem ao save real do jogador nem comprovam uma partida humana.

Três renderizadores e três perfis foram medidos; Mobile foi mantido. Alto registrou aproximadamente 61–81 FPS médios em vistas 1280 × 720. Quatro ciclos das cinco fases retornaram a 18 nós e zero órfãos, RSS 889–900 MiB sem crescimento contínuo. Isso não garante FPS mínimo nem ausência universal de vazamentos. Alguns testes headless com encerramento imediato ainda apresentam avisos de AudioStreamWAV; a captura final e o ensaio com encerramento suave terminaram sem esses avisos. Relatório: `VISUAL_UPGRADE_4.md`; medições: `visual_upgrade_audit.md`.


## Asset Revolution — 16/11/2026

Executor completo final: **1062 verificações em 23 suítes, zero falhas**, sem ERROR/SCRIPT ERROR nos logs finais. Inclui 94 casos novos de assets efetivamente exibidos, preservação de malhas filhas das palmeiras, PBR/sky 1K ativos, rigs/equipamentos/animações dos quatro personagens, pausa, aves e barco. Os 93 testes do fallback procedural/adaptador sintético permanecem; a expectativa de qualidade foi atualizada para MSAA 4×, justificada por benchmark de copas. Regressões anteriores de física, campanha, saves, estrelas, opcionais, UI e 720p/1080p mantidas. Resumo efetivo em tests/artifacts/validation_summary.json. Avisos de áudio em alguns encerramentos headless imediatos permanecem explicitamente registrados; não equivalem a falhas de lógica, mas também não autorizam declarar ausência universal de vazamentos.

## Expansão Ponta Negra — 16/11/2026

Bateria completa: 1184 verificações em 24 suítes, zero falhas e nenhuma mensagem ERROR/SCRIPT ERROR nos logs finais. test_fisheries.gd acrescenta 122 casos de falas, foco, redes, contato WASD, pausa, quatro passageiros/remadas e música por fase; foi reexecutado após reforçar foco na câmera do barco. Onze capturas de revisão em 720p, PCM das cinco músicas inspecionado e mil frames medidos por perfil Alto/Médio. Resultados e limites em PONTA_NEGRA_PESCADORES.md. Ensaios automatizados não substituem uma partida humana prolongada; avisos em encerramento headless imediato permanecem registrados.
