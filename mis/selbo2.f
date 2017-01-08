      SUBROUTINE SELBO2 (TI)        
C        
C     THIS ROUTINE IS THE PHASE II SUBROUTINE OF STRESS DATA RECOVERY   
C     FOR THE BEAM ELEMENT.        
C        
      INTEGER         TLOADS        
      REAL            I1,I2,L,M1A,M2A,M1B,M2B,I12,K1A,K2A,K1B,K2B,      
     1                TI(14),M2BT        
      EQUIVALENCE     (LDTEMP,TEMPLD),(MSTEN,SMTEN),(MSCOM,SMCOM)       
CZZ   COMMON /ZZSDR2/ ZZ(1)        
      COMMON /ZZZZZZ/ ZZ(1)        
      COMMON /SDR2X4/ XXXXXX(33),ICSTM,NCSTM,IVEC,IVECN,LDTEMP,ELDEFM,  
     1                DUM8(8),TLOADS        
C        
C     THE FIRST 100 LOCATIONS OF THE SDR2X7 BLOCK ARE RESERVED FOR INPUT
C     PARAMETERS, THE SECOND 100 FOR STRESS OUTPUT PARAMETERS, AND FORCE
C     OUTPUT PARAMETERS BEGIN AT LOCATION 201.        
C        
      COMMON /SDR2X7/ JELID,JSILNO(2),SA(36),SB(36),ST,SDELTA,A,FJ,I1,  
     1                I2,C,R1,T1,R2,T2,R3,T3,R4,T4,T SUB 0,SIGMAT,      
     2                SIGMAC,L,R,BETAR,THERM(4)        
      COMMON /SDR2X7/ ISELID,SIG1A,SIG2A,SIG3A,SIG4A,SIGAX,SIGAMX,      
     3                SIGAMN,MSTEN,SIG1B,SIG2B,SIG3B,SIG4B,SIGBX,       
     4                SIGBMX,SIGBMN,MSCOM,YYYYYY(83)        
      COMMON /SDR2X7/ IFELID,M1A,M2A,V1,V2,FX,T,M1B,M2BT,V1BT,FXBT,TBT  
C        
      COMMON /SDR2X8/ FA(6),FB(6),IDISP,IUA,IUB,P1,K1A,K2A,K1B,K2B,Q,W  
      DATA    DCR   / .017453292 /        
C        
      SID(X) = SIN(X*DCR)        
      COD(X) = COS(X*DCR)        
C        
      X   = 1.0        
      YL  = R*(1.-COD(BETAR))        
      XL  = R*SID(BETAR)        
      I12 = 0.        
      IDISP = IVEC - 1        
      IUA = IDISP + JSILNO(1)        
      CALL GMMATS (SA(1),6,6,0, ZZ(IUA),6,1,0, FA(1))        
      IUB = IDISP + JSILNO(2)        
      CALL GMMATS (SB(1),6,6,0, ZZ(IUB),6,1,0, FB(1))        
      FX  = -FA(1) - FB(1)        
      V1  = -FA(2) - FB(2)        
      V2  = -FA(3) - FB(3)        
      T   = -FA(4) - FB(4)        
      M2A =  FA(5) + FB(5)        
      M1A = -FA(6) - FB(6)        
C        
C     IF LDTEMP = -1, THE LOADING TEMPERATURE IS UNDEFINED        
C        
      IF (TLOADS .EQ. 0) GO TO 10        
      TBAR = TI(1)        
      DT   = TBAR - TSUB0        
      DO 5 I = 1,6        
      FA(I) = DT*THERM(I)        
    5 CONTINUE        
      FX  = FX  + FA(1)        
      V1  = V1  + FA(2)        
      M1A = M1A + FA(6)        
10    M1B = M1A - V1*XL + FX*YL        
      M2B = M2A - V2*XL        
      TB  = T   - V2*YL        
C        
C     TRANSFORM FORCES AT B-END TO A COORD. SYS TANGENT TO B-END        
C        
      FXBT = V1*SID(BETAR) + FX*ABS(COD(BETAR))        
      V1BT = V1*ABS(COD(BETAR))  - FX*SID(BETAR)        
      M2BT = M2B*ABS(COD(BETAR)) + TB*SID(BETAR)        
      TBT  =-M2B*SID(BETAR) + TB*ABS(COD(BETAR))        
C        
C     COMPUTE ELEMENT STRESSES AT 4 POINTS        
C        
C        
C     COMPUTE K1A AND K2A        
C        
      IF (I12 .NE. 0.0) GO TO 30        
      IF (I1  .NE. 0.0) GO TO 20        
      K1A = 0.0        
      GO TO 40        
   20 K1A = -M1A/I1        
      GO TO 40        
   30 K1A = (M2A*I12 - M1A*I2)/(I1*I2 - I12**2)        
      K2A = (M1A*I12 - M2A*I1)/(I1*I2 - I12**2)        
      GO TO 60        
   40 IF (I2 .NE. 0.0) GO TO 50        
      K2A = 0.0        
      GO TO 60        
   50 K2A = -M2A/I2        
