# Asset Revolution — relatório técnico e artístico

## Segurança

Base preservada: `upgrade-visual-4` em `df0ab5d`. Branch desta etapa: `asset-revolution`; tag de retorno `checkpoint-pre-assets-df0ab5d`. `main` e `fase-1-final` continuam em `3fc476c`. Backup ZIP anterior à integração em `outputs/asset-revolution/pre-assets-df0ab5d.zip` na pasta deste chat. Não houve reset, clean ou sobrescrita de alterações rastreadas existentes. Metadados .uid/.import que já estavam locais foram preservados.

## Resultado por fase

| Fase | Substituições e integração | Preservação |
|---|---|---|
| Centro | Quatro fachadas comerciais diferentes da Kenney, portas/janelas/telhados dos modelos, marquises, postes, cones; árvores Quaternius de troncos ramificados e folhas em camadas; asfalto PBR 1K ambientCG; jardins harmonizados; céu acompanha tempestade e aves recolhem com chuva forte. | Corpos dos prédios, calçadas/rampas, resíduos, coletores, três bueiros e progressão da tempestade. |
| Ubatiba | Árvores, arbustos floridos, samambaias, flores e pedras modeladas; trilha com mapas de solo; mudas usam árvore em miniatura e mantêm crescimento simbólico; grama e cobertura continuam progressivas; céu HDRI suave. | 12 avaliações, oito plantios, três proteções; pontos aptos/inaptos, acesso ao riacho e limites físicos. |
| Ponta Negra | Barco de remo Kenney com casco, bancos e remos; movimento de remos apenas visual; madeira PBR no píer/ponte; vegetação costeira e rochas; céu HDRI refletido de forma simplificada na água e espuma já existente. | Controlador, câmera, embarque/desembarque, capacidade cinco, descarga, perdas, reposições, passagem sob a ponte. |
| Araçatiba | Palmeiras modeladas com folhas filhas preservadas pelo agrupamento, árvores Quaternius, canteiros e flores, rochas e postes; madeira dos bancos/guarda-corpo, céu de manhã e água estilizada. | Orla, ciclovia, 15 resíduos, cores de coleta e barreiras físicas. |
| Itaipuaçu | Areia PBR discreta, palmeiras, vegetação de restinga estilizada, flores, rochas e céu costeiro; coerência de materiais com as demais fases. | Vento e prazo originais, 20 descartes, limite de perdas e acesso aos objetos. |

Os arquivos `.tscn` das fases não foram reconstruídos. As mudanças entram nas cinco cenas pela camada compartilhada `scripts/effects/world_polish.gd`, pelas fábricas e pelos visuais de plantio/barco/personagens. Construções e elementos grandes permanecem nos volumes anteriores. Os modelos de vegetação são estilizações genéricas; não representam identificação botânica de espécies locais.

## Recursos reais e origem

**36 recursos do catálogo aparecem efetivamente no jogo**, contando cada conjunto PBR como um recurso: 18 modelos Kenney selecionados, oito modelos Quaternius de natureza, quatro personagens Quaternius, quatro conjuntos PBR ambientCG, um HDRI Poly Haven e uma ave AssetQuest. O catálogo tem também nove candidatos rejeitados, claramente separados por estado. Tamanhos, formatos, autores, URLs, hashes, caminhos e fases estão em [catalogo_assets.md](catalogo_assets.md) e [asset_manifest.json](asset_manifest.json). `tests/artifacts/asset_integration_report.json` registra os recursos observados na execução.

- **Quaternius**: Stylized Nature MegaKit **Standard gratuito**, CC0 confirmado no arquivo License_Standard.txt; árvores, arbustos, samambaias, flores, grama e rochas. Não usamos os shaders pagos da edição Source.
- **Kenney**: City Kit Commercial, City Kit Roads, Nature Kit e Watercraft Kit; CC0 nas páginas e nos License.txt dos ZIPs. Só modelos selecionados, colormaps referenciados e licenças permanecem na raiz do Godot.
- **Personagens Quaternius via Poly Pizza**: Man, Woman Casual, Woman e Worker. Páginas do autor e diálogos de download confirmam CC0. Rigs próprios e animações originais, com ajuste de paleta, escala e acessórios.
- **ambientCG / Lennart Demes**: Asphalt001, Ground037, Ground055S e Wood001, CC0, mapas Color/Roughness/NormalGL 1K. Mistura de luminosidade com a paleta do jogo; sem displacement ou tesselação.
- **Poly Haven / Greg Zaal e Jarod Guest**: Kloppenheim 05 Pure Sky 1K, CC0, HDR de cerca de 1 MB com hash publicado conferido. Uso da API identificado por User-Agent próprio; créditos Poly Haven incluídos.
- **AssetQuest**: Bird, CC0, 194 triângulos. Corpo original estático com voo, asas leves e pio sintetizado acrescentados pelo projeto.

