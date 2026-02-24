import mido
import os
import sys

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

filename = os.path.splitext(os.path.basename(sys.argv[1]))[0]
filename = filename.replace(" ", "_").replace("-", "_")

datafilename = filename + ".data"

notes = []
active_notes = {}
abs_time = 0
programs = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0] # program for each channel

for msg in mid:
    abs_time += msg.time
    if msg.type == 'program_change':
        programs[msg.channel] = msg.program # keep track of the current instrument
        continue
    if msg.type == 'note_on' and msg.velocity > 0:
        active_notes[(msg.note, msg.channel)] = [msg.velocity, abs_time, programs[msg.channel]] 
        continue
    if msg.type == 'note_off' or (msg.type == 'note_on' and msg.velocity == 0):
        note = active_notes.pop((msg.note, msg.channel), None)

        # skip invalid notes
        if note is None:
            continue

        pitch = msg.note
        instrument = note[2]
        volume = note[0]
        start_time = round(note[1]*1000)    # convert to ms
        end_time = round(abs_time*1000)     # convert to ms
        duration = end_time - start_time
        notes.append((pitch, instrument, volume, duration, start_time))

notes.sort(key=lambda note: note[4]) # sorts by start time

# Write to .data
with open(datafilename, "w") as df: 
    df.write(f"{filename}:\n")
    for n in notes:
        df.write(f"    .byte {n[0]}, {n[1]}, {n[2]}\n")     
        df.write( "    .space 1\n")    # So alignment is kept in the struct
        df.write(f"    .word {n[3]}\n")
        df.write(f"    .word {n[4]}\n\n")
