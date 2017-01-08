      SUBROUTINE DSTROY (NAME,ITEST,IMAGE,IMORE,LIM)        
C        
C     DESTROYS THE SUBSTRUCTURE NAME BY DELETING ITS DIRECTORY FROM THE 
C     MDI AND ITS NAME FROM THE DIT.  NO OPERATION WILL TAKE PLACE IF   
C     NAME IS AN IMAGE SUBSTRUCTURE.  IF NAME IS A SECONDARY SUBSTRUC-  
C     TURE, IT IS DELETED FROM THE LIST OF SECONDARY SUBSTRUCTURES TO   
C     WHICH IT BELONGS, AND ITS IMAGE CONTRIBUTING TREE IS DESTROYED.   
C     IF NAME IS A PRIMARY SUBSTRUCTURE, ALL ITS SECONDARY SUBSTRUCTURES
C     ARE ALSO DESTROYED.  IN ALL CASES, ALL THE SUBSTRUCTURES DERIVED  
C     FROM THE SUBSTRUCTURE BEING DESTROYED ARE ALSO DESTROYED, AND     
C     CONNECTIONS WITH OTHER SUBSTRUCTURES ARE DELETED.        
C        
C     THE BLOCKS OCCUPIED BY THE ITEM ARE RETURNED TO THE LIST OF FREE  
C     BLOCKS IF THEY BELONG TO THE SPECIFIED SUBSTRUCTURE        
C        
C     THE OUTPUT VARIABLE ITEST TAKES ONE OF THE FOLLOWING VALUES.      
C        1  NORMAL RETURN        
C        4  IF NAME DOES NOT EXIST        
C        6  IF NAME IS AN IMAGE SUBSTRUCTURE        
C        
      EXTERNAL        LSHIFT,RSHIFT,ANDF,ORF,COMPLF        
      LOGICAL         DITUP,MDIUP        
      INTEGER         BUF,DIT,DITPBN,DITLBN,DITSIZ,DITNSB,DITBL,        
     1                MDI,MDIPBN,MDILBN,MDIBL,BLKSIZ,DIRSIZ,PS,SS,IS,   
     2                LL,CS,HL,ANDF,ORF,RSHIFT,COMPLF        
      DIMENSION       NAME(2),IMAGE(1),IMORE(1),NMSBR(2)        
CZZ   COMMON /SOFPTR/ BUF(1)        
      COMMON /ZZZZZZ/ BUF(1)        
      COMMON /SOF   / DIT,DITPBN,DITLBN,DITSIZ,DITNSB,DITBL,        
     1                IODUM(8),MDI,MDIPBN,MDILBN,MDIBL,        
     2                NXTDUM(15),DITUP,MDIUP        
      COMMON /SYS   / BLKSIZ,DIRSIZ,SYS(3),IFRST        
      COMMON /ITEMDT/ NITEM,ITEM(7,1)        
      DATA    PS,SS,  IS,LL,CS,HL / 1,1,1,2,2,2    /        
      DATA    IEMPTY/ 4H    /        
      DATA    INDSBR/ 3     /, NMSBR /4HDSTR,4HOY  /        
C        
      CALL CHKOPN (NMSBR(1))        
      ITEST = 1        
      ITOP  = 0        
      IMTOP = 0        
      CALL FDSUB (NAME(1),INDEX)        
      IF (INDEX .EQ. -1) GO TO 1000        
      MASKM = COMPLF(LSHIFT(1023,10))        
      MASKL = COMPLF(LSHIFT(1023,20))        
C                           1023 = 2**10 - 1        
C        
C     SAVE ALL CONNECTIONS WITH OTHER SUBSTRUCTURES.        
C        
   10 CALL FMDI (INDEX,IMDI)        
   20 I     = BUF(IMDI+PS)        
      INDPS = ANDF(I,1023)        
      INDSS = RSHIFT(ANDF(I,1048575),10)        
C                           1048575 = 2**20 - 1        
      INDIS = ANDF(I,1073741824)        
C                    1073741824 = 2**30        
      I     = BUF(IMDI+LL)        
      INDHL = ANDF(I,1023)        
      INDCS = RSHIFT(ANDF(I,1048575),10)        
      INDLL = RSHIFT(ANDF(I,1073741823),20)        