Downloads originais e inventários ficam em `../asset-revolution-downloads`, fora da raiz importável e do Git. Nenhum executável ou script de fornecedor foi extraído ou executado. Nenhuma aplicação foi instalada. Imagens de referência não foram tratadas como modelos 3D.

## Personagens e animações

Lucas foi o piloto; após testes físicos e capturas, o padrão foi aplicado a Marina, Rafael e Bia. Nomes, IDs, seleção, salvamento, paletas verde/turquesa/laranja/roxo e equipamentos ambientais foram mantidos. Os novos modelos têm proporções mais alongadas e novos penteados; a silhueta não é idêntica à versão procedural.

O modelo externo fica sob `ExternalModel/Alignment`; o controlador conserva os mesmos pivôs lógicos, cápsula e câmera. Mochilas/bolsa/equipamentos acompanham o osso do tronco. Animações de caminhada e corrida usam os clipes do próprio modelo. Saltos usam os clipes disponíveis; **Worker/Rafael não traz clipe de salto**, usando idle enquanto a cápsula executa o salto normalmente. Alcance para coleta/plantio é um modificador leve sobre os ossos do próprio rig, sem reutilizar animações de combate. Sem retargeting forçado entre esqueletos.

A pausa congela os clipes importados. A seleção pode mostrar prévias estáticas. O visual procedural continua disponível como fallback e com `--legacy-art`. Os rigs gratuitos não incluem animação facial detalhada, sincronização labial nem clipes exclusivos artísticos de cada ação ambiental; esse refinamento ainda depende de assets/animações adicionais.

## Desempenho e decisões artísticas

Mobile/Vulkan mantido no Godot 4.7.2, viewport 1280×720, Intel UHD integrada. Texturas Quaternius limitadas a 1024 px, materiais PBR 1K, céu 1K, sem novos corpos físicos ou luzes dinâmicas. MultiMesh compartilha geometria de árvores, palmeiras e plantas; a coleta dos filhos acontece antes de ocultar malhas-pai, preservando as folhas dos modelos hierárquicos.

O primeiro piloto com sombras das folhas recortadas e MSAA 8× caiu para cerca de 33 FPS. No ensaio comparativo, sombras opacas simplificadas das copas elevaram o resultado para aproximadamente 45 FPS com 8×; com 2×, aproximadamente 62 FPS. Por isso o Alto desta branch usa **MSAA 4×**, mantendo sombras de 4096/quatro cascatas; Médio usa 2× e sombras próximas; Baixo mantém 3D a 80% e sem sombras. Essa redução foi fundamentada em medição, sem trocar o renderizador ou mexer nas metas.

Aves: uma/duas/quatro por perfil; ativação até 65 m da câmera, trajetórias suaves e pequenas variações de altura, sem IA complexa. Pios usam o bus Ambience e param na pausa. Centro recolhe as aves quando a tempestade fica forte.

Regressão completa executada: **1062 verificações em 23 suítes, zero falhas e nenhuma mensagem ERROR/SCRIPT ERROR nos logs finais**. Alto: 52.9–79.6 FPS médios; Médio: 63.6–87.3; Baixo: 112.2–191.1. Quatro ciclos das cinco fases retornaram a 18 nós e zero órfãos, RSS 882.4–900.8 MiB, sem crescimento contínuo. Valores por fase/p95/draw calls/VRAM em [ASSET_REVOLUTION_MEDICOES.md](ASSET_REVOLUTION_MEDICOES.md). Não interpretar ensaios curtos como garantia de FPS mínimo, bateria/temperatura, primeira importação ou partida humana completa. Layout 1080p não equivale a benchmark a 60 FPS nessa resolução.

## Problemas encontrados e tratamento

- Quaternius antigo no Google Drive: quota excedida; sem contorno. Natureza obtida pelo fluxo gratuito oficial itch.io; personagens pela distribuição pública do próprio autor na Poly Pizza.
- Acesso HTTP automatizado da Poly Pizza recusado: download normal pelo navegador funcionou, sem login ou barreiras contornadas.
- Kenney Mini Characters: rig/animações funcionaram na prévia, mas proporções chibi e profissões descaracterizariam os protagonistas; rejeitados e movidos para o cache externo.
- Árvores Kenney detalhadas/oak: copas muito quadradas em comparação com Quaternius; retiradas da integração final.
- Cabos do City Kit: ajuste resultou em faixas grossas; rejeitados, mantidos cabos finos autorais.
- Barco de pesca: cabine e volume inadequados ao controlador pequeno; adotado barco de remo.
- Filhos de MeshInstance3D: o primeiro agrupamento ocultava pais antes de coletar folhas filhas; corrigido e coberto por teste de contagem de malhas efetivamente desenhadas.
- Árvores na continuação do canal: reposicionadas sobre as margens, sem alterar o canal ou a física; nova verificação de raízes fora da água.
- Avisos de áudio em alguns testes headless que encerram imediatamente são registrados; não declarar ausência universal de vazamentos a partir de ensaios curtos.

## O que ainda pede assets melhores

