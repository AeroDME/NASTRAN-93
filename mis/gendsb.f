      SUBROUTINE GENDSB(NCARAY,NBARAY,SG,CG,NFL,NBEA1,NBEA2,IFLA1,      
     *   IFLA2,DT,DPZ,DPY)        
      INTEGER SCR1,SCR2,SCR3,SCR4,SCR5,ECORE,SYSBUF        
      INTEGER Z        
      DIMENSION NAME(2)        
      DIMENSION NCARAY(1),NBARAY(1),SG(1),CG(1),NFL(1),NBEA1(1)        
      DIMENSION NBEA2(1),IFLA1(1),IFLA2(1)        
      COMPLEX DT(1),DPZ(1),DPY(1)        
      COMMON /SYSTEM/ SYSBUF        
CZZ   COMMON /ZZDAMB / Z(1)        
      COMMON /ZZZZZZ / Z(1)        
      COMMON /AMGMN / MCB(7),NROW,ND,NE,REFC,FMACH,RFK,TSKJ(7),ISK,NSK  
      COMMON /DLBDY/ NJ1,NK1,NP,NB,NTP,NBZ,NBY,NTZ,NTY,NTO,NTZS,NTYS,   
     *   INC,INS,INB,INAS,IZIN,IYIN,INBEA1,INBEA2,INSBEA,IZB,IYB,       
     *   IAVR,IARB,INFL,IXLE,IXTE,INT121,INT122,IZS,IYS,ICS,IEE,ISG,    
     *   ICG,IXIJ,IX,IDELX,IXIC,IXLAM,IA0,IXIS1,IXIS2,IA0P,IRIA,        
     *   INASB,IFLAX,IFLA ,ITH1A,ITH2A,        
     *   ECORE,NEXT,SCR1,SCR2,SCR3,SCR4,SCR5,NTBE        
      DATA NAME /4HGEND,4HB   /        
C   ***   GENERATES THE INFLUENCE COEFFICIENT MATRIX  DT   USING THE    
C         FOLLOWING FOUR SUBROUTINES  --  DPPS, DPZY, DZPY,  AND  DYPZ  
      NBOX = NTP        
      LBO  = 1        
      LSO  = 1        
      JBO  = 1        
      KB   = 0        
      KT   = 0        
      DO 40 I=1,NTBE        
      DPY(I) = (0.0,0.0)        
      DT(I) = (0.0,0.0)        
   40 CONTINUE        
      NBUF = 4        
      IF(NTP.EQ.0) NBUF = NBUF - 1        
      IF(NTZ.EQ.0) NBUF = NBUF - 1        
      IF(NTY.EQ.0) NBUF = NBUF - 2        
      IF(NEXT + NBUF*SYSBUF .GT. ECORE) CALL MESAGE(-8,0,NAME)        
      IBUF1 = ECORE - SYSBUF        
      IBUF2 = IBUF1 - SYSBUF        
      NSTRIP = 0        
      J2 = 0        
      I2 = 0        
      NYFLAG = 0        
      IF(NTP.NE.0) CALL GOPEN(SCR1,Z(IBUF1),1)        
      IF(NTP .EQ.0) GO TO 201        
      I1   = 1        
      I2   = NTP        
      J1   = 1        
      J2   = NTP        
C  DPP-LOOP        
      K    = 1        
C  K IS THE PANEL NUMBER ASSOCIATED WITH RECEIVING POINT  I        
      KS   = 1        
C  KS IS THE STRIP NUMBER ASSOCIATED WITH RECEIVING POINT  I        
      NBXR = NCARAY(K)        
      DO  60  I=I1,I2        
      SGR  = SG(KS)        
      CGR  = CG(KS)        
      CALL      DPPSB(  KS,I,J1,J2,SGR,CGR,           Z(IYS),Z(IZS),    
     *   NBARAY,NCARAY,DT,Z(1))        
      CALL WRITE(SCR1,DT,2*NTP,0)        
      IF (I.EQ.I2)  GO TO  60        
      IF (I.EQ.NBARAY(K))  K=K+1        
      IF (I.EQ.NBXR)  GO TO   50        
      GO TO  60        
   50 CONTINUE        
      KS   = KS+1        
      NBXR = NBXR+NCARAY(K)        
   60 CONTINUE        
      CALL WRITE(SCR1,0,0,1)        
      NSTRIP = KS        
      NZYSV= 0        
      DO  70  J=J1,J2        
      DT(J)= (0.0,0.0)        
   70 CONTINUE        
      NLT1 = 0        
      NLT2 = 0        
      IF (NTZ.EQ.0)  GO TO  180        
      IF(NTY.NE.0) CALL GOPEN(SCR4,Z(IBUF2),1)        
      I1   = I2+1        
      I2   = I2+NTZ        
