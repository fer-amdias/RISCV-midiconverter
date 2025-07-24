import mido
import os
import sys

# MIDICONVERTER
# Inspired by https://github.com/Zen-o/Tradutor_MIDI-RISC-V
#
# This version creates a struct of notes to be used on FPGRARS.

if len(sys.argv) < 2:
    print(f"Usage: python {sys.argv[0]} <filename.mid>")
    exit(1)

FOLDER_PATH = os.path.dirname(os.path.realpath(__file__))
input_path = os.path.join(FOLDER_PATH, sys.argv[1])

if not os.path.isfile(input_path):
    raise Exception("ERROR: The input path doesn't exist.")
if not input_path.endswith(".mid"):
    raise Exception("ERROR: The given file isn't a .mid")

mid = mido.MidiFile(input_path)
filename = os.path.splitext(os.path.basename(sys.argv[1]))[0] + ".data"

notes = []
tempo = 500000  # default tempo (120 BPM)
abs_time = 0
channel_to_instrument = {}

for i, track in enumerate(mid.tracks):
    abs_time = 0
    for msg in track:
        abs_time += msg.time
        if msg.type == 'set_tempo':
            tempo = msg.tempo
        elif msg.type == 'program_change':
            channel_to_instrument[msg.channel] = msg.program
        elif msg.type == 'note_on' and msg.velocity > 0 and not msg.is_meta:
            pitch = msg.note
            instrument = channel_to_instrument.get(msg.channel, 0)
            start_ms = int(mido.tick2second(abs_time, mid.ticks_per_beat, tempo) * 1000)
            duration = 0
            volume = msg.velocity

            # Try to find matching note_off for duration
            rel_time = 0
            for search_msg in track[track.index(msg)+1:]:
                rel_time += search_msg.time
                if (not msg.is_meta and (msg.type == 'note_on' or msg.type == 'note_off')) and \
                    search_msg.note == pitch:
                    duration = int(mido.tick2second(rel_time, mid.ticks_per_beat, tempo) * 1000)
                    break

            # Make sure only matched notes get played
            if (duration):
                notes.append((pitch, instrument, volume, duration, start_ms))

# Sort notes by start time
notes.sort(key=lambda x: x[4])

# Replace spaces with underlines for safety
filename = filename.replace(" ", "_")

# Write  to .data
with open(filename, "w") as f:
    f.write(f"{filename.removesuffix(".data")}:\n")
    for n in notes:
        f.write(f"    .byte {n[0]}, {n[1]}, {n[2]}\n")     
        f.write( "    .space 1\n")    # So alignment is kept in the struct
        f.write(f"    .word {n[3]}\n")
        f.write(f"    .word {n[4]}\n\n")

    f.write(f"{filename.removesuffix(".data")}_FIM:\n")
    f.write(f"    .word 0 0 0")

print("Done! Converted to", filename)
