"""Download oficial, inventário e extração seletiva; nunca executa conteúdo baixado."""
import hashlib
import html
import io
import json
import re
import urllib.request
import zipfile
import http.cookiejar
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
CACHE = ROOT.parent / "asset-revolution-downloads"
CACHE.mkdir(exist_ok=True)
CLIENT = urllib.request.build_opener(urllib.request.HTTPCookieProcessor(http.cookiejar.CookieJar()))

def get(url, referer=None):
    headers = {"User-Agent": "Mozilla/5.0"}
    if referer:
        headers["Referer"] = referer
    with CLIENT.open(urllib.request.Request(url, headers=headers), timeout=60) as response:
        return response.read()

def kenney(pack):
    page_url = "https://kenney.nl/assets/" + pack
    page = get(page_url).decode()
    assert "creativecommons.org/publicdomain/zero/1.0" in page
    download_id = re.search(r"data-download-id='([^']+)'", page)[1]
    url = json.loads(get("https://kenney.nl/download-link/" + download_id, page_url))["url"]
    path = CACHE / (pack + ".zip")
    if not path.exists():
        path.write_bytes(get(url, page_url))
    raw = path.read_bytes()
    with zipfile.ZipFile(io.BytesIO(raw)) as archive:
        entries = [{"path": f.filename, "bytes": f.file_size} for f in archive.infolist()]
        assert sum(f["bytes"] for f in entries) < 300_000_000
        assert all(not Path(f["path"]).is_absolute() and ".." not in Path(f["path"]).parts for f in entries)
    meta = {"name": pack, "author": "Kenney", "page": page_url, "license": "CC0-1.0", "bytes": len(raw), "sha256": hashlib.sha256(raw).hexdigest(), "entries": entries}
    (CACHE / (pack + ".json")).write_text(json.dumps(meta, indent=2), encoding="utf-8")
    print(pack, len(raw), "bytes", len(entries), "entries", [f["path"] for f in entries if f["path"].lower().endswith(".glb")][:9])

if __name__ == "__main__":
    import sys
    for pack in sys.argv[1:]:
        kenney(pack)
