"""Cinco partituras e timbres sintetizados originais; nenhum sample ou música externa.

Requer NumPy (já disponível no Python do ambiente). PCM estéreo 16-bit/22050 Hz.
"""
from pathlib import Path
import hashlib
import json
import math
import wave
import numpy as np

ROOT = Path(__file__).resolve().parents[1]
RATE = 22050
SCORES = {
    "aracatiba": dict(title="Manhã na Orla", bpm=96, root=62, style="bossa leve", lead="flute", chords=[(0,"maj"),(5,"maj"),(2,"min"),(7,"dom")], motif=[0,4,7,9,7,4,2,4,7,12,9,7,4,2,0,2]),
    "itaipuacu": dict(title="Brisa de Itaipuaçu", bpm=112, root=69, style="tropical sincopado", lead="marimba", chords=[(0,"maj"),(-2,"maj"),(-5,"maj"),(0,"dom")], motif=[0,7,9,7,4,2,4,7,9,12,14,12,9,7,4,2]),
    "centro": dict(title="Antes da Chuva", bpm=104, root=62, style="ostinato urbano", lead="felt", chords=[(0,"min"),(-2,"maj"),(-4,"maj"),(7,"min")], motif=[0,7,3,7,2,7,5,7,3,10,7,5,2,5,3,0]),
    "ubatiba": dict(title="Caminhos Verdes", bpm=76, root=67, style="pastoral acústico", lead="flute", chords=[(0,"maj"),(-5,"maj"),(-3,"min"),(2,"min")], motif=[7,4,2,0,2,4,7,9,7,12,9,7,4,2,4,0]),
    "ponta_negra": dict(title="Remada no Canal", bpm=100, root=60, style="baião suave", lead="reed", chords=[(0,"dom"),(5,"maj"),(7,"dom"),(0,"maj")], motif=[0,4,7,9,7,4,2,0,2,4,5,9,7,5,4,2]),
}

def tone(instrument, midi, duration, rng):
    t = np.arange(round(duration*RATE), dtype=np.float64)/RATE
    frequency = 440*2**((midi-69)/12)
    result = np.zeros_like(t)
    if instrument in ("guitar","marimba","felt","bass"):
        decay = {"guitar":2.4,"marimba":4.8,"felt":3.2,"bass":2.5}[instrument]
        for h in range(1,9):
            if frequency*h>9000: break
            weight = 1/(h**(1.5 if instrument=="guitar" else 2.0))
            result += weight*np.sin(math.tau*frequency*h*t)*np.exp(-t*(decay+h*0.7))
        if instrument=="marimba":
            result += 0.14*np.sin(math.tau*frequency*2.76*t)*np.exp(-t*12)
        if instrument=="guitar":
            result += rng.normal(0,0.07,len(t))*np.exp(-t*75)
        result *= np.minimum(1,t/0.004)
    elif instrument in ("flute","reed"):
        vibrato = 0.002*np.sin(math.tau*4.8*t)*np.minimum(1,t/0.15)
        for h,weight in enumerate(([1,0.18,0.07] if instrument=="flute" else [1,0.34,0.20,0.10]),1):
            result += weight*np.sin(math.tau*frequency*h*t+vibrato*frequency*0.05)
        result *= np.minimum(1,t/0.06)*np.minimum(1,np.maximum(0,(duration-t)/0.11))
        if instrument=="flute": result += rng.normal(0,0.012,len(t))*np.minimum(1,t/0.06)
    elif instrument=="kick":
        result = np.sin(math.tau*(58*t+9*(1-np.exp(-t*30))))*np.exp(-t*22)
    elif instrument=="brush":
        noise = rng.normal(0,1,len(t))
        result = (noise-np.roll(noise,1))*np.exp(-t*35)*0.3
    elif instrument=="triangle":
        for f in [3540,4780,6180]: result += np.sin(math.tau*f*t)*np.exp(-t*30)*0.18
    result *= np.minimum(1,np.maximum(0,(duration-t)/0.025))
    return result

