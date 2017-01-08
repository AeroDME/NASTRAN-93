      SUBROUTINE GKAD        
C        
C     GENERAL K ASSEMBLER DIRECT        
C        
C     INPUT = 10,  USETD,GM,GO,KAA,BAA,MAA,K4AA,K2PP,M2PP,B2PP        
C     OUTPUT = 8,  KDD,BDD,MDD,GMD,GOD,K2DD,M2DD,B2DD        
C     SCRATCHES = 6        
C     PARAMETERS 3 BCD, 3 REAL, 11 INTERGER        
C     - TYPE,APP,FORM, G,W3,W4, NOK2PP,MOM2PP,NOB2PP,MULTI,SINGLE,OMIT, 
C       NOUE,NOK4GG,NOBGG,NOKMGG,MODACC        
C        
C        
      INTEGER         TYPE(2),APP(2),FORM(2),IBLOCK(11),BLCK(12),MCB(7),
     1                TRAN,FORC,OMIT,BAA,B2PP,B2DD,B1DD,SCR1,SCR2,SCR3, 
     2                SCR4,SCR5,SCR6,GM,GO,GOD,GMD,BDD,USETD,SINGLE     
      DOUBLE PRECISION BLOCK(5)        
      COMMON /BLANK / TYPE,APP,FORM, G,W3,W4, IK2PP,IM2PP,IB2PP,MULTI,  
     1                SINGLE,OMIT,NOUE,NOK4GG,NOBGG,NOKMGG,MODACC       
      COMMON /BITPOS/ UM,UO,UR,USG,USB,UL,UA,UF,US,UN,UG,UE,UP,UNE,UFE, 
     1                UD        
      EQUIVALENCE     (IBLOCK(1),BLCK(2)),(BLOCK(1),BLCK(3))        
      DATA    USETD , GM, GO, KAA,BAA,MAA,K4AA,K2PP,M2PP,B2PP /        
     1        101   , 102,103,104,105,106,107, 108, 109, 110  /        
      DATA    KDD   , BDD,MDD,GMD,GOD,K2DD,M2DD,B2DD /        
     1        201   , 202,203,204,205,206, 207, 208  /        
      DATA    SCR1  , SCR2,SCR3,SCR4,SCR5,SCR6 /        
     1        301   , 302, 303, 304, 305, 306  /        
      DATA    FORC  , TRAN,MODAL / 4HFORC,4HTRAN,4HMODA     /        
      DATA    BLOCK(1),BLOCK(2),BLOCK(4),BLOCK(5),IBLOCK(1),IBLOCK(7) / 
     1        1.0D0 , 0.0D0,    1.0D0,   0.0D0,   2,        2         / 
      DATA    XNUM  , MCB / 1.0,7*0  /  ,IBLOCK(6) /    -1  /        
C        
C        
      KDD   = 201        
      BDD   = 202        
      MDD   = 203        
      K2DD  = 206        
      M2DD  = 207        
      B2DD  = 208        
      K1DD  = 302        
      M1DD  = 303        
      B1DD  = 304        
      K41DD = 305        
      SCR3  = 303        
      SCR4  = 304        
      IF (NOUE .GT. 0) GO TO 10        
C        
C     NO E-S A = 1DD        
C        
      K1DD  = KAA        
      B1DD  = BAA        
      M1DD  = MAA        
      K41DD = K4AA        
   10 IF (TYPE(1) .EQ. TRAN) GO TO 20        
C        
C     COMPLEX EIGENVALUE OR FREQUENCY RESPONSE - SET UP FOR FINAL ADD   
C        
      IF (IB2PP .LT. 0) B1DD = BDD        
      IF (IM2PP .LT. 0) M1DD = MDD        
      GO TO 50        
C        
C     TRANSIENT ANALYSIS - SETUP FOR FINAL ADD        
C        
   20 IF (IK2PP .LT. 0) K1DD = KDD        
      IF (IM2PP .LT. 0) M1DD = MDD        
      IF (W3 .NE.  0.0) GO TO 30        
      G  = 0.0        
      W3 = 1.0        
   30 IF (W4 .NE. 0.0) GO TO 50        
      W4   = 1.0        
      XNUM = 0.0        
   50 IF (APP(1) .NE. FORC) GO TO 60        
C        
C     FORCE APPROACH P = D        
C        
      K2DD = K2PP        
      B2DD = B2PP        
      M2DD = M2PP        
      GO TO 140        
C        
C     DISPLACEMENT APPROACH - REDUCE P TO D        
C        
C     IF MODAL DO NOT MAKE KDD AND BDD        
C        
   60 IF (FORM(1) .NE. MODAL) GO TO 70        
      KDD  = 0        
      K1DD = 0        
      BDD  = 0        
      B1DD = 0        
   70 IF (NOUE .LT. 0) GO TO 100        
