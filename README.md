# elf_pt_load__pt_note

Pour connaitre la taille en binaire du payload :

1 nasm -f bin bind_shell.asm -o bind_shell.bin 
! Shell à compilé en binaire pour le bon fonctionnement du ELF infector

2 stat -c %s bind_shell.bin (taille en octet)

Pour avoir un ELF de test sans ASRL et PIE :

nasm -f elf64 simple.asm -o simple.o && ld --build-id simple.o -o simple

Pour lancer le ELF Infector :

./ge_elf simple // nom du fichier ELF compilé