Fachadas típicas de Maricá, bancos urbanos e lixeiras de coleta seletiva modelados especificamente; píer/ponte e abrigos rurais mais detalhados; espécies tropicais locais; personagens com figurinos ambientais autorais, penteados fiéis, expressões faciais e clipes específicos de plantio/coleta/remo. As lixeiras e resíduos funcionais mantêm visuais anteriores quando a substituição comprometeria cores, IDs ou acesso. O resultado ainda não equivale a uma produção comercial com assets exclusivos.

## Teste e retorno

Abrir o projeto desta pasta, parar execução antiga com F8 e iniciar F5. Explorar as cinco fases, Q/Esc, tempestade, plantio e barco; testar os quatro personagens. Médio oferece mais margem na GPU integrada. Jogar uma sessão longa com teclado/mouse e som para validar conforto, temperatura e fluidez.

Para comparar sem editar código: executar com o argumento de usuário `--legacy-art`, usando o mesmo save e câmera de teste. Para retornar à versão aprovada, guardar o trabalho atual e usar a branch `upgrade-visual-4`/tag `checkpoint-pre-assets-df0ab5d`, ou criar um worktree limpo a partir da tag. Não usar reset/clean sobre arquivos locais. Copiar saves atuais antes de testar leitores antigos. Não houve merge na main.

## Rastreabilidade

| Mudança | Código | Evidência |
|---|---|---|
| Instanciação, normalização, materiais e MultiMesh | effects/asset_library.gd | test_imported_assets + integração por fase |
| Centro | effects/asset_revolution.gd + world_polish.gd | testes Centro/acesso + capturas iguais antes/depois |
| Jardins e composição | world_polish.gd + reference_art_pass.gd | ambiente e direção de arte |
| Barco | effects/boat_polish.gd | barco/Ponta Negra/acesso e passageiros |
| Plantio visual | gameplay/planting_plot.gd | 12/8/3 e campanha |
| Modelos e rigs | player/production_character.gd + character_appearance.gd + imported_reach.gd | personagens, fallback e rigs reais |
| Aves | effects/ambient_birds.gd | quantidade, pausa e tempestade |
| Pio original | tools/generate_bird_call.py | fonte de síntese e WAV |
| Aquisição seletiva | tools/fetch_asset_revolution.py | páginas oficiais, inventários e hashes |

As regras de reciclagem, plantio, barco, decisões opcionais, estrelas, pontuação e condições de vitória/derrota não foram modificadas. Esta etapa atualiza o GDD de trabalho e créditos; não gera a entrega acadêmica final, vídeo ou instalador Windows.

## Estado das 18 tarefas

| Tarefa | Estado / evidência |
|---|---|
| 01 Preservação | Branch, tag, ZIP e inspeção do projeto. |
| 02 Pesquisa | Fontes oficiais e licenças conferidas; falhas e alternativas documentadas. |
| 03 Catálogo | 45 entradas, 36 integradas e nove rejeitadas; estados separados. |
| 04 Organização | Recursos por autor/pacote, originais fora da raiz importável. |
| 05 Centro | Piloto revisto em captura e validado antes de ampliar. |
| 06 Ubatiba | Plantio e acessos preservados, vegetação/mudas/solo integrados. |
| 07 Ponta Negra | Barco, margens, madeira e água; embarque e ponte verificados. |
| 08 Araçatiba | Orla, palmeiras, jardins e céu; coleta preservada. |
| 09 Itaipuaçu | Areia, vegetação, rochas e horizonte; vento/metas preservados. |
| 10 Personagens | Lucas piloto e quatro rigs integrados; sem retargeting; limitações de clipes/facial explícitas. |
| 11 Céu | HDRI 1K ativo em quatro fases; Centro mantém tempestade progressiva. |
| 12 Aves | Corpo CC0 estático com voo/asas/pio autorais, quantidade/distância/pausa controladas. |
| 13 Materiais/luz | Paleta harmonizada, rugosidade e mapas 1K; luzes e contrastes mantidos coerentes. |
| 14 Otimização | Três perfis medidos, MultiMesh, proxies de sombra, sem colisões complexas extras. |
| 15 Mecânicas | Controladores, corpos e objetivos preservados; regressão física existente mantida. |
| 16 QA | 1062 verificações / 23 suítes sem falhas; capturas 720p/1080p e memória. |
| 17 GDD/créditos | Markdown de trabalho, rastreabilidade e catálogo atualizados; sem entrega acadêmica final. |
| 18 Relatório | Este relatório, medições e comparativos antes/depois; lista de arquivos na pasta de saída. |

Capturas finais: 36 estados de campanha em 720p/1080p, seis detalhes, 12 poses/ações/passageiros e uma galeria frontal dos quatro modelos. Todos os comandos finais de captura e benchmark terminaram sem ERROR/SCRIPT ERROR. A campanha simulada manteve cinco vitórias, 15 estrelas e cinco opcionais com os modelos novos.
