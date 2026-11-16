# ECO MARICÁ — Guardiões da Cidade

GDD de trabalho da campanha de cinco fases. Estrutura baseada no modelo de 16 seções do Prof. Tiago Ruiz de Castro, Desenvolvimento de Jogos Digitais, Universidade de Vassouras. O arquivo descreve a implementação atual; a entrega final em DOCX/PDF e os dados da equipe serão preparados na etapa de entrega.

Identificação: tema 03 — Meio ambiente e cidade limpa; Godot 4.7.2 Standard; GDScript; 3D em terceira pessoa; Windows; um jogador offline. Destino do código: https://github.com/AmaralCharle/Eco_Marica.git . Integrantes, matrículas, data de entrega e link do vídeo: pendentes de informação/produção. Não foram inventados esses dados.

## 1. O problema
Hipótese de problema: estudantes em uma atividade educativa confundem a identificação de materiais, a destinação dos resíduos e a prioridade de ações de recuperação ambiental em cenários urbanos, rurais e aquáticos. Recorte de uso: uma sessão de jogo em computador, em contexto escolar. Essa descrição é uma suposição de design a validar; não há levantamento de estudantes nem evidência sobre condições atuais de Maricá.

Referências oficiais fundamentam o conteúdo ambiental, mas não demonstram que esse público específico apresenta o problema. O jogo coloca decisões no cenário e mostra consequências/retorno, em vez de apenas expor uma cartilha. A efetividade comparada com cartilha ou vídeo permanece não medida.

## 2. Público-alvo
Perfil provisório: estudantes adolescentes e jovens com leitura em português e familiaridade básica com teclado/mouse. Idade, escola e nível de conhecimento devem ser confirmados antes do teste externo. Uso proposto: Windows em atividade orientada, partidas curtas por fase. Barreiras presumidas: identificar material, escolher destino, perceber prioridade e reconhecer que nem toda área deve receber plantio.

Acessibilidade implementada: nomes escritos além de cores, contraste nos painéis, instruções, pausas, retorno textual sem depender de som, habilidades iguais para quatro personagens. Não há suporte a controle, leitor de tela ou remapeamento completo nesta versão. Conforto e legibilidade precisam de avaliação por pessoa externa.

## 3. Objetivo de impacto
Objetivos propostos: identificar o material de exemplos simples, decidir o coletor correto; priorizar resíduos com risco de perda; escolher entre preparar/plantar/proteger/preservar conforme informação do terreno. Hipótese: se o jogador precisa observar o material e as propriedades do ponto para cumprir metas, então poderá praticar escolhas ambientais mais específicas, porque o retorno relaciona ação e consequência.

A mudança fora do jogo não foi medida. Os contadores são ações simuladas e não representam resíduos reais removidos, árvores reais plantadas ou riscos reais evitados.

## 4. Conceito do jogo
Aventura educativa 3D em que um guardião percorre representações fictícias de cinco localidades de Maricá. O jogador separa resíduos, prioriza perdas, realiza ações simuladas de drenagem/restauração e navega para acessar resíduos aquáticos.

Terceira pessoa, um jogador offline, personagens Lucas/Marina/Rafael/Bia com mesmas habilidades. Pilares: observar antes de agir, retorno legível, progressão por novas responsabilidades. Godot/GDScript permitem cenas reutilizáveis e testes nativos, sem servidor ou banco externo. Arte low-poly aprimorada e Forward Mobile equilibram apresentação e custo. As imagens enviadas pelo autor orientaram cores, composição e ambientes; não são modelos importados. Benchmarks controlados, metodologia e limites em `POLIMENTO.md`.

## 5. Mecânica dinâmica e estética
| Mecânica implementada | Dinâmica esperada | Experiência pretendida | Relação com o problema |
|---|---|---|---|
| Ler material e destinar no coletor identificado | Observar antes de confirmar | Domínio gradual | Reconhecimento e classificação |
| Resíduos móveis e limite de perdas | Priorizar menor prazo de risco | Atenção e urgência moderada | Relação entre decisão e perda ambiental simulada |
| Resíduos mais três bueiros no Centro | Planejar tarefas complementares | Responsabilidade | Drenagem como redução de um fator de risco |
| Inspeção, preparo, plantio e proteção em Ubatiba | Diferenciar necessidade por ponto | Cuidado e recuperação | Impede pontuar plantando aleatoriamente |
| Preservar quatro pontos não aptos | Reconhecer quando não intervir | Discernimento | Vegetação existente e adequação importam |
| Barco com carga de cinco e retorno ao píer | Organizar viagens e descarga | Exploração e planejamento | Coleta só se completa com destinação |

