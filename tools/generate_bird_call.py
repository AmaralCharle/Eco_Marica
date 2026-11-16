"""Pio estilizado original por síntese; sem amostras externas."""
import math
import struct
import wave
from pathlib import Path

samples = []
for i in range(11025):
    t = i / 22050
    part = t % 0.25
    envelope = math.sin(math.pi * min(part / 0.18, 1)) ** 2 if part < 0.18 else 0
    phase = math.tau * (2050 * part + 1600 * part ** 2)
    samples.append(round(math.sin(phase) * envelope * 0.12 * 32767))
path = Path(__file__).resolve().parents[1] / "assets/sounds/bird_call.wav"
with wave.open(str(path), "wb") as output:
    output.setparams((1, 2, 22050, 0, "NONE", "not compressed"))
    output.writeframes(struct.pack(f"<{len(samples)}h", *samples))
