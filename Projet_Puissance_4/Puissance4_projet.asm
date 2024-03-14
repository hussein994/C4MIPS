#  Pojet AO Printemps 2021-2022
#  Date de rendu: 12/13/17 11:00AM

################################################################################################################################# 
##  Ce fichier contient un squelete de code pour le jeu du puissance 4.
##  L'ensemble des fonctions d'affichage est d�j� en place. L'affichage repose sur l'�criture de carr�s de 8x8px.
##  Les fonctions � compl�ter sont les suivantes :
##  
################################################################################################################################# 
.data
 

Colors:	#  Contient les couleurs
 .word 0x0000FF # [0] Bleu   0x0000FF	Grille
 .word 0xFF0000 # [1] Rouge  0xFF0000	
 .word 0xE5C420 # [2] Jaune  0xE5C420	
 .word 0x3acf62 # [3] Vert   0x3acf62
 .word 0xfc7e00 # [4] Orange 0xfc7e00
 .word 0xe0079b # [5] Violet 0xe0079b
 .word 0x00FFFF # [6] Cyan   0x00FFFF
 .word 0xFFFFFF # [3] Blanc  0xFFFFFF	Fond

tabCase: .byte 0:42 #tableau de 43 cases pour parcourir les cases du jeu

#  Un cercle est d�finit par une suite de lignes horizontales.
#  Chaque ligne est d�finie par un offset suivit d'une longeur (ex : 2, 4, on d�cale de deux carr�s et on d�ssine 4 carr�s
CircleDef: 
	.word 2, 4, 1, 6, 0, 8, 0, 8, 0, 8, 0, 8, 1, 6, 2, 4

displayStart: .asciiz "Bienvenue dans ce jeu du puissance 4!\nC'est un jeu � deux joueurs.\nLe joueur 1 va commencer.\nEntrez un nombre entre 1 et 7 pour choisir la colonne o� jouer.\nUne fois qu'un joeuur a jou�, attendez que la console demande une nouvelle action pour jouer!\n\nBon Jeu!\n\n"
displayP1: .asciiz "\nTour du joueur 1 : "
displayP2: .asciiz "\nTour du joueur 2 : "
displayP1Win: .asciiz "Le joueur 1 à gagné !\n"
displayP2Win: .asciiz "Le joueur 2 à gagné !\n"
displayInstructions: .asciiz "Choisissez un nombre entre 1 et 7 (inclus)\n"
displayFull: .asciiz "la colonne choisie est pleine. Choisissez en une autre.\n"
displayTie: .asciiz "Il y a égalité !\n"
displayChoixCouleurJ1: .asciiz "Joueur 1, choisissez votre color:\n[1 rouge, 2 jaune, 3 vert, 4 orange, 5 violet, 6 cyan] \n"
displayChoixCouleurJ2: .asciiz "Joueur 2, choisissez votre color:\n[1 rouge, 2 jaune, 3 vert, 4 orange, 5 violet, 6 cyan] \n"
displayCouleurPrise: .asciiz "Cette couleur est soit prise soit invalide(1 a 6)!\n"
displayRejouer: .asciiz "\nVoulez vous rejouer? (1): oui, (0): non. \n"


.text

Init:			# relancement du programme depart.
la $a0, ($sp)
li $v0, 1
syscall

#  D�ssine le plateau
jal DrawGameBoard

#  D�but du jeu
la $a0, displayStart	
li $v0, 4
syscall

################################   Fonction Main ################################  	
ColorChoicePlayer1:			# input de la couleur du joueur 1 
	la $a0, displayChoixCouleurJ1
	li $v0, 4
	syscall
	li $v0, 5
	syscall
	move $t5, $v0
	bgt $t5, 6, clrIndispo1
	blt $t5, 1, clrIndispo1
	
ColorChoicePlayer2:			# input de la couleur du joueur 2
	la $a0, displayChoixCouleurJ2
	li $v0, 4
	syscall
	li $v0, 5
	syscall
	
	beq $v0, $t5 clrIndispo
	
	move $t6, $v0
	bgt $t6 6 clrIndispo
	blt $t6, 1, clrIndispo
	j main


