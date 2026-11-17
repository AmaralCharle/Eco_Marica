# Assets, fontes e uso de IA — polimento 3.0

Atualização de cenários em 16/11/2026: `environment_meshes.gd` gera copas, folhas, tufos, peças chanfradas, trilha e manchas de solo; `environment_surface.gdshader` produz oito famílias de acabamento; água/folhagem e ambientação foram revistas. Código e malhas originais gerados com assistência Codex, sem fontes externas, imagens geradas ou downloads de assets. Uso: cinco fases, barco, lixeiras, bueiros e mudas. Detalhes e limitações em `CENARIOS_2026_11_16.md`.

Revisão dos personagens em 16/11/2026: malhas contínuas e detalhes em `character_geometry.gd`/`character_appearance.gd`, sem modelos externos ou texturas baixadas. Código e geometria originais com assistência Codex. `character_model_adapter.gd` prepara montagem opcional de GLBs; não inclui rig ou animações externos. Contrato e limitações em `MODELOS_GLB.md` e `PERSONAGENS_2026_11_16.md`.

Direção de arte por referências em 16/11/2026: `reference_art_pass.gd` e `art_direction_meshes.gd` acrescentam decoração e relevo originais com assistência Codex; `water.gdshader` e composição da luz/vegetação foram revistos. As seis imagens do autor foram inspiração e não foram copiadas ou distribuídas. Não houve download de novos assets. Detalhes em `DIRECAO_ARTE_REFERENCIAS_2026_11_16.md`.

Recursos implementados neste projeto com auxílio de OpenAI Codex. Não foram baixados modelos, texturas, músicas ou efeitos de terceiros nesta etapa. O autor do projeto deve revisar a atribuição de autoria e a declaração de uso de IA conforme as regras da disciplina. Não se afirma exclusividade ou licença de terceiros para material produzido por IA.

| Recurso | Autor/origem | Fonte reproduzível | Licença/condições | Uso |
|---|---|---|---|---|
| 6 trilhas instrumentais WAV | Síntese matemática original, assistência Codex | `tools/generate_audio.py`, função `main`, escala e osciladores | Sem amostras externas; código/saídas produzidos para este projeto; assistência de IA declarada | Menu e cinco fases |
| 17 efeitos de ação/interface | Síntese matemática original, assistência Codex | Mesmo gerador, `phrase` | Sem gravações ou conteúdo musical comercial | Botões, seleção, missão, coleta, acerto/erro/bônus, vitória/derrota/desbloqueio, plantio/solo, bueiro, embarque/desembarque/descarga |
| 3 passos | Ruído determinístico e osciladores | Mesmo gerador, prefixo `step_` | Originais sintetizados; não são gravações de superfícies reais | Pavimento, areia e terra |
| 8 sons de ambiente/motor | Ruído filtrado e osciladores | Mesmo gerador: cinco localidades, chuva, motor e trovão | Originais sintetizados; pássaros/ondas são sugestões sonoras provisórias, sem gravação de campo | Ambience/SFX |
| Água e vento em folhas | Shaders originais em Godot Shader Language | `assets/materials/water.gdshader`, `foliage.gdshader` | Código gerado no projeto com assistência Codex; sem texturas externas | Lagoa, mar, riacho, canal e vegetação |
| Personagens, árvores, jardins, morros, fachadas e barco | Malhas/primitivas procedurais, assistência Codex | `character_appearance.gd`, `world_polish.gd`, `boat_polish.gd` | Recursos nativos e código do projeto; não são GLB de terceiros | Jogador, prévias e cenários |
| Folha da marca e tema | Desenho vetorial/código original, assistência Codex | `eco_mark.gd`, `eco_theme.gd` | Sem imagem externa ou fonte baixada | Menus e HUD |
| Tipografia de interface | Fontes locais do sistema (Segoe UI/Noto Sans/Arial), com fallback do Godot | `SystemFont` em `eco_theme.gd` | Fontes mantêm suas licenças originais; nenhum arquivo foi copiado ou redistribuído | Interface |
| Ícones da HUD e localidades | Desenho vetorial original com assistência Codex | `eco_icon.gd`, `phase_card.gd`, `campaign_map.gd` | Código do projeto, sem imagens externas | HUD, menus e conclusão |
| Símbolo ♻ dos coletores | Fonte disponibilizada pelo motor | Recursos padrão do Godot | Licenças originais distribuídas com o motor; preservar avisos do exportador | Coletores |

Total de áudio: **34 arquivos** PCM WAV mono 16 bits, 22050 Hz. Reproduzir a geração com Python 3, executando `python tools/generate_audio.py`; Python não é dependência para jogar. Importação e reprodução ficam com o Godot. Os efeitos são intencionalmente simples e ainda podem ser substituídos por gravações CC0 cuidadosamente creditadas após avaliação auditiva.