C        
C     BUILD GMD AND GOD        
C        
C     M-S PRESENT        
C        
      IF (MULTI .GE. 0) CALL GKAD1A (USETD,GM,GMD,SCR1,UE,UN,UNE)       
C        
C     0-S PRESENT        
C        
      IF (OMIT .GE. 0) CALL GKAD1A (USETD,GO,GOD,SCR1,UE,UA,UD)        
C        
  100 IF (MULTI.LT.0 .AND. SINGLE.LT.0 .AND. OMIT .LT.0) GO TO 130      
      IF (IM2PP.LT.0 .AND. IB2PP .LT.0 .AND. IK2PP.LT.0) GO TO 130      
C        
C     REDUCE 2PP-S TO 2DD-S        
C        
      CALL GKAD1C (GMD,GOD,SCR1,SCR2,SCR3,SCR4,SCR5,SCR6,USETD)        
      IF (IK2PP .GE. 0) CALL GKAD1D (K2PP,K2DD)        
      IF (IM2PP .GE. 0) CALL GKAD1D (M2PP,M2DD)        
      IF (IB2PP .GE. 0) CALL GKAD1D (B2PP,B2DD)        
  130 IF (FORM(1).EQ.MODAL .AND. MODACC.LT.0) GO TO 180        
      IF (NOUE .LT. 0) GO TO 140        
C        
C     EXPAND AA-S TO DD SET        
C        
      CALL GKAD1B (USETD,KAA,MAA,BAA,K4AA,K1DD,M1DD,B1DD,K41DD,UA,UE,   
     1             UD,SCR1)        
  140 IF (TYPE (1) .EQ. TRAN) GO TO 190        
C        
C     FREQUENCY RESPONSE OR COMPLEX EIGENVALUE        
C        
      IF (B1DD.EQ.BDD .OR. NOBGG.LT.0 .OR. FORM(1).EQ.MODAL) GO TO 150  
      CALL SSG2C (B1DD,B2DD,BDD,1,IBLOCK(1))        
  150 IF (M1DD.EQ.MDD .OR. NOKMGG.LT.0) GO TO 160        
      CALL SSG2C (M1DD,M2DD,MDD,1,IBLOCK(1))        
  160 IF (K1DD.EQ.KDD .OR. FORM(1).EQ.MODAL .OR. NOKMGG.LT.0) GO TO 180 
      IBLOCK(1) = 4        
      BLOCK(2)  = G        
      IF (NOK4GG .LT. 0) SCR4 = KDD        
C        
C     DETERMINE IF KDD IS REAL OR IMAGINARY  (COMPLEX EIGEN)        
C        
      MCB(1) = K2DD        
      CALL RDTRL (MCB(1))        
      IF (G.NE.0.0 .OR. NOK4GG.GT.0 .OR. MCB(5).GT.2) GO TO 170        
      IBLOCK(1) = 2        
      IBLOCK(7) = 2        
  170 CALL SSG2C (K1DD,K2DD,SCR4,1,IBLOCK)        
      IF (NOK4GG .LT. 0) GO TO 180        
      BLOCK(1) = 0.0D0        
      BLOCK(2) = 1.0D0        
      CALL SSG2C (K41DD,SCR4,KDD,1,IBLOCK(1))        
  180 RETURN        
C        
C     TRANSIENT ANALYSIS        
C        
  190 IBLOCK(1) = 2        
      IBLOCK(7) = 2        
      IF (K1DD.EQ.KDD .OR. NOKMGG.LT.0) GO TO 200        
      CALL SSG2C (K1DD,K2DD,KDD,1,IBLOCK(1))        
  200 IF (M1DD.EQ.MDD .OR. NOKMGG.LT.0) GO TO 210        
      CALL SSG2C (M1DD,M2DD,MDD,1,IBLOCK(1))        
  210 IF (B1DD .EQ. BDD) GO TO 180        
      BLOCK(1) = G/W3        
      BLOCK(4) = XNUM/W4        
      IF (G.EQ.0.0 .AND. XNUM.EQ.0.0 .AND. NOBGG.LT.0 .AND. IB2PP.LT.0) 
     1    GO TO 180        
      IF (NOBGG.LT.0 .AND. IB2PP.LT.0) SCR3 = BDD        
      CALL SSG2C (K1DD,K41DD,SCR3,1,IBLOCK(1))        
      IF (SCR3 .EQ. BDD) GO TO 180        
      BLOCK(1) = 1.0D0        
      BLOCK(4) = 1.0D0        
      CALL SSG2C (B1DD,B2DD,SCR5,1,IBLOCK(1))        
      CALL SSG2C (SCR5,SCR3,BDD, 1,IBLOCK(1))        
      GO TO 180        
      END        
