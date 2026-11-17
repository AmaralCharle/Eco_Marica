# Ponta Negra — queda na água e piso do píer — 17/11/2026

## Correções

- Cair a pé na água ou além das bordas do gramado agora encerra a tentativa em derrota, com “Você caiu na água! Use o barco para navegar pelo canal.” O fluxo existente oferece jogar novamente ou voltar ao menu. A tela de instruções e o GDD incluem a nova condição. A verificação usa os pés do controlador abaixo de y=-0,02, sem restringir x/z, pois todas as superfícies caminháveis da fase ficam em y>=0. Saltar acima da água não encerra a partida antes do contato.
- O teste é exclusivo de JOGANDO e fora do barco. Navegação, posição do jogador oculto, pausa, ponte, margens e desembarque permanecem seguros. Não cria perda de resíduo, pontos extras ou outro formato de save.
- O tablado original se estendia de x=6 até x=10, enquanto o gramado começava em x=8. Ambas as faces superiores estavam em y=0: sobreposição de dois metros, sujeita a z-fighting conforme a câmera se move.
- A malha visível do tablado termina agora em x=8, junto à margem, e as linhas das tábuas acompanham esse limite. O collider original 4×0,25×4, o nível do piso, o acesso e as posições de embarque/desembarque foram preservados. Nenhuma configuração global de renderização foi reduzida.

## Verificação

`tests/test_ponta_water.gd`: 15 verificações de caminhada real do gramado ao píer sem oscilação da altura do controlador, embarque, navegação com jogador oculto, desembarque, segurança nas margens/píer/ponte e durante salto, pausa, queda física por gravidade, interrupção dos controles e preservação do motivo da derrota. Usa saves isolados de teste.

Bateria completa: **1.199 verificações em 25 suítes, zero falhas**. A suíte de interface foi reexecutada após atualizar a instrução: 226 verificações sem falhas. Encerramentos headless imediatos ainda apresentam avisos ObjectDB já conhecidos; a execução gráfica com encerramento suave terminou sem erros/avisos. Esses testes não substituem a confirmação do autor durante uma partida no notebook.

O modo opcional `--capture` gera três imagens em Mobile/Vulkan, 1280×720: piso por dois ângulos e tela de derrota por queda. A revisão remove a sobreposição geométrica identificada; capturas estáticas não provam ausência de toda cintilação em qualquer câmera ou configuração. Conferir também o percurso habitual no notebook.

Arquivos de implementação: `scripts/levels/ponta_negra.gd`, `scripts/levels/ponta_negra_world.gd`, `scripts/effects/world_polish.gd`, `scripts/ui/expansion_hud.gd`. Testes e evidências: `tests/test_ponta_water.gd`, `tests/artifacts/ponta_fix_*`, `tests/artifacts/test_ponta_water.log` e `tests/artifacts/validation_summary.json`.

## Retorno do autor: água no final da grama

A primeira correção verificava apenas x entre -8 e 8, z entre -70 e 20. O autor relatou queda no final do gramado, fora desse retângulo. O novo teste reproduziu o erro com caminhada real desde (11,0,19), além de cinco quedas externas: 21 verificações, seis falhas antes da correção (`ponta_edge_reproduction.log`, resultado negativo esperado da versão anterior).

A restrição horizontal foi removida. Agora a mesma caminhada e as cinco bordas causam derrota; navegação, ponte, margens, píer e pausa continuam seguros. Regressão focal após correção: **169 verificações sem falhas** — água/bordas 21, acesso 6, missão 20, pescadores 122. Não foi repetida a bateria completa de 1.199; seu resumo permanece como histórico da execução anterior. Nova execução gráfica: 21 verificações sem falhas e quarta captura `ponta_fix_grass_edge_game_over.png`, com derrota após sair pelo final do gramado.
