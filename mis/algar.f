      SUBROUTINE ALGAR
C
      REAL LOSS,LAMI,LAMIP1,LAMIM1
C
      DIMENSION XX1(21),XX2(21),XX3(21),XX4(21),VMOLD(21),VMLOLD(21)
      DIMENSION DELTAR(59,30),PASS(59)
C
      COMMON /UD3PRT/ IPRTC
      COMMON /CONTRL/ NANAL,NAERO,NARBIT,LOQ1,LOQ2,LOQ3,LOQ4,LOQ5,LOQ6
      COMMON /UD300C/ NSTNS,NSTRMS,NMAX,NFORCE,NBL,NCASE,NSPLIT,NREAD,
     1NPUNCH,NPAGE,NSET1,NSET2,ISTAG,ICASE,IFAILO,IPASS,I,IVFAIL,IFFAIL,
     2NMIX,NTRANS,NPLOT,ILOSS,LNCT,ITUB,IMID,IFAIL,ITER,LOG1,LOG2,LOG3,
     3LOG4,LOG5,LOG6,IPRINT,NMANY,NSTPLT,NEQN,NSPEC(30),NWORK(30),
     4NLOSS(30),NDATA(30),NTERP(30),NMACH(30),NL1(30),NL2(30),NDIMEN(30)
     5,IS1(30),IS2(30),IS3(30),NEVAL(30),NDIFF(4),NDEL(30),NLITER(30),
     6NM(2),NRAD(2),NCURVE(30),NWHICH(30),NOUT1(30),NOUT2(30),NOUT3(30),
     7NBLADE(30),DM(11,5,2),WFRAC(11,5,2),R(21,30),XL(21,30),X(21,30),
     8H(21,30),S(21,30),VM(21,30),VW(21,30),TBETA(21,30),DIFF(15,4),
     9FDHUB(15,4),FDMID(15,4),FDTIP(15,4),TERAD(5,2),DATAC(100),
     1DATA1(100),DATA2(100),DATA3(100),DATA4(100),DATA5(100),DATA6(100),
     2DATA7(100),DATA8(100),DATA9(100),FLOW(10),SPEED(30),SPDFAC(10),
     3BBLOCK(30),BDIST(30),WBLOCK(30),WWBL(30),XSTN(150),RSTN(150),
     4DELF(30),DELC(100),DELTA(100),TITLE(18),DRDM2(30),RIM1(30),
     5XIM1(30),WORK(21),LOSS(21),TANEPS(21),XI(21),VV(21),DELW(21),
     6LAMI(21),LAMIM1(21),LAMIP1(21),PHI(21),CR(21),GAMA(21),SPPG(21),
     7CPPG(21),HKEEP(21),SKEEP(21),VWKEEP(21),DELH(30),DELT(30),VISK,
     8SHAPE,SCLFAC,EJ,G,TOLNCE,XSCALE,PSCALE,PLOW,RLOW,XMMAX,RCONST,
     9FM2,HMIN,C1,PI,CONTR,CONMX
C
      IF = 0
      LOG1=LOQ1
      LOG2=LOQ2
      LOG3=LOQ3
      LOG5=LOQ5
      LOG6=LOQ6
      IF (IPRTC .EQ. 1) WRITE(LOG2,1)
1     FORMAT(1HT)                                                       
      PI=3.141592653589
      C1=180.0/PI
      HMIN=50.0
      VMIN = 25.0
      IF (IPRTC .EQ. 1) WRITE(LOG2,50)
50    FORMAT(1H1,37X, 53HPROGRAM ALG - COMPRESSOR DESIGN - AERODYNAMIC S
     1ECTION,/,38X,53(1H*))                                             
      LNCT=2
      CALL ALG02
      ICASE=1
  100 IF (IPRTC .EQ. 1) WRITE(LOG2,104) ICASE
104   FORMAT(1H1,9X,20HOUTPUT FOR POINT NO.,I2,/,10X,22(1H*))           
      LNCT=2
      DO 106 I=1,30
      DO 106 J=1,59
106   DELTAR(J,I)=0.0
      IF((ICASE.EQ.1.AND.NREAD.EQ.1).OR.(ICASE.GT.1.AND.IFAILK.EQ.0))GO
     1TO 254
      IF(NSPLIT.EQ.1)GO TO 170
      L1=NSPEC(1)
      XX1(1)=0.0
      DO 110 K=2,L1
110   XX1(K)=XX1(K-1)+SQRT((RSTN(K)-RSTN(K-1))**2+(XSTN(K)-XSTN(K-1))**2
     1)
      X1=1.0/XX1(L1)
      DO 120 K=2,L1
