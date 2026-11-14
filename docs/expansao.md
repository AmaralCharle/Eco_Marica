# Expansão da campanha para cinco fases

## Inspeção e checkpoint
Base existente: `aracatiba.gd` reúne estados, início, resultados e transições por definição; fases 2/3 sobrescrevem objetivos. `recycling_session.gd` é autoridade de pontos/IDs, `interaction.gd` revalida distância/visibilidade, `guardian.gd` compartilha movimento/câmera, `mission_progress.gd` e `player_profile.gd` guardam dados locais. Recursos e cenas foram reutilizados. O modelo GDD do professor foi consultado integralmente na preparação da base; sua estrutura orienta `GDD_5_FASES.md`.

Checkpoint anterior às mudanças: **6ea7e11**. A pasta ainda não tinha Git; foi inicializada localmente e o remoto indicado pelo responsável registrado, sem push. Alterações anteriores preservadas nesse commit.

## Correção do Centro
Meio-fio elevado sem acesso inclinado impedia chegar caminhando à calçada onde estava o coletor azul. Coletores realocados ao nível da rua; rampas ligam calçadas às três estações. Teste real com WASD confirma alcance dos 12 coletores e subida pelos dois lados sem pulo.

## Ubatiba
12 pontos: três aptos com solo exposto, cinco aptos com falha de cobertura e quatro não aptos à muda proposta (vegetação existente ou ponto úmido que requer orientação). São propriedades pedagógicas predefinidas, não diagnóstico de Ubatiba real.

Inspecionar antes de agir. Oito preparos e plantios nativos adequados; os três expostos exigem proteção complementar. Preservar quatro não aptos conclui suas avaliações. Avaliação só conta quando a sequência correta do ponto termina. Meta 12/8/3, 300s e até três erros. Na quarta decisão incorreta, derrota. Ações repetidas não rendem pontos.

Pontuação: preparo +5; plantio +20; proteção +15; preservação +5; erro -5 com piso zero; missão +100. Partida perfeita 365. Índice = (avaliações + plantios + proteções) / 23. Muda cresce em animação simples e cobertura muda de aparência. Chuva/solo demonstrados de forma simbólica; não há geotecnia nem garantia de evitar deslizamentos.

## Ponta Negra
Protótipo isolado em `boat_prototype.tscn` validado antes da integração. Barco `CharacterBody3D`, aceleração 3 m/s², desaceleração 4 m/s², máximo 6 m/s, recuo máximo 3 m/s e rotação gradual. Colisão nativa com limites; câmera/passagerio acompanham. Navegação simplificada.

20 itens; cinco inicialmente móveis seguem trajetória definida e só se perdem ao cruzar a zona z=-17. Capacidade de cinco itens em estado STORED, sem coleta duplicada. Desembarque próximo ao píer e com velocidade até 0,6 m/s; transferência para mãos mantém o estado/recompensa sem recolher de novo. Carga deve ser destinada antes de embarcar. Câmera/controle terrestre são restaurados ao desembarcar.

Vitória com 20 destinos corretos, tempo positivo e menos de cinco perdas. Prazo 360s. Até a quarta perda há novo ID em local alcançável. Teste também conclui os 20 destinos após quatro perdas, preservando índice 83% (20/24). Quinta perda encerra sem reposição. Partida perfeita 520.

## Progresso e encerramento
Versão 2 migra os saves 1. Final antigo de três fases libera a quarta, preserva a escolha e não inventa estatísticas. Centro agora libera Ubatiba; Ubatiba libera Ponta Negra; apenas Ponta Negra encerra a campanha. Soma final corresponde aos melhores resultados registrados, acompanhada de métricas do jogo e mapa animado esquemático de cinco pontos. Sem afirmação de impacto ambiental real.

## Pendências
Modelos low-poly provisórios, áudio/volume e polimento; avaliação externa de clareza/dificuldade; FPS sustentados; revisão acadêmica da equipe; vídeo, exportação e GDD final DOCX/PDF. Os contadores dos testes não são resultados de participantes reais.
