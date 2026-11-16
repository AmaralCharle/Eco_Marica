# ECO MARICÁ — Guardiões da Cidade

Jogo acadêmico 3D educativo para Windows, um jogador offline. Godot 4.7.2 Standard e GDScript, renderizador Forward Mobile/Vulkan. Campanha com cinco fases, áudio sintetizado original, cenários/personagens aprimorados e opções de volume, câmera e qualidade. A entrega acadêmica final ainda será preparada.

## Abrir e jogar
1. Abra o `project.godot` desta pasta no Godot 4.7.2. Se o editor estava aberto em Compatibility, reabra o projeto para carregar o novo renderizador.
2. Pare uma execução anterior com F8 e pressione F5.
3. Escolha um dos quatro personagens e uma fase desbloqueada.
4. Leia as instruções e clique em Começar missão. Cada vitória libera a próxima fase.

WASD move, mouse gira câmera terrestre, Shift corre, Espaço pula, E interage e Esc pausa. No treino, R reinicia e M volta ao menu. Os quatro personagens usam o mesmo controlador e cápsula.

## Campanha
| Fase | Local | Objetivos | Prazo / derrota |
|---|---|---|---|
| 1 | Operação Araçatiba | 15 resíduos, pelo menos 12 destinos corretos | 300s; quarto erro |
| 2 | Resgate de Itaipuaçu | 20 destinos corretos, papel/plástico/vidro/metal | 240s; quinta perda ao mar |
| 3 | Alerta de Tempestade — Centro | 15 destinos corretos e três bueiros | 180s; tempo esgotado |
| 4 | Ubatiba — Raízes da Vida | 12 avaliações, oito plantios e três proteções | 300s; quarta decisão incorreta |
| 5 | Ponta Negra — Águas Limpas | Barco e 20 destinos corretos, carga máxima cinco | 360s; quinta saída da zona de coleta |

Todas as fases perdem no tempo zero. O mapa final mostra cinco localidades esquemáticas; não é um mapa geográfico exato. Estatísticas são ações simuladas, não resultados ambientais reais.

## Correção do Centro
Os 12 coletores agora estão no nível da rua, em estações com acesso sem pulo. Há seis rampas para acessar as calçadas. `test_centro_access.gd` verifica os coletores e as duas rampas laterais caminhando com o controlador real.

## Áudio, câmera e gráficos

Atualização de cenários de 16/11/2026: materiais de solo/pavimentação/madeira, vegetação, água, luz e atmosfera revistos nas cinco fases; detalhes adicionais no Centro, Ubatiba e Ponta Negra. Não muda as metas ou as posições dos objetivos. Ver `docs/CENARIOS_2026_11_16.md` para arquivos, evidências e limites.
No menu ou na pausa, abra **Configurações**. Master, Music, Ambience e SFX possuem volumes independentes; zero silencia. Sensibilidade e suavização da câmera são ajustáveis. Qualidade Baixa remove sombras e reduz vegetação; Média usa sombras próximas e MSAA 2×; Alta acrescenta detalhes, mais vegetação e MSAA 4×. O nível não troca o renderizador nem reinicia a campanha. Preferências em `user://eco_settings.cfg`, separadas dos saves.

As 34 faixas/efeitos WAV foram sintetizados originalmente por código, com auxílio de IA; não foram baixados. São provisórios e não gravações de ambientes reais. Há passos por superfície, sons de ações, menu, restauração, chuva, motor e trilhas instrumentais discretas. Veja `docs/ASSETS_E_CREDITOS.md` e `docs/POLIMENTO.md`.

Foi adotado Forward Mobile após abrir e comparar os três renderizadores na Intel UHD. Para diagnóstico em outra máquina, é possível iniciar pelo console com `--rendering-method gl_compatibility --rendering-driver opengl3`; para comparar Forward+, use `--rendering-method forward_plus --rendering-driver vulkan`. Não é necessário editar os saves.

## Ubatiba
Aproxime-se de um ponto e use E. Inspecione aptidão, cobertura e solo exposto; escolha nos botões. Prepare os oito pontos aptos antes de plantar mudas nativas adequadas ao cenário. Os três expostos exigem proteção após o plantio. Preserve os quatro não aptos. Fechar/Esc volta ao terreno. O cronômetro continua durante a inspeção. Repetir ação concluída não gera pontos nem novas mudas.

