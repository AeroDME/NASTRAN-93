      SUBROUTINE SUBA        
C        
C     UNSTEADY FLOW ANAYSIS OF A SUPERSONIC CASCADE        
C        
C     LIFT AND MOMENT COEFICIENT        
C        
      DIMENSION       PRES1(21),PRES2(21),PRES3(21),PRES4(21),QRES4(21),
     1                SBKDE1(201),SBKDE2(201),SUMSV1(201),SUMSV2(201),  
     2                SVKL1(201),SVKL2(201),XLSV1(21),XLSV2(21),        
     3                XLSV3(21),XLSV4(21)        
      COMPLEX         SBKDE1,SBKDE2,F4,F4S,AM4,F5S,F6S,AM4TST,SUM3,SUM4,
     1                AM5TT,AM6,SUMSV1,SUMSV2,SVKL1,SVKL2,F5,F5T,AM5,   
     2                AM5T,AI,A,B,BSYCON,ALP,F1,AM1,ALN,BLKAPM,BKDEL3,  
     3                F1S,C1,C2P,C2N,C2,AMTEST,FT2,BLAM1,FT3,AM2,SUM1,  
     4                SUM2,F2,BLAM2,FT2T,C1T,FT3T,F2P,AM2P,SUM1T,SUM2T, 
     5                C1P,C1N,BKDEL1,BKDEL2,BLKAP1,ARG,ARG2,FT3TST,BC,  
     6                BC2,BC3,BC4,BC5,CA1,CA2,CA3,CA4,CLIFT,CMOMT,      
     7                PRES1,PRES2,PRES3,PRES4,QRES4,FQA,FQB,T1,T2,T3,T4,
     8                GUSAMP,FQ7,CEXP3,CEXP4,CEXP5,CONST,C1A,C2A        
      CHARACTER       UFM*23        
      COMMON /XMSSG / UFM        
      COMMON /SYSTEM/ SYSBUF,IBBOUT        
      COMMON /BLK1  / SCRK,SPS,SNS,DSTR,AI,PI,DEL,SIGMA,BETA,RES        
      COMMON /BLK2  / BSYCON        
      COMMON /BLK3  / SBKDE1,SBKDE2,F4,F4S,AM4,F5S,F6S,AM4TST,SUM3,SUM4,
     1                AM5TT,AM6,SUMSV1,SUMSV2,SVKL1,SVKL2,F5,F5T,AM5,   
     2                AM5T,A,B,ALP,F1,AM1,ALN,BLKAPM,BKDEL3,F1S,C1,C2P, 
     3                C2N,C2,AMTEST,FT2,BLAM1,FT3,AM2,SUM1,SUM2,F2,     
     4                BLAM2,FT2T,C1T,FT3T,F2P,AM2P,SUM1T,SUM2T,C1P,C1N, 
     5                BKDEL1,BKDEL2,BLKAP1,ARG,ARG2,FT3TST,BC,BC2,BC3,  
     6                BC4,BC5,CA1,CA2,CA3,CA4,CLIFT,CMOMT,PRES1,PRES2,  
     7                PRES3,PRES4,QRES4,FQA,FQB,FQ7        
      COMMON /BLK4  / I,R,Y,A1,B1,C4,C5,GL,I6,I7,JL,NL,RI,RT,R5,SN,SP,  
     1                XL,Y1,AMU,GAM,IDX,INX,NL2,RL1,RL2,RQ1,RQ2,XL1,    
     2                ALP1,ALP2,GAMN,GAMP,INER,IOUT,REDF,STAG,STEP,     
     3                AMACH,BETNN,BETNP,BKAP1,XLSV1,XLSV2,XLSV3,XLSV4,  
     4                ALPAMP,AMOAXS,GUSAMP,DISAMP,PITAXS,PITCOR        