clrIndispo1:				# pour eviter que les deux joueur choisissent la meme couleur
	la $a0, displayCouleurPrise
	li $v0, 4
	syscall
	j ColorChoicePlayer1

clrIndispo:				# pour eviter que les deux joueur choisissent la meme couleur
	la $a0, displayCouleurPrise
	li $v0, 4
	syscall
	j ColorChoicePlayer2

main:

#  R�cup�re l'instruction du joueur 1
playerOne:
la $a0, displayP1
li $v0, 4
syscall
li $v0, 5
syscall

#  Place le jeton et contr�le si il y a une erreur
move $a0, $t5 #1 changes this <-----------------------------------------------------
jal UpdateRecord

#  D�ssine le jeton
move $a0, $t5 #1 changes this <-----------------------------------------------------
jal DrawPlayerChip

#  Test si le joueur 1 � gagner sinon on reviens et on pass � la suite (instruction "playerTwo:")
jal WinCheck

#  R�cup�re l'instruction du joueur 2
playerTwo:
la $a0, displayP2
li $v0, 4
syscall
li $v0, 5
syscall

#  Place le jeton et contr�le si il y a une erreur
move $a0, $t6 #1 changes this <-----------------------------------------------------
jal UpdateRecord

#  D�ssine le jeton
move $a0, $t6 #1 changes this <-----------------------------------------------------
jal DrawPlayerChip

#  Test si le joueur 1 � gagner sinon on passe � la suite (instruction "j main")
jal WinCheck

j main	#  Passe au porchain tour
################################   Fin de la fonction Main ################################  



################################   D�but des proc�dures d'affichage ################################  
##################### Il n'est pas obligatoire de comprendre ce qu'elles font. ##################### 
# Procedure: DrawPlayerChip
# Input: $a0 - Num�ro du joueur
# Input: $v0 - Position (entre 0 et 41)
DrawPlayerChip:
	
	addiu $sp, $sp, -12
	sw $ra, ($sp)
	sw $a0, 4($sp)
	sw $v0, 8($sp)
	
	#  place la couleur du jeton en argument
	move $a2, $a0
	
	#  On calcul la position
	li $t0, 7
	div $v0, $t0
	mflo $t0	# Division (Y)
	mfhi $t1	# Reste (X)

	#  Y-Position = 63-[(Y+1)*9+4] = 50-9Y (dans $t0)
	li $t2, 50
	mul $t0, $t0, 9
	mflo $t0
	sub $t0, $t2, $t0 
	
	# X-Position = [X*9]+1 (dans $t1)
	mul $t1, $t1, 9
	addi $t1, $t1, 1
	
	#  Copie les positions dans les registres d'arguments
	move $a0, $t1
	move $a1, $t0
	
	jal DrawCircle
	
	lw $v0, 8($sp)
	lw $a0, 4($sp)
	lw $ra, ($sp)
	addiu $sp, $sp, 4
	jr $ra

# Procedure: DrawGameBoard
# Affiche la grille
DrawGameBoard:
	addiu $sp, $sp, -4
	sw $ra, ($sp)
	
	#  Fond en blanc
	li $a0, 0
	li $a1, 0
	li $a2, 7	#chnaged this for color bonus <--------------------------------------
	li $a3, 64
	jal DrawSquare #  Affiche un carr� blanc de 64x64 en position 0,0)
	
	#  Ligne du haut
	li $a0, 0	
	li $a1, 0	
	li $a2, 0	
	li $a3, 64	
	jal DrawHorizontalLine
	li $a1, 1
	jal DrawHorizontalLine
	li $a1, 2	
	jal DrawHorizontalLine
	li $a1, 3	
	jal DrawHorizontalLine
	li $a1, 4	
	jal DrawHorizontalLine
	
	#  Ligne du bas
	li $a0, 0	
	li $a1, 58	
	li $a2, 0	
	li $a3, 64	
	jal DrawHorizontalLine
	li $a1, 59
	jal DrawHorizontalLine
	li $a1, 60	
	jal DrawHorizontalLine
	li $a1, 61	
	jal DrawHorizontalLine
	li $a1, 62	
	jal DrawHorizontalLine
	li $a1, 63	
	jal DrawHorizontalLine


	#  Lignes verticales
	li $a0, 0	
	li $a1, 0	
	li $a2, 0	
	li $a3, 64	
	jal DrawVerticalLine	
	li $a0, 9	# (X = 9)
	jal DrawVerticalLine
	li $a0, 18	# (X = 18)
	jal DrawVerticalLine
	li $a0, 27	# (X = 27)
	jal DrawVerticalLine
	li $a0, 36	# (X = 36)
	jal DrawVerticalLine
	li $a0, 45	# (X = 45)
	jal DrawVerticalLine
	li $a0, 54	# (X = 54)
	jal DrawVerticalLine
	li $a0, 63	# (X = 63)
	jal DrawVerticalLine

	#  Lignes horizontales
	li $a0, 0	
	li $a1, 13	
	li $a2, 0	
	li $a3, 64	
	jal DrawHorizontalLine
	li $a1, 22
	jal DrawHorizontalLine
	li $a1, 31	
	jal DrawHorizontalLine
	li $a1, 40	
	jal DrawHorizontalLine
	li $a1, 49	
	jal DrawHorizontalLine

	lw $ra, ($sp)
	addiu $sp, $sp, 4
	jr $ra


