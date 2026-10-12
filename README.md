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

# Docs fichier ELF

1) ge_elf.asm

Plan du fichier :

1. Récupérer les arguments
   - Vérification du nombre d'argument.
   - Récupéreration du nom de l'ELF et du payload.
2. Ouvrir l'ELF
   - open
   - Conserver le file descriptor (pour effectué des opération sur l'ELF).
3. Lire l'ELF Header
   - Lire les 64 premiers octets.
   - Vérifier :
     - 7F ELF → fichier ELF
     - ELF64
     - little endian
     - x86-64
4. Récupérer les informations importantes
   - e_entry → point d'entrée actuel.
   - e_phoff → début des Program Headers.
   - e_phentsize → taille d'un Program Header.
   - e_phnum → nombre de Program Headers.
5. Parcourir les Program Headers
   - Pour chaque entrée :
   e_phoff + i × e_phentsize
   - Regarder p_type.
   - Chercher notamment :
     - PT_NOTE
     - PT_LOAD
6. Analyser les PT_LOAD
   - Récupérer :
     - p_flags
     - p_offset
     - p_vaddr
     - p_filesz
     - p_memsz
     - p_align
   - Calculer où se termine le dernier segment chargé.
7. Ouvrir le payload
   - Lire son contenu.
   - Éventuellement (argument 0 ou 1) appliquer le dechiffrage XOR.
   - Déterminer sa taille.
8. Préparer les nouvelles informations ELF
   - Construire un nouveau Program Header.
   - Définir notamment :
   PT_LOAD
   flags
   offset
   adresse virtuelle
   taille
   alignement
9. Modifier l'ELF
   - Modifier e_entry.
   - Modifier un Program Header.
   - Écrire les données du payload dans le fichier.
10. Fermer et quitter
    - close
    - exit

Resumé Ultra rapide : 

Verif arguments
   ↓
Ouvrir ELF
   ↓
Lire + vérifier ELF Header
   ↓
Récupérer e_phoff / e_phnum / e_phentsize
   ↓
Parcourir les Program Headers
   ↓
Trouver/analyser PT_LOAD et PT_NOTE
   ↓
Lire le payload
   ↓
Préparer les nouvelles données ELF
   ↓
Modifier le fichier
   ↓
Fermer


