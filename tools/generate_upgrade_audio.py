"""Feedback 4.0 original: síntese sem samples externos, PCM mono 22050 Hz."""
from pathlib import Path
import math
import struct
import wave

root = Path(__file__).resolve().parents[1] / "assets/sounds"
for name, notes in {"decision": [659, 880], "optional": [523, 659, 784], "stars": [784, 988, 1175]}.items():
    samples = []
    for frequency in notes:
        length = 0.10 if name == "decision" else 0.15
        count = int(length * 22050)
        for i in range(count):
            t = i / 22050
            envelope = min(1.0, t / 0.012) * (1.0 - i / count) ** 1.6
            value = (math.sin(math.tau * frequency * t) + 0.15 * math.sin(math.tau * frequency * 2 * t)) * envelope * 0.16
            samples.append(round(value * 32767))
    with wave.open(str(root / f"{name}.wav"), "wb") as output:
        output.setparams((1, 2, 22050, 0, "NONE", "not compressed"))
        output.writeframes(struct.pack(f"<{len(samples)}h", *samples))
