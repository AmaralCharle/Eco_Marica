# Ponta Negra — pescadores, tarrafas, remada e cinco trilhas

## Segurança e escopo

Branch `ponta-negra-pescadores`, a partir de `asset-revolution` em `4f5b05f`. Checkpoint de retorno: `checkpoint-pre-pescadores-4f5b05f`. Main e Asset Revolution permanecem preservadas. Nenhuma fase foi reconstruída; não foram alterados resíduos, pontuação, 360 segundos, capacidade cinco, requisitos de vitória/derrota ou formato de salvamento.

O documento de expansão foi aplicado junto às falas fornecidas diretamente pelo usuário. Não foram adicionadas vozes: o projeto não contém gravações licenciadas desses diálogos. As legendas sempre estão disponíveis.

## Pescadores e diálogos

| Nome | Local | Cumprimento |
|---|---|---|
| Cacadi | Margem leste, perto de x=8,65 / z=5,2 | OPAAAA! Fala, meu patrão! Cuidado com a tarrafa! |
| João do Canal | Margem oeste, perto de x=-8,65 / z=-8 | Aê, meu camarada! Hoje o peixe tá esperto! |
| Naldo | Ponte, x=-3,2 / y=3,625 | Opa! Dá uma segurada aí que vou jogar a rede! |
| Beto da Ponte | Ponte, x=3,2 / y=3,625 | Fala, parceiro! Passa pelo cantinho que tô pescando! |

Cada NPC é um Node3D visual, usando o modelo Man de Quaternius já licenciado em CC0. Camisas variadas, chapéus e tarrafas enroladas diferenciam os pescadores. Há animação idle e alcance simples no preparo/recolhimento, sem IA complexa e sem novos corpos físicos.

A distância é tridimensional, inclusiva até **5 metros**, tomando o barco como visitante quando embarcado. Cumprimento dura **3 segundos**, com cooldown **individual de 20 segundos**; outros pescadores não compartilham o intervalo. Aproximação e permanência podem produzir novo cumprimento após o intervalo. Ao preparar o lançamento, aparece **“Olha a tarrafa!”** por três segundos. Aviso e cumprimento têm temporizadores separados: podem compartilhar o balão sem cortar uma fala ainda ativa. A pausa congela esses tempos; reiniciar a fase reinicia os ciclos.

O nome aparece somente sob foco da câmera: centro da tela com mouse capturado, ponteiro com mouse livre. O componente `canal_interaction.gd` existente chama a seleção por raio projetado, volume aproximado do corpo e linha de visão do mundo. Alcance visual de 35 m; some ao tirar o foco ou pausar. Funciona a pé e na câmera do barco. Foco não substitui E nem interfere no alvo de resíduos/lixeiras.

Revisão de 17/11: o mouse também orienta a câmera embarcada, com sensibilidade, suavização e limites de inclinação existentes. A lente gira sem deslocar o braço protegido da câmera nem virar o casco; W/S e A/D continuam responsáveis pela navegação. Pausar bloqueia a mira. A captura `fisheries_boat_aim_bridge.png` confirma identificação de Beto pelo centro da câmera do barco.

## Tarrafa temporária e equilíbrio

Ciclo: espera → preparo de **2,5 s** → lançamento de **0,8 s** → aberta por **5 s** → recolhimento de **1,2 s** → espera de **34,5 s**. Em condição normal, cada pescador repete a cada 44 s; primeiros preparos em 6, 17, 28 e 39 s escalonam uma rede por vez. Existe também limite de segurança de **duas abertas simultaneamente**, caso os ciclos se aproximem após adiamentos.

Preparo mostra aro âmbar no destino e balão de aviso. Lançamento usa arco visual e abertura progressiva; malha circular/aro claro identificam a rede na água. Recolhimento reduz e leva a malha de volta ao pescador.

Foi escolhida a abordagem de reação/velocidade. Uma varredura analítica do deslocamento do barco contra o círculo da rede impede atravessá-la de um passo para outro, reduz a velocidade e mostra **“Tarrafa na água — contorne ou aguarde.”** Não adiciona colisores físicos, dano, perda de carga, erros ou desconto de pontos. Recuar e sair da área são permitidos; uma entrada artificial/limítrofe tem saída liberada. A rede deixa de bloquear ao iniciar o recolhimento.

