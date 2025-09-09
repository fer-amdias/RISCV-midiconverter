######################################
#     GAME LOOP WITH AUDIO DEMO	     #
#		  		     #
#			             #
# Fernando A. M. Dias - 2025.09.09   #
######################################

# WARNING: this will not work properly in RARS.
# RARS struggles to play more than one MIDI note at a time.
# Prefer LeoRiether's FPGRARS.

.data 

# this is included in the demo folder. switch it for another song if youd like.
.include "./example.data" 

.text

# the default address in FPGRARS 8-bit screen. You may want to change these numbers to match the VGA start and end if they're different in your emulator.
.eqv VGA_ADDRESS     0xFF000000
.eqv VGA_ADDRESS_END 0xFF012C00

START:

li a0, 1		# MODE: add audio
la a1, example		# ADDRESS: example.data
li a2, 1		# TRACK: 1
li a3, 0		# LOOP: no loop
jal PLAY_AUDIO_DEMO	# calls the demo

GAMELOOP:

###### varying the screen with several colours ######
# ...this is not necessary for this to work. its just
# an example of a game loop doing *other stuff* while
# also playing the audio 

# you can safely remove this if it doesnt run for some reason

			
FILL_SCREEN:		
			# shift colour by one unit to create a gradient effect over time
			addi t3, t3, 1
			
			li t1, VGA_ADDRESS
			li t2, VGA_ADDRESS_END
			
			srli t4, t3, 8			# divides the colour by 256 to slow down the effect

FILL_SCREEN_LOOP: 	beq t1,t2,FILL_SCREEN_END	# if weve reached the last address, leave loop
			sb t4,0(t1)			# write the bit to the VGA memory
			addi t1,t1,1			# add 1 to address (go to next bit)
			j FILL_SCREEN_LOOP		# checks again				

FILL_SCREEN_END:	# screen is filled

#####################################################

PLAY_AUDIO:
			# keep playing tracks. Very important to have this in the game loop if you want your audio to play AT ALL
			li a0, 0
			jal PLAY_AUDIO_DEMO

			j GAMELOOP  # end of gameloop: restart

######################################
.include "./audioplayer_EN.s"