## 6. Regras e jogabilidade
Ciclo: menu, escolha de personagem, escolha de fase desbloqueada, instruções, ações da missão, retorno, vitória/derrota, reinício/próxima fase/menu. Ao concluir Ponta Negra há celebração e mapa esquemático das cinco localidades.

Controles terrestres: WASD, mouse, Shift para correr, Espaço para pular, E para interagir, Esc para pausar. Ubatiba: E abre inspeção; botões escolhem ação; o tempo continua durante decisão. Barco: E embarca perto do píer, W/S controlam aceleração/recuo, A/D giram; E recolhe; próximo ao píer e quase parado, E desembarca. Capacidade de cinco, um resíduo por vez em mãos ao descarregar.

Pontuação compartilhada: coleta única +5; destino correto +10; erro -5, mínimo zero; cada bloco de três acertos consecutivos +20; erro quebra sequência; missão +100 uma única vez. Bueiro +30 único. Ubatiba: preparar +5, plantar +20, proteger +15, preservar +5; repetição não pontua e ação incorreta desconta 5. Inspecionar não gera pontos por repetição. Índices são calculados a partir de tarefas e itens registrados, não somente coleta.

| Fase | Objetivos e prazo | Vitória | Derrota |
|---|---|---|---|
| Araçatiba | 15 itens, pelo menos 12 destinos corretos, 300s | Todos classificados, pelo menos 12 acertos, no máximo três erros | Quarto erro ou tempo zero |
| Itaipuaçu | 20 destinos corretos, quatro materiais, 240s | Meta completa, menos de cinco perdas | Quinta perda ou tempo zero |
| Centro | 15 destinos corretos e três bueiros, 180s | Ambas as metas completas | Tempo zero |
| Ubatiba | 12 avaliações, oito plantios e três proteções, 300s | Todas as metas, até três decisões incorretas | Quarta decisão incorreta ou tempo zero |
| Ponta Negra | 20 destinos corretos usando barco, 360s | Meta completa e menos de cinco perdas | Quinta saída efetiva da zona ou tempo zero |

Araçatiba consome o item no descarte errado; treino, Itaipuaçu, Centro e Ponta Negra permitem correção. Até a quarta perda nas fases 2 e 5, outro ID aparece em área alcançável para manter a meta possível. O perdido continua registrado. O bônus de missão e a coleta não podem ser duplicados pelo mesmo ID. Fases são desbloqueadas sequencialmente.

## 7. Progressão e dificuldade
Araçatiba introduz papel/plástico. Itaipuaçu acrescenta vidro/metal e prioridade por movimento. Centro combina classificação e drenagem sob prazo menor. Ubatiba acrescenta diagnóstico e sequência de ações em vez de coleta. Ponta Negra combina controle de embarcação, limite de carga, retorno e destinação.

Parâmetros em `scripts/core/game_config.gd`: durações, metas, limites de erro/perda, velocidade de deslocamento, alcance, pontuação e movimento do barco. O jogador lê instruções antes do relógio começar. O treino permanece acessível. Balanceamento por pessoa ainda pendente.

## 8. Motivação e ética
Impulsos propostos: domínio por retorno/objetivos claros e significado por cuidado ambiental; orientação white hat, sem monetização, culpa ou penalidade que apague fases já conquistadas. Perfis favorecidos: realizadores e exploradores. Esses enquadramentos são interpretações de design, não resultados observados.

O cenário é fictício; não acusa localidades reais de degradação. Cor é acompanhada por nome. Reposição não recupera magicamente o objeto perdido: o contador e o índice preservam a perda. Plantio não garante estabilidade e limpeza não garante evitar enchentes. Barco/água são simplificados e não ensinam condução real. Fontes oficiais na seção 16.

## 9. Mundo narrativa e personagens
Maricá estilizada e fictícia. O guardião conclui ações educativas em Araçatiba, Itaipuaçu, Centro, Ubatiba e Ponta Negra. A mudança visual é simbólica. Lucas: verde/mochila; Marina: turquesa/cabelo preso; Rafael: laranja/boné/botas; Bia: roxo/cacheados. Todos compartilham controlador, cápsula, câmera e habilidades.

Entidades: resíduos com ID/estado, coletores, bueiros, pontos de restauração e barco com passageiro/carga. Modelos provisórios produzidos com primitivas do Godot; sem assets externos.

