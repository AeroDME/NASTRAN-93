      SUBROUTINE GUST2(FOL,WJ,ACPT,X0,V,CSTM,QHJL)        
C        
C     GUST2 MAKE  WJ(W) MATRIX FOR GUST        
C        
      INTEGER FOL,WJ,ACPT,CSTM,QHJL,BUF1,FILE        
      INTEGER SYSBUF,IZ(1),TRL(7),ACDR(13),NAM(2)        
C        
      COMMON /CONDAS/ PI,TWOPI        
      COMMON /SYSTEM/ SYSBUF        
CZZ   COMMON /ZZGUS2/ Z(1)        
      COMMON /ZZZZZZ/ Z(1)        
      COMMON /ZBLPKX/ A(4),IRN        
C        
      EQUIVALENCE (Z(1),IZ(1))        
C        
      DATA  NAM /4HGUST,1H2 /        
      DATA NHNJU,NHACJ /4HNJU ,4HACJ /        
C        
      ICORE = KORSZ(IZ) - SYSBUF-2        
      BUF1 = ICORE+1        
C        
C     READ IN FREQUENCYS AND CONVERT TO OMEGA        
C        
      FILE = FOL        
      CALL OPEN(*999,FOL,Z(BUF1),0)        
      CALL FREAD(FOL,Z,-2,0)        
      CALL READ(*998,*10,FOL,Z,ICORE,0,NFREQ)        
      GO TO 997        
   10 DO 20 I=1,NFREQ        
   20 Z(I) = Z(I) * TWOPI        
      CALL CLOSE(FOL,1)        
C        
C     SPACE FOR COLUMN OF W - 2 * J  LONG  1 J FOR A  1 J FOR COEF.     
C        
      FILE = QHJL        
      TRL(1) =  QHJL        
      CALL RDTRL(TRL)        
      IF(TRL(1).LT.0) GO TO 999        
      NJ = TRL(3)        
      JAP= NFREQ        
      JCP = JAP + NJ        
      IACPT = JCP + NJ + 1        
      IF(IACPT.GT.ICORE) GO TO 997        
      DO 30 I=1,NJ        
   30 Z(JAP+I) = 0.0        
C        
C     SET UP WJ        
C        
      TRL(1) = WJ        
      TRL(2) = 0        
      TRL(3) = NJ        
      TRL(4) = 2        
      TRL(5) = 3        
      TRL(6) = 0        
      TRL(7) = 0        
C        
C     READ ACPT RECORDS BY METHOD AND FILL IN THE TWO COLUMNS        
C     A =  COS G (CG) FOR DLB  1 FOR Z BODIES  0 FOR ALL ELSE        
C     COEF =   XM  FOR PANELS AND BODIES        
C        
      CALL GOPEN(ACPT,Z(BUF1),0)        
      NJU = 0        
      FILE = ACPT        
   40 CALL READ(*100,*100,ACPT,METH,1,0,NWR)        
      GO TO (50,60,90,90,90), METH        
C        
C     DOUBLET LATTICE WITHOUT BODIES        
C        
   50 CALL READ(*998,*995,ACPT,ACDR,4,0,NWR)        
      NP = ACDR(1)        
      NSTRIP = ACDR(2)        
      NJG = ACDR(3)        
      NR = 2*NP + 5*NSTRIP + 2*NJG        
      IF(IACPT+NR.GT.ICORE) GO TO 997        
      CALL READ(*998,*995,ACPT,Z(IACPT),NR,1,NWR)        
      IXIC  =  IACPT + 2*NP + 5*NSTRIP - 1        
      IDELX =  IXIC + NJG        
      ICG   =  IACPT + 2*NP + 4*NSTRIP        
      K = 0        
      KS= 0        
      NBXR = IZ(IACPT)        
      DO 59 I = 1,NJG        
      Z(JAP+NJU+I)=Z(ICG+KS)        
      Z(JCP+NJU+I)=Z(IXIC+I) + .5* Z(IDELX+I)        
      IF(I.EQ.NJG) GO TO 59        
      IF(I.EQ.IZ(IACPT+NP+K)) K=K+1        
      IF(I.NE.NBXR) GO TO 59        
      KS = KS+1        
      NBXR = NBXR + IZ(IACPT+K)        
   59 CONTINUE        
      NJU = NJU+NJG        
      GO TO 40        