Raio visual 1,25 m, margem conservadora de embarcação 1,45 m. O lançamento é adiado se o barco estiver a até 3,2 m do destino; não nasce sob ele. Posicionamento mantém corredor central livre e redes afastadas do píer. Resíduos sob uma rede temporária podem aguardar o recolhimento; a missão não exige atravessar a rede. Prazos e posições dos resíduos foram mantidos.

## Passageiro sentado e remada

O passageiro visual já existente foi reutilizado. O controlador terrestre continua oculto/desativado durante embarque, sem criar outro personagem lógico ou mexer no inventário. Um modificador de esqueleto dobra coxas/joelhos e orienta braços; alinhamento pelo osso Hips coloca o quadril no banco. Os quatro rigs foram verificados. No desembarque, o passageiro é ocultado e o jogador original volta ao píer com controles normais.

**Há remada procedural em movimento, não apenas pose sentada.** As duas metades dos remos do modelo Kenney foram separadas visualmente e articuladas; braços e remos compartilham fase/intensidade de remada. Ao parar, a intensidade chega a zero; pausa congela fase e animações. A propulsão continua sendo o controlador original, sem física de remos. O som de motor fictício foi desativado em Ponta Negra; a ambiência de água foi preservada.

A pose é autoral sobre os próprios rigs, sem importar animação de outro esqueleto. O contato exato das mãos com cada cabo ainda é aproximado, sem IK de contato ou simulação física de cordas/rede. No fallback procedural antigo, a pose é simplificada.

## Cinco músicas novas

As cinco faixas antigas compartilhavam a mesma frase em variantes. Foram substituídas por cinco composições originais com melodias, harmonias, levadas e timbres diferentes, em estéreo PCM 16-bit/22050 Hz. Sem samples, gravações comerciais ou melodias externas. Menu, buses, volume e transições do mixer foram preservados.

| Fase | Título | Direção musical | BPM | Duração |
|---|---|---|---|---|
| Araçatiba | Manhã na Orla | Bossa leve; timbres sintetizados de cordas dedilhadas e flauta | 96 | 40,00 s |
| Itaipuaçu | Brisa de Itaipuaçu | Tropical sincopado, marimba e cordas dedilhadas | 112 | 34,29 s |
| Centro | Antes da Chuva | Ostinato urbano, teclas suaves e percussão contida | 104 | 36,92 s |
| Ubatiba | Caminhos Verdes | Pastoral acústico, flauta e arpejos espaçosos | 76 | 50,53 s |
| Ponta Negra | Remada no Canal | Baião suave, timbre de palheta, cordas e triângulo | 100 | 38,40 s |

São timbres sintetizados, não gravações instrumentais. Fonte reproduzível: `tools/compose_phase_music.py`; partitura/metadados/hashes em `docs/trilhas_originais.json`. O gerador geral também foi atualizado para preservar essa organização quando executado novamente. NumPy já estava disponível; nenhum programa adicional foi instalado.

## Validação executada

- Revisão final de 17/11: **1.184 verificações em 24 suítes, zero falhas**, sem ERROR/SCRIPT ERROR nos logs finais.
- Suíte específica `test_fisheries.gd`: **122 verificações**, também reexecutada após adicionar conferência de foco na câmera do barco. Cobre quatro nomes/localizações, limite de 5 m, duração de 3 s, cooldown individual de 20 s, coexistência de aviso/cumprimento, foco a pé/embarcado, todos os estados durante 180 s simulados, limite simultâneo, espaço central/píer, adiamento sobre o barco, varredura em passo longo, navegação WASD real contra rede, passagem após recolher, pausa, quatro poses sentadas/remadas/desembarques e as cinco músicas no mixer.
- Regressões existentes preservadas: campanha, coleta/descarte, perdas/reposição, vitória/derrota, acesso ao píer, ponte, pausa, física, personagens, saves e interface em 720p/1080p.
- PCM das cinco faixas: estéreo, duração acima de 30 s, sem silêncio/clipping, DC baixo, junção do loop sem salto e hashes diferentes. Evidência `fisheries_audio_quality.json`.
- Onze capturas 1280×720: cumprimentos dos quatro NPCs, preparo, rede aberta, os quatro passageiros remando e mira embarcada na ponte. São estados controlados de revisão, não uma partida humana.