120   XX1(K)=XX1(K)*X1
      DO 130 K=1,11
130   XX2(K)=FLOAT(K-1)*0.1
      CALL ALG01(XX1,XSTN,L1,XX2,XX3,X1,11,0,0)
      CALL ALG01(XX1,RSTN,L1,XX2,XX4,X1,11,0,0)
      DO 136 K=2,11
      XX1(K)=XX1(K-1)+SQRT((XX3(K)-XX3(K-1))**2+(XX4(K)-XX4(K-1))**2)
136   XX3(K-1)=(XX1(K)+XX1(K-1))*0.5
      L2=IS1(2)
      XX2(1)=ATAN2(RSTN(L2)-RSTN(1),XSTN(L2)-XSTN(1))
      L2=L2+NSPEC(2)-1
      XX2(2)=ATAN2(RSTN(L2)-RSTN(L1),XSTN(L2)-XSTN(L1))
      XI(1)=0.0
      XI(2)=XX1(11)
      CALL ALG01(XI,XX2,2,XX3,PHI,X1,10,1,0)
      CALL ALG01(RSTN,XSTN,L1,XX3,X1,GAMA,10,0,1)
      XX3(1)=0.0
      DO 140 K=2,11
140   XX3(K)=XX3(K-1)+COS(PHI(K-1)+ATAN(GAMA(K-1)))*(XX4(K)+XX4(K-1))*(X
     1X1(K)-XX1(K-1))
      X1=1.0/XX3(11)
      X2=1.0/XX1(11)
      DO 150 K=2,11
      XX1(K)=XX1(K)*X2
150   XX3(K)=XX3(K)*X1
      X1=1.0/FLOAT(ITUB)
      DO 160 K=1,NSTRMS
160   XX2(K)=FLOAT(K-1)*X1
      CALL ALG01(XX1,XX3,11,XX2,DELF,X1,NSTRMS,1,0)
170   DO 250 I=1,NSTNS
      L1=IS1(I)
      L2=NSPEC(I)
      XX1(1)=0.0
      VV(1)=0.0
      DO 180 K=2,L2
      L3=L1+K-1
180   VV(K)=VV(K-1)+SQRT((RSTN(L3)-RSTN(L3-1))**2+(XSTN(L3)-XSTN(L3-1))*
     1*2)
      X1=1.0/VV(L2)
      DO 190 K=2,L2
190   XX1(K)=VV(K)*X1
      DO 200 K=1,11
200   XX2(K)=FLOAT(K-1)*0.1
      CALL ALG01(XX1,XSTN(L1),L2,XX2,XX3,X1,11,0,0)
      CALL ALG01(XX1,RSTN(L1),L2,XX2,XX4,X1,11,0,0)
      DO 230 K=2,11
      XX1(K)=XX1(K-1)+SQRT((XX3(K)-XX3(K-1))**2+(XX4(K)-XX4(K-1))**2)
      GAMA(K-1)=(XX4(K)+XX4(K-1))*0.5
230   XX3(K-1)=(XX1(K)+XX1(K-1))*0.5
      IF(I.EQ.1.OR.I.EQ.NSTNS)GO TO 234
      L3=IS1(I+1)
      L4=IS1(I-1)
      L5=L1
      XX2(1)=(ATAN2(RSTN(L3)-RSTN(L5),XSTN(L3)-XSTN(L5))+ATAN2(RSTN(L5)-
     1RSTN(L4),XSTN(L5)-XSTN(L4)))*0.5
      L3=L3+NSPEC(I+1)-1
      L4=L4+NSPEC(I-1)-1
      L5=L5+L2-1
      XX2(2)=(ATAN2(RSTN(L3)-RSTN(L5),XSTN(L3)-XSTN(L5))+ATAN2(RSTN(L5)-
     1RSTN(L4),XSTN(L5)-XSTN(L4)))*0.5
      GO TO 238
234   IF(I.EQ.NSTNS)GO TO 236
      L3=IS1(2)
      XX2(1)=ATAN2(RSTN(L3)-RSTN(1),XSTN(L3)-XSTN(1))
      L4=NSPEC(1)
      L3=L3+NSPEC(2)-1
      XX2(2)=ATAN2(RSTN(L3)-RSTN(L4),XSTN(L3)-XSTN(L4))
      GO TO 238
236   L4=IS1(I-1)
      XX2(1)=ATAN2(RSTN(L1)-RSTN(L4),XSTN(L1)-XSTN(L4))
      L4=L4+NSPEC(I-1)-1
      L3=L1+L2-1
      XX2(2)=ATAN2(RSTN(L3)-RSTN(L4),XSTN(L3)-XSTN(L4))