C        
      S1   = SPS - SNS        
      S2   = SPS*DEL - SIGMA        
      S3   = SPS/(DSTR**2)        
      S4   = SNS/DSTR        
      S0   = 2.0 - SPS + SNS        
      T1   = CEXP(-AI*SIGMA)        
      T2   = CEXP(AI*SIGMA)        
      A1   = 2.0*PI/S1        
      B1   = S2/S1        
      GAM  = S2        
      C1P  = GAM/DSTR - SCRK        
      C1N  = GAM/DSTR + SCRK        
      ALP  = GAM*S3 + S4*CSQRT(C1P)*CSQRT(C1N)        
      BC   = -B1/ALP*BSYCON/SIN(PI*B1/A1)        
      T3   = ALP - DEL        
      F1   = (ALP-AMU)/T3*AI*SNS/(BETA*(GAM-ALP*SPS))        
      ARG2 = DEL        
      CALL AKAPM (ARG2,BKDEL1)        
      ARG  = DEL - GL        
      CALL AKAPM  (ARG,BKDEL2)        
      CALL DLKAPM (ARG2,BLKAP1)        
      INX  = 0        
      CALL DRKAPM (ALP,INX,BLKAPM)        
      F1   = F1*BKDEL1/BLKAPM*(-T3/(T3+GL)*A*AI*BKDEL2/BKDEL1 +        
     1       B*BLKAP1+B/T3)        
      F1S  = F1        
      NL   = 10        
      RL1  = NL - 1        
      CEXP3 = CEXP(-AI*T3/RL1*S1)        
      PRES1(1) = F1S        
      NNL1 = NL - 1        
      DO 453 JL = 1,NNL1        
      PRES1(JL+1) = PRES1(JL)*CEXP3        
  453 CONTINUE        
      F1   = F1*AI/T3*(CEXP(-AI*T3*S1)-1.0)        
      AM1  = F1/(AI*T3)-F1S/(AI*T3)*S1*CEXP(-AI*T3*S1)        
      AMTEST = 0.0        
      FQB  = BKDEL1/(BETA*BC)*CEXP(AI*S2/2.0)*        
     1      (-A*AI*BKDEL2/BKDEL1+B*BLKAP1)        
      DO 20 I = 1,200        
      R    = I        
      GAMP = 2.0*PI*R + S2        
      GAMN =-2.0*PI*R + S2        
      C1P  = (GAMP/DSTR) - SCRK        
      C2P  = (GAMP/DSTR) + SCRK        
      ALP  = GAMP*S3 + S4*CSQRT(C1P)*CSQRT(C2P)        
      T3   = ALP - DEL        
      IDX  = I        
      CALL DRKAPM (ALP,IDX,BLKAPM)        
      C1   = (ALP-AMU)/T3*AI*SNS/(BETA*(GAMP-ALP*SPS))*BKDEL1/        
     1       (BLKAPM)*(-T3/(T3+GL)*A*AI*BKDEL2/BKDEL1+B*BLKAP1+B/T3)    
      C1N  = (GAMN/DSTR) - SCRK        
      C2N  = (GAMN/DSTR) + SCRK        
      ALN  = GAMN*S3 + S4*CSQRT(C1N)*CSQRT(C2N)        
      T4   = ALN - DEL        
      IDX  =-I        
      CALL DRKAPM (ALN,IDX,BLKAPM)        
      C2   = (ALN-AMU)/T4*AI*SNS/(BETA*(GAMN-ALN*SPS))*BKDEL1/        
     1       (BLKAPM)*(-T4/(T4+GL)*A*AI*BKDEL2/BKDEL1+B*BLKAP1+B/T4)    
      F1   = F1+C1*AI/T3*(CEXP(-AI*T3*S1)-1.0)+C2*AI/        
     1       T4*(CEXP(-AI*T4*S1)-1.0)        
      AM1  = AM1+C1/(AI*T3)*(-S1*CEXP(-AI*T3*S1)+AI/        
     1       T3*(CEXP(-AI*T3*S1)-1.0))+C2/(AI*T4)*        
     2       (-S1*CEXP(-AI*T4*S1)+AI/T4*(CEXP(-AI*T4*S1)-1.0))        
      C2A  = C2        
      C1A  = C1        
      AA   = S1/RL1        
      CEXP3 = CEXP(-AI*T3*AA)        
      CEXP4 = CEXP(-AI*T4*AA)        
      TEMP  = 2.0*PI*R        
      CEXP5 = CEXP(AI*(SIGMA-SNS*DEL)/S1*AA)        
      CONST = 4.0*FQB/TEMP        
      PRES1(1) = PRES1(1) + C1 + C2        
      DO 454 JL = 1,NNL1        
      CONST = CONST*CEXP5        
      C1A   = C1A*CEXP3        
      C2A   = C2A*CEXP4        
      PRES1(JL+1) = PRES1(JL+1) + C1A + C2A        
      PRES1(JL+1) = PRES1(JL+1) + CONST*SIN(TEMP*JL/RL1)        
  454 CONTINUE        
      IF (CABS((AM1-AMTEST)/AM1) .LT. 0.0005) GO TO 45        
      AMTEST = AM1        
   20 CONTINUE        
      GO TO 9992        
 9992 WRITE  (IBBOUT,3005) UFM        
 3005 FORMAT (A23,' FROM AMG MODULE. AM1 LOOP IN SUBROUTINE SUBA DID ', 
     1        'NOT CONVERGE.')        
      CALL MESAGE (-61,0,0)        
   45 CONTINUE        
      AA    = S1/RL1        
      CEXP3 = CEXP(AI*(SIGMA-SNS*DEL)/RL1)        
      CONST = FQB        
      TEMP  = 2.0*AA/(SPS-SNS)        
      PRES1(1) = PRES1(1) - FQB        
      DO 4541 JL = 1,NNL1        
      CONST = CONST*CEXP3        
      PRES1(JL+1) = PRES1(JL+1) - CONST*(1.0-JL*TEMP)        
 4541 CONTINUE        
      Y    = 0.0        
      Y1   = SNS        
      ARG  = DEL - GL        
      CALL ALAMDA (ARG,Y,BLAM1)        
      CALL ALAMDA (ARG,Y1,BLAM2)        
      CALL AKAPPA (ARG,BKAP1)        
      FT2  = A*AI*(DEL-GL-AMU)*BLAM1/BKAP1        
      FT2T = A*AI*(DEL-GL-AMU)*BLAM2/BKAP1        
      ARG  = DEL        
      CALL ALAMDA (ARG,Y,BLAM1)        
      CALL ALAMDA (ARG,Y1,BLAM2)        
      CALL AKAPPA (ARG,BKAP1)        
      GAM  = SQRT(DEL**2-SCRK**2)        
      S5   = SIN(SNS*GAM)        
      S6   = COS(SNS*GAM)        
      C1   =-1.0/(BETA*GAM*S5)        
      C1T  = C1*(AI*SPS*T2*S6-SNS*DEL/GAM*T2*S5)-BLAM2/BKAP1*DEL/GAM*(S5
     1       +GAM*SNS*S6)/(GAM*S5)        
      C1   = C1*(ARG/GAM*SNS*S5+AI*SPS*T2)-BLAM1/BKAP1*DEL/(GAM*S5)*(S5/
     1       GAM+SNS*S6)        
      FT3  =-B*(BLAM1/BKAP1+(DEL-AMU)*C1)        
      FT3T =-B*(BLAM2/BKAP1+(DEL-AMU)*C1T)        
      IF (GL .EQ. 0.0) GO TO 50        
      F2   = FT2*(CEXP(2.0*AI*GL)-CEXP(AI*GL*S1))/(AI*GL)+        
     1       FT3*S0+B*AI*(DEL-AMU)*BLAM1/BKAP1*(4.0-S1**2)/2.0        
      AM2  = FT2*(2.0*CEXP(2.0*AI*GL)/(AI*GL)-S1/(AI*GL)*CEXP(GL*AI*S1)+
     1       (CEXP(2.0*AI*GL)-CEXP(AI*S1*GL))/GL**2)+FT3*(4.0-S1**2)/2.0
     2       +B*AI*(DEL-AMU)*BLAM1/BKAP1*(8.0-S1**3)/3.0        
      F2P  = FT2T*T1*CEXP(AI*GL*SNS)/(AI*GL)*(CEXP(2.0*AI*GL)-        
     1       CEXP(AI*GL*S1))+FT3T*T1*S0+B*AI*(DEL-AMU)*T1*BLAM2/        
     2       BKAP1*(S0**2/2.0+SPS*S0)        
      AM2P = FT2T*T1*(CEXP(AI*GL*SPS)/(AI*GL)*S0*CEXP(AI*GL*S0)+        
     1       CEXP(AI*GL*SPS)/(GL**2)*(CEXP(AI*GL*S0)-1.0))+        
     2       FT3T*T1*S0**2/2.0+B*AI*(DEL-AMU)*T1*BLAM2/BKAP1*(S0**3/3.0+
     3       SPS*S0**2/2.0)        
      GO TO 55        
   50 CONTINUE        
      F2   = FT2*S0+FT3*S0+B*AI*(DEL-AMU)*BLAM1/BKAP1*(4.-S1**2)/2.     
      AM2  = FT2*(4.0-S1**2)/2.0+FT3*(4.0-S1**2)/2.0+B*AI*(DEL-AMU)*    
     1       BLAM1/BKAP1*(8.0-S1**3)/3.0        
      F2P  = FT2T*T1*S0+FT3T*T1*S0+B*AI*(DEL-AMU)*T1*BLAM2/BKAP1*(S0**2 
     1       /2.0+SPS*S0)        
      AM2P = FT2T*T1*S0**2/2.0+FT3T*T1*S0**2/2.0+B*AI*(DEL-AMU)*T1*BLAM2
     1       /BKAP1*(S0**3/3.0+SPS*S0**2/2.0)        
   55 CONTINUE        
      NL2  = 20        
      RL2  = NL2 - 1        
      AA   = SPS - SNS        
      CONST = B*AI*(DEL-AMU)*BLAM1/BKAP1        
      TEMP = S0/RL2        
      C1A  = AI*GL        
      CEXP3 = CEXP(C1A*AA)        
      CEXP4 = CEXP(C1A*TEMP)        
      DO 455 JL = 1,NL2        
      XL = AA + TEMP*(JL-1)        
      PRES2(JL) = FT2*CEXP3 + FT3+CONST*XL        
      CEXP3 = CEXP3*CEXP4        
  455 CONTINUE        
      CALL SUBBB        
      RETURN        
      END        