As seis imagens fornecidas pelo autor serviram de direção artística: aventura urbana, reflorestamento em Ubatiba, Revenge of the Savage Planet, Reef by Barji, personagem de Isla Wanderleaf e cena tropical low-poly do Arthub. As imagens não foram copiadas para os assets, recortadas, convertidas em modelos ou redistribuídas. A referência não concede licença sobre personagens, marcas, modelos ou músicas desses jogos/sites. Não foram inventados autores ou URLs ausentes.

Diretórios usados: `assets/music`, `assets/sounds`, `assets/materials`; malhas, animações e efeitos permanecem em código nativo em `scripts/player` e `scripts/effects`. Não existem texturas/modelos externos a catalogar nesta versão. `icon.svg` anterior foi preservado. Fontes ambientais e acadêmicas anteriores continuam em `escopo_e_creditos.md`.

## Upgrade 4 — recursos adicionais

`upgrade_visuals.gd` cria detalhes comerciais e respingos agrupados; `stylized_glass.gdshader` e `rain_splash.gdshader` são shaders originais. `environment_meshes.gd` recebeu folíolos curvos; a recuperação usa geometria nativa e material de cobertura. `character_appearance.gd` articula cotovelos sem assets externos. Código, modelagem procedural e materiais produzidos no projeto com assistência Codex.

Três WAV adicionais: decision, optional e stars. Síntese matemática original em `tools/generate_upgrade_audio.py`, PCM mono 16 bits/22050 Hz, sem samples ou músicas externas. Executar o gerador anterior para 34 arquivos e o novo para esses três; total atual **37 WAV**. Nenhum GLB externo foi importado. Referências visuais continuam apenas inspiração e não foram redistribuídas. Limitações e declaração de uso de IA preservadas.


## Asset Revolution — recursos externos efetivamente utilizados

Catálogo completo por arquivo/conjunto, autor, licença, URL, destino e fase: [catalogo_assets.md](catalogo_assets.md), [asset_manifest.json](asset_manifest.json). São 36 recursos integrados, todos CC0: Kenney (18 modelos selecionados dos kits Commercial/Roads/Nature/Watercraft), Quaternius (oito modelos da edição Standard gratuita Stylized Nature MegaKit e quatro personagens via Poly Pizza), ambientCG/Lennart Demes (Asphalt001, Ground037, Ground055S, Wood001, 1K), Poly Haven/Greg Zaal e Jarod Guest (Kloppenheim 05 Pure Sky 1K) e AssetQuest (Bird, 194 triângulos). Licenças e créditos acompanham assets/imported; arquivos originais e hashes no cache externo/manifesto.

Quaternius: https://quaternius.com/packs/stylizednaturemegakit.html ; personagens: https://poly.pizza/m/HMnuH5geEG , https://poly.pizza/m/jpKRgGDxhk , https://poly.pizza/m/Yg2bQZO6Hj , https://poly.pizza/bundle/Animated-Women-Pack-HHSKxnk1mY . Kenney: https://kenney.nl/assets . ambientCG: https://ambientcg.com/ . Poly Haven: https://polyhaven.com/a/kloppenheim_05_puresky . Bird: https://poly.pizza/m/ZQmkPfCsNQ .

Adaptações com assistência Codex: seleção, redução de texturas Quaternius para até 1024px usando Pillow já disponível, paleta, escala, agrupamento, sombras simplificadas, ligação de acessórios aos ossos e pose de alcance. Os modelos externos são obras dos autores creditados; não foram criados pela IA. Voo/asas acrescentados e bird_call.wav são autorais do projeto; pio sintetizado sem samples de terceiros por tools/generate_bird_call.py. Não foram incorporados shaders pagos Source, arquivos executáveis nem scripts de fornecedores.

## Pescadores, tarrafas e trilhas — 16/11/2026

Reuso do modelo Man de Quaternius, CC0, https://poly.pizza/m/HMnuH5geEG , e Watercraft Kit de Kenney, CC0, https://kenney.nl/assets/watercraft-kit . Sem novos downloads. Chapéus, balões, malha de tarrafa, pose de remada e lógica são autorais/adaptações com assistência Codex. As cinco novas composições e timbres são sintetizados originalmente, sem samples ou melodias de terceiros; fonte em tools/compose_phase_music.py, títulos/BPM/hashes em docs/trilhas_originais.json. Menu e efeitos existentes preservados; total de arquivos WAV continua 38, pois cinco foram substituídos. Não há vozes nem gravações humanas nesta etapa. Falas em texto fornecidas pelo usuário.

## Living World 7 — primeiro lote — 17/11/2026

Reutiliza Nature Kit de Kenney (CC0, https://kenney.nl/assets/nature-kit) nos canteiros e Man de Quaternius (CC0, fonte já registrada acima) nos dois moradores de Araçatiba. Walk/Idle são clipes originais do próprio modelo; não são animações criadas pela IA. Bordas/cobertura dos canteiros, transições, câmeras, montagem e textos de recuperação foram elaborados com assistência Codex. Sem downloads novos, vozes ou samples externos. Os demais personagens, reações e paisagens mantêm seus créditos anteriores. Relatório de escopo: LIVING_WORLD_7_ETAPA_1.md.