C        
C     CHANGE STRESS RECOVERY CONSTANTS FROM CYL. TO RECT. COORD.        
C        
      C1 = R1*SID(T1)        
      C2 = R1*COD(T1)        
      D1 = R2*SID(T2)        
      D2 = R2*COD(T2)        
      F1 = R3*SID(T3)        
      F2 = R3*COD(T3)        
      G1 = R4*SID(T4)        
      G2 = R4*COD(T4)        
C        
C     COMPUTE SIG1A, SIG2A, SIG3A AND SIG4A        
C        
   60 SIG1A = K1A*C1*C + K2A*C2        
      SIG2A = K1A*D1*C + K2A*D2        
      SIG3A = K1A*F1*C + K2A*F2        
      SIG4A = K1A*G1*C + K2A*G2        
C        
C     COMPUTE K1B AND K2B        
C        
      IF (I12 .NE. 0.0) GO TO 80        
      IF (I1  .NE. 0.0) GO TO 70        
      K1B = 0.0        
      GO TO 90        
   70 K1B = -M1B/I1        
      GO TO 90        
   80 K1B = (M2BT*I12 - M1B *I2)/(I1*I2 - I12**2)        
      K2B = (M1B *I12 - M2BT*I1)/(I1*I2 - I12**2)        
      GO TO 110        
   90 IF (I2 .NE. 0.0) GO TO 100        
      K2B = 0.0        
      GO TO 110        
  100 K2B = -M2BT/I2        
C        
C     COMPUTE SIG1B, SIG2B, SIG3B AND SIG4B        
C        
  110 SIG1B = K1B*C1*C + K2B*C2        
      SIG2B = K1B*D1*C + K2B*D2        
      SIG3B = K1B*F1*C + K2B*F2        
      SIG4B = K1B*G1*C + K2B*G2        
      IF (TLOADS .EQ. 0) GO TO 115        
C        
C     TEST IF AT LEAST ONE POINT TEMPERATURE IS GIVEN        
C        
      DO 111 I = 7,14        
      IF (TI(I) .NE. 0.0) GO TO 112        
  111 CONTINUE        
      GO TO 115        
  112 IF (A .EQ. 0.0) GO TO 115        
      EALF  =-ST/A        
      SIG1A = SIG1A + EALF*(TI( 7) - TI(3)*C1*C - TI(5)*C2 - TI(1))     
      SIG2A = SIG2A + EALF*(TI( 8) - TI(3)*D1*C - TI(5)*D2 - TI(1))     
      SIG3A = SIG3A + EALF*(TI( 9) - TI(3)*F1*C - TI(5)*F2 - TI(1))     
      SIG4A = SIG4A + EALF*(TI(10) - TI(3)*G1*C - TI(5)*G2 - TI(1))     
      SIG1B = SIG1B + EALF*(TI(11) - TI(4)*C1*C - TI(6)*C2 - TI(2))     
      SIG2B = SIG2B + EALF*(TI(12) - TI(4)*D1*C - TI(6)*D2 - TI(2))     
      SIG3B = SIG3B + EALF*(TI(13) - TI(4)*F1*C - TI(6)*F2 - TI(2))     
      SIG4B = SIG4B + EALF*(TI(14) - TI(4)*G1*C - TI(6)*G2 - TI(2))     
  115 CONTINUE        
C        
C     COMPUTE AXIAL STRESS        
C        
      SIGAX = 0.0        
      SIGBX = 0.0        
      IF (A .NE. 0.0) SIGAX = FX/A        
      IF (A .NE. 0.0) SIGBX = FXBT/A        
C        
C     COMPUTE MAXIMA AND MINIMA        
C        
      SIGAMX = SIGAX + AMAX1(SIG1A,SIG2A,SIG3A,SIG4A)        
      SIGBMX = SIGBX + AMAX1(SIG1B,SIG2B,SIG3B,SIG4B)        
      SIGAMN = SIGAX + AMIN1(SIG1A,SIG2A,SIG3A,SIG4A)        
      SIGBMN = SIGBX + AMIN1(SIG1B,SIG2B,SIG3B,SIG4B)        
C        
C     COMPUTE MARGIN OF SAFETY IN TENSION        
C        
      IF (SIGMAT .LE. 0.0) GO TO 620        
      IF (AMAX1(SIGAMX,SIGBMX) .LE. 0.0) GO TO 620        
      Q = SIGMAT/AMAX1(SIGAMX,SIGBMX)        
      SMTEN = Q - 1.0        
      GO TO 630        
  620 MSTEN = 1        
C        
C     COMPUTE MARGIN OF SAFETY IN COMPRESSION        
C        
  630 IF (SIGMAC .LE. 0.0) GO TO 640        
      IF (AMIN1(SIGAMN,SIGBMN) .GE. 0.0) GO TO 640        
      W = -SIGMAC/AMIN1(SIGAMN,SIGBMN)        
      SMCOM  = W - 1.0        
      GO TO 150        
  640 MSCOM  = 1        
  150 ISELID = JELID        
      IFELID = JELID        
      RETURN        
      END        