## 10. Level design
Araçatiba: percurso de orla com estações próximas, ciclovia e vegetação. Itaipuaçu: praia com faixas de coleta e mar a oeste. Centro: rua com calçadas, rampas de acesso e coletores no nível da rua; três bueiros distribuídos pelo trajeto. Ubatiba: 12 pontos em quatro faixas, três solos expostos aptos, cinco falhas de cobertura aptas e quatro pontos de preservação; demonstração decorativa de chuva/solo e riacho. Ponta Negra: canal limitado, ponte com passagem para barco, píer e coletores em terra; 20 itens em faixas alcançáveis.

As malhas e posições efetivas estão nos scripts de cenário e nos testes/capturas. O mapa final é esquemático, sem compromisso cartográfico. Ainda faltam diagramas/mapas de entrega final e avaliação de ritmo por pessoa.

## 11. Arte interface e áudio

Direção de arte por referências atualizada em 16/11/2026: copas, vegetação, fachadas, relevo de fundo, atmosfera e água, com prioridade Centro/Ubatiba/Ponta Negra e coerência nas cinco fases. Recursos procedurais originais; as imagens fornecidas não foram incorporadas aos assets. Colisões e objetivos preservados. Detalhes e limitações em `DIRECAO_ARTE_REFERENCIAS_2026_11_16.md`.

Personagens revistos em 16/11/2026: corpo contínuo, rosto e olhos com piscar, cabelo, roupas e equipamentos próprios para as quatro identidades. Validação inicial com Lucas; aplicação posterior aos demais. Controlador/cápsula/câmera preservados. Modelos procedurais, com montagem opcional de GLB e mapa de animações em estrutura separada. Qualidade Alta ampliada para MSAA 8×/sombras 4096. Ver `PERSONAGENS_2026_11_16.md` e `MODELOS_GLB.md` para evidências e limites.

Interface revisada em 16/11/2026: HUD modular nas bordas, cartões das cinco localidades, prévias de personagens maiores e telas de pausa/resultados/conclusão com hierarquia comum. Preserva regras e todos os indicadores. Detalhes em `INTERFACE_2026_11_16.md`; teste de interface e capturas a 1280 × 720.

Polimento dos cenários atualizado em 16/11/2026: superfícies, vegetação, água, iluminação, atmosfera e detalhes ambientais das cinco fases, com destaque para Centro/Ubatiba/Ponta Negra. Preserva objetivos e colisões. Implementação, verificação e limitações registradas em `CENARIOS_2026_11_16.md`; origem dos recursos em `ASSETS_E_CREDITOS.md`.
Primitivas low-poly, vegetação e água estilizadas, materiais leves e sem texturas baixadas. Personagens, plantio, chuva e água usam efeitos procedurais simples. Menu com cinco fases, seleção de quatro personagens, instruções, HUD, pausa, vitória/derrota, inspeção de terreno e encerramento com mapa/estatísticas.

As estatísticas finais são dos melhores resultados registrados por missão; repetir uma pontuação menor não aumenta nem reduz o acumulado. Saves antigos não recebem estatísticas fabricadas. O mixer `GameAudio` separa Master/Music/Ambience/SFX; volumes, câmera e qualidade possuem preferências locais. Sons e músicas originais sintetizados por código são provisórios, com origem registrada em `ASSETS_E_CREDITOS.md`. Fonte de interface: SystemFont com Segoe UI/Noto Sans/Arial e fallback nativo do Godot, sem redistribuição de fontes; ícone original preservado e marca vetorial de folha nos menus.

## Upgrade 4 — extensão das seções 5–13

Branch de avaliação `upgrade-visual-4`, preservando `main`/tag `fase-1-final`. Q abre decisões opcionais com tempo pausado: separação de partes removíveis em Araçatiba (sem mudar as 15 unidades), vento lateral limitado em Itaipuaçu, prioridade por proximidade de resíduos aos bueiros no Centro, leitura do laudo em Ubatiba e planejamento de carga/distância em Ponta Negra. Cinco opcionais independentes da vitória. Não há penalidade principal por revisão do caderno.

Estrelas: 1 por vitória; 2 com até dois erros e duas perdas nas fases pertinentes, com limite de um erro em Ubatiba; 3 sem erros/perdas. Velocidade não aumenta a nota e estrelas não bloqueiam progressão. Melhor nota independe do melhor score. Tentativas, histórico e opcionais são extensões aditivas do save versão 2; dados históricos ausentes não são fabricados. Câmeras e colisões permanecem.

Materiais, folhas, respingos, barco, recuperação simbólica e cotovelos visuais evoluídos. Perfis com densidade/efeitos e resolução interna; Baixo mantém a HUD e toda a jogabilidade. Regras completas, parâmetros, arquivos/funções e validações em `VISUAL_UPGRADE_4.md`; medições em `visual_upgrade_audit.md`. O documento descreve a versão de avaliação, ainda sujeita à partida humana e à revisão do autor.

