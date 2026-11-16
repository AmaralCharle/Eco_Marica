extends RefCounted
## Estrelas nunca dependem de velocidade extra nem bloqueiam fases.
const TWO_STAR_ERRORS = {"aracatiba":2,"itaipuacu":2,"centro":2,"ubatiba":1,"ponta_negra":2}
static func calculate(id: String, record: Dictionary, won: bool) -> int:
	if not won: return 0
	var errors: int = record.get("errors",0)
	var losses: int = record.get("lost",0) if id in ["itaipuacu","ponta_negra"] else 0
	if errors == 0 and losses == 0: return 3
	if errors <= TWO_STAR_ERRORS.get(id,2) and losses <= 2: return 2
	return 1
static func symbols(value: int) -> String:
	return "★".repeat(clampi(value,0,3))+"☆".repeat(3-clampi(value,0,3))
