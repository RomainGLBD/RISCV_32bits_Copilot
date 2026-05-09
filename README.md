# RISCV_32bits_Copilot

Conception d'un processeur RISCV-32bits à l'aide d'instructions Copilot.

2 Archi :

RISCV : Ajoutez le code directement dans les mémoires puis générez le bistream et implémentez.

RISCV_UART : Possiilité d'ajouter les codes des mémoires par liaison UART via la commande :

Cas standard - 2 fichiers:
python3 ./PROG/send_prog.py instructions.hex data.hex /dev/ttyUSB0 --run

Cas mono-fichier:
python3 ./PROG/send_prog.py instructions.hex /dev/ttyUSB0 --target imem --run
python3 ./PROG/send_prog.py data.hex /dev/ttyUSB0 --target dmem

exemple de format : PGCD (mémoire instruction):

00300613
008000EF
00008067
FF410113
00112423
00812223
00000513
02060663
00150513
02A60263
FFF60613
00C12023
FDDFF0EF
00012603
FFF60613
00050433
FCDFF0EF
00850533
00412403
00812083
00C10113
00008067