C  DPZ-LOOP    **    ALSO USED FOR GENERATING THE DPY-MATRIX  --  SEE   
C  COMMENT IN  DPY-LOOP  BELOW        
   80 CONTINUE        
      KB   = KB+1        
C  KB  IS THE BODY NUMBER ASSOCIATED WITH RECEIVING POINT  I        
      IZ   = 0        
      KT   = KT+1        
C  KT  IS THE INDEX OF THE ARRAY OF FIRST-AND-LAST-ELEMENTS FOR THETA-1 
      ICOUNT = 1        
      IFL    = NFL(KB)        
      NZYKB = NBEA2(KB)        
      IFIRST = IFLA1(KT)        
      ILAST = IFLA2(KT)        
      DO  170  I=I1,I2        
      DO  90  J=J1,J2        
      DPZ(J) = (0.0,0.0)        
      DPY(J) = (0.0,0.0)        
   90 CONTINUE        
      CALL       DPZY(   KB,IZ,I,J1,J2,IFIRST,ILAST,Z(IYB),        
     * Z(IZB),Z(IAVR),Z(IARB),Z(ITH1A+NLT1),Z(ITH2A+NLT2),Z(INT121),    
     * Z(INT122),NBARAY,NCARAY,NZYKB,DPZ,DPY)        
      GO TO  (100,100,110),  NZYKB        
  100 CONTINUE        
      CALL WRITE(SCR1,DPZ,2*NTP,0)        
      IF (NZYKB.EQ.1)  GO TO 120        
  110 CONTINUE        
      CALL WRITE(SCR4,DPY,2*NTP,0)        
  120 CONTINUE        
      IF (IZ.EQ.NBEA1(KB) )  GO TO 130        
      IF (IZ.EQ.ILAST.AND.ICOUNT.LT.IFL)  GO TO 160        
      GO TO  170        
  130 CONTINUE        
      IZ     = 0        
      IF (NZYSV.LE.1.AND.NZYKB.GE.2)  GO TO  140        
      GO TO  150        
  140 CONTINUE        
      LBO  = KB        
      LSO  = NSTRIP+LBO        
      JBO  = I-NBEA1(KB) -NBOX+1        
  150 CONTINUE        
      NZYSV = NZYKB        
      IF(I.EQ.I2) GO TO 180        
      KB     = KB+1        
      ICOUNT = 0        
      IFL    = NFL(KB)        
      NZYKB = NBEA2(KB)        
  160 CONTINUE        
      KT     = KT+1        
      ICOUNT = ICOUNT+1        
      IFIRST = IFLA1(KT)        
      ILAST = IFLA2(KT)        
  170 CONTINUE        
  180 CONTINUE        
      IF(I2.EQ.NTBE) GO TO 190        
C  DPY-LOOP    **    THIS LOOP IS REDUCED TO SETTING THE CORRECT INDICES
C  AND USING THE  DPZ-LOOP  ABOVE        
      IF(NTZ.EQ.0) CALL GOPEN(SCR4,Z(IBUF2),1)        
      I1   = I2+1        
      I2 = NTBE        
      GO TO 80        
  190 CALL WRITE(SCR1,0,0,1)        
      IF(NTY.NE.0) CALL WRITE(SCR4,0,0,1)        
      CALL CLOSE(SCR1,1)        
      CALL CLOSE(SCR4,1)        
      I1   = 1        
      I2   = NTP        
      IF (NTZ.EQ.0)  GO TO  250        
      CALL GOPEN(SCR2,Z(IBUF1),1)        
C  DZP-LOOP        
      K    = 1        
C  K  IS THE PANEL NUMBER ASSOCIATED WITH RECEIVING POINT  I        
      KS   = 1        
C  KS  IS THE STRIP NUMBER ASSOCIATED WITH RECEIVING POINT  I        
      NBXR = NCARAY(K)        
      KB   = 0        
