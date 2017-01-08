      SUBROUTINE RDMODX (FILE,MODE,WORD)        
C        
C     ENTRY POINTS - RDMODX (FILE ,MODE,WORD)        
C                    RDMODY (A    ,MODE,WORD)        
C                    RDMODE (*,*,*,MODE,WORD)        
C                    RDWORD (      MODE,WORD)        
C     RDMODX, RDMODE AND RDWORD CALLED BY PLOT, FIND, PARAM AND SETINP  
C     RDMODY CALLED ONLY BY PLOT        
C        
C     REVISED 10/10/92 BY G.CHAN/UNISYS        
C     THE ORIGINAL WAY PASSING 'FILE' AND ARRAY 'A' FROM RDMODX AND     
C     RDMODY ARE NOT ANSI FORTRAN77 STANDARD. THERE IS NO GUARANTY THAT 
C     RDMODE AND RDWORD WILL PICK THEM UP CORRECTLY. MODIFICATIONS HERE 
C     ARE (1) SAVE 'FILE' IN /XRDMOD/, AND (2) COMPUTE A REFERENCE      
C     POINTER, REFPTR, SUCH THAT ARRAY A IS ACCESSIBLE VIA ARRAY Z      
C        
      INTEGER         FILEX,CHECK1,CHECK2,BITSON,ENTRY,COMPLF,EOR,BLANK,
     1                FILE,REFPTR,Z,A(1),MODE(1),WORD(2),NAME(2),NEXT(2)
      COMMON /XRDMOD/ FILEX,REFPTR,CHECK1,CHECK2,BITSON,ENTRY        
CZZ   COMMON /XNSTRN/ Z(1)        
      COMMON /ZZZZZZ/ Z(1)        
      DATA    BLANK , EOR,NAME / 1H ,1000000, 4HRDMO,4HDX  /        
C        
C     -RDMODX- IS CALLED IF -MODE- IS TO BE READ FROM DATA SET -FILE-   
C        
      ENTRY  = 0        
      FILEX  = FILE        
      CHECK1 = 13579        
      GO TO 10        
C        
C        
      ENTRY RDMODY (A,MODE,WORD)        
C     ==========================        
C        
C     -RDMODY- IS CALLED IF -MODE- IS TO BE READ FROM THE -A- ARRAY     
C        
C     COMPUTE THE REFERENCE POINTER FROM Z(1) TO A(1), AND NEXT TIME    
C     WHEN A ARRAY IS USED, USE Z ARRAY WITH THE REFERENCE POINTER      
C        
      ENTRY  = 1        
      REFPTR = LOCFX(A(1)) - LOCFX(Z(1))        
      CHECK2 = 24680        
   10 BITSON = COMPLF(0)        
      RETURN        
C        
C        
      ENTRY RDMODE (*,*,*,MODE,WORD)        
C     ==============================        
C        
C     -RDMODE- IS CALLED TO READ -MODE-        
C     IF MODE = -4, THE NEXT TWO WORDS ARE READ INTO -WORD-        
C     IF MODE IS NEGATIVE AND NOT = -4, ONLY THE NEXT ONE WORD IS READ  
C     INTO -WORD-        
C     RETURN 1 - NUMERIC MODE (-MODE- NEGATIVE)        
C                -MODE- = -1, -WORD- IS INTEGER        
C                -MODE- = -2, -WORD- IS REAL NUMBER        
C                -MODE- = -3, -WORD- IS ZERO ?        
C                -MODE- = -4, -WORD- IS D.P.REAL        
C     RETURN 2 - ALPHABETIC MODE (-MODE- POSITIVE)        
C     RETURN 3 - END OF LOGICAL CARD (RECORD TERMINATED),        
C                -MODE- = 1000000        
C        
      IF (ENTRY .NE. 0) GO TO 80        
      IF (CHECK1 .NE. 13579) CALL MESAGE (-37,0,NAME)        
C        
   20 CALL FREAD (FILEX,MODE,1,0)        
      IF (MODE(1)) 70,30,40        
   30 CALL FREAD (FILEX,0,0,1)        
      GO TO 20        
   40 IF (MODE(1) .GE. EOR) GO TO 60        
   50 CALL FREAD (FILEX,NEXT,2,0)        
      IF (NEXT(1).NE.BITSON .AND. NEXT(1).NE.BLANK) RETURN 2        
      MODE(1) = MODE(1) - 1        
      IF (MODE(1)) 20,20,50        
   60 CALL FREAD (FILEX,0,0,1)        
      RETURN 3        
C        
   70 I = 1        
      IF (MODE(1) .EQ. -4) I = 2        
      CALL FREAD (FILEX,WORD,I,0)        
      RETURN 1        
C        
   80 IF (CHECK2 .NE. 24680) CALL MESAGE (-37,0,NAME)        
C     MODE(1) = A(ENTRY)        
      MODE(1) = Z(ENTRY+REFPTR)        
      ENTRY   = ENTRY + 1        
      IF (MODE(1)) 120,80,90        
   90 IF (MODE(1) .GE. EOR) GO TO 110        
C 100 NEXT(1) = A(ENTRY+0)        
C     NEXT(2) = A(ENTRY+1)        
  100 NEXT(1) = Z(ENTRY+0+REFPTR)        
      NEXT(2) = Z(ENTRY+1+REFPTR)        
      ENTRY   = ENTRY + 2        
      IF (NEXT(1).NE.BITSON .AND. NEXT(1).NE.BLANK) RETURN 2        
      MODE(1) = MODE(1) - 1        
      IF (MODE(1)) 80,80,100        
  110 ENTRY   = ENTRY + 1        
      RETURN 3        
C        
C 120 WORD(1) = A(ENTRY)        
  120 WORD(1) = Z(ENTRY+REFPTR)        
      ENTRY   = ENTRY + 1        
      IF (MODE(1) .NE. -4) RETURN 1        
C     WORD(2) = A(ENTRY)        
      WORD(2) = Z(ENTRY+REFPTR)        
      ENTRY   = ENTRY + 1        
      RETURN 1        
C        
C        
      ENTRY RDWORD (MODE,WORD)        
C     ========================        
C        
C     -RDWORD- IS CALLED TO READ TWO BCD WORDS INTO -WORD-        
C     NOTE - ALL DATA FIELD DELIMITERS ARE SKIPPED        
C        
      WORD(1) = NEXT(1)        
      WORD(2) = NEXT(2)        
  130 MODE(1) = MODE(1) - 1        
      IF (MODE(1) .LE. 0) GO TO 160        
      IF (ENTRY   .NE. 0) GO TO 140        
      IF (CHECK1  .NE. 13579) CALL MESAGE (-37,0,NAME)        
      CALL FREAD (FILEX,NEXT,2,0)        
      GO TO 150        
C        
  140 IF (CHECK2 .NE. 24680) CALL MESAGE (-37,0,NAME)        
C     NEXT(1) = A(ENTRY  )        
C     NEXT(2) = A(ENTRY+1)        
      NEXT(1) = Z(ENTRY  +REFPTR)        
      NEXT(2) = Z(ENTRY+1+REFPTR)        
      ENTRY   = ENTRY + 2        
  150 IF (NEXT(1).EQ.BITSON .OR. NEXT(1).EQ.BLANK) GO TO 130        
  160 RETURN        
      END        