A demonstração de chuva sobre solo exposto/protegido é ilustrativa. Plantio isolado não elimina risco de deslizamento; recuperação real exige orientação técnica.

## Ponta Negra
1. Caminhe até o barco pelo píer e pressione E perto dele.
2. W/S controlam aceleração/recuo; A/D giram gradualmente. A câmera acompanha o barco.
3. Aproxime-se de um resíduo e pressione E. Capacidade: cinco; cheio, retorne ao píer.
4. Próximo ao píer, solte os comandos para parar e pressione E para desembarcar.
5. O primeiro item da carga vem às mãos. Vá ao coletor identificado e use E; os próximos itens são descarregados um de cada vez automaticamente, sem repetir pontos de coleta.
6. Destine toda a carga antes de embarcar novamente.

Somente resíduos que cruzam a linha de saída z=-17 contam como perdidos. Até a quarta perda outro ID aparece em área alcançável; a perda permanece registrada. A quinta causa derrota sem reposição. O barco colide com as margens e passa sob a ponte; o personagem tem limites terrestres para evitar caminhar no canal. Pausa suspende barco, resíduos e tempo.

## Pontos e resultados
Coleta única +5, destino correto +10, erro -5 (piso zero), bônus por bloco de três acertos consecutivos +20 e missão +100 único. Bueiro +30. Ubatiba: preparar +5, plantar +20, proteger +15, preservar +5; erro -5. Pontuações perfeitas por missão: 425, 520, 515, 365 e 520.

Araçatiba consome o item descartado errado; nas demais fases de classificação ele permanece em mãos para corrigir. O Índice inclui tarefas realmente concluídas e preserva perdas. Em Ubatiba usa avaliações/plantios/proteções. No Centro inclui bueiros.

## Salvamento e migração
Perfil local em `user://player_profile.json`; progresso/resultado em `user://mission_progress.json`. Progresso versão 2 aceita saves antigos versão 1. Quem concluiu o antigo jogo de três fases recebe Ubatiba desbloqueada e a campanha expandida em aberto. Estatísticas antigas ausentes não são inventadas; o final informa a limitação.

O acumulado é a soma dos melhores resultados registrados por fase. Repetir uma pontuação menor não soma pontos artificialmente. Derrota não apaga progresso. Os arquivos são validados e gravados em temporário antes de substituição. Não há serviços online, banco externo ou telemetria.

## Verificação
Execute na raiz do projeto:

```powershell
.\tests\run_all.ps1
# Outro caminho do motor:
.\tests\run_all.ps1 -Godot 'C:\caminho\Godot_v4.7.2-stable_win64_console.exe'
```

Validação atual: 378 verificações em 16 suítes, sem falhas. Inclui áudio, apresentação, cenário e preservação física da camada decorativa. Medições e limites em `docs/CENARIOS_2026_11_16.md`; resumo em `tests/artifacts/validation_summary.json`. O executor confere código de saída e mensagens do motor, salvando logs em `tests/artifacts/test_*.log`. Testes usam saves próprios e não concluem a campanha real do jogador.

Há testes de física real e de estados com reposicionamento controlado; não substituem uma partida humana completa nem avaliação da dificuldade. Capturas `capture_ubatiba.gd`, `capture_ponta_negra.gd` e demais scripts geram estados simulados para inspeção gráfica. Não são evidência de teste externo.

## Arquivos e documentação
- `scripts/core`: configuração, personagens, perfil, definições e progresso.
- `scripts/player`: controlador terrestre, aparências e barco.
- `scripts/gameplay`: coleta, classificação, terreno e inventário.
- `scripts/levels`, `scenes/levels`: objetivos e cenário de cada fase.
- `scripts/ui`: menus, HUD, inspeção e mapa.
- `docs/GDD_5_FASES.md`: GDD de trabalho com as 16 seções e rastreabilidade real na seção 13.
- `docs/rastreabilidade.md`, `validacao.md`, `expansao.md`, `escopo_e_creditos.md`: regras, evidências e fontes.

Modelos e efeitos procedurais usam recursos nativos, sem assets baixados. Os benchmarks representam vistas controladas, sem garantir FPS de uma partida completa. Usabilidade externa, métricas de aprendizagem, revisão humana da mixagem/dificuldade, rigs externos, DOCX/PDF final, vídeo e exportação Windows permanecem pendentes.

Repositório de destino: https://github.com/AmaralCharle/Eco_Marica.git . Checkpoints locais; nenhuma publicação automática.
