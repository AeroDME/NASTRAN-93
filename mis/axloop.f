      SUBROUTINE AXLOOP (BUF,IBUF,XX,YY,ZZ,HC1,HC2,HC3)        
C        
      INTEGER         OTPE        
      DIMENSION       BUF(50),IBUF(50)        
      CHARACTER       UFM*23,UWM*25        
      COMMON /XMSSG / UFM,UWM        
      COMMON /SYSTEM/ SYSBUF,OTPE        
      COMMON /BLANK / IDUM(3),EPSE        
C        
      PI    = 3.1415926536        
      PIBY2 = 1.5707963268        
      FPI   = 12.56637062        
      C     = 1.        
C        
      XJ  = BUF(1)        
      IAXI= IBUF(2)        
      X1  = BUF(3)        
      Y1  = BUF(4)        
      Z1  = BUF(5)        
      X2  = BUF(6)        
      Y2  = BUF(7)        
      Z2  = BUF(8)        
      XC  = BUF(9)        
      YC  = BUF(10)        
      ZC  = BUF(11)        
C        
C     FOR NOW, ICID = 0        
C        
      ICID = IBUF(12)        
C        
C     CHECK FOR AXISYMMETRIC PROBLEM        
C        
      IF (IAXI .NE. 1) GO TO 10        
      XC = 0.        
      YC = 0.        
      ZC = Z1        
      X2 = 0.        
      Y2 = X1        
      Z2 = Z1        
   10 CONTINUE        
C        
C     DETERMINE THE DIRECTION OF THE CURRENT LOOP AXIS        
C        
      CX = X1 - XC        
      CY = Y1 - YC        
      CZ = Z1 - ZC        
      BX = X2 - XC        
      BY = Y2 - YC        
      BZ = Z2 - ZC        
C        
C     THE VECTOR AN IS NORMAL TO THE PLANE OF THE LOOP        
C        
      ANX = CY*BZ - CZ*BY        
      ANY = CZ*BX - CX*BZ        
      ANZ = CX*BY - CY*BX        
      AT1 = SQRT(ANX*ANX + ANY*ANY + ANZ*ANZ)        
      AT2  = BX*BX + BY*BY + BZ*BZ        
      RAD2 = CX*CX + CY*CY + CZ*CZ        
      RADIUS = SQRT(RAD2)        
      XIACPI = (XJ*RAD2*PI)/C        
C        
      ANX = ANX/AT1        
      ANY = ANY/AT1        
      ANZ = ANZ/AT1        
C        
C     THE VECTOR R IS FROM THE CENTER OF LOOP TO THE FIELD POINT        
C        
      RX = XX - XC        
      RY = YY - YC        
      RZ = ZZ - ZC        
C        
      R2 = RX*RX + RY*RY + RZ*RZ        
      R  = SQRT(R2)        
C        
C     AT (OR NEAR) CENTER OF LOOP TEST        
C        
      IF (R .GE. .001) GO TO 218        
      COSTHE = 1.        
      SINTHE = 0.        
      SQAR2S = SQRT(RAD2+R2)        
      RX  = ANX        
      RY  = ANY        
      RZ  = ANZ        
      RPX = 0.        
      RPY = 0.        
      RPZ = 0.        
      GO TO 220        
  218 CONTINUE        
C        
      RX = RX/R        
      RY = RY/R        
      RZ = RZ/R        
      COSTHE = ANX*RX + ANY*RY + ANZ*RZ        
      SINTHE = SQRT(1. - COSTHE*COSTHE)        
C        
C     ON (OR VERY NEAR) AXIS OF LOOP TEST        
C        
      IF (SINTHE .GE. .000001) GO TO 219        
      COSTHE = 1.        
      SINTHE = 0.        
      SQAR2S = SQRT(RAD2+R2)        
      RX  = ANX        
      RY  = ANY        
      RZ  = ANZ        
      RPX = 0.        
      RPY = 0.        
      RPZ = 0.        
      GO TO 220        
  219 CONTINUE        
C        
      SQAR2S = SQRT(RAD2 + R2 + (2.*RADIUS*R*SINTHE))        
      REALK2 = (4.*RADIUS*R*SINTHE)/(RAD2+R2+(2.*RADIUS*R*SINTHE))      
      REALK  = SQRT(REALK2)        
      XIACR  = (XJ*RADIUS)/(C*R)        
C        
C     A CROSS R, NORMAL TO THE PLANE OF A AND R        
C        
      TX = ANY*RZ - ANZ*RY        
      TY = ANZ*RX - ANX*RZ        
      TZ = ANX*RY - ANY*RX        
C        
C     (A CROSS R) CROSS R, NORMAL TO THE PLANE OF R AND (A AND R)       
C        
      TRPX = TY*RZ - TZ*RY        
      TRPY = TZ*RX - TX*RZ        
      TRPZ = TX*RY - TY*RX        
      AT3  = SQRT(TRPX*TRPX + TRPY*TRPY + TRPZ*TRPZ)        