238   XI(1)=0.0
      XI(2)=XX1(11)
      CALL ALG01(XI,XX2,2,XX3,PHI,X1,10,1,0)
      CALL ALG01(RSTN(L1),XSTN(L1),L2,GAMA,X1,GAMA,10,0,1)
      XX3(1)=0.0
      DO 240 K=2,11
240   XX3(K)=XX3(K-1)+COS(PHI(K-1)+ATAN(GAMA(K-1)))*(XX4(K)+XX4(K-1))*(X
     1X1(K)-XX1(K-1))
      X1=1.0/XX3(11)
      DO 244 K=2,11
244   XX3(K)=XX3(K)*X1
      CALL ALG01(XX3,XX1,11,DELF,XL(1,I),X1,NSTRMS,1,0)
      X1=VV(L2)/XX1(11)
      DO 246 J=2,NSTRMS
246   XL(J,I)=XL(J,I)*X1
      CALL ALG01(VV,XSTN(L1),L2,XL(1,I),X(1,I),X1,NSTRMS,0,0)
250   CALL ALG01(VV,RSTN(L1),L2,XL(1,I),R(1,I),X1,NSTRMS,0,0)
254   IF(ICASE.GT.1)GO TO 270
      X1=(X(IMID,2)-X(IMID,1))**2+(R(IMID,2)-R(IMID,1))**2
      DRDM2(1)=((R(NSTRMS,1)-R(1,1))**2+(X(NSTRMS,1)-X(1,1))**2)/X1
      L1=NSTNS-1
      DO 260 I=2,L1
      X2=(X(IMID,I+1)-X(IMID,I))**2+(R(IMID,I+1)-R(IMID,I))**2
      X3=X2
      IF(X1.LT.X3)X3=X1
      DRDM2(I)=((R(NSTRMS,I)-R(1,I))**2+(X(NSTRMS,I)-X(1,I))**2)/X3
260   X1=X2
      DRDM2(NSTNS)=((R(NSTRMS,NSTNS)-R(1,NSTNS))**2+(X(NSTRMS,NSTNS)-X(1
     1,NSTNS))**2)/X2
270   DO 280 I=1,NSTNS
280   WWBL(I)=WBLOCK(I)
      IPASS=1
290   I=1
      IF((IPASS.GT.1.OR.ICASE.GT.1).AND.NDATA(1).EQ.1)GO TO 400
      L1=NDIMEN(1)+1
      GO TO(300,320,340,360),L1
300   DO 310 J=1,NSTRMS
310   XX1(J)=R(J,1)
      GO TO 380
320   DO 330 J=1,NSTRMS
330   XX1(J)=R(J,1)/R(NSTRMS,1)
      GO TO 380
340   DO 350 J=1,NSTRMS
350   XX1(J)=XL(J,1)
      GO TO 380
360   DO 370 J=1,NSTRMS
370   XX1(J)=XL(J,1)/XL(NSTRMS,1)
380   L1=NTERP(1)
      L2=NDATA(1)
      CALL ALG01(DATAC,DATA1,L2,XX1,S    ,X1,NSTRMS,L1,0)
      CALL ALG01(DATAC,DATA2,L2,XX1,H    ,X1,NSTRMS,L1,0)
      CALL ALG01(DATAC,DATA3,L2,XX1,TBETA,X1,NSTRMS,L1,0)
      DO 390 J=1,NSTRMS
      H(J,1)=ALG6(S(J,1),H(J,1))
      S(J,1)=ALG3(S(J,1),H(J,1))
390   TBETA(J,1)=TAN(TBETA(J,1)/C1)
400   IF(IPASS.GT.1.OR.ICASE.GT.1)GO TO 420
      X1=FLOW(1)/(ALG5(H,S)*PI*(R(NSTRMS,1)+R(1,1))*XL(NSTRMS,1))*SCLFAC
     1**2
      DO 410 J=1,NSTRMS
410   VM(J,1)=X1
      IF(ISTAG.EQ.1)VM(1,1)=0.0
420   IFAILO=0
      IFFAIL=0
      IVFAIL=0
      DO 430 J=1,NSTRMS
430   VMOLD(J)=VM(J,1)
      GO TO 500
440   IF(IPASS.GT.1)GO TO 460
      DO 450 J=1,NSTRMS
450   VM(J,I)=VM(J,I-1)
      IF(I-1.EQ.ISTAG)VM(1,I)=VM(2,I)
      IF(I.EQ.ISTAG)VM(1,I)=0.0
460   ILOSS=1
      DO 464 J=1,NSTRMS
