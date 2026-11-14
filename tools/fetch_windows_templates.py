"""Obtém somente templates Windows x64 do pacote oficial Godot via HTTP Range.
Python 3, biblioteca padrão. ZipFile valida CRC antes de gravar cada executável.
"""
from pathlib import Path
import argparse
import io
import json
import urllib.request
import zipfile

VERSION = '4.7.2-stable'
URL = f'https://godot-releases.nbg1.your-objectstorage.com/{VERSION}/Godot_v{VERSION}_export_templates.tpz'

class RemoteArchive(io.RawIOBase):
    def __init__(self, url):
        self.url = url
        self.position = 0
        self.transferred = 0
        request = urllib.request.Request(url, method='HEAD')
        with urllib.request.urlopen(request, timeout=30) as response:
            self.length = int(response.headers['Content-Length'])

    def readable(self): return True
    def seekable(self): return True
    def tell(self): return self.position

    def seek(self, offset, whence=0):
        self.position = offset if whence == 0 else self.position + offset if whence == 1 else self.length + offset
        if self.position < 0: raise ValueError('Negative seek')
        return self.position

    def read(self, size=-1):
        if self.position >= self.length or size == 0: return b''
        if size < 0: size = self.length - self.position
        end = min(self.length - 1, self.position + size - 1)
        request = urllib.request.Request(self.url, headers={'Range': f'bytes={self.position}-{end}'})
        with urllib.request.urlopen(request, timeout=120) as response:
            if response.status != 206:
                raise RuntimeError('Servidor não aceitou Range; download integral não iniciado')
            data = response.read()
        if len(data) != end - self.position + 1:
            raise IOError('Resposta Range incompleta')
        self.position += len(data)
        self.transferred += len(data)
        return data

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--list', action='store_true')
    parser.add_argument('--output', type=Path, default=Path(__file__).resolve().parents[1] / '.build-tools' / 'templates')
    args = parser.parse_args()
    remote = RemoteArchive(URL)
    with zipfile.ZipFile(remote) as archive:
        selected = [x for x in archive.infolist() if x.filename.endswith(('windows_release_x86_64.exe', 'windows_debug_x86_64.exe', 'version.txt'))]
        if args.list:
            print(json.dumps([{'name': x.filename, 'size': x.file_size, 'compressed': x.compress_size} for x in selected]))
            return
        if len(selected) != 3:
            raise RuntimeError('Pacote não contém os templates esperados')
        args.output.mkdir(parents=True, exist_ok=True)
        for entry in selected:
            data = archive.read(entry)
            if entry.filename.endswith('version.txt'):
                if data.decode().strip() != '4.7.2.stable':
                    raise ValueError('Versão do template divergente')
            elif not data.startswith(b'MZ'):
                raise ValueError('Template não é executável PE')
            (args.output / Path(entry.filename).name).write_bytes(data)
            print('Obtido:', Path(entry.filename).name, len(data), 'bytes')
    print('Transferido:', remote.transferred, 'bytes; pacote completo:', remote.length)

if __name__ == '__main__': main()
