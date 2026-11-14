# Operação Araçatiba — regras implementadas

## Ciclo e objetivo
Menu → instruções → jogando → vitória/derrota → reinício ou menu. Esc alterna jogando/pausado. Instruções e pausa não consomem tempo. Não existe tela de campanha finalizada nesta etapa.

São 15 resíduos identificados individualmente, de papel ou plástico, dispostos em cinco faixas ao longo da orla. Há três pares de coletores, próximos ao início, meio e fim do percurso. Lagoa, ciclovia, bancos, vegetação e limites físicos compõem uma representação fictícia.

O jogador carrega um item por vez; usa E dentro do alcance de 2,2 metros e com linha de visão desobstruída. Coleta +5 uma única vez. Destino correto +10. Destino incorreto -5 (mínimo zero), consome o item e quebra a sequência. A cada bloco de três acertos consecutivos, +20. No treino o erro mantém o item em mãos, para possibilitar a correção.

## Vitória e derrota
Vitória: 15 itens recolhidos **e classificados**, pelo menos 12 acertos, no máximo três erros e tempo restante positivo. Derrota: quarto erro ou tempo zero. Coletar o último item sem classificá-lo ainda não vence. A decisão de resultado trava ações e impede bônus de missão repetido.

Vitória concede +100. Uma partida perfeita rende 425 pontos. A tela mostra pontos, tempo utilizado, coletados, acertos, erros e índice. Índice = acertos / 15; a vitória com 12 acertos mostra 80%. A recuperação visual acrescenta flores, altera a vegetação e mostra uma placa, sem aumentar o índice.

## Progresso e próximos passos
Vitória grava o desbloqueio de Itaipuaçu em arquivo local validado. Derrota ou reinício não apagam esse arquivo. Esta é a única informação persistida nesta etapa. Itaipuaçu já é jogável, após desbloqueio, pelo menu ou pela opção Próxima fase.

Teste humano de ritmo, dificuldade e clareza permanece pendente. Os testes automatizados e as capturas não constituem evidência de aprendizagem. A seleção de personagens e as três missões já estão integradas; o próximo trabalho é polimento e preparação da entrega.