As poses modificadas foram medidas no sinal `modification_processed`, antes de o motor restaurar as poses-base, conforme a [documentação oficial do Godot](https://docs.godotengine.org/en/stable/classes/class_skeletonmodifier3d.html). O teste não confunde a pose-base em pé com a pose enviada à renderização.

Alguns testes headless que encerram imediatamente continuam apresentando avisos de AudioStreamWAV/ObjectDB já registrados no projeto. As capturas e perfis com encerramento suave terminaram sem ERROR/SCRIPT ERROR; não se declara prova universal de ausência de vazamentos.

## Desempenho medido

Medição de 16/11: Intel UHD integrada, Mobile/Vulkan, 1280×720; mil frames por perfil depois do aquecimento. Quatro NPCs, passageiro remando e ciclos reais; houve uma tarrafa ativa nas amostras. O barco fica fixo para comparação e o prazo da missão é congelado, enquanto ciclos/animações continuam.

| Perfil | FPS médio | p95 | Pior frame | RSS | VRAM |
|---|---|---|---|---|---|
| Alto | 72,78 | 17,63 ms | 23,86 ms | 889,9 MiB | 217,1 MiB |
| Médio | 79,92 | 15,25 ms | 23,26 ms | 889,8 MiB | 199,6 MiB |

Carga da cena com motor iniciado: aproximadamente 1,64–1,68 s. Logs/JSON `fisheries_performance_*.json`. Não é garantia de FPS mínimo numa partida prolongada, bateria/temperatura, primeira importação ou todos os ângulos. Não foi feita validação externa com jogadores.

## Arquivos e rastreabilidade

| Recurso | Arquivos |
|---|---|
| NPCs, falas, ciclos e balões | `scripts/gameplay/fisherman.gd` |
| Distribuição, foco, limites e contato com rede | `scripts/gameplay/canal_fisheries.gd` |
| Integração na fase e interação existente | `scripts/levels/ponta_negra.gd`, `scripts/gameplay/canal_interaction.gd` |
| Embarque/postura e reação de navegação | `scripts/player/boat.gd`, `scripts/player/character_appearance.gd` |
| Rig e pose autoral | `scripts/player/production_character.gd`, `scripts/player/seated_rowing_pose.gd` |
| Remos, alinhamento e áudio de navegação | `scripts/effects/boat_polish.gd`, `scripts/effects/mission_presentation.gd` |
| Composição e arquivos sonoros | `tools/compose_phase_music.py`, `tools/generate_audio.py`, cinco WAVs em `assets/music/`, `docs/trilhas_originais.json` |
| QA e evidências | `tests/test_fisheries.gd`, `tests/capture_fisheries.gd`, `tests/profile_fisheries.gd`, logs/JSON/capturas `fisheries_*` |
| Documentação | Este relatório, README, GDD de trabalho, créditos, continuidade, validação e rastreabilidade |

Sem downloads novos: NPCs reutilizam **Man de Quaternius (CC0)**, https://poly.pizza/m/HMnuH5geEG ; remos/casco reutilizam **Watercraft Kit de Kenney (CC0)**, https://kenney.nl/assets/watercraft-kit . Chapéus, rede, balões, ciclos, poses e composições são adaptações/recursos autorais do projeto com assistência Codex. Créditos anteriores continuam válidos; as novas músicas não foram atribuídas a artistas externos.

## Teste e próximos refinamentos

F8/F5 no projeto; selecionar Ponta Negra. Aproximar-se até 5 m, mirar para ler o nome, observar o aviso/aro e a rede; contornar pelo centro, recuar ou esperar. Embarcar com E, usar o mouse para olhar, W/S para acelerar/recuar e A/D para virar, parar e desembarcar como antes. Selecionar os quatro protagonistas para conferir postura. Comparar as cinco músicas pelo controle Música já existente.

Refinamentos possíveis: animações próprias de arremesso/recolhimento, mãos com IK nos remos, modelos de pescadores mais variados e gravações de fala licenciadas mantendo legendas. As músicas podem receber gravações instrumentais licenciadas numa etapa futura. Não há vozes nesta entrega.
