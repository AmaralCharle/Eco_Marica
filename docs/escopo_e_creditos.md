# Escopo, fontes e créditos

## Fundação
Representação fictícia estilizada; esta área de treino não representa condições ambientais atuais de Maricá. Geometria feita com primitivas nativas do Godot. Um guardião provisório com colete verde e mochila; quatro aparências e animação de coleta ainda pendentes. Não há modelos, texturas ou áudio baixados. Fonte de interface: padrão incluído no Godot. O ícone original do projeto foi preservado.

## Uso de IA
OpenAI Codex: elaboração dos arquivos da Etapa 1, controlador, cenas, geometria procedural, testes e documentação. Arquivos identificados na rastreabilidade e no README. Validação técnica registrada separadamente; revisão e capacidade de explicação pela equipe acadêmica continuam pendentes. Não há resultados de jogadores externos inventados.

## Referências fornecidas
- Modelo GDD - Desafio P2 (preenchivel).docx, Prof. Tiago Ruiz de Castro: lido integralmente antes da implementação, 16 seções e anexos.
- Atividade para P2_SEG_MAR.pdf: critérios, liberdade de motor/estilo, requisitos de entrega.
- Prompt mestre 2.0 fornecido pelo responsável: escopo e sequência de desenvolvimento.
- Ajuda local do executável Godot 4.7.2: comandos de importação, execução, headless e verificação.

Não foram introduzidas orientações específicas de descarte nesta etapa. Referências ambientais confiáveis deverão ser verificadas antes da criação desse conteúdo.

## Pendências acadêmicas
Definir público e problema com evidência (ou suposição identificada); preencher o GDD com o jogo efetivamente entregue; testar com pessoa externa; obter métricas reais; produzir vídeo e exportação Windows. Os templates de exportação não foram instalados nesta etapa. Nenhuma promessa de cumprimento integral da P2 decorre desta fundação.


## Atualização da etapa 2
Codex gerou os componentes de coleta, sessão, classificação, lixeiras, HUD, testes e atualização da área de treino e configuração. Primitivas 3D nativas, sem assets externos. As novas regras e arquivos estão registrados em `rastreabilidade.md`; resultados executados em `validacao.md`. Revisão acadêmica pela equipe e testes externos seguem pendentes.

### Referência ambiental consultada
Resolução CONAMA nº 275/2001, anexo: azul para papel/papelão; vermelho para plástico. Fonte oficial consultada em 14/11/2026: https://www.siam.mg.gov.br/sla/download.pdf?idNorma=291 (órgão ambiental de Minas Gerais); também disponível em https://conama.mma.gov.br/images/conteudo/LivroConama.pdf . A fonte fundamenta o código de cores, sem afirmar disponibilidade de uma coleta específica em Maricá. Todos os coletores exibem o nome do material; o jogo recomenda consultar as regras locais. Exemplos simplificados: papel limpo e garrafas plásticas.

### Decisões das regras do treino
Capacidade: um item por vez. Um erro desconta pontos e interrompe a sequência, mantendo o item em mãos para corrigir. O bônus +20 ocorre em blocos não sobrepostos de três acertos (3, 6, 9...). O índice do treino é destinos corretos / total de resíduos; coletar sem destinar não aumenta esse índice. Não há bônus +100 de missão porque o treino ainda não é uma missão.


## Atualização da etapa 3
OpenAI Codex: criação de `aracatiba.gd`, `aracatiba_world.gd`, `aracatiba.tscn`, `mission_hud.gd`, `mission_progress.gd`, testes/capturas da missão e atualização de configuração, sessão compartilhada, interação, acesso ao treino e documentação. Toda arte nova usa primitivas nativas, sem downloads ou assets de terceiros. Verificações executadas e capturas revisadas em `validacao.md`; revisão e explicação pela equipe acadêmica continuam pendentes.

A orla é fictícia, inspirada no conceito fornecido, sem alegações sobre condições reais locais. O descarte incorreto consome o item somente na missão para compatibilizar os 15 resíduos com a margem de três erros. Vitória não elimina o registro dos erros. O desbloqueio da fase 2 é persistido, mas ela não foi implementada; a interface declara isso. A mudança visual é simbólica e não altera artificialmente o Índice de Limpeza.


