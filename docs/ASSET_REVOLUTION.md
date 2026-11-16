# Asset Revolution — auditoria e diário

## Segurança e estado inicial

- Base: `upgrade-visual-4`, commit `df0ab5d83cdf28697a52d046701f4483bdf8da40`.
- Nova branch: `asset-revolution`; checkpoint `checkpoint-pre-assets-df0ab5d`.
- `main` e `fase-1-final` continuam na versão `3fc476c`.
- Sem modificações rastreadas no início. Metadados .uid/.import existentes preservados; nenhum reset/clean.
- Motor instalado: `C:\Users\CHARLE\Downloads\Godot\Godot_v4.7.2-stable_win64_console.exe`.
- Renderizador ativo: Mobile/Vulkan; Jolt; viewport 1280×720. Mantido.

## Estrutura e fronteiras

As cinco cenas `scenes/levels/{aracatiba,itaipuacu,centro,ubatiba,ponta_negra}.tscn` usam scripts em `scripts/levels/`; o mundo é criado por código. `scripts/effects/world_polish.gd` cria apresentação e agrupa malhas estáticas depois da construção. `reference_art_pass.gd` e `upgrade_visuals.gd` acrescentam decoração. Pontos de missão ficam em grupos independentes. A integração deve ocorrer antes do agrupamento, alterando apenas malhas e materiais.

- Prédios: `scripts/levels/centro_world.gd:building`; corpos e shapes ficam preservados.
- Árvores/arbustos/rochas/postes: fábricas de `world_polish.gd`; candidatos prioritários a modelos GLB.
- Barco: apresentação `scripts/effects/boat_polish.gd`, separada do controlador em `scripts/player/eco_boat.gd` (confirmar caminho ao integrar).
- Personagens: `scripts/player/character_appearance.gd`; adaptador visual `character_model_adapter.gd`; não alterar controlador ou câmera.
- Materiais: `assets/materials/`; água já tem shader de movimento compatível com Mobile.
- Preservar metas, interação E, caderno Q, condições de vitória/derrota, IDs, colisões e saves.

## Progresso sequencial

1. Auditoria e checkpoint criados.
2. Pesquisa oficial e licenças: Kenney City Kit Commercial, Nature Kit, Watercraft Kit, City Kit Roads. Quaternius Stylized Nature tem CC0, mas o primeiro download público retornou quota excedida; não contornado.
3. Catálogo e manifesto criados **antes** de integrar. Extraídos 23 GLBs (aproximadamente 680 KiB), colormaps referenciados e licenças. ZIPs e inventários originais fora da raiz importável. Nenhum executável ou script de fornecedor extraído/executado.
4. Importação Godot executada. Captura e medição da versão anterior em andamento.
5. Próximo checkpoint: Centro, com modelos de edifícios, árvores e postes. Só avançar após testes e revisão visual.