464   VMOLD(J)=VM(J,I)
470   DO 474 J=1,NSTRMS
      VWKEEP(J)=VW(J,I-1)
      SKEEP(J)=S(J,I-1)
474   HKEEP(J)=H(J,I-1)
      X1=H(IMID,I-1)-(VM(IMID,I-1)**2+VW(IMID,I-1)**2)/(2.0*G*EJ)
      IF(X1.LT.HMIN)X1=HMIN
      PSMID=ALG4(X1,S(IMID,I-1))
      IF(NMIX.EQ.1)CALL ALG04(H(1,I-1),S(1,I-1),VW(1,I-1),R(1,I-1),R(1,
     1I),X(1,I-1),X(1,I),VM(1,I-1),CONMX,SCLFAC,G,EJ,HMIN,VMIN,PSMID,NST
     2RMS,LOG2,LNCT,IF)
      IF(IF.EQ.0)GO TO 478
      IFAILO=I-1
      GO TO 640
478   IF(NWORK(I).EQ.0)GO TO 480
      CALL ALG05
      IF(NTRANS.EQ.1.AND.IPASS.GT.1)CALL ALG06(R(1,I-1),R(1,I),X(1,I-1)
     1,X(1,I),H(1,I),S(1,I),VM(1,I),TBETA(1,I-1),TBETA(1,I),LOSS,CONTR,S
     2CLFAC,SPEED(I),SPDFAC(ICASE),G,EJ,HMIN,NSTRMS,PI)
      ITER=0
      CALL ALG07
      GO TO 500
480   DO 490 J=1,NSTRMS
      H(J,I)=H(J,I-1)
      S(J,I)=S(J,I-1)
      VW(J,I)=0.0
      IF(I.GT.ISTAG.OR.J.NE.1)VW(J,I)=VW(J,I-1)*RIM1(J)/R(J,I)
490   CONTINUE
500   DO 510 J=1,NSTRMS
510   VMLOLD(J)=VM(J,I)
      IF(NEQN.GE.2)GO TO 514
      CALL ALG08
      GO TO 516
  514 CALL ALG26
516   IF(NEVAL(I).LE.0)GO TO 590
      IPRINT=0
      CALL ALG09
      IF(IFAILO.NE.0.AND.IPASS.GT.NFORCE)GO TO 550
      DO 520 J=1,NSTRMS
      IF(ABS(VM(J,I)/VMLOLD(J)-1.0).GT.TOLNCE/5.0)GO TO 530
520   CONTINUE
      GO TO 590
530   IF(ILOSS.GE.NLITER(I))GO TO 550
      ILOSS=ILOSS+1
      DO 540 J=1,NSTRMS
540   VMLOLD(J)=VM(J,I)
      GO TO 470
550   IF(IPASS.LE.NFORCE)GO TO 590
      IF(LNCT+1.LE.NPAGE)GO TO 570
      IF (IPRTC .EQ. 1) WRITE(LOG2,560)
560   FORMAT(1H1)                                                       
      LNCT=1
570   LNCT=LNCT+1
      X1=VM(1,I)/VMLOLD(1)
      X2=VM(IMID,I)/VMLOLD(IMID)
      X3=VM(NSTRMS,I)/VMLOLD(NSTRMS)
      IF (IPRTC .EQ. 1) WRITE(LOG2,580) IPASS,I,X1,X2,X3
580   FORMAT(5X,4HPASS,I3,9H  STATION,I3,66H  VM PROFILE NOT CONVERGED W
     1ITH LOSS RECALC   VM NEW/VM PREV  HUB=,F9.6,6H  MID=,F9.6,7H  CASE
     2=,F9.6)                                                           
590   IF(NBL.EQ.1.AND.(IFAILO.EQ.0.OR.IPASS.LE.NFORCE))CALL ALG10
      DO 600 J=1,NSTRMS
      XIM1(J)=X(J,I)
      RIM1(J)=R(J,I)
      IF(I.EQ.ISTAG.AND.J.EQ.1)GO TO 600
      IF(ABS(VM(J,I)/VMOLD(J)-1.0).GT.TOLNCE)IVFAIL=IVFAIL+1
      IF(ABS(DELW(J)-DELF(J)).GT.TOLNCE)IFFAIL=IFFAIL+1
600   CONTINUE
      IF(NMAX.EQ.1.OR.(IPASS.EQ.1.AND.NREAD.EQ.1))GO TO 624
      X1=FM2
      IF(X1.LT.1.0-XMMAX)X1=1.0-XMMAX
      X2=1.0
      IF(I.EQ.1.OR.NWORK(I).GE.5)X2=1.0+TBETA(IMID,I)**2
      X1=1.0/(1.0+X1*DRDM2(I)/(RCONST*X2))
      L3=NSTRMS-2
      CALL ALG01(DELW,XL(1,I),NSTRMS,DELF(2),XX1(2),X1,L3,1,0)
      XX=XL(IMID,I)
      DO 610 J=2,ITUB
