      SUBROUTINE SDHTF2(IEQEX,NEQEX)        
C*****        
C     THIS ROUTINE CALCULATES TEMPERATURE GRADIENTS AND HEAT FLOWS      
C     FOR ALL ELEMENTS IN A HEAT TRANSFER PROBLEM.        
C      DATA IS OUTPUT FOR ELEMENT FORCE REQUEST ONLY.        
C******        
      INTEGER  IGRAD(3), IQOUT(3), FTUBE        
      REAL    ESTA(202)        
      DIMENSION IZ(1),IPT(21)        
CZZ   COMMON /ZZSDR2/  ZZ(1)        
      COMMON /ZZZZZZ/  ZZ(1)        
      COMMON  /SDR2X4/  DUMMY(35),IVEC        
      COMMON/SDR2X7/IDE,ISIL(32),NQ,NSIL,NAME(2),RK(9),CE(96),        
     1              DUM(58),IDO,NAMO(2),TGRAD(3),QOUT(3)        
      COMMON/SDR2X8/TVEC(32)        
      EQUIVALENCE  (TGRAD(1),IGRAD(1)) ,(QOUT(1),IQOUT(1))        
      EQUIVALENCE  (ZZ(1),IZ(1)), (ESTA(1),IDE)        
      DATA IHEX/4HIHEX/,IONE,ITWO,ITHR/4H1   ,4H2   ,4H3   /        
      DATA IHEX1,IHEX2,IHEX3/4HHEX1,4HHEX2,4HHEX3/        
      DATA FTUBE/4HFTUB/        
      DATA IOLD/0/        
      DATA IPT/4H   1,4H  E1,4H   4,4H  E2,4H   7,4H  E3,4H  10,        
     1         4H  E4,4H  E5,4H  E6,4H  E7,4H  E8,4H  21,4H  E9,        
     2         4H  24,4H E10,4H  27,4H E11,4H  30,4H E12,4H   0/        
C        
      IF (NAME(1) .EQ. FTUBE) GO TO 70        
      DO 10 I=1,3        
      IGRAD(I)= 1        
   10 IQOUT(I)= 1        
      IDO= IDE        
      NAMO(1)= NAME(1)        
      NAMO(2)= NAME(2)        
C        
C FOR ISOPARAMETRIC SOLIDS, GET SIL NUMBER AND CONVERT TO EXTERNAL.     
C STORE IT IN NAMO(2)        
C        
      IF(NAMO(1).NE.IHEX) GO TO 29        
      IF(IOLD.EQ.IDE) GO TO 11        
      IOLD=IDE        
      ISTRPT=0        
   11 IF(NAMO(2).EQ.IONE) NAMO(1)=IHEX1        
      IF(NAMO(2).EQ.ITWO) NAMO(1)=IHEX2        
      IF(NAMO(2).EQ.ITHR) NAMO(1)=IHEX3        
      ISTRPT=ISTRPT+1        
      IF(ISTRPT.EQ.NSIL+1.OR.ISTRPT.EQ.21) IOLD=0        
      IF(NAMO(1).EQ.IHEX3) GO TO 12        
      IF(NAMO(1).EQ.IHEX1.AND.ISTRPT.EQ.9) GO TO 15        
      IF(NAMO(1).EQ.IHEX2.AND.ISTRPT.EQ.21) GO TO 15        
      GO TO 13        
   12 NAMO(2)=IPT(ISTRPT)        
      GO TO 29        
   13 ISUB1=IEQEX+1        
      ISUB2=IEQEX+NEQEX-1        
      DO 14 JJJ=ISUB1,ISUB2,2        
      NS=IZ(JJJ)/10        
      IF(NS.NE.ISIL(ISTRPT)) GO TO 14        
      NAMO(2)=IZ(JJJ-1)        
      GO TO 29        
   14 CONTINUE        
      CALL MESAGE(-30,164,IZ(JJJ))        
   15 NAMO(2)=0        
   29 CONTINUE        
      IF(NQ .LE. 0) GO TO 60        
      DO 30 I=1,NSIL        
      TVEC(I)= 0.0        
      IP= ISIL(I)        
      IF( IP .EQ. 0) GO TO 30        
      ITEMP = IVEC + IP -1        
      TVEC(I) = ZZ(ITEMP)        
   30 CONTINUE        
C***        
      CALL GMMATS( CE(1),NQ,NSIL,0, TVEC(1),NSIL,1,0, TGRAD(1) )        
C        
      CALL GMMATS( RK(1),NQ,NQ,0, TGRAD(1),NQ,1,0, QOUT(1) )        
C        
      DO 40 I=1,NQ        
   40 QOUT(I) =-QOUT(I)        
      RETURN        
   60 TGRAD(1) = 0.0        
      QOUT(1) = 0.0        
      GO TO 80        
C        
   70 IDO=IDE        
      ITEMP=IVEC + ISIL(1) - 1        
      TVEC(1)=ZZ(ITEMP)        
      ESTA(202)=TVEC(1)*ESTA(4)        
C        
   80 RETURN        
      END        
