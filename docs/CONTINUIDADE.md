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


## Continuidade — Asset Revolution

Branch `asset-revolution`; base aprovada `upgrade-visual-4` em df0ab5d e tag `checkpoint-pre-assets-df0ab5d`. Main permanece anterior. Leia ASSET_REVOLUTION.md e catalogo_assets.md antes de trocar modelos. Recursos são somente visuais; preserve colisões, grupos, IDs e condições. testes/test_imported_assets.gd valida rigs reais, materiais/sky ativos, malhas filhas desenhadas, aves, pausa e barco. --legacy-art desativa o novo passe para comparação. O fallback procedural continua testado separadamente. Próximos refinamentos dependem de assets ambientais autorais e animações faciais/ações específicas, não de criar fases.

## Pescadores — 16/11/2026

Branch ponta-negra-pescadores, checkpoint anterior checkpoint-pre-pescadores-4f5b05f. Veja PONTA_NEGRA_PESCADORES.md para regras, tempos, posições e limitações. Redes usam reação analítica apenas no barco, sem novos corpos físicos; não transformar em bloqueios do corredor central/píer. Falas e avisos têm timers separados. O passageiro existente usa SeatedRowingPose no rig; propulsão/inventário originais. Cinco músicas originais reproduzíveis via compose_phase_music.py; não restaurar a antiga frase compartilhada por acidente. Vozes dependem de gravações/assets licenciados.

Revisão 17/11: câmera embarcada admite mira pelo mouse sem deslocar o SpringArm ou virar o casco. O teste espera o blend de embarque e mira pelo centro da tela; a captura adicional mostra Beto na ponte. Não substituir esse teste por projeção arbitrária fora da tela.

Correção posterior solicitada pelo autor: cair a pé no canal causa DERROTA, sem afetar o barco. Tablado visível termina em x=8 para não sobrepor o gramado; collider original preservado. Não ampliar novamente a malha/tábuas sobre o gramado coplanar. Ver PONTA_NEGRA_CORRECOES_AGUA_PIER.md e test_ponta_water.gd. Última regressão: 1.199 verificações em 25 suítes sem falhas.

Retorno do autor: a queda ocorria no final do gramado, fora do retângulo original do canal. Não restringir check_water_fall por x/z: qualquer queda abaixo do piso seguro da fase deve perder, exceto embarcado. Novo teste caminha realmente além de z=20; outras cinco bordas também cobertas. Regressão focal mais recente: 169 verificações sem falhas; bateria completa anterior não repetida.
