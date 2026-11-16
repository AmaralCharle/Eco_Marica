# Assets, fontes e uso de IA — polimento 3.0

Atualização de cenários em 16/11/2026: `environment_meshes.gd` gera copas, folhas, tufos, peças chanfradas, trilha e manchas de solo; `environment_surface.gdshader` produz oito famílias de acabamento; água/folhagem e ambientação foram revistas. Código e malhas originais gerados com assistência Codex, sem fontes externas, imagens geradas ou downloads de assets. Uso: cinco fases, barco, lixeiras, bueiros e mudas. Detalhes e limitações em `CENARIOS_2026_11_16.md`.

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
| Fonte e símbolo ♻ | Fonte de interface disponibilizada pelo motor | Recursos padrão do Godot | Permanecem sob suas licenças originais distribuídas com Godot; preservar avisos no exportador | Interface e coletores |

Total de áudio: **34 arquivos** PCM WAV mono 16 bits, 22050 Hz. Reproduzir a geração com Python 3, executando `python tools/generate_audio.py`; Python não é dependência para jogar. Importação e reprodução ficam com o Godot. Os efeitos são intencionalmente simples e ainda podem ser substituídos por gravações CC0 cuidadosamente creditadas após avaliação auditiva.

As seis imagens fornecidas pelo autor serviram de direção artística: aventura urbana, reflorestamento em Ubatiba, Revenge of the Savage Planet, Reef by Barji, personagem de Isla Wanderleaf e cena tropical low-poly do Arthub. As imagens não foram copiadas para os assets, recortadas, convertidas em modelos ou redistribuídas. A referência não concede licença sobre personagens, marcas, modelos ou músicas desses jogos/sites. Não foram inventados autores ou URLs ausentes.

Diretórios usados: `assets/music`, `assets/sounds`, `assets/materials`; malhas, animações e efeitos permanecem em código nativo em `scripts/player` e `scripts/effects`. Não existem texturas/modelos externos a catalogar nesta versão. `icon.svg` anterior foi preservado. Fontes ambientais e acadêmicas anteriores continuam em `escopo_e_creditos.md`.
