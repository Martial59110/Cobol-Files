       IDENTIFICATION DIVISION.
       PROGRAM-ID. ccblbase.
       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT ASSU ASSIGN TO "assurances-partafixed.dat"
           ORGANIZATION IS LINE SEQUENTIAL 
           ACCESS MODE IS SEQUENTIAL
           FILE STATUS IS ASSU-STATUS.

           SELECT ASSU2 ASSIGN TO "assurances-partbfixed.dat"
           ORGANIZATION IS LINE SEQUENTIAL 
           ACCESS MODE IS SEQUENTIAL
           FILE STATUS IS ASSU2-STATUS.

           SELECT ASSU-RAPPORT ASSIGN TO "rapport-assurances.dat"
           ORGANIZATION IS LINE SEQUENTIAL 
           ACCESS MODE IS SEQUENTIAL
           FILE STATUS IS ASSU-RSTATUS.
       DATA DIVISION.
       FILE SECTION.
       FD ASSU.
        01 F-DATA PIC X(122).

       FD ASSU2.
        01 F-DATA2 PIC X(122).

       FD ASSU-RAPPORT.
       01 F-DATA-RAPPORT PIC X(122).
 
       WORKING-STORAGE SECTION.
       01  ASSU-STATUS PIC X(2).
       01  ASSU2-STATUS PIC X(2).
       01  ASSU-RSTATUS PIC X(2).
       01  WS-IDX PIC 9(2).
        01  WS-ARRAY-TABLE.
           03 ARRAY OCCURS 1 TO 99 TIMES
                DEPENDING ON WS-IDX.
            05 ID-NUM PIC X(8).
            05 ID-NAME PIC X(15).
            05 LIBELLE PIC X(16).
            05 DESCRIPTION PIC X(40).
            05 STATUT PIC X(11).
            05 NUMBER1 PIC X(8).
            05 NUMBER2 PIC X(11).
            05 NUMBER3 PIC 9(8).
           
            05 EURO PIC X(3).
        01 WS-TIRET PIC X(50).
        01 TOTAL PIC 9(8).
        01 TOTALCLEAN PIC X(9).
        01 VIRGULE PIC X VALUE ",".
        01 WS-SPACE PIC X(50).
        01 WS-COUNT PIC 9(2).
        01 WS-DISPLAY PIC X(60) VALUE  "Liste des clients :".
        01 WS-DISPLAY1 PIC X(30) VALUE  "Nombre d'enregistrements :".
        01 WS-INSPECT PIC X(8) VALUE "Actif".
        01 WS-INSPECT-COUNT-A PIC 9(2).
        01 WS-INSPECT-COUNT-R PIC 9(2).
        01 WS-INSPECT-COUNT-S PIC 9(2).
        01 WS-DISPLAY2 PIC X(30) VALUE "Nombre d'Actifs :".
        01 WS-DISPLAY-LI PIC X(20).
        01 WS-DISPLAY-LIFULL PIC X(26).
        
       01  WS-SC-LINE PIC 9.
       01  WS-SC-CLR-A PIC 9.
       01  WS-SC-CLR-B PIC 9.
       

       PROCEDURE DIVISION.
           MOVE ALL "-" TO WS-TIRET.
           MOVE ALL " " TO WS-SPACE.

      *    Ouverture du premier fichier

           OPEN input ASSU
                  OUTPUT ASSU-RAPPORT.

      *    Entête et mise en forme

           WRITE F-DATA-RAPPORT FROM WS-SPACE.
           WRITE F-DATA-RAPPORT FROM WS-DISPLAY.
           WRITE F-DATA-RAPPORT FROM WS-SPACE.
           WRITE F-DATA-RAPPORT FROM WS-TIRET.

      *    Première boucle (fichier1)

           PERFORM LIRE-FICHIER1 VARYING WS-IDX FROM 1 BY 1 UNTIL 
           WS-IDX > 36.

           CLOSE ASSU.
           CLOSE ASSU-RAPPORT.

           OPEN INPUT ASSU2.
           OPEN extend ASSU-RAPPORT.

      *     Deuxième boucle (fichier2)

           SET WS-IDX TO 0.
           PERFORM LIRE-FICHIER2 VARYING WS-IDX FROM 1 BY 1 UNTIL 
           WS-IDX > 36.

      *    Fin des boucles et mise en forme
      
           WRITE F-DATA-RAPPORT FROM WS-DISPLAY1.
           WRITE F-DATA-RAPPORT FROM WS-COUNT.
           WRITE F-DATA-RAPPORT FROM WS-DISPLAY2. 
           WRITE F-DATA-RAPPORT FROM WS-INSPECT-COUNT-A.
           Move "Nombre de résiliés :" TO WS-DISPLAY2.
           WRITE F-DATA-RAPPORT FROM WS-DISPLAY2. 
           WRITE F-DATA-RAPPORT FROM WS-INSPECT-COUNT-R.
           Move "Nombre de suspendus:" TO WS-DISPLAY2.
           WRITE F-DATA-RAPPORT FROM WS-DISPLAY2. 
           WRITE F-DATA-RAPPORT FROM WS-INSPECT-COUNT-S.
           MOVE TOTAL TO TOTALCLEAN(1:6).
           MOVE TOTAL(7:2) TO TOTALCLEAN(8:2).
           MOVE VIRGULE TO TOTALCLEAN(7:1).
           Move "ARGENT TOTAL:" TO WS-DISPLAY2.
           WRITE F-DATA-RAPPORT FROM WS-DISPLAY2.
           WRITE F-DATA-RAPPORT FROM TOTALCLEAN.

           CLOSE ASSU2.
           CLOSE ASSU-RAPPORT.
           STOP RUN.
           
        LIRE-FICHIER1. 

      *    Lire le fichier1 et remplacement des * par des espaces

           READ ASSU INTO F-DATA
           INSPECT F-DATA REPLACING ALL "*" BY " "
           ADD 1 TO WS-COUNT.
           
      *    Déplacement des données du fichier dans mon tableau.
      *    Recherche des actifs etc... avec Inspect puis ajout au 
      *     compteur.
      *    Ecriture des Libellés et statuts uniquement dans le fichier 
      *    de sortie.

           MOVE F-DATA TO ARRAY(WS-IDX).
           ADD NUMBER3(WS-IDX) TO TOTAL.
           MOVE "Actif" TO WS-INSPECT.
           INSPECT STATUT(WS-IDX) TALLYING WS-INSPECT-COUNT-A
           FOR ALL WS-INSPECT.
           MOVE "Resilie" TO WS-INSPECT.
           INSPECT STATUT(WS-IDX) TALLYING WS-INSPECT-COUNT-R
           FOR ALL WS-INSPECT.
           MOVE "Suspendu" TO WS-INSPECT.
           INSPECT STATUT(WS-IDX) TALLYING WS-INSPECT-COUNT-S
           FOR ALL WS-INSPECT.
          
          
           MOVE "ID:" TO WS-DISPLAY-LI.
           WRITE  F-DATA-RAPPORT FROM SPACE.
           WRITE F-DATA-RAPPORT FROM WS-DISPLAY-LI.
           WRITE F-DATA-RAPPORT FROM ID-NUM(WS-IDX).
           MOVE "IRP:" TO WS-DISPLAY-LI.
           WRITE  F-DATA-RAPPORT FROM SPACE.
           WRITE F-DATA-RAPPORT FROM WS-DISPLAY-LI.
           WRITE F-DATA-RAPPORT FROM LIBELLE(WS-IDX).
           MOVE "Société :" TO WS-DISPLAY-LI.
           WRITE  F-DATA-RAPPORT FROM SPACE.
           WRITE F-DATA-RAPPORT FROM WS-DISPLAY-LI.
           WRITE F-DATA-RAPPORT FROM DESCRIPTION(WS-IDX).
           MOVE "SIREN 1 :" TO WS-DISPLAY-LI.
           WRITE  F-DATA-RAPPORT FROM SPACE.
           WRITE F-DATA-RAPPORT FROM WS-DISPLAY-LI.
           WRITE F-DATA-RAPPORT FROM NUMBER1(WS-IDX).
           
           MOVE "SIREN 2 :" TO WS-DISPLAY-LI.
           WRITE  F-DATA-RAPPORT FROM SPACE.
           WRITE F-DATA-RAPPORT FROM WS-DISPLAY-LI.
           WRITE F-DATA-RAPPORT FROM NUMBER2(WS-IDX). 
            MOVE "Argent :" TO WS-DISPLAY-LI.
            WRITE  F-DATA-RAPPORT FROM SPACE.
           WRITE F-DATA-RAPPORT FROM WS-DISPLAY-LI.
           WRITE F-DATA-RAPPORT FROM NUMBER3(WS-IDX).
            MOVE "Libellé :" TO WS-DISPLAY-LI.
            WRITE  F-DATA-RAPPORT FROM SPACE.
           WRITE F-DATA-RAPPORT FROM WS-DISPLAY-LI.
           WRITE F-DATA-RAPPORT FROM ID-NAME(WS-IDX).
           MOVE "Statut :" TO WS-DISPLAY-LI.
           WRITE  F-DATA-RAPPORT FROM SPACE.
           WRITE F-DATA-RAPPORT FROM WS-DISPLAY-LI.
           WRITE F-DATA-RAPPORT FROM STATUT(WS-IDX).
           WRITE F-DATA-RAPPORT FROM WS-TIRET.

            

         LIRE-FICHIER2.

      *    Même chose que fichier1.

           READ ASSU2 INTO F-DATA2.
           INSPECT F-DATA2 REPLACING ALL "*" BY " ".
           ADD 1 TO WS-COUNT.
           
           
           MOVE F-DATA2 TO ARRAY(WS-IDX).
           ADD NUMBER3(WS-IDX) TO TOTAL.
           MOVE "Actif" TO WS-INSPECT.
           INSPECT STATUT(WS-IDX) TALLYING WS-INSPECT-COUNT-A
           FOR ALL WS-INSPECT.
           MOVE "Resilie" TO WS-INSPECT.
           INSPECT STATUT(WS-IDX) TALLYING WS-INSPECT-COUNT-R
           FOR ALL WS-INSPECT.
           MOVE "Suspendu" TO WS-INSPECT.
           INSPECT STATUT(WS-IDX) TALLYING WS-INSPECT-COUNT-S
           FOR ALL WS-INSPECT.
          
           MOVE "ID:" TO WS-DISPLAY-LI.
           WRITE  F-DATA-RAPPORT FROM SPACE.
           WRITE F-DATA-RAPPORT FROM WS-DISPLAY-LI.
           WRITE F-DATA-RAPPORT FROM ID-NUM(WS-IDX).
           MOVE "IRP:" TO WS-DISPLAY-LI.
           WRITE  F-DATA-RAPPORT FROM SPACE.
           WRITE F-DATA-RAPPORT FROM WS-DISPLAY-LI.
           WRITE F-DATA-RAPPORT FROM LIBELLE(WS-IDX).
           MOVE "Société :" TO WS-DISPLAY-LI.
           WRITE  F-DATA-RAPPORT FROM SPACE.
           WRITE F-DATA-RAPPORT FROM WS-DISPLAY-LI.
           WRITE F-DATA-RAPPORT FROM DESCRIPTION(WS-IDX).
           MOVE "SIREN 1 :" TO WS-DISPLAY-LI.
           WRITE  F-DATA-RAPPORT FROM SPACE.
           WRITE F-DATA-RAPPORT FROM WS-DISPLAY-LI.
           WRITE F-DATA-RAPPORT FROM NUMBER1(WS-IDX).
           
           MOVE "SIREN 2 :" TO WS-DISPLAY-LI.
           WRITE  F-DATA-RAPPORT FROM SPACE.
           WRITE F-DATA-RAPPORT FROM WS-DISPLAY-LI.
           WRITE F-DATA-RAPPORT FROM NUMBER2(WS-IDX). 
            MOVE "Argent :" TO WS-DISPLAY-LI.
            WRITE  F-DATA-RAPPORT FROM SPACE.
           WRITE F-DATA-RAPPORT FROM WS-DISPLAY-LI.
           WRITE F-DATA-RAPPORT FROM NUMBER3(WS-IDX).
            MOVE "Libellé :" TO WS-DISPLAY-LI.
            WRITE  F-DATA-RAPPORT FROM SPACE.
           WRITE F-DATA-RAPPORT FROM WS-DISPLAY-LI.
           WRITE F-DATA-RAPPORT FROM ID-NAME(WS-IDX).
           MOVE "Statut :" TO WS-DISPLAY-LI.
           WRITE  F-DATA-RAPPORT FROM SPACE.
           WRITE F-DATA-RAPPORT FROM WS-DISPLAY-LI.
           WRITE F-DATA-RAPPORT FROM STATUT(WS-IDX).
           WRITE F-DATA-RAPPORT FROM WS-TIRET.

            