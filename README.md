# elf_pt_load__pt_note

Lancement du programme simplifié :

exemple :

make FILE=simple PAYLOAD=reverse_shell.bin XOR=0 

ou

make FILE=simple PAYLOAD=bind_shell.bin XOR=1 KEY=0x5A 

ou

make FILE=simple PAYLOAD=bind_shell.bin XOR=1 
// Par default dans le programe : KEY=0x5A 

Lancement du programme manuel : 

1) compiler le shell en binaire

 nasm -f bin bind_shell.asm -o bind_shell.bin ** Shell à compilé en binaire pour le bon fonctionnement du ELF infector**

(bonus) stat -c %s bind_shell.bin (taille en octet)

2) Compiler un ELF simple de test sans ASRL et PIE (fichier fournis = simple.asm) :

nasm -f elf64 simple.asm -o simple.o && ld --build-id simple.o -o simple

3) Compiler l'Infecteur d'ELF ge_elf.asm

nasm -f elf64 ge_elf.asm -o ge_elf.o && ld ge_elf.o -o ge_elf

4) Lancer le ELF Infector 

./ge_elf (nomfichierELF) (nomshell.bin) (0 ou 1) (optionnel clée xor exemple: 0x5A) // nom du fichier ELF compilé simple et shell avec reverse ou bin_shell et si le shell est chiffrer en xor et enfin optionnel la clée

5) tester si l'Infector à fonctionné

./simple
