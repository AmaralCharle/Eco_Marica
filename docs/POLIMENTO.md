# Polimento audiovisual 3.0 — implementação e verificação

## A. Diagnóstico e preservação

Projeto inspecionado em `C:\Users\CHARLE\Documents\Eco-Maricá\eco-marica`, Godot 4.7.2 Standard/GDScript. Checkpoint de segurança **517fedb** antes das mudanças, sobre a campanha de cinco fases **9f4b07c**. Origem Git mantida; nenhum push realizado nesta etapa.

Foram localizados: controlador compartilhado (`guardian.gd`), câmera SpringArm com colisão, aparências separadas (`character_appearance.gd`), sessão de coleta/classificação, restauração, carga do barco, controladores de missões, perfil e progresso versão 2. Não existia sistema de áudio. Recursos visuais eram primitivas com personagens bastante quadrados, água estática/ondas simples, fachadas repetidas, árvores em cruz e HUD volumoso. Renderizador inicial Compatibility, sombras desligadas. As cinco fases e seus sistemas não foram recriados.

Prioridade executada: áudio → cenários → personagem/padrão dos quatro → interface/efeitos → comparação gráfica → documentação. Pontuação, metas, perdas, bloqueios e formato dos saves da campanha permanecem os mesmos. Novos sinais de apresentação não decidem resultados. Arquivos da pasta do projeto são os únicos arquivos do jogo alterados.

## B. Áudio

`scripts/core/game_audio.gd`, autoload `GameAudio`: barramentos Master/Music/Ambience/SFX, pool limitado a 12 efeitos simultâneos, cache de streams, loops de música/ambiente e transição de volume. Preferências em `user://eco_settings.cfg`, separadas da campanha. O menu/pausa abre `scripts/ui/settings_panel.gd`, com controles persistentes de volume, sensibilidade, suavização e qualidade. Erro de gravação é mostrado.

34 arquivos originais sintetizados por `tools/generate_audio.py`: navegação, confirmação, seleção, início, coleta, classificação, bônus, vitória/derrota/desbloqueio, passos, plantio/solo/bueiro, embarque/desembarque/descarga, cinco ambientes, chuva, trovão e motor, além de seis trilhas. O motor altera volume/tom com a velocidade; chuva varia com a tempestade e trovões só ocorrem ocasionalmente. Menus/pausa encerram motor e chuva. Passos dependem de movimento efetivo, chão e corpo visível; são interrompidos parado, no salto e embarcado. Treino também recebe efeitos de coleta/classificação.

`test_audio.gd`: 17 verificações, incluindo arquivo de preferências real, barramentos/mute, eventos da missão, loops, motor e gravação do mix Godot em `tests/artifacts/audio_mix.wav` com amostras não silenciosas sem saturação no ensaio. Executado também com janela/Vulkan, retorno 0. Isso verifica reprodução técnica, não preferência auditiva humana. Sons são provisórios e sintetizados, não gravações naturais; mixagem e repetição musical ainda precisam da escuta do autor.

## C. Cenários e iluminação

`scripts/effects/world_polish.gd` acrescenta uma camada decorativa sem corpos físicos: troncos cilíndricos, folhas de palmeiras trianguladas com movimento leve, árvores com copas, arbustos/jardins, morros arredondados, gramado em MultiMesh, postes e variação de materiais. Água tem cor, ondulação visual e normais animadas sem simulação física, transparência cara ou SSR. Araçatiba recebe paginação do piso/ciclovia; praia recebe dunas/restinga/pedras; Centro recebe toldos, molduras, floreiras e nuvens arredondadas; Ubatiba recebe margens vegetadas/pedras no riacho; Ponta Negra recebe píer com tábuas, guarda-corpo visual da ponte e margens.

Nuvens não projetam sombras sólidas sobre as metas. O Centro tem preenchimento ambiente explícito para preservar leitura na chuva. Transformação de recuperação preexistente é preservada; efeitos de ação e o crescimento simbólico da muda complementam a apresentação. Nenhum crescimento representa escala temporal ecológica real.