# Procedure: DrawCircle
# Input - $a0 = X 
# Input - $a1 = Y
# Input - $a2 = Color (0-5)
# Affiche le Jeton
DrawCircle:
	#  Fait de a place sur la pile
	addiu $sp, $sp, -28 	
	#  Y ajoute les arguments suivants $ra, $s0, $a0, $a2
	sw $ra, 20($sp)
	sw $s0, 16($sp)
	sw $a0, 12($sp)
	sw $a2, 8($sp)
	li $s2, 0	#  Initaitllise le compteur et on passe dans la boucle de la fonction
	
CircleLoop:
	la $t1, CircleDef
	#  Utilise le compteur pour r�cup�er le bon indice dans CircleDef
	addi $t2, $s2, 0	
	mul $t2, $t2, 8		
	add $t2, $t1, $t2	
	lw $t3, ($t2)		
	add $a0, $a0, $t3	
	
	#  On d�ssine la ligne
	addi $t2, $t2, 4	
	lw $a3, ($t2)		
	sw $a1, 4($sp)		
	sw $a3, 0($sp)		
	sw $s2, 24($sp)		
	jal DrawHorizontalLine
	
	#  On remet en place les arguments
	lw $a3, 0($sp)
	lw $a1, 4($sp)
	lw $a2, 8($sp)
	lw $a0, 12($sp)
	lw $s2, 24($sp)
	addi $a1, $a1, 1	#  Incremente Y value
	addi $s2, $s2, 1	#  Incremente le compteur
	bne $s2, 8, CircleLoop	#  On boucle pour �crire les 8 lignes
	
	
	#  R�staure les valeurs de $ra, $s0, $sp
	lw $ra, 20($sp)
	lw $s0, 16($sp)
	addiu $sp, $sp, 28
	jr $ra
	
# Procedure: DrawSquare
# Input - $a0 = X 
# Input - $a1 = Y
# Input - $a2 = Color (0-5)
# Input - $a3 = W 
# D�ssine un carr� de taille WxW en position (X, Y)
DrawSquare:
	addiu $sp, $sp, -24 	# Sauvegarde $ra, $s0, $a0, $a2
	sw $ra, 20($sp)
	sw $s0, 16($sp)
	sw $a0, 12($sp)
	sw $a2, 8($sp)
	move $s0, $a3		
	
BoxLoop:
	sw $a1, 4($sp)	
	sw $a3, 0($sp)	
	jal DrawHorizontalLine
	
	# R�staure $a0-3
	lw $a3, 0($sp)
	lw $a1, 4($sp)
	lw $a2, 8($sp)
	lw $a0, 12($sp)
	addi $a1, $a1, 1	# Incr�mente Y 
	addi $s0, $s0, -1	# D�cr�mente le nombre de ligne
	bne $zero, $s0, BoxLoop	# Jusqu'� ce que le compteur soit � z�ro
	
	# R�staure $ra, $s0, $sp
	lw $ra, 20($sp)
	lw $s0, 16($sp)
	addiu $sp, $sp, 24	# Reset $sp
	jr $ra
	
