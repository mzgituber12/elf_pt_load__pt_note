# elf_pt_load__pt_note

Lancement du programme : 

1) compiler le shell en binaire

 nasm -f bin bind_shell.asm -o bind_shell.bin ** Shell à compilé en binaire pour le bon fonctionnement du ELF infector**

(bonus) stat -c %s bind_shell.bin (taille en octet)

2) Compiler un ELF simple de test sans ASRL et PIE (fichier fournis = simple.asm) :

nasm -f elf64 simple.asm -o simple.o && ld --build-id simple.o -o simple

3) Compiler l'Infecteur d'ELF ge_elf.asm

nasm -f elf64 ge_elf.asm -o ge_elf.o && ld ge_elf.o -o ge_elf

4) Lancer le ELF Infector 

./ge_elf simple // nom du fichier ELF compilé

5) tester si l'Infector à fonctionné

./simple