`boat_polish.gd`: casco triangulado com proa, convés, motor, identificação, balanço apenas visual e pequena esteira quando em movimento. Colisão e controle do barco permanecem na raiz física.

## D. Personagens e câmera

Lucas foi revisado visualmente antes de completar os penteados/acessórios dos demais. Corpo/cabeça/membros arredondados, olhos com brilho, sobrancelhas, nariz, boca, orelhas, cabelo, solas, alças, emblema e detalhes individuais. Lucas conserva mochila; Marina coque/bolsa de campo; Rafael boné/refletores/botas; Bia cacheados/bolsa. Cápsula, velocidades e habilidades compartilhadas continuam inalteradas; pivôs e nomes de membros preservados.

Animações procedurais: respiração, passos/corrida, pose de salto, gesto de coleta/interação, inclinação de plantio, acomodação ao embarcar e gesto ao desembarcar. São poses simples sem esqueleto e não animações capturadas. `animation_state` comunica estado; `attach_external_model(PackedScene)` permite integrar GLB/glTF importado e `AnimationPlayer` com nomes equivalentes. Um modelo externo pode conter sua própria AnimationTree, mas nenhum rig ou grafo AnimationTree foi fornecido/implementado nesta etapa.

Câmera terrestre com sensibilidade persistente, interpolação opcional, limites e SpringArm existentes. `camera_transition.gd` interpola durante 0,45 s entre terra/barco, preserva transform local, lida com reembarque rápido e não move o corpo. A suavização visual é desativada nos testes headless para tornar a verificação de limites imediata; o comportamento com janela é inspecionado nas capturas.

## E. Interface e feedback

`eco_theme.gd` centraliza botões, foco visível, estados bloqueados e barras; `eco_mark.gd` desenha marca vetorial simples. Menus mostram cenário de fundo, quatro prévias, cinco fases com bloqueio/destaque, configurações e transição curta. HUD mais compacto preserva tempo, pontos, tarefas, mãos/carga/perdas e inclui barra do índice. HUD fica oculto atrás dos menus. Ponta Negra e Ubatiba mantêm contadores específicos. Avisos educacionais continuam visíveis.

`mission_presentation.gd` observa eventos da sessão e mostra pequenos bursts de sete partículas de malha, com duração limitada. Coleta/classificação/erro/plantio/bueiro/descarga e vitória têm retorno sem decidir pontos. Efeitos pertencem à cena e são descartados na troca. Resíduos receberam detalhes e limite de distância dos rótulos; coletores receberam tampa/abertura/base/símbolo; mudas têm folhas individuais.

## F. Qualidade, desempenho e limites

Máquina observada: Intel UHD Graphics, i5-12450H, Windows 11 e aproximadamente 12 GB de RAM. Não se assume a configuração hipotética de 16 GB como medida da máquina. Compatibility, Forward Mobile e Forward+ abriram. Ensaios preliminares em qualidade alta deram aproximadamente 89–104 FPS médios no Compatibility, 100–124 no Mobile e 63–66 no Forward+. O conteúdo mudou levemente durante esses ensaios; são diagnóstico, não comparação científica. A configuração padrão passou para **Forward Mobile/Vulkan** por compatibilidade observada e margem de desempenho. Não são usados SDFGI, SSR, SSAO ou volumetria pesada.

Qualidades: Baixa sem sombras/MSAA e 100 instâncias de gramado; Média sombras próximas/45m, MSAA2× e 240; Alta sombras/65m, MSAA4×, 360 e decoração extra. Mesmo mapa físico e objetivos em todos os níveis. Materiais decorativos reutilizados por cor; gramado em lote; pool de áudio limitado. Não há dependências pagas.