## 12. Arquitetura técnica
Motor Godot 4.7.2 Standard, GDScript; recursos nativos, sem bibliotecas externas de execução. Máquina observada: Windows 11 64 bits, Intel Core i5-12450H, aproximadamente 12 GB de RAM instalada e Intel UHD Graphics. Renderização padrão Forward Mobile/Vulkan após ensaios comparativos, em 1280 × 720. Há benchmarks de vistas controladas das cinco fases, sem garantia de FPS sustentados em partida humana; resultados em `POLIMENTO.md`.

`scenes/levels` guarda cenas próprias; `scripts/levels` define cenários e objetivos; `scripts/core` reúne configuração/catálogo/perfil/progresso; `scripts/gameplay` separa sessão, interação, restauração e inventário; `scripts/player` contém controlador terrestre, aparências e barco; `scripts/ui` contém HUD, seleção e mapa; `tests` guarda testes e evidências; `docs` documentação.

O controlador de missões existente é reutilizado por herança, com substituição de objetivos e tempo em cada fase. O estado JOGANDO habilita ações; menu, pausa e resultados bloqueiam. Movimento usa `_physics_process(delta)` e `move_and_slide`, colisões nativas e linha de visão para interação. O barco possui controlador/câmera separados e limites de navegação. O estado STORED identifica itens na carga antes da transferência para mãos; transferência não repete a recompensa.

Persistência local: perfil em `user://player_profile.json`, progresso em `user://mission_progress.json`. Progresso versão 2 lê a versão 1: um final antigo de três fases libera Ubatiba, mantém o personagem e não conclui a campanha expandida. Não inventa resultados ausentes. Gravação temporária antes de substituição. Melhor resultado por fase, desbloqueios e estatísticas preservados. Preferências independentes em `user://eco_settings.cfg`.

Executar: abrir `project.godot` no Godot 4.7.2, F5, escolher personagem/fase e seguir instruções. Testes: executar `tests/run_all.ps1` no PowerShell ajustando o caminho do motor, se necessário. Passo a passo completo no README.

## 13. Rastreabilidade do GDD ao código
| Regra | Seções | Arquivo e função real | Estado e evidência |
|---|---|---|---|
| Coleta única, classificação e piso zero | 5, 6 | scripts/gameplay/recycling_session.gd: collect, sort_into | Implementado; test_recycling.gd |
| Movimento/câmera compartilhados | 6, 9 | scripts/player/guardian.gd: _physics_process, apply_look | Implementado; test_foundation.gd, test_characters.gd |
| Quatro aparências/perfil | 9, 11, 12 | scripts/player/character_appearance.gd: apply_character; scripts/core/player_profile.gd: select_character | Implementado; test_characters.gd |
| Metas/tempo de Araçatiba | 6, 7 | scripts/levels/aracatiba.gd: advance_time, evaluate_objectives | Implementado; test_aracatiba.gd |
| Resíduos móveis/perdas/reposição | 6, 7 | scripts/levels/itaipuacu.gd: evaluate_objectives; scripts/gameplay/drifting_waste.gd: advance_drift | Implementado; test_itaipuacu.gd |
| Bueiros e tempestade | 6, 7 | scripts/levels/centro.gd: evaluate_objectives; scripts/gameplay/recycling_session.gd: clean_drain; scripts/levels/centro_world.gd: advance_storm | Implementado; test_centro.gd |
| Acesso aos coletores/calçadas | 6, 10 | scripts/levels/centro.gd: spawn_objects; scripts/levels/centro_world.gd: _ready | Corrigido; test_centro_access.gd sem pulo |
| Inspeção/preparo/plantio/proteção/preservação | 5, 6 | scripts/gameplay/restoration_session.gd: inspect, act, resolved; scripts/levels/ubatiba.gd: choose_action | Implementado; test_ubatiba.gd e capturas |
| Barco: aceleração, rotação, colisões, câmera e embarque | 6, 10 | scripts/player/boat.gd: embark, disembark, _physics_process | Implementado; test_boat.gd e test_ponta_access.gd |
| Carga máxima de cinco/descarga sem pontos repetidos | 6 | scripts/gameplay/canal_session.gd: store_from_boat, take_next_to_hand; scripts/levels/ponta_negra.gd: auto_unload | Implementado; test_ponta_negra.gd |
| Saída efetiva de resíduos e reposição controlada | 6, 7 | scripts/gameplay/floating_waste.gd: advance_float; scripts/levels/ponta_negra.gd: evaluate_objectives | Implementado; testes de travessia, cinco perdas e vitória após quatro |
| Progressão, migração e melhor resultado | 7, 12 | scripts/core/mission_progress.gd: _init, record_result, total_score; scripts/levels/aracatiba.gd: open_level | Implementado; test_progress_extension.gd, test_campaign.gd |
| Final somente após Ponta Negra | 6, 11 | scripts/levels/aracatiba.gd: show_campaign_completion; scripts/ui/mission_hud.gd: update_screen; scripts/ui/campaign_map.gd: _draw | Implementado; teste completo de cinco fases e captura |