## Atualização da etapa 4
OpenAI Codex: catálogo de Lucas/Marina/Rafael/Bia, `character_appearance.gd`, cena `character_visual.tscn`, perfil `player_profile.gd`, seletor `character_selection.gd`, testes/capturas e integração no controlador/menu/estado da missão. Inclui animação procedural simples de coleta e respiração em repouso. Modelos e acessórios construídos com primitivas nativas do Godot, sem assets externos. Perfil e desbloqueio independentes; escolha salva somente após confirmação com gravação bem-sucedida.

Os quatro personagens têm habilidades idênticas e uma cápsula de colisão comum. Gênero/identidade seguem o conceito fornecido, sem diferenças de capacidade. Modelos provisórios e limitações estão declarados em `personagens.md` e `validacao.md`; a equipe ainda precisa revisar, explicar o código e realizar a validação externa acadêmica.


## Atualização da etapa 5
OpenAI Codex: `mission_definitions.gd`, `itaipuacu.gd`, `itaipuacu_world.gd`, `itaipuacu.tscn`, `drifting_waste.gd`, cena de resíduo móvel, teste/captura da fase 2 e integração em sessão, materiais, coletores, HUD, controlador e progresso. Arte procedural com primitivas; nenhum download de modelos, texturas ou sons.

Código de cores dos novos materiais: verde para vidro e amarelo para metal, conforme anexo da Resolução CONAMA nº 275/2001. Fonte oficial consultada em 14/11/2026: https://www.siam.mg.gov.br/sla/download.pdf?idNorma=291 ; cópia institucional: https://unifesp.br/reitoria/dga/images/legislacao/residuos/conama_275.pdf . A fonte fundamenta as cores, sem afirmar serviços locais ou que qualquer tipo de vidro/metal é aceito em toda coleta. O cenário usa frascos inteiros e latas como exemplos simplificados.

Decisões para a fase 2: erro de classificação permite corrigir com penalidade; uma perda não retorna ao mundo como o mesmo objeto. Um novo ID aparece na areia até a quarta perda para manter a meta de 20 acertos possível, enquanto a perda permanece nas métricas. Na quinta perda, derrota sem reposição. A reposição é uma regra de jogo, não uma recuperação do resíduo perdido. A simulação não descreve a situação real de Itaipuaçu nem o movimento real do mar.


## Atualização da etapa 6
OpenAI Codex: cenário `centro_world.gd`, controlador `centro.gd`, cena `centro.tscn`, bueiro `storm_drain.gd`/cena, testes/capturas e integração em configuração, sessão, interação, interface, definições e progresso. Chuva por MultiMesh, prédios, ruas, grades e obstruções feitos com primitivas nativas, sem assets externos. Resultados executados em `validacao.md`.

### Fonte de prevenção e limites
Ministério da Integração e do Desenvolvimento Regional / Defesa Civil Nacional, recomendações de autoproteção em alagamentos: https://www.gov.br/mdr/pt-br/noticias/copy_of_conheca-medidas-de-autoprotecao-que-a-populacao-deve-tomar-em-casos-de-alagamento (rota alternativa consultada: https://www.gov.br/pt-br/noticias/transito-e-transportes/2022/07/conheca-medidas-de-autoprotecao-que-a-populacao-deve-tomar-em-casos-de-alagamento ). A orientação oficial inclui comunicar bueiros obstruídos/destampados à prefeitura, descartar resíduos adequadamente e evitar contato com áreas alagadas. Referência adicional consultada: https://www.gov.br/mdr/pt-br/noticias/defesa-civil-prevencao-ajuda-a-evitar-desastres-naturais . Consulta em 14/11/2026.

A mecânica de limpeza é uma abstração executada por guardiões na simulação; não ensina abrir tampas, entrar em galerias ou atuar em áreas alagadas. Desobstruir reduz um fator de risco, sem garantir que enchentes sejam evitadas: precipitação, infraestrutura e outros fatores não são simulados. A vitória não limpa o céu nem promete segurança real. Não foi inventado resultado de aprendizagem ou teste externo.
