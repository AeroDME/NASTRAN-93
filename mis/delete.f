      SUBROUTINE DELETE (NAME,ITEMX,ITEST)        
C        
C     DELETES ITEM WHICH BELONGS TO THE SUBSTRUCTURE NAME.  THE MDI IS  
C     UPDATED ACCORDINGLY AND THE BLOCKS ON WHICH ITEM WAS WRITTEN ARE  
C     RETURNED TO THE LIST OF FREE BLOCKS.  ITEST IS AN OUTPUT PARAMETER
C     WHICH TAKES ON ONE OF THE FOLLOWING VALUES        
C        
C              1  IF ITEM DOES EXIST        
C              2  IF ITEM PSEUDO-EXISTS        
C              3  IF ITEM DOES NOT EXIST        
C              4  IF NAME DOES NOT EXIST        
C              5  IF ITEM IS AN ILLEGAL ITEM NAME        
C        
C     THE BLOCKS OCCUPIED BY THE ITEM ARE RETURNED TO THE LIST OF FREE  
C     BLOCKS IF THEY BELONG TO THE SPECIFIED SUBSTRUCTURE        
C        
C        
      EXTERNAL        RSHIFT,ANDF        
      LOGICAL         MDIUP        
      INTEGER         BUF,MDI,MDIPBN,MDILBN,MDIBL,BLKSIZ,DIRSIZ,PS,SS,  
     1                ANDF,RSHIFT        
      DIMENSION       NAME(2),NMSBR(2)        
CZZ   COMMON /SOFPTR/ BUF(1)        
      COMMON /ZZZZZZ/ BUF(1)        
      COMMON /SOF   / DITDUM(6),IODUM(8),MDI,MDIPBN,MDILBN,MDIBL,       
     1                NXTDUM(15),DITUP,MDIUP        
      COMMON /SYS   / BLKSIZ,DIRSIZ,SYS(3),IFRST        
      COMMON /ITEMDT/ NITEM,ITEM(7,1)        
      DATA    IS,PS , SS/ 1,1,1    /        
      DATA    NMSBR / 4HDELE,4HTE  /        
C        
      CALL CHKOPN (NMSBR(1))        
      CALL FDSUB  (NAME(1),K)        
      IF (K .EQ. -1) GO TO 500        
      CALL FMDI (K,IMDI)        
      II  = ITCODE(ITEMX)        
      IF (II .EQ. -1) GO TO 510        
      ITM = II - IFRST + 1        
      IBL = ANDF(BUF(IMDI+II),65535)        
C                             55535 = 2**16 - 1        
      IF (IBL .NE. 0) GO TO 10        
C        
C     ITEM DOES NOT EXIST.        
C        
      ITEST = 3        
      RETURN        
C        
   10 BUF(IMDI+II) = 0        
      MDIUP = .TRUE.        
      IF (IBL .NE. 65535) GO TO 20        
C        
C     ITEM PSEUDO-EXISTS.        
C        
      ITEST = 2        
      GO TO 30        
C        
C     ITEM DOES EXIST.        
C        
   20 ITEST = 1        
   30 IF (ANDF(BUF(IMDI+IS),1073741824) .EQ. 0) GO TO 35        
C                           1073741824 = 2**30        
C        
C     IMAGE SUBSTRUCTURE        
C        
      IF (ITEST .NE. 1) RETURN        
      IF (ITEM(4,ITM) .EQ. 0) GO TO 32        
      CALL RETBLK (IBL)        
   32 RETURN        
C        
C     NAME IS A SECONDARY OR A PRIMARY SUBSTRUCTURE        
C        
   35 ISVPS = ANDF(BUF(IMDI+PS),1023)        
C                               1023 = 2**10 - 1        
      IF (ISVPS .EQ. 0) GO TO 39        
C        
C     SECONDARY SUBSTRUCTURE        
C        
      IF (ITEST .NE. 1) RETURN        
      IF (ITEM(5,ITM) .EQ. 0) GO TO 37        
      CALL RETBLK (IBL)        
   37 RETURN        
C        
C     PRIMARY SUBSTRUCTURE        
C        
   39 IF (ITEST .EQ. 1) CALL RETBLK (IBL)        
   40 ISVSS = RSHIFT(ANDF(BUF(IMDI+SS),1048575),10)        
C                                      1048575 = 2*20 - 1        
      IF (ISVSS .EQ. 0) RETURN        
      CALL FMDI (ISVSS,IMDI)        
      IF (ANDF(BUF(IMDI+II),65535) .NE. IBL) GO TO 40        
      BUF(IMDI+II) = 0        
      MDIUP = .TRUE.        
      GO TO 40        
C        
C     NAME DOES NOT EXIST.        
C        
  500 ITEST = 4        
      RETURN        
C        
C     ITEM IS AN ILLEGAL ITEM NAME.        
C        
  510 ITEST = 5        
      RETURN        
      END        