C  HERE  KB=0  SERVES AS A FLAG INDICATING THAT THE RECEIVING POINT   I 
C  IS ON A PANEL AND NOT   ON A BODY        
      J1   = J2+1        
      J2   = J2+NTZ        
      DO  210  I=I1,I2        
      LS   = NSTRIP+1        
      SGR  = SG(KS)        
      CGR  = CG(KS)        
      CALL       DZPY(KB,KS,LS,   I,J1,J2,NYFLAG,          SGR,CGR,     
     1           FMACH,   Z(IARB),Z(INBEA1),DT)        
      CALL WRITE(SCR2,DT(J1),2*NTZ,0)        
      IF (I.EQ.I2)  GO TO  210        
      IF (I.EQ.NBARAY(K))  K =K +1        
      IF (I.EQ.NBXR)  GO TO  200        
      GO TO  210        
  200 CONTINUE        
      KS   = KS+1        
      NBXR = NBXR+NCARAY(K)        
  210 CONTINUE        
      CALL WRITE(SCR2,0,0,1)        
  201 CONTINUE        
      IF(NTZ.EQ.0) GO TO 250        
      IF(NTP.EQ.0) CALL GOPEN(SCR2,Z(IBUF1),1)        
      NYFLAG = 0        
C  DZZ-LOOP    **    ALSO USED FOR GENERATING THE  DZY  MATRIX  --  SEE 
C  COMMENT IN  DZY-LOOP  BELOW        
      KB   = 1        
C  KB  IS THE BODY NUMBER ASSOCIATED WITH RECEIVING POINT  I        
      KS   = NSTRIP+1        
      IZ   = 0        
      I1   = I2+1        
      I2   = I2+NTZ        
      SGR  = 0.0        
      CGR  = 1.0        
  220 CONTINUE        
      LS   = NSTRIP+1        
      LSX  = LS        
      DO  240  I=I1,I2        
      LS   = LSX        
      IZ   = IZ+1        
C  KS IS THE INDEX OF THE Y  AND  Z  COORDINATES OF RECEIVING POINT I   
C  IN THE  DZZ-LOOP  KS RUNS FROM  (NSTRIP+1)  THROUGH  (NSTRIP+NBZ)    
C  IN THE  DZY-LOOP  KS  RUNS FROM  (NSTRIP+NB-NBY+1) THROUGH  NSTRIP+NB
      CALL       DZPY(KB,KS,LS,   I,J1,J2,NYFLAG,          SGR,CGR,     
     1           FMACH,   Z(IARB),Z(INBEA1),DT)        
      CALL WRITE(SCR2,DT(J1),2*NTZ,0)        
      IF (IZ.EQ.NBEA1(KB) )  GO TO  230        
      GO TO  240        
  230 CONTINUE        
      IZ   = 0        
      KB   = KB+1        
      KS   = KS+1        
  240 CONTINUE        
      CALL WRITE(SCR2,0,0,1)        
      IF(NTY.EQ.0) CALL CLOSE(SCR2,1)        
      IF (NTY.EQ.0)  GO TO 320        
      IF (NYFLAG.NE.0)  GO TO  250        
C  DZY-LOOP    **    THIS LOOP IS REDUCED TO SETTING THE CORRECT INDICES
C  AND USING THE  DZZ-LOOP  ABOVE        
      I1 = NTBE-NTY+1        
      I2 = NTBE        
      NYFLAG = 1        
      KB   = LBO        
      KS   = LSO        
      SGR  =-1.0        
      CGR  = 0.0        
      GO TO  220        
  250 CONTINUE        
      CALL CLOSE(SCR2,1)        
      IF (NTY.EQ.0)  GO TO 320        
      CALL GOPEN(SCR3,Z(IBUF1),1)        
      I1   = 1        
      I2   = NTP        
      J1 = NTBE-NTY+1        
      J2 = NTBE        
      IF(NTP.EQ.0) GO TO 275        
C  DYP-LOOP        
      K    = 1        
      KS   = 1        
      KB   = 0        
      NBXR = NCARAY(K)        
      SGR  = SG(KS)        
      CGR  = CG(KS)        
      DO  270  I=I1,I2        
      CALL       DYPZ(KB,KS,LS,   I,J1,J2,NYFLAG,          SGR,CGR,     
     1           FMACH,   Z(IARB),Z(INBEA1),          LBO,LSO,JBO,DT)   
      CALL WRITE(SCR3,DT(J1),2*NTY,0)        
      IF (I.EQ.NBARAY(K))  K=K+1        
      IF (I.EQ.NBXR)  GO TO  260        
      GO TO  270        
  260 CONTINUE        
      KS   = KS+1        
      NBXR = NBXR+NCARAY(K)        
      SGR  = SG(KS)        
      CGR  = CG(KS)        
  270 CONTINUE        
      CALL WRITE(SCR3,0,0,1)        
  275 CONTINUE        
      NYFLAG = 0        
      IZ   = 0        
      IF (NTZ.EQ.0)  GO TO  310        