C        
C     DOUBLET LATTICE WITH BODIES        
C        
   60 CALL READ(*998,*995,ACPT,ACDR,13,0,NWR)        
      NJG = ACDR(1)        
      NP  = ACDR(3)        
      NB = ACDR(4)        
      NTP = ACDR(5)        
      NTO = ACDR(10)        
      NTZS= ACDR(11)        
      NTYS = ACDR(12)        
      NSTRIP = ACDR(13)        
      IC = IACPT        
      IB = IC + NP        
      IB1= IB + 2*NP        
      IBS= IB1+ 2*NB        
      NR = 3*NP + 3*NB        
      CALL READ(*998,*995,ACPT,Z(IACPT),NR,0,NWR)        
      NBEI = 0        
      NBES = 0        
      DO 61 I=1,NB        
      NBEI= NBEI+ IZ(IB1+I-1)        
      NBES= NBES+ IZ(IBS+I-1)        
   61 CONTINUE        
      ICG = IB+ NP        
      IX  = ICG + NSTRIP  -1        
      IXS1= IX  + 4*NTP + 2*NBEI + NBES        
      IXS2= IXS1+ NBES        
      NR = 11*NB + 4*NSTRIP        
      CALL READ(*998,*995,ACPT,Z(ICG),-NR,0,NWR)        
      NR =  NSTRIP + 4*NTP + 2*NBEI + 3* NBES        
      IF(ICG+NR.GT.ICORE) GO TO 997        
      CALL READ(*998,*995,ACPT,Z(ICG),NR,1,NWR)        
      IF(NTP.EQ.0) GO TO 65        
      K= 0        
      KS=0        
      NBXR = IZ(IC)        
      DO 64 I=1,NTP        
      Z(JAP+NJU+I)  =  Z(ICG+KS)        
      Z(JCP+NJU+I)  =  Z(IX+I)        
      IF(I.EQ.NTP) GO TO 64        
      IF(I.EQ.IZ(IB+K)) K=K+1        
      IF(I.NE.NBXR) GO TO 64        
      KS = KS + 1        
      NBXR = NBXR +  IZ(IC+K)        
   64 CONTINUE        
   65 NJU = NJU + NTO        
      IF(NTZS.EQ.0) GO TO 80        
      DO 70 I=1,NTZS        
      Z(JAP+NJU+I) = 1.0        
      Z(JCP+NJU+I) =  .5 * (Z(IXS1+I) + Z(IXS2+I))        
   70 CONTINUE        
   80 NJU = NJU + NTZS + NTYS        
      GO TO 40        
C        
C     MACH BOX  STRIP  PISTON  THEORIES        
C        
   90 CALL READ(*998,*995,ACPT,NJG,1,1,NWR)        
      NJU= NJU + NJG        
      GO TO 40        
  100 CALL CLOSE(ACPT,1)        
      CALL BUG(NHNJU ,100,NJU,1)        
      CALL BUG(NHACJ ,100,Z(JAP+1),2*NJ)        
      IF(NJU.NE.NJ) GO TO 996        
C        
C     BUILD WJ LOOP OVER ALL FREQUENCIES WITH AN INNER LOOP ON NJ       
C        
      CALL GOPEN(WJ,Z(BUF1),1)        
      DO 150 I=1,NFREQ        
      FREQ = Z(I)        
      CALL BLDPK(3,3,WJ,0,0)        
      DO 140 J=1,NJ        
      AM = Z(JAP+J)        
      IF( AM .EQ. 0.0 ) GO TO 140        
      IRN = J        
      TEMP   =   FREQ *((Z(JCP+J)-X0)/V)        
      A(1) = COS(TEMP)*AM        
      A(2) = -SIN(TEMP)*AM        
      CALL ZBLPKI        
  140 CONTINUE        
      CALL BLDPKN(WJ,0,TRL)        
  150 CONTINUE        
      CALL CLOSE(WJ,1)        
      CALL WRTTRL(TRL)        
      CALL DMPFIL(-WJ,Z,ICORE)        
 1000 RETURN        
C        
C     ERROR MESSAGES        
C        
  995 CALL MESAGE(-3,FILE,NAM)        
  996 CALL MESAGE(-7,0,NAM)        
  997 CALL MESAGE(-8,0,NAM)        
  998 CALL MESAGE(-2,FILE,NAM)        
  999 CALL MESAGE(-1,FILE,NAM)        
      GO TO 1000        
      END        
