# Personagens — Etapa 4

## Identidades
| ID estável | Nome | Papel | Visual provisório |
|---|---|---|---|
| lucas | Lucas | Explorador ambiental | Colete verde, bolsos e mochila |
| marina | Marina | Guardiã ambiental | Uniforme turquesa, cabelo preso e cinto |
| rafael | Rafael | Agente ambiental | Colete laranja com faixas, boné e botas |
| bia | Bia | Protetora da natureza | Jaqueta roxa e cabelo cacheado |

Nenhum personagem tem vantagem mecânica. Todos usam `guardian.tscn` / `guardian.gd`, com os mesmos parâmetros de movimento, câmera e colisões. O visual é uma cena independente, também usada nas prévias. Membros permanecem estáveis ao trocar aparência; somente materiais e acessórios mudam. Animações procedurais: repouso com respiração sutil, caminhada, corrida e gesto de coleta.

## Seleção
MENU → SELECAO_PERSONAGEM → confirmar ou cancelar → MENU. Quatro prévias visíveis juntas, botões por nome, descrição do selecionado, rotação opcional, confirmação nominal e retorno. Só confirmar grava a escolha; cancelar/Esc não alteram o perfil. Instruções e jogabilidade mantêm seu fluxo anterior.

## Persistência
`user://player_profile.json`: versão 1 e `selected_character`. Leitura valida estrutura, versão e ID; dados ausentes/corrompidos usam Lucas. Escrita passa por arquivo temporário no mesmo diretório antes de substituir o perfil. Se falhar, o estado anterior é mantido e a seleção mostra aviso. O desbloqueio continua no arquivo independente de progresso e não é apagado por seleção ou cancelamento.

O controlador aplica o perfil ao entrar no treino; Araçatiba aplica o mesmo perfil antes de iniciar a missão. A escolha é reaplicada em novas instâncias do jogo. Testes usam perfis próprios, sem alterar o perfil real do jogador.

## Limitações
Os quatro visuais são modelos low-poly provisórios. Animação procedural, sem rig, vozes ou áudio. Aplicação validada nas duas cenas já existentes; fases futuras reutilizarão o controlador e serão testadas ao serem implementadas. Avaliação artística, conforto e usabilidade por pessoa externa permanecem pendentes.
