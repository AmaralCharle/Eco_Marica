# Resgate de Itaipuaçu — Etapa 5

## Acesso e missão
Requer Araçatiba concluída. O menu e a opção Próxima fase abrem a cena própria com instruções; o cronômetro começa ao confirmar. Acesso direto também verifica o desbloqueio. Escolha de personagem e progresso são preservados nas transições.

Objetivo: 20 destinos corretos, quatro materiais, 240 segundos. Derrota no tempo zero ou na quinta perda ao mar. Não há limite de erros de classificação nesta fase; cada erro tira 5 pontos, respeita piso zero, quebra sequência e mantém o item em mãos para corrigir.

## Layout e risco
20 itens iniciais em cinco faixas e quatro colunas na areia, cinco de cada material. Três estações de quatro coletores identificados. Mar a oeste, restinga e limite de circulação a leste, cenário fictício estilizado. Objetos de vidro representam frascos inteiros.

Sete itens se movem para oeste; a velocidade base é 0,06 m/s, com incremento de 0,01 por faixa. Linha de perda: x = -11,5. A legenda → MAR mostra a estimativa restante em segundos. Coletar interrompe o deslocamento; pausa/menu/instruções congelam movimento e cronômetro. Itens disponíveis que cruzam a linha são marcados LOST e ocultados; não podem pontuar nem ser recoletados.

## Perdas, reposição e índice
Cada uma das primeiras quatro perdas gera um novo item parado na areia, com outro ID. O objeto perdido continua registrado. Isso preserva 20 itens recuperáveis sem eliminar a consequência da perda. A quinta perda encerra a fase antes de qualquer nova reposição.

Índice = destinos corretos / total de itens registrados. Exemplos: 20/20 = 100%; 20/24 = 83% após quatro perdas. Pontuação segue coleta +5, destino +10, erro -5, bônus +20 por bloco de três acertos consecutivos e missão +100. Partida perfeita: 520 pontos. Vitória ativa recuperação simbólica e grava o desbloqueio do Centro.

## Limites e validação
O Centro é desbloqueado ao vencer e já pode ser iniciado pela opção Próxima fase ou pelo menu. Deslocamento do mar é programado, não uma simulação natural. Testes e capturas usam estados controlados; avaliação humana de ritmo, conforto e aprendizagem segue pendente. Ver `validacao.md` para resultados executados e `rastreabilidade.md` para arquivos e funções.
