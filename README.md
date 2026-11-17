# ECO MARICÁ — Guardiões da Cidade

Jogo acadêmico 3D educativo para Windows, um jogador offline. Godot 4.7.2 Standard e GDScript, renderizador Forward Mobile/Vulkan. Campanha com cinco fases, áudio sintetizado original, cenários/personagens aprimorados e opções de volume, câmera e qualidade. A entrega acadêmica final ainda será preparada.

## Asset Revolution — versão de avaliação

Branch atual: `asset-revolution`, com modelos CC0 reais, quatro personagens rigados, barco, materiais PBR 1K, vegetação e céu HDRI. As cinco fases e regras foram preservadas. Base de retorno: `upgrade-visual-4`/tag `checkpoint-pre-assets-df0ab5d`. Relatório, limitações e medições: [docs/ASSET_REVOLUTION.md](docs/ASSET_REVOLUTION.md); autores/licenças/estados: [docs/catalogo_assets.md](docs/catalogo_assets.md). Execute F8/F5 para carregar a versão nova.

Aves e animações pausam com a missão. Alto usa MSAA 4× após comparação medida; Médio oferece mais margem na Intel UHD. O argumento `--legacy-art` permite comparação visual sem editar arquivos. Nenhum modelo pago ou aplicativo adicional foi necessário.

## Upgrade 4 — base anterior desta branch

Branch `upgrade-visual-4`; a `main` e a tag `fase-1-final` conservam a versão anterior. Reinicie com F8/F5 para testar. Q abre decisões opcionais com tempo pausado; Esc retorna. Estrelas e opcionais não bloqueiam a campanha e não alteram os pontos principais. Melhor classificação, tentativas e histórico são locais, com save versão 2 compatível com o leitor antigo.

Centro piloto com vitrines/respingos, recuperação simbólica em Ubatiba, barco/resíduos revistos, folhas tropicais e cotovelos articulados. HUD validada em 720p/1080p. Alto medido em aproximadamente 61–81 FPS nas vistas a 1280×720; não é garantia em partida completa. Baixo usa 3D a 80%, mantendo a HUD nativa. Detalhes, limites, rollback e regras em `docs/VISUAL_UPGRADE_4.md`, auditoria em `docs/visual_upgrade_audit.md` e diário em `docs/visual_upgrade_tasks.md`.

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

## Interface

HUD e telas redesenhadas em 16/11/2026: objetivos compactos, tempo/pontos separados, inventário/carga e limpeza nas bordas, cartões de fases, seleção com prévias maiores e resultados padronizados. Preserva todos os indicadores e controles. Detalhes, arquivos e limites em `docs/INTERFACE_2026_11_16.md`.

## Personagens

Polimento de 16/11/2026: quatro personagens com corpo contínuo, rostos/olhos/cabelos revistos, roupas e equipamentos próprios. Lucas foi validado antes da aplicação aos demais. Controlador, câmera, colisão e regras preservados. Estrutura opcional para GLB em `docs/MODELOS_GLB.md`; resultados e limites em `docs/PERSONAGENS_2026_11_16.md`.

## Direção de arte por referências

Nova passagem visual de 16/11/2026, inspirada nas seis referências já enviadas: prioridade para Centro, Ubatiba e Ponta Negra, com fachadas/vegetação mais ricas, relevo de fundo, luz/atmosfera e água revistos. Preserva as mecânicas e acessos. Adaptações, desempenho e assets futuros em `docs/DIRECAO_ARTE_REFERENCIAS_2026_11_16.md`.

## Áudio, câmera e gráficos

Atualização de cenários de 16/11/2026: materiais de solo/pavimentação/madeira, vegetação, água, luz e atmosfera revistos nas cinco fases; detalhes adicionais no Centro, Ubatiba e Ponta Negra. Não muda as metas ou as posições dos objetivos. Ver `docs/CENARIOS_2026_11_16.md` para arquivos, evidências e limites.
No menu ou na pausa, abra **Configurações**. Master, Music, Ambience e SFX possuem volumes independentes; zero silencia. Sensibilidade e suavização da câmera são ajustáveis. Qualidade Baixa remove sombras e reduz vegetação; Média usa sombras próximas e MSAA 2×; Alta acrescenta detalhes, mais vegetação, MSAA 8× e quatro cascatas de sombras direcionais de 4096. Alta é o padrão para instalações sem preferências salvas. O nível não troca o renderizador nem reinicia a campanha. Preferências em `user://eco_settings.cfg`, separadas dos saves.

As 37 faixas/efeitos WAV foram sintetizados originalmente por código, com auxílio de IA; não foram baixados. São provisórios e não gravações de ambientes reais. Há passos por superfície, sons de ações, menu, restauração, chuva, motor e trilhas instrumentais discretas. Veja `docs/ASSETS_E_CREDITOS.md` e `docs/POLIMENTO.md`.

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

Validação atual: 1062 verificações em 23 suítes, sem falhas. Inclui áudio, apresentação, cenário, preservação física da camada decorativa e interface das cinco fases em 1280 × 720. Medições e limites em `docs/CENARIOS_2026_11_16.md`; resumo em `tests/artifacts/validation_summary.json`. O executor confere código de saída e mensagens do motor, salvando logs em `tests/artifacts/test_*.log`. Testes usam saves próprios e não concluem a campanha real do jogador.

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

## Ponta Negra — pescadores e remada

Branch `ponta-negra-pescadores`, base preservada em `checkpoint-pre-pescadores-4f5b05f`. Quatro NPCs cumprimentam a até 5 m; balão por 3 s, intervalo individual de 20 s. Mire para ver o nome. “Olha a tarrafa!” avisa o lançamento; contorne ou aguarde a rede temporária. Sem perda de pontos/carga. Passageiro sentado com braços e remos animados; controles e metas originais preservados. As cinco fases ganharam músicas instrumentais originais distintas, com o mesmo controle de volume. Relatório e limitações em [docs/PONTA_NEGRA_PESCADORES.md](docs/PONTA_NEGRA_PESCADORES.md).

No barco, o mouse permite olhar para os pescadores e o cenário; W/S acelera/recua e A/D vira o casco. Sensibilidade e suavização seguem as preferências existentes.
