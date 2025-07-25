# RISCV-midiconverter
This repository contains a Python-based MIDI-to-DATA converter designed to work with [LeoRiether's FPGRARS](https://github.com/LeoRiether/FPGRARS), a RISC-V simulator with MIDI output capability. It transforms .mid files into .data files that be manipulated by assembly programs.

Unlike the vast majority of midi converters for RARS or FPGRARS, the converter encodes notes as structs, containing PITCH, INSTRUMENT, VOLUME, DURATION (in millisseconds) and START TIME (in millisseconds)
```asm
.byte pitch, instrument, volume
.space 1                 # alignment
.word duration_ms
.word start_time_ms
```

The first four can be loaded directly into the MidiOut ecall, while the fifth is used to determine when the note is supposed to be called. An example of this would be the file `musicplayer.s` in this repository. It will simply store a timestamp once the music starts playing, then calculate how many miliseconds have passed since. Using its pointer, it will go through the file until it finds one or more notes with a matching or lower start_time_ms. If it reaches the end (there is always an appendix .word 0 0 0 to mark it), it will wait for the last note to play before finalizing.

The music player is a program on its own, so it is not made to run, say, during game loops. Fortunately, here is included [the procedure (originally in Portuguese)](https://github.com/fer-amdias/quatro/blob/main/src/tocar_audio.s) used inside a game, [Quatro](https://github.com/fer-amdias/quatro/tree/main). The demonstration file `async_musicplayer.s` has three tracks and can play the three simultaneously, without wrestling control away from the game loop.

## Usage
Running the converter will require python and [mido](https://pypi.org/project/mido/) installed. If you don't have mido, simply run:
```console
pip install mido
```

Running the RV32IM Assembly files will require [LeoRiether's FPGRARS](https://github.com/LeoRiether/FPGRARS). Versions 2.0 and above of FPGRARS have a tendency to stack overflow over time, so it is recommended to download v1.13.1 instead. Once you have it installed and in the same directory as your file, simply run:
```[FPGRARS_FILE_NAME] musicplayer.s```
or alternatively,
```[FPGRARS_FILE_NAME] async_musicplayer.s```

# RISCV-midiconverter (Português)
Esse repositório possui um conversor MIDI para DATA baseado em Python feito para funcionar com o [FPGRARS do LeoRiether](https://github.com/LeoRiether/FPGRARS), um simulador RISCV com suporte à saída MIDI. Ele transforma arquivos .mid em arquivos .data que podem ser manipulados por programas de assembly.

Diferentemente da maioria dos conversores midi para RARS ou FPGRARS, aqui as notas são transformadas em structs, com TOM, INSTRUMENTO, VOLUME, DURAÇÃO (em milissegundos), e TIMESTAMP_INICIO (em ms)
```asm
.byte tom, instrumento, volume
.space 1                 # alignment
.word duracao_ms
.word timestamp_inicio_ms
```

Os primeiros quatro podem ser carregados diretamente na ecall de MidiOut, enquanto o quinto é utilizado para determinar quando uma nota deve ser tocada. Um exemplo nesse repositório seria `music_player`.s. Uma timestamp vai ser carregada quando a música comecar a tocar, e vai ser usada para calcuar quandos segundos se passaram desde o início da música. Utilizando-se de um ponteiro, o arquivo vai procurar uma ou mais notas com TIMESTAMP_INICIO menor ou igual ao atual, percorrendo o caminho até que encontre uma nota mais à frente. Se o ponteiro chegar no final (sempre tem um apêndice .word 0 0 0 mara marcar o fim), então ele vai esperar até a última nota para fechar.

O toca-músicas é um programa por si próprio, então não é feito para rodar durante game loops. Felizmente, aqui está incluido o procedimento utilizado dentro de um jogo, [Quatro](https://github.com/fer-amdias/quatro/tree/main). O arquivo de demonstração `async_musicplayer.s` tem três tracks e pode tocar os três concomitantemente, sem tirar o controle do game loop.

## Uso
Rodar o conversor requerirá Python e [mido](https://pypi.org/project/mido/). Se você não tem ele instalado, simplesmente rode:
```console
pip install mido
```

Rodar os arquivos Assembly RV32IM requere o [FPGRARS do Leo Riether](https://github.com/LeoRiether/FPGRARS). As versões 2.0 e acima do FPGRARS tendem a dar stack overflow, então é recommendado o uso da versão v1.13.1. Quando ter o programa no mesmo diretório do arquivo, rode
```[ARQUIVO_FPGRARS] musicplayer.s```
alternativamente,
```[ARQUIVO_FPGRARS] async_musicplayer.s```
