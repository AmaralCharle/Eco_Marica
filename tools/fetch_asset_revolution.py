"""Download oficial, inventário e extração seletiva; nunca executa conteúdo baixado."""
import hashlib
import html
import io
import json
import re
import urllib.request
import urllib.parse
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

def quaternius(pack):
    page_url = "https://quaternius.itch.io/" + pack
    page = get(page_url).decode()
    token = re.search(r'name="csrf_token" value="([^"]+)"', page)[1]
    request = urllib.request.Request(page_url + "/download_url", data=urllib.parse.urlencode({"csrf_token":token}).encode(), headers={"Referer":page_url})
    response = json.loads(CLIENT.open(request, timeout=60).read())
    page = get(response["url"]).decode()
    # Seleção apenas da edição gratuita Standard mostrada pelo fluxo público.
    upload = re.search(r'data-upload_id="(\d+)"[^>]*>Download</a>.*?title="([^"]*\[Standard\][^"]*\.zip)"', page)
    assert upload, "Nenhum Standard gratuito encontrado; não prosseguir com premium"
    token = re.search(r'name="csrf_token" value="([^"]+)"', page)[1]
    request = urllib.request.Request(page_url + "/file/" + upload[1], data=urllib.parse.urlencode({"csrf_token":token}).encode(), headers={"Referer":response["url"]})
    response = json.loads(CLIENT.open(request, timeout=60).read())
    assert "url" in response, "Download indisponível"
    path = CACHE / (pack + ".zip")
    if not path.exists(): path.write_bytes(get(response["url"]))
    raw = path.read_bytes()
    with zipfile.ZipFile(io.BytesIO(raw)) as archive:
        entries = [{"path": f.filename, "bytes":f.file_size} for f in archive.infolist()]
        assert sum(f["bytes"] for f in entries) < 600_000_000
        assert all(not Path(f["path"]).is_absolute() and ".." not in Path(f["path"]).parts for f in entries)
        for entry in entries:
            if "license" in entry["path"].lower() and entry["bytes"] < 12000:
                print(archive.read(entry["path"]).decode(errors="replace")[:2500])
    (CACHE/(pack+".json")).write_text(json.dumps({"name":pack,"author":"Quaternius","page":page_url,"bytes":len(raw),"sha256":hashlib.sha256(raw).hexdigest(),"entries":entries},indent=2),encoding="utf-8")
    print(pack,len(raw),"bytes",len(entries),"entries")

if __name__ == "__main__":
    import sys
    for pack in sys.argv[1:]:
        quaternius(pack[2:]) if pack.startswith("q:") else kenney(pack)
