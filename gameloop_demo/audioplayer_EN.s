#################################################################
# PLAY_AUDIO_DEMO				       	     	#
# Adds and plays audio on three distinct audio tracks.   	#
# 							     	#
# RECEIVES:						        #
#	A0 : MODE (0 = keep playing, 1 = add audio)	        #
#	if a0 = 1:						#
#		A1 = audio address		                #
#		A2 = track to overwrite (1, 2 or 3)      	#
#		A3 = loop mode			                #
# RETURNS:                                                  	#
#       (n/a)                                             	#
#################################################################

.data

# It's generally a good idea to define the purpose of each track within your project at the start
# For instance, TRACK1 could be for background music, TRACK2 for sound effects, and TRACK3 for dialog
# Each one is equally as good for each, so it doesn't really matter which you pick.

TRACK1:
	TRACK1_ACTIVE: 		.word 0	# whether the track is playing anything
	TRACK1_TIMESTAMP:	.word 0 # when the track started playing
	TRACK1_START_PTR:	.word 0 # pointer to audio address (also to first note)
	TRACK1_NEXT_PTR:	.word 0 # pointer to next note
	TRACK1_LOOP:		.word 0	# whether the track is looping or nay
	
TRACK2:
	TRACK2_ACTIVE: 		.word 0	# whether the track is playing anything
	TRACK2_TIMESTAMP:	.word 0 # when the track started playing
	TRACK2_START_PTR:	.word 0 # pointer to audio address (also to first note)
	TRACK2_NEXT_PTR:	.word 0 # pointer to next note
	TRACK2_LOOP:		.word 0	# whether the track is looping or nay

TRACK3:
	TRACK3_ACTIVE: 		.word 0	# whether the track is playing anything
	TRACK3_TIMESTAMP:	.word 0 # when the track started playing
	TRACK3_START_PTR:	.word 0 # pointer to audio address (also to first note)
	TRACK3_NEXT_PTR:	.word 0 # pointer to next note
	TRACK3_LOOP:		.word 0	# whether the track is looping or nay
	
#	Notes (struct){
#		byte pitch
#		byte instrument
#		byte volume
#		space 1
#		word duration
#		word start_ms
#	}

.text
.eqv pitch 0
.eqv instrument 1
.eqv volume 2
.eqv duration, 4
.eqv start_ms 8
.eqv note_struct_size 12

PLAY_AUDIO_DEMO:
		addi sp, sp, -4
		sw ra, (sp)
		beqz, a0, PLAY_AUDIO.PLAY_ALL	# only plays the tracks if mode is 0
		
		# otherwise start up chosen track
PLAY_AUDIO.SWITCH1:
		li t0, 1
		bne a2, t0, PLAY_AUDIO.SWITCH2
		jal PLAY_AUDIO.INIT_TRACK1		# initializes track 1
		j PLAY_AUDIO.SWITCH_END
PLAY_AUDIO.SWITCH2:
		li t0, 2
		bne a2, t0, PLAY_AUDIO.SWITCH3
		jal PLAY_AUDIO.INIT_TRACK2		# init track 2
		j PLAY_AUDIO.SWITCH_END
PLAY_AUDIO.SWITCH3:
		li t0, 3
		bne a2, t0, PLAY_AUDIO.SWITCH_END
		jal PLAY_AUDIO.INIT_TRACK3		# init track 3
PLAY_AUDIO.SWITCH_END:

PLAY_AUDIO.PLAY_ALL:
	jal PLAY_AUDIO.TRACK1
	jal PLAY_AUDIO.TRACK2
	jal PLAY_AUDIO.TRACK3
	j P_TA1_FIM
	


PLAY_AUDIO.INIT_TRACK1: 		
		sw a1, TRACK1_START_PTR, t1     # saves the audio as the start pointer
		sw a1, TRACK1_NEXT_PTR, t1	# also saves the audio as the next pointer (to play the first note)
       		li t0, 1
      		sw t0, TRACK1_ACTIVE, t1	# activates the track
      		csrr t0, time
      		sw t0, TRACK1_TIMESTAMP, t1	# saves the moment that the track started
      		sw a3, TRACK1_LOOP, t1		# saves whether loop is on or off
      		ret			
       		
PLAY_AUDIO.TRACK1: 

		lw t0, TRACK1_ACTIVE
		beqz t0, PLAY_AUDIO.TRACK1_RET	# if the track is no longer active, dont play it
		
		lw t0, TRACK1_TIMESTAMP
		csrr t1, time
		sub t2, t1, t0			# miliseconds since start of song
		
		lw t0, TRACK1_NEXT_PTR
		lw t1, duration(t0)
		beqz t1, PLAY_AUDIO.TRACK1_END	# if the duration of this note is zero, we've reached the end
		
		lw t1, start_ms(t0)		
		bgt t1, t2, PLAY_AUDIO.TRACK1_RET	# if start_ms < ms_since_timestamp: not yet time to play the next note, skip track
		
		lb a0, pitch(t0)
		lw a1, duration(t0)
		lb a2, instrument(t0)
		lb a3, volume(t0)
		li a7, 31
		ecall
		
		addi t0, t0, note_struct_size
		sw t0, TRACK1_NEXT_PTR, t1	# go to the next note in the file
		
		j PLAY_AUDIO.TRACK1		# checks if theres any note we should be playing in synchrony
		
PLAY_AUDIO.TRACK1_END:	
		lw t0, TRACK1_LOOP
		beqz t0, PLAY_AUDIO.TRACK1_STOP
		# if loop is on, restart song
		
		lw t0, TRACK1_START_PTR
		sw t0, TRACK1_NEXT_PTR, t1	# puts the pointer back in the start
		csrr t0, time
		sw t0, TRACK1_TIMESTAMP, t1	# restarts track timestamp (so it plays from the start)
		j PLAY_AUDIO.TRACK1_RET		# continues with the rest of the procedure
		