Benchmark reproduzível: `Godot --path . --script res://tests/capture_polish.gd -- final_mobile`. Mede viewport real, qualidade Alta, 1280×720, VSync desligado apenas no processo de benchmark, 60 frames de aquecimento e 180 amostras por fase. Registro em `tests/artifacts/final_mobile_benchmark.json`. Câmera inicial estática, temporizador principal congelado e tempestade do Centro fixada em 90%; não mede percurso completo, troca de todos os ângulos ou desempenho em outra máquina. Tempo `elapsed_ms` inclui aquecimento/amostras/captura e não deve ser chamado de tempo de carregamento.

Execução final, após os testes e sem outra execução de teste em paralelo:

| Vista da fase | FPS médio | Frame p95 (ms) | Pior frame amostrado (ms) |
|---|---:|---:|---:|
| Araçatiba | 104,6 | 11,36 | 12,03 |
| Itaipuaçu | 122,9 | 9,99 | 11,32 |
| Centro, tempestade em 90% | 106,0 | 12,51 | 14,40 |
| Ubatiba | 89,8 | 15,44 | 17,70 |
| Ponta Negra | 109,8 | 12,47 | 14,10 |

Esses dados não asseguram 60 FPS constantes em partida: piores ângulos, uso de outros aplicativos, energia/temperatura e carregamento não foram caracterizados. Capturas `final_mobile_*.png`, telas `review_*.png` e estados de Ubatiba/Ponta Negra foram inspecionados no renderizador real. Comparações preliminares permanecem nos JSON com prefixos `mobile`, `compatibility` e `forward_plus`.

Regressão final: **356 verificações em 15 suítes, zero falhas e nenhum ERROR/SCRIPT ERROR nos logs finais**. Inclui as 306 verificações anteriores, áudio 17 e apresentação 33. O executor também produz `validation_summary.json`. Algumas execuções registram avisos de instâncias de áudio ainda referenciadas no encerramento imediato do motor; isso não foi caracterizado como crescimento de memória durante uma partida e fica registrado para acompanhamento. Não foi ocultado pelo executor. As capturas/revisões são automatizadas, não testes de usabilidade externa.

## G. Rastreabilidade e pendências acadêmicas

| Sistema | Arquivos principais | Evidência |
|---|---|---|
| Mixer e preferências | `core/game_audio.gd`, `ui/settings_panel.gd`, `tools/generate_audio.py` | `test_audio.gd`, captura real do mix |
| Qualidade, cenário, shaders | `effects/world_polish.gd`, `assets/materials/*.gdshader` | cinco capturas/benchmark, `test_presentation.gd` |
| Aparência/animação | `player/character_appearance.gd`, `player/guardian.gd` | `test_characters.gd`, prévias e partida |
| Barco e câmera | `player/boat.gd`, `player/camera_transition.gd`, `effects/boat_polish.gd` | `test_boat.gd`, `test_ponta_access.gd`, reembarque rápido |
| Eventos e efeitos | `gameplay/*session.gd`, `effects/mission_presentation.gd`, `levels/aracatiba.gd` | regressões de pontuação, metas e cinco fases |
| Interface | `ui/mission_hud.gd`, `expansion_hud.gd`, `eco_theme.gd`, `eco_mark.gd` | capturas, limites do menu, Esc das opções |

Os caminhos de scripts nesta tabela são relativos a `scripts/`. Leia também `ASSETS_E_CREDITOS.md` e o GDD de trabalho atualizado. Históricos anteriores em `validacao.md` descrevem o estado daquelas etapas, antes do áudio e da expansão atual.

Ainda dependem de trabalho/revisão humana: partida completa com avaliação da dificuldade, gosto/volume/repetição dos sons, teste externo com perfil e observações, métricas de aprendizagem, conteúdo revisado pela equipe, nomes/matrículas, GDD final DOCX/PDF, vídeo e exportação Windows. Modelos continuam procedurais; integração de GLB está preparada, sem alegar existência de modelos profissionais. O projeto não comprova impacto ambiental real nem aprendizagem.