# Procedure: DrawHorizontalLine
# Input - $a0 = X 
# Input - $a1 = Y
# Input - $a2 = Color (0-5)
# Input - $a3 = W
# D�ssine une ligne horizontale de longueur W en position (X, Y)
DrawHorizontalLine:
	addiu $sp, $sp, -28 	
	# Sauvegarde $ra, $a1, $a2
	sw $ra, 16($sp)
	sw $a1, 12($sp)
	sw $a2, 8($sp)
	sw $a0, 20($sp)
	sw $a3, 24($sp)
	
HorizontalLoop:
	# Sauvegarde $a0, $a3 
	sw $a0, 4($sp)
	sw $a3, 0($sp)
	jal DrawPixel
	# R�staure tout sauf $ra
	lw $a0, 4($sp)
	lw $a1, 12($sp)
	lw $a2, 8($sp)
	lw $a3, 0($sp)	
	addi $a3, $a3, -1		# D�cr�mente la longueur W
	addi $a0, $a0, 1		# Incr�mente X 
	bnez $a3, HorizontalLoop	# Boucle tant que W > 0 	
	lw $ra, 16($sp)			# R�staure $ra
	lw $a0, 20($sp)
	lw $a3, 24($sp)
	addiu $sp, $sp, 28		# R�staure $sp
	jr $ra
	
# Procedure: DrawVerticalLine
# Input - $a0 = X 
# Input - $a1 = Y
# Input - $a2 = Color (0-5)
# Input - $a3 = W
# D�ssine une ligne verticale de longeur W en position (X, Y)
DrawVerticalLine:
	addiu $sp, $sp, -28
	# Sauvegarde $ra, $a1, $a2
	sw $ra, 16($sp)
	sw $a1, 12($sp)
	sw $a2, 8($sp)
	sw $a0, 20($sp)
	sw $a3, 24($sp)
	
VerticalLoop:
	# Save $a0, $a3 (changes with next procedure call)
	sw $a1, 4($sp)
	sw $a3, 0($sp)
	jal DrawPixel
	# Restore all but $ra
	lw $a1, 4($sp)
	lw $a0, 20($sp)
	lw $a2, 8($sp)
	lw $a3, 0($sp)	
	addi $a3, $a3, -1		# D�cr�mente la longueur W
	addi $a1, $a1, 1		# Incr�mente Y 
	bnez $a3, VerticalLoop		# Boucle tant que W > 0 	
	lw $ra, 16($sp)			# R�staure $ra
	lw $a1, 12($sp)
	lw $a3, 24($sp)
	addiu $sp, $sp, 28		# R�staure $sp
	jr $ra
	
# Procedure: DrawPixel
# Input - $a0 = X
# Input - $a1 = Y
# Input - $a2 = Color (0-5)
# D�ssine un pixel sur la Bitmap en �crivant au bon endroit sur la m�moire (sur le tas/heap) via la fonction GetAddress
DrawPixel:
	addiu $sp, $sp, -8
	# Save $ra, $a2
	sw $ra, 4($sp)
	sw $a2, 0($sp)
	jal GetAddress		# Calcule l'adresse m�moire
	lw $a2, 0($sp)		
	sw $v0, 0($sp)		
	jal GetColor		# R�cup�re la couleur
	lw $v0, 0($sp)		
	sw $v1, ($v0)		# Ecrit la couleur en m�moire
	lw $ra, 4($sp)		
	addiu $sp, $sp, 8	
	jr $ra


# Procedure: GetAddress
# Input - $a0 = X
# Input - $a1 = Y
# Output - $v0 = l'adresse m�moire exacte o� �crire le pixel
GetAddress:
	sll $t0, $a0, 2			# Multiplie X par 4
	sll $t1, $a1, 8			# Multiplie Y par 64*4 (512/8= 64 * 4 words)
	add $t2, $t0, $t1		# Additionne les deux 
	addi $v0, $t2, 0x10040000	# Ajout de l'adresse point� par Bitmap (heap) 
	jr $ra

# Procedure: GetColor
# Input - $a2 = Index dans Colors (0-5)
# Output - $v1 = valeur Hexad�cimale
# Retourne la valeur Hexad�cimale de la couleur demand�e
GetColor:
	la $t0, Colors		
	sll $a2, $a2, 2		
	add $a2, $a2, $t0	
	lw $v1, ($a2)		
	jr $ra