def compose(name, score):
    seconds_per_beat = 60/score["bpm"]
    duration = 64*seconds_per_beat
    length = round(duration*RATE)
    mix = np.zeros((length,2),dtype=np.float64)
    rng = np.random.default_rng(9600+list(SCORES).index(name))
    def add(instrument, midi, beat, beats, gain, pan=0):
        sound = tone(instrument,midi,beats*seconds_per_beat,rng)*gain
        stereo = sound[:,None]*np.array([math.sqrt((1-pan)/2),math.sqrt((1+pan)/2)])[None,:]
        start = round(beat*seconds_per_beat*RATE)%length
        first = min(len(sound),length-start)
        mix[start:start+first] += stereo[:first]
        if first<len(sound): mix[:len(sound)-first] += stereo[first:]
    qualities={"maj":[0,4,7,11],"min":[0,3,7,10],"dom":[0,4,7,10]}
    for bar in range(16):
        root,quality=score["chords"][bar%4]
        chord_root=score["root"]+root-12
        chord=qualities[quality]
        start=bar*4
        # Arpejos e levadas distintos, sem reutilizar a frase do gerador anterior.
        pattern={"aracatiba":[0,0.75,1.5,2,2.75,3.5],"itaipuacu":[0,0.5,1.25,1.75,2.5,3.25],"centro":[0,0.5,1,1.5,2,2.5,3,3.5],"ubatiba":[0,1,2.5],"ponta_negra":[0,0.75,1.5,2.5,3.25]}[name]
        for k,offset in enumerate(pattern):
            add("felt" if name=="centro" else "guitar",chord_root+chord[k%4],start+offset,1.25,0.10,-0.28)
        for offset in ([0,2.5] if name=="ponta_negra" else [0,2]):
            add("bass",chord_root-12+(7 if offset>0 else 0),start+offset,1.4,0.16)
        if name!="ubatiba":
            add("kick",0,start,0.32,0.11)
            add("kick",0,start+2.5 if name=="ponta_negra" else start+2,0.28,0.07)
            for offset in [1,3]: add("brush",0,start+offset,0.18,0.06,0.3)
        for offset in ([0.5,2.5] if name=="ubatiba" else [0.5,1.5,2.5,3.5]):
            add("triangle" if name=="ponta_negra" else "brush",0,start+offset,0.16,0.025,0.5)
        # Frases de dois compassos, com pausas e resposta na segunda metade.
        if bar%4!=3:
            count=2 if name=="ubatiba" else 3
            for k in range(count):
                index=(bar*3+k)%16
                offset=([0.5,2.25] if name=="ubatiba" else [0.5,1.75,2.75])[k]
                note=score["root"]+score["motif"][index]+(12 if name=="itaipuacu" else 0)
                add(score["lead"],note,start+offset,1.15 if name=="ubatiba" else 0.65,0.075,0.18)
    mix -= mix.mean(axis=0)
    rms=float(np.sqrt(np.mean(mix*mix)))
    peak=float(np.max(np.abs(mix)))
    mix *= min(0.11/max(rms,1e-9),0.65/max(peak,1e-9))
    fade=np.minimum(1,np.arange(length)/(RATE*0.015))*np.minimum(1,np.arange(length)[::-1]/(RATE*0.015))
    mix *= fade[:,None]
    pcm=np.round(mix*32767).astype('<i2')
    path=ROOT/'assets/music'/f'{name}.wav'
    with wave.open(str(path),'wb') as output:
        output.setparams((2,2,RATE,0,'NONE','not compressed'))
        output.writeframes(pcm.tobytes())
    return dict(id=name,**score,seconds=duration,bars=16,rate=RATE,channels=2,peak=float(np.max(np.abs(mix))),rms=float(np.sqrt(np.mean(mix*mix))),seam_jump=float(np.max(np.abs(mix[0]-mix[-1]))),sha256=hashlib.sha256(path.read_bytes()).hexdigest(),origin="Composição e síntese originais do projeto com assistência Codex; sem samples externos")

def generate_all():
    metadata=[compose(name,score) for name,score in SCORES.items()]
    (ROOT/'docs/trilhas_originais.json').write_text(json.dumps(metadata,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
    for row in metadata: print(row['id'],round(row['seconds'],2),'s',row['bpm'],'BPM',round(row['peak'],3),'peak')

if __name__=='__main__': generate_all()