C  DYZ-LOOP    **    ALSO USED FOR GENERATING THE  DYY  MATRIX  --  SEE 
C  COMMENT IN  DYY-LOOP  BELOW        
      I1   = I2+1        
      I2   = I2+NTZ        
      KS   = NSTRIP+1        
      KB   = 1        
      SGR  = 0.0        
      CGR  = 1.0        
  280 CONTINUE        
      DO  300  I=I1,I2        
      LS   = LSO        
      IZ   = IZ+1        
      CALL       DYPZ(KB,KS,LS,   I,J1,J2,NYFLAG,          SGR,CGR,     
     1           FMACH,   Z(IARB),Z(INBEA1),          LBO,LSO,JBO,DT)   
      CALL WRITE(SCR3,DT(J1),2*NTY,0)        
      IF (IZ.EQ.NBEA1(KB) )  GO TO  290        
      GO TO  300        
  290 CONTINUE        
      IZ   = 0        
      KB   = KB+1        
      KS   = KS+1        
  300 CONTINUE        
      CALL WRITE(SCR3,0,0,1)        
  310 CONTINUE        
      IF (NYFLAG.NE.0)  GO TO 320        
C  DYY-LOOP    **    THIS LOOP IS REDUCED TO SETTING THE CORRECT INDICES
C  AND USING THE  DYZ-LOOP  ABOVE        
      IF(NTP.EQ.0.AND.NTZ.EQ.0) CALL GOPEN(SCR3,Z(IBUF1),1)        
      I1 = NTBE-NTY+1        
      I2 = NTBE        
      NYFLAG = 1        
      KB   = LBO        
      KS   = LSO        
      SGR  =-1.0        
      CGR  = 0.0        
      GO TO  280        
  320 CONTINUE        
      CALL CLOSE(SCR3,1)        
C        
C     BUILD SCR5 WITH GEND PART OF A MATRIX        
C        
      I1   = 1        
      I2   = NTP+NTZ        
      NYFLAG = 0        
      CALL GOPEN(SCR5,Z(IBUF1),1)        
      IBUF3 = IBUF2 - SYSBUF        
      IBUF4 = IBUF3 - SYSBUF        
      IF(NTZ.NE.0) CALL GOPEN(SCR2,Z(IBUF3),0)        
      IF(NTY.NE.0) CALL GOPEN(SCR3,Z(IBUF4),0)        
      ITAPE = SCR1        
      IF(I2.EQ.0) GO TO 365        
  330 IF(NTP.NE.0) CALL GOPEN(ITAPE,Z(IBUF2),0)        
      DO 360  I=I1,I2        
      J1   = 1        
      J2   = NTP        
      IF(NTP.NE.0) CALL FREAD(ITAPE,DT,2*J2,0)        
      IF(I.EQ.NTP) CALL FREAD(ITAPE,0,0,1)        
      IF (NTZ.EQ.0)  GO TO 340        
      J1   = J2+1        
      J2   = J2+NTZ        
      CALL FREAD(SCR2,DT(J1),2*NTZ,0)        
      IF(I.EQ.NTP) CALL FREAD(SCR2,0,0,1)        
  340 CONTINUE        
      IF (NTY.EQ.0)  GO TO 350        
      J1   = J2+1        
      J2 = J2+NTY        
      CALL FREAD(SCR3,DT(J1),2*NTY,0)        
      IF(I.EQ.NTP) CALL FREAD(SCR3,0,0,1)        
  350 CONTINUE        
      CALL WRITE(SCR5,DT,2*J2,0)        
  360 CONTINUE        
      IF (NTY.EQ.0)  GO TO 370        
      IF (NYFLAG.NE.0)  GO TO 370        
      IF(NTZ.NE.0.AND.NTP.NE.0)CALL FREAD(SCR2,0,0,1)        
      IF(NTY.NE.0.AND.NTP.NE.0)CALL FREAD(SCR3,0,0,1)        
      CALL CLOSE(ITAPE,1)        
  365 CONTINUE        
      NYFLAG = 1        
      I1   = I2+1        
      I2   = I2+NTY        
      ITAPE = SCR4        
      GO TO 330        
  370 CONTINUE        
      CALL WRITE(SCR5,0,0,1)        
      CALL CLOSE(SCR1,1)        
      CALL CLOSE(SCR2,1)        
      CALL CLOSE(SCR3,1)        
      CALL CLOSE(SCR4,1)        
      CALL CLOSE(SCR5,1)        
      CALL DMPFIL(SCR5,Z(NEXT),ECORE-NEXT-100)        
      RETURN        
      END        