################################ des proc�dures d'affichage ################################  



################################ D�but UpdateRecord ################################ 
# Procedure: UpdateRecord
# Input: Index donn� par l'utilisateur - $v0
# Input: Num�ro du joeur (1 ou 2) - $a0
# Output: num�ro du carr� ($v0)
# D�termine la position exacte o� placer le jeton et met � jour l'�tat du jeu en m�moire, puis renvoit la position de jeton
UpdateRecord:
	addiu $v0, $v0, -1		# -1 pour que l'input soit égale aux indices d'un tableau (de 0 à 6)
	bgtu $v0, 6, HorsGrille   	#test si le input est bien entre 6 et 0 inclus (entre 1 et 7 inclus pour le joueur)
	bltu $v0, 0, HorsGrille		#sinon eon renvoi le message d'error
	j checkifpleine
	
PreCheckifpleine:
	addi $v0, $v0, 7		# on additionne 7 pour chaque case de la colonne colonne	

checkifpleine:	 
    	bgtu $v0, 41, colonePleine	# si on depasse 41 (l'indice de ma derniere case) la colonne est pleine
   	lb $v1, tabCase($v0)		#sinon on recupere la valeur stocker dans la tabeau de case au dessus de celle avec l'indice $v0
    	bnez $v1, PreCheckifpleine		#si elle est pas vide, on re-test sinon on desssine le jeton a cette case:
	sb $a0, tabCase($v0)		#on met le num du joueurs comme valeur dans cette case
	j exit
 
	
colonePleine:			#affichage du message d'erreur colonne pleine
	move $t0, $a0
	la $a0, displayFull
	li $v0, 4
	syscall
	move $a0, $t0
	j rejouer
	
HorsGrille:			#affichage du message d'erreur hors grille
	move $t0, $a0
	la $a0, displayInstructions
	li $v0, 4
	syscall
	move $a0, $t0
	 
rejouer:
	beq $a0, $t5, playerOne
	beq $a0, $t6, playerTwo
	 

################################ Fin UpdateRecord ################################ 
	
			
 ########################################################################## D�but WinCheck ################################################################################################  
# Procedure: WinCheck
# Input: $a0 - Player Number
# Input: $v0 - Last location offset chip was placed
# D�termine si le dernier jeton jou� a permis de gagner

WinCheck:    	
     	#  Vous devez v�rifier sur :
     	# 1. la ligne horizontale			check 1
     	# 2. la ligne verticale				check 2
     	# 3. la diagonale avant				check 3
     	# 4. la diagonale arri�re   			check 4
     	# 5. si tout le plateau est remplit (Egalit�)	check 5
     	
#-------------------------------------------Debut verifie la ligne horizontale -------------------------------------------

     	li $t4, 1 			# conteur pour le nombre de jeton
     	li $t7, 7 			#registre pour l'entier 7
     	move $t2, $v0 			#numero de la case ou le jeton est dessiné
     	
verifieràGauche:			#on commence par verifier à gauche
     	la $t0, tabCase($t2)		#l'adresse de la cese ou on a dessiné le jeton
     	
#test d'abord si le jeton n'est pas tout à gauche de la grille
     	div $t2, $t7  			#ici on divise le numero de la case et on regarde si le reste n'est pas égale à 0 sinon on est en effet tout à gauche 
     	mfhi $t3 
     	beqz $t3, PreVerifieràDroite
#sinon on verifie les cases à gauche
     	lb $t1, -1($t0)			 #$t1 la valeur de la case à gauche de celle du jeton qui viens d'etre dessiné ($t0)
	bne $t1, $a0, PreVerifieràDroite #et on test si les valeurs (les jetons) sont les memes, sinon on verifier à droite
     	addi $t4, $t4, 1		 #ajouter 1 au conteur de jeton sinon
     	addiu $t2, $t2 -1		 #et on actualise la valeur $t2 avec l'adresse du jeton à gauche pour contnuer le test
     	beq $t4, 4, PlayerWon 		 #on affiche le message de victoire si le conteur = 4
     	j verifieràGauche
     	
