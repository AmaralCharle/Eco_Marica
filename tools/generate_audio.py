"""Áudio original sintetizado para ECO MARICÁ. Sem amostras externas.
Execute com Python 3 e NumPy; efeitos/menu mono e cinco trilhas estéreo PCM 16-bit/22050 Hz.
"""
import math
import random
import struct
import wave
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1] / 'assets'
RATE = 22050
TAU = math.tau

def save(folder, name, samples):
    path = ROOT / folder / (name + '.wav')
    path.parent.mkdir(parents=True, exist_ok=True)
    with wave.open(str(path), 'wb') as out:
        out.setparams((1, 2, RATE, 0, 'NONE', 'not compressed'))
        out.writeframes(b''.join(struct.pack('<h', round(max(-0.85, min(0.85, x)) * 32767)) for x in samples))

def phrase(name, notes, duration=0.12, noise=0.0):
    rng = random.Random(name)
    samples = []
    for freq in notes:
        for i in range(round(RATE * duration)):
            t = i / RATE
            envelope = min(1, t / 0.008) * math.exp(-t * 6 / duration)
            samples.append(envelope * (0.32 * math.sin(TAU * freq * t) + noise * rng.uniform(-1, 1)))
    save('sounds', name, samples)

def main():
    for name, notes in {
        'hover': [720], 'confirm': [440, 660], 'select': [523, 784],
        'start': [392, 523, 659], 'collect': [880, 1175],
        'correct': [523, 659, 784], 'wrong': [220, 165],
        'bonus': [659, 784, 1047], 'victory': [523, 659, 784, 1047],
        'defeat': [330, 294, 220], 'unlock': [784, 1047, 1319],
        'plant': [294, 392, 587], 'soil': [170, 140], 'drain': [196, 392],
        'embark': [196, 294], 'disembark': [294, 196], 'unload': [440, 523],
    }.items():
        phrase(name, notes, .16 if name in ('victory', 'defeat') else .10,
               .14 if name in ('plant', 'soil', 'drain', 'embark', 'disembark') else 0)
    for name, freq, noise in [('step_pavement', 110, .12), ('step_sand', 60, .3), ('step_soil', 85, .22)]:
        phrase(name, [freq], .13, noise)
    # Noise low-pass + oscillators. Endpoints crossfade to make seamless loops.
    for index, name in enumerate(('aracatiba', 'itaipuacu', 'centro', 'ubatiba', 'ponta_negra', 'rain', 'engine', 'thunder')):
        rng = random.Random(730 + index)
        duration = 8 if name != 'engine' else 2
        n = RATE * duration
        samples = []
        smooth = 0.0
        for i in range(n):
            t = i / RATE
            smooth = .97 * smooth + .03 * rng.uniform(-1, 1)
            swell = .55 + .4 * math.sin(TAU * t / duration)
            value = smooth * swell * .8
            if name in ('aracatiba', 'ubatiba', 'itaipuacu'):
                phase = t % 2.0
                value += .07 * math.sin(TAU * (1700 * t + 85 * math.sin(t * 13))) * max(0, 1 - abs(phase - .4) * 14)
            if name in ('itaipuacu', 'ponta_negra'):
                value += rng.uniform(-.07, .07) * swell
            if name == 'centro':
                value += .022 * math.sin(TAU * 90 * t) * swell
            if name == 'rain':
                value = rng.uniform(-.16, .16) + smooth
            if name == 'engine':
                value = .12 * math.sin(TAU * 65 * t) + .07 * math.sin(TAU * 130 * t) + smooth * .2
            if name == 'thunder':
                value = (smooth * 2 + .09 * math.sin(TAU * 43 * t)) * math.sin(math.pi * t / duration) ** 2
            samples.append(value)
        # Short matching fades eliminate boundary clicks.
        for i in range(220):
            samples[i] *= i / 220
            samples[-1-i] *= i / 220
        save('sounds', name, samples)
    for index, name in enumerate(('menu',)):
        n = RATE * 16
        samples = [0.0] * n
        scale = (261.626, 329.628, 391.995, 440.0, 523.251, 391.995, 329.628, 293.665)
        for beat in range(32):
            freq = scale[(beat + index * 2) % len(scale)]
            begin = round(beat * .5 * RATE)
            for j in range(round(.48 * RATE)):
                t = j / RATE
                env = min(1, t / .025) * math.exp(-t * 7)
                samples[begin+j] += .10 * env * (math.sin(TAU * freq * t) + .22 * math.sin(TAU * freq * 2 * t))
                samples[begin+j] += .035 * env * math.sin(TAU * freq * .5 * t)
        save('music', name, samples)
    if __package__:
        from .compose_phase_music import generate_all
    else:
        from compose_phase_music import generate_all
    generate_all()

if __name__ == '__main__':
    main()
