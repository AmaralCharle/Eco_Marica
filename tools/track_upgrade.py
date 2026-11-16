"""Atualiza o diário da branch sem alterar arquivos de jogo."""
import re
import sys
from pathlib import Path

number, status, note = sys.argv[1:4]
path = Path(__file__).resolve().parents[1] / "docs/visual_upgrade_tasks.md"
text = path.read_text(encoding="utf-8-sig")
text, count = re.subn(rf"(^\| {number} [^|]*\| )[^|]+",rf"\g<1>{status} ",text,flags=re.M)
if count != 1:
    raise SystemExit("Task não encontrada")
text += f"\n### TASK {number} — {status}\n\n{note}\n"
path.write_text(text,encoding="utf-8")