PreVerifieràDroite:			 #les labels avec des "Pre" sont pour ne pas reinitialiser un registre durant une boucle
     	move $t2, $v0			 #on reinstalise $t2 au num de la case du jeton qui viens d'etre dessiné
     	
verifieràDroite: 
	la $t0, tabCase($t2)		 #l'adresse de la cese ou on a dessiné le jeton
#verifier d'abord si on est pas tout à droite de la grille
	div $t2, $t7			 #ici on divise le numero de la case et on regarde si le reste n'est pas égale à 6 sinon on est en effet tout à droite 
	mfhi $t3
	beq $t3, 6, check2 		 #donc on passe eu test suivant
#Sinon on commence la verification des jeton a droite 
	lb $t1, 1($t0)			 #stock la valeur de la case qui est à a droite du jeton dessiné en $t1
	bne $t1, $a0 check2
	addi $t4, $t4, 1
	addi $t2, $t2, 1 		 #et on actualise la valeur $t2 avec l'adresse du jeton à drote pour contnuer le test
	beq $t4, 4, PlayerWon
	j verifieràDroite
	
#------------------------------------------- verification horizontale-------------------------------------------

check2:

#------------------------------------------- Debut verifie la ligne verticale-------------------------------------------

	li $t4, 1 			# counteur pour le nombre de jeton
	move $t2, $v0 			#numero de la case ou le jeton est dessiné

checkCol:
	la $t0, tabCase($t2)		#l'adresse de la cese ou on a dessiné le jeton
	addiu $t3, $t2, -7
	bltz $t3, check3 		#saute vers le test suivant
#Sinon
	lb $t1, -7($t0)			#$t1 la valeur de la case en dessous de celle du jeton qui viens d'etre dessiné ($t0)
	bne $t1, $a0, check3 		#et on test si les valeurs (les jetons) sont les memes, sinon on passe au test suivant
	addi $t4, $t4, 1		#sinon si les é jetons son les memes, +1 au conteur
	addiu $t2, $t2, -7		#on met le num de la case juste en dessous dans t2 pour refaire le test 
	beq $t4, 4, PlayerWon		#sort de la fonction si conteur == 4 sinon on refait le test avec le nouveau t2
	j checkCol
	
#------------------------------------------- verification verticale-------------------------------------------

check3:

#------------------------------------------- Debut verification diagonale avant-------------------------------------------

	li $t4, 1 			# counteur pour le nombre de jeton
	li $t7, 7 			
	move $t2, $v0 			#on met le numero de la case ou le jeton est dessiné
	
#test d'abord si le jeton n'est pas tout à gauche ou en bas de la grille

verifieBG:
	la $t0, tabCase($t2)		#mettre l'adresse du jeton dans $t0
	
	blt $t2, 7, PreVerifierHD	#Si jeton est dans la ligne tout en bas
	div $t2, $t7			#Si jeton n'est pas dans la colonne tout à gauche
	mfhi $t3
	beq $t3, 0, PreVerifierHD	#saute vers PreVerifierHD
	
#Si les tests precedents sont faux, donc on peut verifier la case qui est en bas à gauche
	lb $t1, -8($t0)			#on recupere la valeur dans la case en bas à gauche 
	bne $t1, $a0, PreVerifierHD	#si il y'a pas le meme jeton, saute vers PreVerifierHD
	addi $t4, $t4, 1		#sinon +1 au conteur
	beq $t4, 4, PlayerWon		#Si conteur == 4 PlayerWon
	addiu $t2, $t2, -8		#sinon on passe a la case en bas à gauche et on refait la fonction
	j verifieBG			#sinon on refait le test avec la nouvelle case $t2
	
	
PreVerifierHD:
     	move $t2, $v0
#test d'abord si le jeton n'est pas tout en haut ou à droite de la grille
	
verifieHD:
	la $t0, tabCase($t2)		#mettre l'adresse du jeton dans $t0
	
	bge $t2, 35, check4		#Si jeton est dans la ligne tout en haut
	div $t2, $t7			#Si jeton n'est pas dans la colonne tout à droite
	mfhi $t3
	beq $t3, 6, check4		#saute vers le test suivant