C                           1073741823 = 2**30 - 1        
      IF (INDIS .GT. 0) GO TO 1010        
      IF (INDPS .EQ. 0) GO TO 60        
      ASSIGN 30 TO IRET1        
      GO TO 300        
C        
C     REMOVE INDEX FROM THE LIST OF SUBSTRUCTURES THAT ARE SECONDARY TO 
C     INDPS.        
C        
   30 ISAVE = INDPS        
   40 CALL FMDI (ISAVE,IMDI)        
      ISAVE = RSHIFT(ANDF(BUF(IMDI+SS),1048575),10)        
      IF (ISAVE .EQ. 0) GO TO 50        
      IF (ISAVE .NE. INDEX) GO TO 40        
      BUF(IMDI+SS) = ORF(ANDF(BUF(IMDI+SS),MASKM),LSHIFT(INDSS,10))     
      MDIUP = .TRUE.        
      IF (INDLL .EQ. 0) GO TO 120        
      ILL   = INDLL        
      INDLL = 0        
      ISAVE = INDEX        
   50 ASSIGN 120 TO IRET2        
      GO TO 330        
C        
C     PRIMARY SUBSTRUCTURE.        
C     RETURN THE BLOCKS USED BY ALL ITEMS TO THE LIST OF FREE BLOCKS.   
C        
   60 DO 70 J = IFRST,DIRSIZ        
      IBL = ANDF(BUF(IMDI+J),65535)        
C                            65535 = 2**16 - 1        
      IF (IBL.GT.0 .AND. IBL.NE.65535) CALL RETBLK (IBL)        
   70 CONTINUE        
      IF (INDSS .EQ. 0) GO TO 130        
C        
C     THE PRIMARY SUBSTRUCTURE BEING DESTROYED HAS SECONDARY EQUIVALENT 
C     SUBSTRUCTURES.  MUST DESTROY ALL OF THEM.        
C        
      ASSIGN 320 TO IRET1        
      ASSIGN 90  TO IRET2        
      ISV   = INDSS        
   80 ISAVE = ISV        
      CALL FMDI (ISAVE,IMDI)        
      ISV = RSHIFT(ANDF(BUF(IMDI+SS),1048575),10)        
      IIS = ANDF(BUF(IMDI+IS),1073741824)        
      IF (IIS .GT. 0) GO TO 110        
C        
C     THE SECONDARY SUBSTRUCTURE IS NOT AN IMAGE SUBSTRUCTURE.  ADD ITS 
C     INDEX TO THE LIST (IMORE) OF SUBSTRUCTURES TO BE DESTROYED LATER. 
C        
      ITOP = ITOP + 1        
      IF (ITOP .GT. LIM) GO TO 1030        
      IMORE(ITOP) = ISAVE        
      GO TO 300        
C        
C     UPDATE THE MDI OF THE SECONDARY SUBSTRUCTURE WITH INDEX ISAVE.    
C        
   90 CALL FMDI (ISAVE,IMDI)        
      BUF(IMDI+PS) = 0        
      BUF(IMDI+LL) = ANDF(BUF(IMDI+LL),MASKL)        
      DO 100 J = IFRST,DIRSIZ        
      BUF(IMDI+J) = 0        
  100 CONTINUE        
      MDIUP = .TRUE.        
  110 IF (ISV .NE. 0) GO TO 80        
C        
C     BACK TO THE SUBSTRUCTURE WITH INDEX  INDEX .        
C     DELETE ITS DIRECTORY FROM THE MDI.        
C        
  120 CALL FMDI (INDEX,IMDI)        
  130 DO 140 J = 1,DIRSIZ        
      BUF(IMDI+J) = 0        
  140 CONTINUE        
      MDIUP = .TRUE.        
C        
C     DELETE SUBSTRUCTURE NAME FROM THE DIT.        
C        
      CALL FDIT (INDEX,JDIT)        
      BUF(JDIT  ) = IEMPTY        
      BUF(JDIT+1) = IEMPTY        
      DITUP = .TRUE.        
      IF (INDEX*2 .NE. DITSIZ) GO TO 150        
      DITSIZ = DITSIZ - 2        
  150 DITNSB = DITNSB - 1        
      IF (INDCS .EQ. 0) GO TO 180        