C        
C     RPERP, PERPENDICULAR TO THE VECTOR FROM THE CENTER TO THE FIELD PT
C        
      RPX = TRPX/AT3        
      RPY = TRPY/AT3        
      RPZ = TRPZ/AT3        
C        
C     FOR SMALL POLAR ANGLE OR SMALL RADIUS USE ALTERNATIVE APPROX.     
C        
      IF (REALK2 .LT. .0001) GO TO 220        
C        
C     COMPUTE ELLIPTIC INTEGRAL OF FIRST KIND        
C        
      F = 1.        
      DELTF1 = 1.        
      DO 240 N = 1,15000        
      XN2  = 2.*FLOAT(N)        
      XN21 = XN2 - 1.        
      DELTF1 = DELTF1*(XN21/XN2)*REALK        
      DELTF2 = DELTF1*DELTF1        
      F = F + DELTF2        
      IF (ABS(DELTF2/F) .LE. EPSE) GO TO 250        
  240 CONTINUE        
      DELF = ABS(DELTF2/F)        
      WRITE (OTPE,245) UWM,XX,YY,ZZ,XC,YC,ZC,X1,Y1,Z1,X2,Y2,Z2,DELF,EPSE
  245 FORMAT (A25,', CONVERGENCE OF ELLIPTIC INTEGRAL IS UNCERTAIN. ',  
     1     'GRID OR INTEGRATION POINT AT COORDINATES', /5X,        
     2     1P,3E15.6,'  IS TOO CLOSE TO CURRENT LOOP WITH CENTER AT',   
     3     /5X,1P,3E15.6,' AND 2 POINTS AT ',1P,3E15.6, /5X,4HAND ,1P,  
     4     3E15.6,' COMPUTATIONS WILL CONTINUE WITH LAST VALUES', /5X,  
     5     'CONVERGENCE VALUE WAS ',1P,E15.6,        
     6     ' CONVERGENCE CRITERION IS ',1P,E15.6)        
  250 F = PIBY2*F        
C        
C     COMPUTE ELLIPTIC INTEGRAL OF SECOND KIND        
C        
      E = 1.        
      DELTE1 = 1.        
      DO 260 N = 1,15000        
      XN2  = 2.*FLOAT(N)        
      XN21 = XN2-1.        
      DELTE1 = DELTE1*(XN21/XN2)*REALK        
      DELTE2 = (DELTE1*DELTE1)/XN21        
      E = E - DELTE2        
      IF (ABS(DELTE2/E) .LE. .000001) GO TO 270        
  260 CONTINUE        
      DELE = ABS(DELTE2/E)        
      WRITE (OTPE,245) UWM,XX,YY,ZZ,XC,YC,ZC,X1,Y1,Z1,X2,Y2,Z2,DELE     
  270 E = PIBY2*E        
C        
C     COMPUTE THE RADIAL COMPONENT OF THE MAGNETIC FIELD        
C        
      BR = XIACR*(COSTHE/SINTHE)*(E/SQAR2S)*(REALK2/(1.-REALK2))        
C        
C     COMPUTE THE POLAR COMPONENT OF THE MAGNETIC FIELD        
C        
      BTHE = XIACR*(1./(SQAR2S*RADIUS*R*SINTHE))*        
     1       (((((2.*R2)-((R2+(RADIUS*R*SINTHE))*REALK2))/        
     2       (1.-REALK2))*E)-(2.*R2*F))        
C        
C     GO TO THE RESOLUTION OF FIELD COMPONENTS        
C        
      GO TO 230        
C        
C     ALTERNATIVE APPROXIMATION FOR SMALL K**2        
C        
C     COMPUTE THE RADIAL COMPONENT OF THE MAGNETIC FIELD        
C        
  220 CONTINUE        
      BR = XIACPI*COSTHE*(((2.*RAD2)+(2.*R2)+(RADIUS*R*SINTHE))/        
     1     ((SQAR2S)**5))        
C        
C     COMPUTE THE POLAR COMPONENT OF THE MAGNETIC FIELD        
C        
      BTHE = -XIACPI*SINTHE*        
     1       (((2.*RAD2)-R2+(RADIUS*R*SINTHE))/((SQAR2S)**5))        
C        
C     RESOLVE MAGNETIC FIELD COMPONENTS INTO RECTANGULAR COMPONENTS     
C        
  230 CONTINUE        
      HCX = RX*BR + RPX*BTHE        
      HCY = RY*BR + RPY*BTHE        
      HCZ = RZ*BR + RPZ*BTHE        
      HC1 = HCX/FPI        
      HC2 = HCY/FPI        
      HC3 = HCZ/FPI        
      RETURN        
      END        