#sinon verifier la case en haut à drite
	lb $t1, 8($t0)			#on recupere la valeur dans la case en haut à droite
	bne $t1, $a0, check4		#si il y'a pas le meme jeton, saute vers verfieHD
	addi $t4, $t4,1			#sinon +1 au conteur
	beq $t4, 4, PlayerWon		#Si conteur == 4 PlayerWon
	addi $t2, $t2, 8		#sinon on passe a la case en haut à droite et on refait la fonction
	j verifieHD
#------------------------------------------- verification diagonale avant -------------------------------------------

check4:

#------------------------------------------- Debut verification diagonale arriere -------------------------------------------
	#méme façon que le test diagonale avant

	li $t4, 1 			# counteur pour le nombre de jeton
	li $t7, 7 
	move $t2, $v0 			#numero de la case ou le jeton est dessiné
	
#test d'abord si le jeton n'est pas tout à gauche ou en bas de la grille
verifieBD:
	la $t0, tabCase($t2)
	
	blt $t2, 7, PreVerifierHG		
	div $t2, $t7
	mfhi $t3
	beq $t3, 6, PreVerifierHG
	
#sinon verifier la case en bas à gauche
	lb $t1, -6($t0)
	bne $t1, $a0, PreVerifierHG
	addi $t4, $t4, 1
	beq $t4, 4, PlayerWon
	addiu $t2, $t2, -6
	j verifieBD
	
PreVerifierHG:
     	move $t2, $v0
     	
verifieHG:
	la $t0, tabCase($t2)
	

	bge $t2, 35, check5	
	
	div $t2, $t7
	mfhi $t3
	beq $t3, 7, check5
	

	lb $t1, 6($t0)
	bne $t1, $a0, check5
	addi $t4, $t4,1
	beq $t4, 4, PlayerWon
	addi $t2, $t2, 6
	j verifieHG
#------------------------------------------- verification diagonale arriere -------------------------------------------

check5:

#------------------------------------------- Debut verification si tout le plateau est remplit (Egalite) --------------------------------

	li $t3 35		# numero de la case tout en haut a gauche 
     	la $t0 tabCase($t3)
     	li $t4 0		# compteur
     	
Grillepleine:
    	lb $t1 ($t0)		#stock la valeur de la case dans $t1
    	beqz $t1 exit		# on sort de la fonction si elle est vide
    	addi $t0 $t0, 1		#sinon on passe a la case suivante
    	addi $t4 $t4 1		#et +1 au conteur
    	beq $t4 7 GameTie	#si contur == 7 donc la grille est pleine donc on saute vers GameTie
    	j Grillepleine	

#------------------------------------------- verification si tout le plateau est remplit (Egalit�)-------------------------------------------
   	
     	
#############################################################################  Fin WinCheck ################################################################################################    


################################  Debut GameTie ################################  
# Procedure: GameTie
# Affiche l'�galit� et arr�te de jeu
GameTie:

    la $a0, displayTie
    li $v0, 4
    syscall
    j rejouerQ

################################  GameTie ################################  

################################  Debut PlyeWon ################################  
# Procedure: PlayerWon
# Input: $a0 - Player Number
# Affiche le gagnant et arr�te de jeu

PlayerWon:

    bne $a0, $t5 J2gagne    
#Sinon J1
    la $a0, displayP1Win
    li $v0, 4
    syscall
    j rejouerQ

J2gagne:
    la $a0, displayP2Win
    li $v0, 4
    syscall
    j rejouerQ
    

################################  PlayerWon ################################   


################################ Debut relancement de partie ################################  

rejouerQ:
    la $a0, displayRejouer
    li $v0, 4
    syscall
    li $v0, 5
    syscall 
#reponse dans v0
    beq $v0, 1 preRESET
    li $v0, 10
    syscall
    
preRESET:
    li $t1 0 #cpt
    j resetTab
        
resetTab:			#fonction pour reinstaliser le tableau de case si le joueur choisi de rejouer
    bgt $t1, 41 Init 		#on saute vers le debut du prog apres avoir reset toute les cases a 0
    la $t3, tabCase($t1)	#met l'adresse de la case dans $t3
    sb $zero, ($t3)		#stock 0 dans cette case
    addi $t1, $t1 1		# +1 au conteur
    j resetTab
    
################################ relancement de partie ################################  

exit:
	jr $ra  
