import numpy as np
from scipy.io import wavfile
import os
import subprocess

# Sample rate
sample_rate = 44100

# Duration of each note in seconds
duration = 0.3

# Generate time array
t = np.linspace(0, duration, int(sample_rate * duration), False)

# Notes frequencies (C4 to B4)
frequencies = [261.63, 293.66, 329.63, 349.23, 392.00, 440.00, 493.88]

# Create sounds directory if it doesn't exist
os.makedirs('assets/sounds', exist_ok=True)

# Generate and save each note
for i, freq in enumerate(frequencies):
    # Generate sine wave
    note = np.sin(2 * np.pi * freq * t)
    
    # Apply simple envelope
    envelope = np.exp(-3 * t)
    note = note * envelope
    
    # Normalize
    note = note / np.max(np.abs(note))
    
    # Convert to 16-bit PCM
    note = (note * 32767).astype(np.int16)
    
    # Save to WAV file
    wav_file = f'assets/sounds/note{i}.wav'
    wavfile.write(wav_file, sample_rate, note)
    
    # Convert to MP3 using ffmpeg
    mp3_file = f'assets/sounds/note{i}.mp3'
    subprocess.run(['ffmpeg', '-i', wav_file, '-codec:a', 'libmp3lame', '-qscale:a', '2', mp3_file])
    
    # Remove the WAV file
    os.remove(wav_file) 