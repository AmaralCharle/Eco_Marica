# Estado para retomada

Atualizado em 16/11/2026. O autor retomou o desenvolvimento e solicitou polimento dos cenários e, em seguida, redesenho da interface e melhoria dos personagens. A aprovação registrada em 14/11 refere-se à versão anterior; a etapa atual ainda aguarda sua avaliação.

O desenvolvimento continua aberto. O autor vai trazer novas ideias após uma pausa. A preparação da entrega acadêmica e da exportação foi interrompida a seu pedido; só deve ser retomada quando ele avisar. Não interpretar a aprovação do polimento como encerramento do projeto.

## Versão aprovada

- Cinco fases implementadas: Araçatiba, Itaipuaçu, Centro, Ubatiba e Ponta Negra.
- Correção do acesso às lixeiras do Centro preservada.
- Polimento audiovisual, quatro personagens, barco, menus, áudio sintetizado e configurações locais.
- Forward Mobile/Vulkan como padrão; opções de qualidade Baixa, Média e Alta.
- 356 verificações em 15 suítes aprovadas; benchmark controlado e limites em `POLIMENTO.md`.
- O autor informou que testou e aprovou o resultado visual. Isso não substitui o teste externo acadêmico, cujo perfil e observações ainda não foram registrados.

## Preparação interrompida

O modelo GDD e o enunciado foram relidos, sem alterar os originais. Nenhum GDD final, vídeo ou executável Windows foi concluído. Os templates de exportação não estão instalados; o utilitário opcional `tools/fetch_windows_templates.py` foi preparado e apenas listou os arquivos disponíveis no pacote oficial. Não foi feito o download dos executáveis de template.

O GDD de trabalho permanece em `docs/GDD_5_FASES.md`. Identificação da equipe, matrículas, data de entrega e teste externo continuam pendentes para quando o autor decidir preparar a entrega.

## Próxima ação

Polimento de cenários implementado nas cinco fases, com prioridade para Centro, Ubatiba e Ponta Negra. Alterações, evidências, desempenho e limites em `CENARIOS_2026_11_16.md`. Interface também implementada: HUD e telas comuns nas cinco fases, com 604 verificações em 17 suítes e revisão gráfica 1280 × 720; detalhes em `INTERFACE_2026_11_16.md`. Personagens também aprimorados: Lucas validado primeiro, depois Marina/Rafael/Bia; qualidade Alta ativada e fronteira opcional para GLB. Referências visuais também aplicadas em nova passagem dos cenários, com prioridade Centro/Ubatiba/Ponta Negra e preservação dos acessos. Resultado atual: 727 verificações em 19 suítes. Ver `DIRECAO_ARTE_REFERENCIAS_2026_11_16.md`. Evidências em `PERSONAGENS_2026_11_16.md`. Próxima ação: avaliação do autor e novas ideias. Preservar as cinco fases, os saves e os testes; não retomar a finalização acadêmica/exportação sem solicitação do autor.

## Branch de avaliação 4.0

O autor autorizou o prompt 4.0 e pediu retorno seguro se necessário. Base preservada na main/tag `fase-1-final` (3fc476c); configuração local do editor preservada em d89078f; trabalho em `upgrade-visual-4`. Há backup ZIP, patch, arquivos não versionados e saves pré-upgrade fora do repositório. Não houve reset/clean nem merge na main.

Novos materiais/vegetação/poses, caderno Q, vento lateral, prioridades, planejamento, estrelas, opcionais e histórico. Auditoria comparou três renderizadores e manteve Mobile. Quatro ciclos de memória sem órfãos/acúmulo de nós; Alto próximo de 61–81 FPS nas vistas controladas. Diário em `visual_upgrade_tasks.md`, regras e rollback em `VISUAL_UPGRADE_4.md`. Próxima ação após entrega: teste humano do autor no notebook. Não interpretar essa evolução como finalização acadêmica ou aprovação humana já ocorrida.