Rastreabilidade complementar do polimento em `POLIMENTO.md`: mixer/volumes (`game_audio.gd`), decoração/qualidade (`world_polish.gd`), efeitos observadores (`mission_presentation.gd`), câmera (`camera_transition.gd`), aparências (`character_appearance.gd`) e tema (`eco_theme.gd`). Testes adicionais: `test_audio.gd` e `test_presentation.gd`. Situações parciais: revisão humana de áudio/arte, teste externo, rigs, vídeo e exportação.

## 14. Testes e validação
Ver `validacao.md` e logs do executor para contagem efetivamente executada. Testes automatizados cobrem regras, limites, estados, persistência, física, acesso, barco e transições. Capturas no renderizador real são evidência visual de estados simulados. Testes que reposicionam o jogador não substituem percurso humano nem balanceamento.

Teste externo: pendente. Perfil de participante, observações e mudanças: não registrados. Métrica de comportamento proposta: erros de decisão/classificação e perdas por missão; dados do jogo são registrados por resultado. Métrica de impacto proposta: acertos em tarefa equivalente antes/depois da sessão, fora do jogo; ainda não coletada nem implementada como pesquisa. Critério de sucesso educativo deve ser definido pela equipe antes do teste. Não há dados para afirmar redução real de erro ou aprendizagem.

Defeitos conhecidos/limitações: modelos procedurais estilizados, informação 3D que pode sobrepor em ângulos próximos, navegação/água/chuva simplificadas, áudio sintetizado provisório, dificuldade ainda sem avaliação externa. Bug de acesso do Centro tratado e coberto por teste de caminhada e rampas.

## 15. Riscos limitações e próximos passos
Exploração: coleta e tarefas únicas usam IDs/estados; sequência só premia blocos completos; melhores resultados não somam repetição ilimitada. Saves locais são editáveis pelo dono e não oferecem proteção competitiva. Riscos educativos: generalizar coleta local, tratar reposição como resgate, supor que plantio elimina deslizamentos ou limpeza impede enchentes. Interface e créditos delimitam as simplificações.

Próximos passos: revisar o polimento com o autor, realizar partida humana e teste externo, ajustar mixagem/dificuldade, revisar fontes/conteúdo com a equipe; gerar GDD de entrega, vídeo de 1–3 minutos e exportação Windows. O estado atual não é prova de atendimento integral à P2.

## 16. Equipe uso de IA e créditos
Integrantes, matrículas e divisão real do trabalho: pendentes de informação do grupo. OpenAI Codex gerou e integrou scripts, cenas, primitivas, testes e documentação, com correções após execução e inspeção visual. Os arquivos alterados estão no histórico Git e na rastreabilidade. A equipe deve revisar e conseguir explicar cada implementação. Não foi atribuído trabalho a integrantes não identificados.

Fontes: modelo GDD e enunciado P2 do professor; CONAMA 275/2001 (cores); Embrapa WebAmbiente/Adensamento (estratégias de restauração e adequação); Defesa Civil Nacional (prevenção e limites de atuação). Links verificados em `escopo_e_creditos.md`. Modelos e efeitos são primitivas nativas, sem downloads externos; fonte padrão do motor. Não há música ou áudio de terceiros.

## Anexo A Trechos centrais
Consultar os trechos de `scripts/gameplay/restoration_session.gd:act`, `scripts/player/boat.gd:_physics_process` e `scripts/gameplay/canal_session.gd:store_from_boat`, com responsabilidades explicadas na seção 13. A seleção final de 1–3 trechos e sua formatação para a entrega permanecem para a preparação do DOCX/PDF.

## Anexo B Capturas
Capturas verificadas de treino, personagens, três primeiras missões, Ubatiba e Ponta Negra estão em `tests/artifacts/`. São estados automatizados e não evidências de teste externo. Selecionar 3–6 figuras com legendas para o GDD de entrega; o vídeo ainda não foi produzido.