C        
C     DELETE LINK THROUGH COMBINED SUBSTRUCTURES, AND REMOVE ITEMS      
C     CREATED AS A RESULTS OF THE COMBINE OR REDUCE.        
C     THESE ITEMS WILL BE RETURNED TO THE LIST OF FREE BLOCKS.        
C        
  160 IF (INDCS .EQ. INDEX) GO TO 180        
      CALL FMDI (INDCS,IMDI)        
      INDCS = RSHIFT(ANDF(BUF(IMDI+CS),1048575),10)        
  173 BUF(IMDI+HL) = ANDF(BUF(IMDI+HL),COMPLF(1023))        
      BUF(IMDI+CS) = ANDF(BUF(IMDI+CS),MASKM)        
      DO 176 J = 1,NITEM        
      IF (ITEM(6,J) .EQ. 0) GO TO 176        
      ITM = J + IFRST - 1        
      IBL = ANDF(BUF(IMDI+ITM),65535)        
      IF (IBL.GT.0 .AND. IBL.NE.65535) CALL RETBLK (IBL)        
      BUF(IMDI+ITM) = 0        
  176 CONTINUE        
      MDIUP = .TRUE.        
      IF (INDCS .EQ. 0) GO TO 1020        
      GO TO 160        
  180 IF (INDLL .EQ. 0) GO TO 190        
C        
C     SUBSTRUCTURE WAS THE RESULT OF COMBINING LOWER LEVEL SUBSTRUCTURES
C     TOGETHER.  UPDATE THE MDI ACCORDINGLY.        
C        
      CALL FMDI (INDLL,IMDI)        
      INDCS = RSHIFT(ANDF(BUF(IMDI+CS),1048575),10)        
      INDEX = INDLL        
      INDLL = 0        
      IF (INDCS .EQ. 0) INDCS = INDEX        
      GO TO 173        
  190 IF (INDHL .EQ. 0) GO TO 220        
C        
C     A HIGHER LEVEL SUBSTRUCTURE WAS DERIVED FROM THE ONE BEING        
C     DESTROYED. DESTROY THE HIGHER LEVEL SUBSTRUCTURE.        
C        
      INDEX = INDHL        
      CALL FMDI (INDEX,IMDI)        
      BUF(IMDI+LL) = ANDF(BUF(IMDI+LL),MASKL)        
      MDIUP = .TRUE.        
      GO TO 20        
  220 IF (ITOP .EQ. 0) RETURN        
C        
C     MORE SUBSTRUCTURES TO DESTROY.        
C        
      INDEX = IMORE(ITOP)        
      ITOP  = ITOP - 1        
      GO TO 10        
C        
C     INTERNAL SUBROUTINE.        
C     RETURN TO THE LIST OF FREE BLOCKS THE BLOCKS USED BY A        
C     SECONDARY SUBSTRUCTURE.        
C     THESE BLOCKS INCLUDE THE FOLLOWING ITEMS        
C        
C     ITEMS COPIED DURING A EQUIV OPERATION        
C     SOLUTION ITEMS        
C     ITEMS PRODUCED BY A COMBINE OR REDUCE OPERATION        
C        
  300 DO 310 J = 1,NITEM        
      IF (ITEM(5,J) .EQ. 0) GO TO 310        
      ITM = J + IFRST - 1        
      IBL = ANDF(BUF(IMDI+ITM),65535)        
      IF (IBL.GT.0 .AND. IBL.NE.65535) CALL RETBLK (IBL)        
      BUF(IMDI+ITM) = 0        
  310 CONTINUE        
      GO TO IRET1, (30,320)        
