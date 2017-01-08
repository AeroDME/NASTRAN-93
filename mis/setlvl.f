      SUBROUTINE SETLVL (NEWNM,NUMB,OLDNMS,ITEST,IBIT)        
C        
C     CREATES A NEW SUBSTRUCTURE NEWNM WHERE        
C     - NEWNM IS AN INDEPENDENT SUBSTRUCTURE IF NUMB = 0        
C     - NEWNM IS REDUCED FROM THE FIRST SUBSTRUCTURE IN THE ARRAY OLDNMS
C     - NEWNM RESULTS FROM COMBINING THE FIRST I SUBSTRUCTURES IN THE   
C       ARRAY OLDNMS IF NUMB = I        
C        
C     THE OUTPUT VARIABLE ITEST TAKES ON ONE OF THE FOLLOWING VALUES    
C          4  IF ONE  OR MORE SUBSTRUCTURES IN OLDNMS DO NOT EXIST      
C          7  IF NEWNM ALREADY EXISTS        
C          8  IF ONE OF THE SUBSTRUCTURES IN OLDNMS HAS ALREADY        
C             BEEN USED IN A REDUCTION OR COMBINATION        
C          1  OTHERWISE        
C        
C     IF ITEST IS SET TO 4, NUMB WILL BE SET TO THE NUMBER OF        
C     SUBSTRUCTURES IN OLDNMS THAT DO NOT EXIST AND THE FIRST NUMB NAMES
C     IN OLDNMS WILL BE SET TO THE NAMES OF THOSE SUBSTRUCTURES THAT DO 
C     NOT EXIST.  BIT IBIT OF THE FIRST MDI WORD IS SET TO INDICATE THE 
C     APPROPRIATE TYPE OF SUBSTRUCTURE. IF IBIT IS ZERO NO CHANGE IS    
C     MADE TO THE MDI        
C        
      IMPLICIT INTEGER (A-Z)        
      EXTERNAL        LSHIFT,ANDF,ORF,COMPLF        
      LOGICAL         DITUP,MDIUP        
      DIMENSION       NEWNM(2),OLDNMS(14),IOLD(7),NMSBR(2)        
CZZ   COMMON /SOFPTR/ BUF(1)        
      COMMON /ZZZZZZ/ BUF(1)        
      COMMON /SOF   / DIT,DITPBN,DITLBN,DITSIZ,DITNSB,DITBL,        
     1                IODUM(8),MDI,MDIPBN,MDILBN,MDIBL,        
     2                NXTDUM(15),DITUP,MDIUP        
      DATA    IEMPTY/ 4H    /, NMSBR / 4HSETL,4HVL  /        
      DATA    LL,CS , HL    /  2,2,2 /        
      DATA    IB    / 1     /        
C        
      CALL CHKOPN (NMSBR(1))        
      ITEST = 1        
      CALL FDSUB (NEWNM(1),I)        
      IF (I  .NE.  -1) GO TO 500        
      IF (NUMB .EQ. 0) GO TO 20        
C        
C     MAKE SURE THAT ALL THE SUBSTRUCTURES IN OLDNMS DO EXIST.        
C        
      ICOUNT = 0        
      DO 10 I = 1,NUMB        
      K = 2*(I-1) + 1        
      CALL FDSUB (OLDNMS(K),IOLD(I))        
      IF (IOLD(I) .GT. 0) GO TO 10        
      ICOUNT = ICOUNT + 1        
      KK = 2*(ICOUNT-1) + 1        
      OLDNMS(KK  ) = OLDNMS(K  )        
      OLDNMS(KK+1) = OLDNMS(K+1)        
   10 CONTINUE        
      IF (ICOUNT .EQ. 0) GO TO 20        
      NUMB = ICOUNT        
      GO TO 510        
   20 CALL CRSUB (NEWNM(1),INEW)        
      IF (NUMB .EQ. 0) RETURN        
C        
C     NEWNM IS NOT A BASIC SUBSTRUCTURE (LEVEL 0).        
C     UPDATE NEWNM S DIRECTORY IN THE MDI.        
C        
      CALL FMDI (INEW,IMDI)        
      LLMASK = COMPLF(LSHIFT(1023,20))        
      BUF(IMDI+LL) = ORF(ANDF(BUF(IMDI+LL),LLMASK),LSHIFT(IOLD(1),20))  
      IF (IBIT .NE. 0) BUF(IMDI+IB) = ORF(BUF(IMDI+IB),LSHIFT(1,IBIT))  
      MDIUP = .TRUE.        
C        
C     UPDATE IN THE MDI THE DIRECTORIES OF THE SUBSTRUCTURES IN OLDNMS. 
C        
      IF (NUMB .GT. 7) NUMB = 7        
      MASKCS = COMPLF(LSHIFT(1023,10))        
      DO 50 I = 1,NUMB        
      CALL FMDI (IOLD(I),IMDI)        
      IF (ANDF(BUF(IMDI+HL),1023) .EQ. 0) GO TO 40        
      ICOUNT = I        
      GO TO 520        
   40 BUF(IMDI+HL) = ORF(BUF(IMDI+HL),INEW)        
      MDIUP = .TRUE.        
      IF (NUMB .EQ. 1) RETURN        
      IF (I .EQ. NUMB) GO TO 130        
      BUF(IMDI+CS) = ORF(ANDF(BUF(IMDI+CS),MASKCS),LSHIFT(IOLD(I+1),10))
   50 CONTINUE        
  130 BUF(IMDI+CS) = ORF(ANDF(BUF(IMDI+CS),MASKCS),LSHIFT(IOLD(1),10))  
      RETURN        
C        
C     NEWNM ALREADY EXISTS.        
C        
  500 ITEST = 7        
      RETURN        
C        
C     ONE OR MORE OF THE SUBSTRUCTURES IN OLDNMS DO NOT EXIST.        
C        
  510 ITEST = 4        
      RETURN        
C        
C     ONE OF THE SUBSTRUCTURES IN OLDNMS HAS ALREADY BEEN USED IN A     
C     REDUCTION OR COMBINATION.  REMOVE ALL CHANGES THAT HAVE BEEN MADE.
C        
  520 ITEST = 8        
      CALL FDIT (INEW,IDIT)        
      BUF(IDIT  ) = IEMPTY        
      BUF(IDIT+1) = IEMPTY        
      DITUP = .TRUE.        
      IF (2*INEW .NE. DITSIZ) GO TO 525        
      DITSIZ = DITSIZ - 2        
  525 DITNSB = DITNSB - 1        
      CALL FMDI (INEW,IMDI)        
      BUF(IMDI+LL) = ANDF(BUF(IMDI+LL),LLMASK)        
      MDIUP  = .TRUE.        
      ICOUNT = ICOUNT - 1        
      IF (ICOUNT .LT. 1) RETURN        
      DO 530 I = 1,ICOUNT        
      CALL FMDI (IOLD(I),IMDI)        
      BUF(IMDI+HL) = ANDF(BUF(IMDI+HL),COMPLF(1023))        
      BUF(IMDI+CS) = ANDF(BUF(IMDI+CS),MASKCS)        
      MDIUP = .TRUE.        
  530 CONTINUE        
      RETURN        
      END        
