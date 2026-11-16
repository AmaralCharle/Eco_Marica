# Integração visual de GLB

O jogo atual funciona com as quatro aparências procedurais. Esta estrutura é opcional e foi testada com PackedScenes sintéticas; ainda não há um GLB artístico externo validado.

## Contrato

- Arquivo importado pelo Godot como PackedScene, com raiz Node3D, malhas e, se houver animações, Skeleton3D/AnimationPlayer próprios.
- Origem no chão entre os pés, eixo Y para cima e frente em -Z. Referência visual: aproximadamente 2 m de altura. O ajuste de importação pode corrigir orientação, escala e altura sem mudar a cápsula.
- A cena importada deve ser apenas visual: sem CharacterBody3D, RigidBody3D, StaticBody3D, CollisionShape3D ou Camera3D. O adaptador rejeita essas cenas e mantém o visual procedural.
- Animações de locomoção no lugar, sem deslocamento do modelo para fora do controlador. Este adaptador não aplica root motion à física.
- O código de controle permanece em `scripts/player/guardian.gd`, a cápsula e câmera em `scenes/player/guardian.tscn`. As referências LeftLeg/RightLeg/LeftArm/RightArm são conservadas mesmo quando invisíveis.

## Configuração

Na cena compartilhada `scenes/player/character_visual.tscn`, configure as propriedades exportadas do Visual:

| Propriedade | Conteúdo |
|---|---|
| `external_models` | Dicionário ID -> PackedScene do GLB importado |
| `external_transforms` | Dicionário ID -> Transform3D opcional, aplicado por um nó Alignment fora do rig |
| `external_animations` | Dicionário estado do jogo -> nome do clipe importado |

IDs: `lucas`, `marina`, `rafael`, `bia`. Ao selecionar uma identidade sem modelo configurado, o procedural correspondente aparece. Configurar a cena compartilhada permite reutilizar o mesmo visual nas prévias, no jogador e no passageiro do barco.

Exemplo de configuração por código, em uma cena com Player:

```gdscript
var visual = $Player/Visual
visual.external_models["lucas"] = load("res://assets/models/characters/lucas.glb")
visual.external_transforms["lucas"] = Transform3D(
    Basis(Vector3.UP, PI).scaled(Vector3.ONE), Vector3.ZERO)
visual.external_animations = {
    "idle": "Idle", "walk": "Walk", "run": "Run", "jump": "Jump",
    "collect": "Collect", "plant": "Plant", "interact": "Interact",
    "embark": "Embark", "disembark": "Disembark"
}
visual.apply_character("lucas")
```

O ajuste PI do exemplo é para um modelo originalmente voltado para +Z; remova a rotação para um modelo em -Z. Ajuste a escala observando os pés e a altura visual. Padronize os nomes dos clipes entre os modelos ou configure o mapa na instância apropriada. Loops e transições de entrada/saída das animações precisam de revisão artística no importador.

A API direta `visual.attach_external_model(cena, transformacao)` também está disponível para integração pontual. `visual.attach_external_model()` remove o importado e restaura o procedural. Um modelo inválido devolve null e descreve a causa em `visual.external_error`.

## Animação e limites

O adaptador procura AnimationPlayer por tipo, aceitando nomes diferentes. Faz transição curta de 0,15 s, mapeia nomes e tenta idle quando falta o clipe solicitado. Se locomoção e ação chegam no mesmo tick, o último pedido prevalece; um clipe já ativo não é reiniciado a cada tick. Modelos estáticos permanecem estáticos e não causam falha.

Não há retargeting automático, conversão de rigs, geração de blendshapes, IK, sincronização de pés ou criação de animações ausentes. AnimationTree/rigs com scripts próprios precisam de integração e testes específicos; o adaptador entregue controla AnimationPlayer. Para modelos externos, desative scripts de controle, root motion de deslocamento e importação de colisões.

## Validação ao adicionar um asset real

Revisar escala, materiais, orientação e licenças. Inspecionar os quatro personagens na seleção, caminhada, corrida, pulo, coleta/plantio, pausa e barco. Rodar `tests/run_all.ps1`; revisar também as imagens e o comportamento real do rig. Os testes atuais comprovam a fronteira com PackedScenes sintéticas e o funcionamento dos modelos procedurais, não o acabamento de um GLB ainda não fornecido.