C        
C     INTERNAL SUBROUTINE.        
C     BUILD A LIST IMAGE OF ALL THE IMAGE SUBSTRUCTURES CONTRIBUTING TO 
C     THE SECONDARY SUBSTRUCTURE WITH INDEX ISAVE, AND DELETE EACH IMAGE
C     SUBSTRUCTURE FROM THE LIST OF SECONDARY SUBSTRUCTURES TO WHICH IT 
C     BELONGS.        
C        
  320 CALL FMDI (ISAVE,IMDI)        
      ILL = RSHIFT(ANDF(BUF(IMDI+LL),1073741823),20)        
      IF (ILL .EQ. 0) GO TO IRET2, (90,120)        
  330 IMTOP = 1        
      IMAGE(IMTOP) = ILL        
      ICOUNT = 1        
      IHERE  = IMAGE(ICOUNT)        
  350 CALL FMDI (IHERE,IMDI)        
      I   = BUF(IMDI+PS)        
      IPS = ANDF(I,1023)        
      ISS = RSHIFT(ANDF(I,1048575),10)        
      IIS = ANDF(I,1073741824)        
      I   = BUF(IMDI+LL)        
      ILL = RSHIFT(ANDF(I,1073741823),20)        
      ICS = RSHIFT(ANDF(I,1048575),10)        
      IF (IIS .EQ. 0) GO TO 1010        
C        
C     DELETE THE SUBSTRUCTURE WITH INDEX IHERE FROM THE MDI AND THE DIT.
C     RETURN THE BLOCKS USED BY THE IMAGE SUBSTRUCTURE TO THE LIST OF   
C     FREE BLOCKS.  THIS INCLUDES THE FOLLOWING ITEMS        
C        
C     ITEMS COPIED DURING A EQUIV OPERATION        
C     SOLUTION ITEMS        
C        
      DO 355 J = 1,NITEM        
      IF (ITEM(4,J) .EQ. 0) GO TO 355        
      ITM = J + IFRST - 1        
      IBL = ANDF(BUF(IMDI+ITM),65535)        
      IF (IBL.GT.0 .AND. IBL.NE.65535) CALL RETBLK (IBL)        
      BUF(IMDI+ITM) = 0        
  355 CONTINUE        
      DO 360 J = 1,DIRSIZ        
      BUF(IMDI+J) = 0        
  360 CONTINUE        
      MDIUP = .TRUE.        
      CALL FDIT (IHERE,IDIT)        
      BUF(IDIT  ) = IEMPTY        
      BUF(IDIT+1) = IEMPTY        
      DITUP = .TRUE.        
      IF (IHERE*2 .NE. DITSIZ) GO TO 370        
      DITSIZ = DITSIZ - 2        
  370 DITNSB = DITNSB - 1        
C        
C     DELETE POINTERS TO IHERE.        
C        
      ICHECK = IPS        
  380 CALL FMDI (ICHECK,IMDI)        
      ICHECK = RSHIFT(ANDF(BUF(IMDI+SS),1048575),10)        
      IF (ICHECK .EQ. 0) GO TO 390        
      IF (ICHECK .NE. IHERE) GO TO 380        
      BUF(IMDI+SS) = ORF(ANDF(BUF(IMDI+SS),MASKM),LSHIFT(ISS,10))       
      MDIUP = .TRUE.        
C        
C     ARE THERE MORE SUBSTRUCTURES TO ADD TO THE LIST IMAGE        
C        
  390 IF (ILL .EQ. 0) GO TO 410        
      DO 400 J = 1,IMTOP        
      IF (IMAGE(J) .EQ. ILL) GO TO 410        
  400 CONTINUE        
      IMTOP = IMTOP + 1        
      IMAGE(IMTOP) = ILL        
  410 IF (ICS .EQ. 0) GO TO 430        
      DO 420 J = 1,IMTOP        
      IF (IMAGE(J) .EQ. ICS) GO TO 430        
  420 CONTINUE        
      IMTOP = IMTOP + 1        
      IF (IMTOP .GT. LIM) GO TO 1030        
      IMAGE(IMTOP) = ICS        
C        
C     ARE THERE MORE SUBSTRUCTURES ON THE LIST IMAGE        
C        
  430 IF (ICOUNT .EQ. IMTOP) GO TO IRET2, (90,120)        
      ICOUNT = ICOUNT + 1        
      IHERE  = IMAGE(ICOUNT)        
      GO TO 350        
C        
C     NAME DOES NOT EXIST.        
C        
 1000 ITEST = 4        
      RETURN        
C        
C     NAME IS AN IMAGE SUBSTRUCTURE.        
C        
 1010 ITEST = 6        
      RETURN        
C        
C     ERROR MESSAGES.        
C        
 1020 CALL ERRMKN (INDSBR,8)        
 1030 CALL MESAGE (-8,0,NMSBR)        
      RETURN        
      END        
