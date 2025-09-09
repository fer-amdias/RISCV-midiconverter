######################################
#      AUDIO PLAYER FOR FPGRARS	     #
#  		         v1.0		     	 #
#			             			 #
# Fernando A. M. Dias - 2025.07.22   #
######################################

.data

# switch this for the path of the file you wish to play
.include "example.data"

TRACK_TIMESTAMP:	.word 0 # start timestamp
TRACK_POINTER:		.word 0 # points to the next note

.text

# switch "example" for the name of the file you wish to play
.eqv file example

.eqv pitch 0
.eqv instrument 1
.eqv volume 2
.eqv duration, 4
.eqv start_ms 8
.eqv note_struct_size 12

# Gives FPGRARS time to fully load audio playback 
WARMUP:
		li a0, 60      
		li a1, 1       # 1 ms duration
		li a2, 0       
		li a3, 0       # no volume
		li a7, 31      # MidiOut ecall
		ecall
		
		li a0, 300
		li a7, 32      # sleep for 300 ms
		ecall

START: 		la t0, file
       		sw t0, TRACK_POINTER, t1	# saves the file to the track pointer
       		csrr t0, time
      		sw t0, TRACK_TIMESTAMP, t1	# saves the start timestamp
       		
PLAY: 
		lw t0, TRACK_POINTER
		lw t1, duration(t0)
		beqz t1, FINISH			# if duration == 0, we've reached the end of the file. quit.

		lw t2, TRACK_TIMESTAMP
		csrr t1, time
		sub t2, t1, t2			# milisseconds since timestamp
		
		lw t1, start_ms(t0)		# load the ms since start of this note
		bge t1, t2, PLAY		# if its not yet time to play it (start_ms > ms_since_timestamp), check again
		
		lb a0, pitch(t0)
		lw a1, duration(t0)
		lb a2, instrument(t0)
		lb a3, volume(t0)
		li a7, 31			# MidiOut ecall
		ecall				# plays the note
		
		addi t0, t0, note_struct_size
		sw t0, TRACK_POINTER, t1	# goes to the next note
		
		j PLAY				# keeps checking
FINISH:
       		# j START			uncomment to loop
       		
       		# we need to wait until the last notes play
       		
       		lw t0, TRACK_POINTER
       		addi t0, t0, -4			# goes back to the last played note
       		
       		lw a0, duration(t0)		# sleep until the last note plays
		li a7, 32      # sleep for 300 ms
		ecall
       	
       		li a7, 10
       		ecall				# exit
       		
       
       
       
       
       
       