PLAY_AUDIO.TRACK1_STOP:
		sw zero, TRACK1_NEXT_PTR, t0	# cleans up pointer
		sw zero, TRACK1_ACTIVE, t0	# closes down track
PLAY_AUDIO.TRACK1_RET:
       		ret
       		
       		
       		
       		
       		
       		
       		
PLAY_AUDIO.INIT_TRACK2: 		
		sw a1, TRACK2_START_PTR, t1     # saves the audio as the start pointer
		sw a1, TRACK2_NEXT_PTR, t1	# also saves the audio as the next pointer (to play the first note)
       		li t0, 1
      		sw t0, TRACK2_ACTIVE, t1	# activates the track
      		csrr t0, time
      		sw t0, TRACK2_TIMESTAMP, t1	# saves the moment that the track started
      		sw a3, TRACK2_LOOP, t1		# saves whether loop is on or off
      		ret
       		
PLAY_AUDIO.TRACK2: 

		lw t0, TRACK2_ACTIVE
		beqz t0, PLAY_AUDIO.TRACK2_RET	# if the track is no longer active, dont play it
		
		lw t0, TRACK2_TIMESTAMP
		csrr t1, time
		sub t2, t1, t0			# miliseconds since start of song
		
		lw t0, TRACK2_NEXT_PTR
		lw t1, duration(t0)
		beqz t1, PLAY_AUDIO.TRACK2_END	# if the duration of this note is zero, we've reached the end
		
		lw t1, start_ms(t0)		
		bgt t1, t2, PLAY_AUDIO.TRACK2_RET	# if start_ms < ms_since_timestamp: not yet time to play the next note, skip track
		
		lb a0, pitch(t0)
		lw a1, duration(t0)
		lb a2, instrument(t0)
		lb a3, volume(t0)
		li a7, 31
		ecall
		
		addi t0, t0, note_struct_size
		sw t0, TRACK2_NEXT_PTR, t1	# go to the next note in the file
		
		j PLAY_AUDIO.TRACK2		# checks if theres any note we should be playing in synchrony
		
PLAY_AUDIO.TRACK2_END:	
		lw t0, TRACK2_LOOP
		beqz t0, PLAY_AUDIO.TRACK2_STOP
		# if loop is on, restart song
		
		lw t0, TRACK2_START_PTR
		sw t0, TRACK2_NEXT_PTR, t1	# puts the pointer back in the start
		csrr t0, time
		sw t0, TRACK2_TIMESTAMP, t1	# restarts track timestamp (so it plays from the start)
		j PLAY_AUDIO.TRACK2_RET		# continues with the rest of the procedure
		
PLAY_AUDIO.TRACK2_STOP:
		sw zero, TRACK2_NEXT_PTR, t0	# cleans up pointer
		sw zero, TRACK2_ACTIVE, t0	# closes down track
PLAY_AUDIO.TRACK2_RET:
       		ret
       		
       		
       		
       		
       		
       		
       		
       		
       		
       		
PLAY_AUDIO.INIT_TRACK3: 		
		sw a1, TRACK3_START_PTR, t1     # saves the audio as the start pointer
		sw a1, TRACK3_NEXT_PTR, t1	# also saves the audio as the next pointer (to play the first note)
       		li t0, 1
      		sw t0, TRACK3_ACTIVE, t1	# activates the track
      		csrr t0, time
      		sw t0, TRACK3_TIMESTAMP, t1	# saves the moment that the track started
      		sw a3, TRACK3_LOOP, t1		# saves whether loop is on or off
      		ret
       		
PLAY_AUDIO.TRACK3: 

		lw t0, TRACK3_ACTIVE
		beqz t0, PLAY_AUDIO.TRACK3_RET	# if the track is no longer active, dont play it
		
		lw t0, TRACK3_TIMESTAMP
		csrr t1, time
		sub t2, t1, t0			# miliseconds since start of song
		
		lw t0, TRACK3_NEXT_PTR
		lw t1, duration(t0)
		beqz t1, PLAY_AUDIO.TRACK3_END	# if the duration of this note is zero, we've reached the end
		
		lw t1, start_ms(t0)		
		bgt t1, t2, PLAY_AUDIO.TRACK3_RET	# if start_ms < ms_since_timestamp: not yet time to play the next note, skip track
		
		lb a0, pitch(t0)
		lw a1, duration(t0)
		lb a2, instrument(t0)
		lb a3, volume(t0)
		li a7, 31
		ecall
		
		addi t0, t0, note_struct_size
		sw t0, TRACK3_NEXT_PTR, t1	# go to the next note in the file
		
		j PLAY_AUDIO.TRACK3		# checks if theres any note we should be playing in synchrony
		
PLAY_AUDIO.TRACK3_END:	
		lw t0, TRACK3_LOOP
		beqz t0, PLAY_AUDIO.TRACK3_STOP
		# if loop is on, restart song
		
		lw t0, TRACK3_START_PTR
		sw t0, TRACK3_NEXT_PTR, t1	# puts the pointer back in the start
		csrr t0, time
		sw t0, TRACK3_TIMESTAMP, t1	# restarts track timestamp (so it plays from the start)
		j PLAY_AUDIO.TRACK3_RET		# continues with the rest of the procedure
		
PLAY_AUDIO.TRACK3_STOP:
		sw zero, TRACK3_NEXT_PTR, t0	# cleans up pointer
		sw zero, TRACK3_ACTIVE, t0	# closes down track
PLAY_AUDIO.TRACK3_RET:
       		ret
       
       
P_TA1_FIM:
		lw ra, (sp)
		addi sp, sp, 4
		ret
       
       
       