610   XL(J,I)=XL(J,I)+X1*(XX1(J)-XL(J,I))
      L1=IPASS
      IF(L1.LE.59)GO TO 618
      L1=59
      DO 616 K=1,58
616   DELTAR(K,I)=DELTAR(K+1,I)
618   DELTAR(L1,I)=XL(IMID,I)-XX
      L1=IS1(I)
      L2=NSPEC(I)
      XX1(1)=0.0
      DO 620 K=2,L2
      KK=L1-1+K
620   XX1(K)=XX1(K-1)+SQRT((XSTN(KK)-XSTN(KK-1))**2+(RSTN(KK)-RSTN(KK-1)
     1)**2)
      CALL ALG01(XX1,RSTN(L1),L2,XL(2,I),R(2,I),X1,L3,0,0)
      CALL ALG01(XX1,XSTN(L1),L2,XL(2,I),X(2,I),X1,L3,0,0)
624   IF(IPASS.GT.NFORCE.AND.IFAILO.NE.0)GO TO 640
      IF(I.EQ.NSTNS)GO TO 630
      I=I+1
      GO TO 440
630   IF(IPASS.GE.NMAX)GO TO 640
      IF(IFAILO.NE.0)GO TO 635
      IF(IVFAIL.EQ.0.AND.IFFAIL.EQ.0)GO TO 640
635   IPASS=IPASS+1
      GO TO 290
640   CALL ALG11
      L1=NSTNS
      IF(IFAILO.NE.0)L1=IFAILO
      IPRINT=1
      DO 650 I=2,L1
      IF(NEVAL(I).NE.0)CALL ALG09
650   CONTINUE
      IF(NPLOT.NE.0)CALL ALG12
      IF(IFAILO.NE.0)GO TO 750
      IF(NPUNCH.EQ.0)GO TO 680
      WRITE(LOG3,660)(DELF(J),J=1,NSTRMS)
660   FORMAT(6F12.8)                                                    
      WRITE(LOG3,670)((R(J,I),X(J,I),XL(J,I),I,J,J=1,NSTRMS),I=1,NSTNS)
670   FORMAT(3F12.8,2I3)                                                
680   DO 700 I=1,NSTNS
      IF(NOUT1(I).EQ.0)GO TO 700
      WRITE(LOG3,690)(R(J,I),J,I,J=1,NSTRMS)
690   FORMAT(F12.8,60X,2I4)                                             
700   CONTINUE
      L1=LOG3
      IF(NARBIT.NE.0)L1=LOG6
      DO 740 I=1,NSTNS
      IF(NOUT2(I).EQ.0)GO TO 740
      L2=IS1(I)
      L3=L2+NSPEC(I)-1
      WRITE(L1,710)NSPEC(I),(XSTN(K),RSTN(K),K=L2,L3)
710   FORMAT(I3,/,(2F12.7))                                             
      XN=SPEED(I)
      IF(I.EQ.NSTNS)GO TO 714
      IF(SPEED(I).NE.SPEED(I+1).AND.NWORK(I+1).NE.0)XN=SPEED(I+1)
714   XN=XN*SPDFAC(ICASE)*PI/(30.0*SCLFAC)
      DO 720 J=1,NSTRMS
720   XX1(J)=ATAN((VW(J,I)-XN*R(J,I))/VM(J,I))*C1
      WRITE(L1,730)(R(J,I),XX1(J),J,I,J=1,NSTRMS)
730   FORMAT(2F12.8,48X,2I4)                                            
740   CONTINUE
750   IF(NSTPLT.EQ.0)GO TO 759
      L1=IPASS
      IF(L1.GT.59)L1=59
      DO 754 K=1,L1
754   PASS(K)=FLOAT(K)
      DO 758 K=1,NSTNS
      IF (IPRTC .EQ. 1) WRITE(LOG2,756) K
756   FORMAT(1H1,53X,19HDELTA L FOR STATION,I3,/,2X)                    
758   CALL ALG25(L1,IPASS,LOG2,PASS,DELTAR(1,K))
759   IF(ICASE.GE.NCASE)GO TO 760
      ICASE=ICASE+1
      IFAILK=IFAILO
      GO TO 100
  760 IF (IPRTC .EQ. 1) WRITE(LOG2,770)
770   FORMAT(1HS)                                                       
      RETURN
      END
