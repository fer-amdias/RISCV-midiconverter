######################################
#     GAME LOOP COM AUDIO DEMO	     #
#		  		     #
#			             #
# Fernando A. M. Dias - 2025.09.09   #
######################################

# AVISO: Isso nao vai funcionar bem no RARS.
# RARS tem dificuldade em tocar varias notas MIDI ao mesmo tempo.
# Prefira o FPGRARS, de LeoRiether.

.data 

# esse audio estah incluso na pasta demo. troque-o por outro se quiser
.include "./example.data" 

.text

# o endereco padrao na tela 8-bit do FPGRARS. Talvez tenha que mudar esses numeros para estarem em conformidade com o comeco e fim do endereco VGA em seu emulador.
.eqv VGA_ADDRESS     0xFF000000
.eqv VGA_ADDRESS_END 0xFF012C00

START:

li a0, 1		# MODO: tocar novo audio
la a1, example		# ENDERECO: example.data
li a2, 1		# TRACK: 1
li a3, 0		# LOOP: sem loop
jal PLAY_AUDIO_DEMO	# chama a demonstracao

GAMELOOP:

###### mudando a tela com varias, varias cores ######
# ...isso nao eh necessario pra o gameloop funcionar,
# isso eh so um exemplo de um gameloop fazendo outras
# coisas enquanto tambem toca o audio

# vc pode remover essa parte se ela nao roda por algum motivo

			
FILL_SCREEN:		
			# muda a cor por uma unidade para criar um efeito gradiente com o tempo
			addi t3, t3, 1
			
			li t1, VGA_ADDRESS
			li t2, VGA_ADDRESS_END
			
			srli t4, t3, 8			# divide a cor por 256 para desacelerar o efeito

FILL_SCREEN_LOOP: 	beq t1,t2,FILL_SCREEN_END	# se chegamos no ultimo endereco, sai do loop
			sb t4,0(t1)			# escreve o bit no endereco de memoria
			addi t1,t1,1			# vai pro proximo bit
			j FILL_SCREEN_LOOP		# checa de novo			

FILL_SCREEN_END:	# tela preenchida

#####################################################

PLAY_AUDIO:
			# continua tocando os tracks. Muito importante ter isso no gameloop se vc quer seu audio toque, para comeco de conversa
			li a0, 0
			jal PLAY_AUDIO_DEMO

			j GAMELOOP  # fim do gameloop: recomeca ele

######################################
.include "./audioplayer_PT.s"

