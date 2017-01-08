      SUBROUTINE PARAM (SETID,XX,BUF4)        
C        
C     THIS PARAM ROUTINE IS CALLED ONLY BY DPLOT, WHICH IS THE DRIVER   
C     OF THE PLOT MODULE           ==== == =====        
C        
C     THE DRIVER FOR THE PARAM MODULE IS QPARAM        
C        
      LOGICAL TEST        
      INTEGER SETID(1),XX(1)    ,BUF4     ,BUF1     ,BUFSIZ   ,TITLE   ,
     1        PRNT    ,PARM     ,PLTBUF   ,CAMERA   ,BFRAMS   ,PLTMOD  ,
     2        TAPDEN  ,PENSIZ   ,PENCLR   ,PAPTYP   ,AXIS     ,DAXIS   ,
     3        FVP     ,PRJECT   ,FOR      ,ORG      ,ORIGIN   ,PLOTER  ,
     4        WORD    ,AWRD(2)  ,ERR(3)   ,BLANK    ,PLTNAM(2),EOR     ,
     5        TRA     ,WHERE    ,DIRECT   ,FSCALE   ,PLTYPE   ,FPLTIT  ,
     6        PLTITL  ,SAVTIT(96),MSG1(20),MSG2(20) ,MSG4(22) ,MSG5(16),
     7        ANTI    ,AXISD(7) ,BOTH     ,BPI      ,BY       ,COLO    ,
     8        COMM    ,DEFO     ,DENS     ,DISP     ,EVEN     ,FILM    ,
     9        FRAM    ,HMODE    ,HPLOT(2) ,HKEY(19) ,HX       ,OESX    ,
     O        NKWD(3) ,ICNDA(20),PLAN     ,POIN     ,PAPE     ,SEPA    ,
     1        SIZE    ,STRE     ,SYMM     ,TYPE     ,Z1       ,Z2      ,
     2        FILL    ,COLOR    ,LAYER    ,OES1     ,OES1L    ,ONRGY1   
      REAL    MAXDEF        
      DOUBLE PRECISION DWRD        
      COMMON /SYSTEM/  KSYSTM(65)        
      COMMON /OUTPUT/  TITLE(96)        
      COMMON /BLANK /  SKP11(3) ,PRNT     ,SKP12(6) ,PARM     ,SKP2(9) ,
     1                 MERR     ,SKPIT(2) ,OESX        
      COMMON /XXPARM/  PLTBUF   ,CAMERA   ,BFRAMS   ,PLTMOD(2),TAPDEN  ,
     1                 NPENS    ,PAPSIZ(2),PAPTYP(2),PENSIZ(8)         ,
     2                 PENCLR(8,2),PENPAP ,SCALE(2) ,FSCALE   ,MAXDEF  ,
     3                 DEFMAX   ,AXIS(3)  ,DAXIS(3) ,VANGLE(3)         ,
     4                 SKPVUE(6),FVP      ,VANPNT(5),D02      ,D03     ,
     5                 PRJECT   ,S0S      ,FOR      ,ORG      ,NORG    ,
     6                 ORIGIN(11),EDGE(11,4),XY(11,3),NCNTR   ,CNTR(50),
     7                 ICNTVL   ,WHERE    ,DIRECT   ,SUBCAS   ,FLAG    ,
     8                 DATA     ,LASSET   ,FPLTIT   ,PLTITL(17)        ,
     9                 COLOR    ,LAYER        
      COMMON /PLTDAT/  MODEL    ,PLOTER   ,SKPPLT(17),CHRSCL  ,SKPA(2) ,
     1                 CNTSIN   ,SKPD1(6) ,PLTYPE    ,SKPD2(3),CNTIN3   
      EQUIVALENCE      (KSYSTM(1),BUFSIZ) ,(PAPE,HKEY(10))    ,        
     1                 (WORD,AWRD(1),DWRD ,FWRD,IWRD)        
C        
C     THE FOLLOWING ARE THE ALLOWABLE FIRST WORDS ON THE LOGICAL CARD.  
C     THE PROJECTION DETERMINES HOW MANY WORDS ARE CHECKED.        
C        
C     OES1   IS THE NORMAL STRESS FILE, 111        
C     OES1L  IS THE LAYER COMPOSITE STRESS FILE, 112        
C     ONRGY1 IS THE ELEMENT  STRAIN ENERGY FILE, 113        
C        
      DATA OES1 , OES1L , ONRGY1 /111,112,113   /        
      DATA NKWD / 17,19,19/     , BLANK4 /4H    /        
      DATA HKEY / 4HFIND, 4HVIEW, 4HAXES, 4HMAXI, 4HORTH, 4HPERS,       
     1            4HSTER, 4HCONT, 4HCAME, 4HPAPE, 4HPEN , 4HBLAN,       
     2            4HORIG, 4HSCAL, 4HCSCA, 4HPROJ, 4HPTIT, 4HOCUL,       
     3            4HVANT/        
C        
C     THE FOLLOWING ARE RECOGNIZABLE PARAMETERS        
C        
      DATA AXISD/ 2HMZ   , 2HMY, 2HMX, 0, 1HX,  1HY,     1HZ        /,  
     1     ANTI / 4HANTI/, BOTH/ 4HBOTH/, BPI / 4HBPI /, BY  /4HBY  /,  
     2     COLO / 4HCOLO/, DEFO/ 4HDEFO/, DENS/ 4HDENS/, FILM/4HFILM/,  
     3     FRAM / 4HFRAM/,HMODE/ 4HMODE/,HPLOT/ 4HPLOT,  4HTER      /,  
     4     HX   / 4HX   /, PLAN/ 4HPLAN/, POIN/ 4HPOIN/, SEPA/4HSEPA/,  
     5     SIZE / 4HSIZE/, SYMM/ 4HSYMM/, TYPE/ 4HTYPE/,        
C        
C     CONTOUR PLOTTING        
C        
     6     DISP / 4HDISP/, STRE/ 4HSTRE/, EVEN/ 4HEVEN/, LAYE/ 4HLAYE/, 
     7     LIST / 4HLIST/, Z1  / 2HZ1  /, Z2  / 2HZ2  /, MAX / 3HMAX /, 
     8     MID  / 3HMID /, COMM/ 4HCOMM/, LOCA/ 4HLOCA/, FILL/ 4HFILL/  
C        
      DATA  ICNDA  /4HMAJP, 4HMINP, 4HMAXS, 4HXNOR, 4HYNOR, 4HZNOR,     
     1      4HXYSH, 4HXZSH, 4HYZSH, 4HXDIS, 4HYDIS, 4HZDIS, 4HMAGN,     
     2      4HNRM1, 4HNRM2, 4HSH12, 4HSH1Z, 4HSH2Z, 4HBDSH, 4HSTRA/     
C        
      DATA  EOR   , BLANK/ 1000000, 1H  /,        
     1      NMSG5 , MSG5 / 16,4H(25X, 4H,31H, 4HMORE, 4H THA, 4HN 50,   
     2      4H CON, 4HTOUR,   4HS SP, 4HECIF, 4HIED,, 4H1P,E, 4H14.6,   
     3      4H,9H , 4HREJE,   4HCTED, 4H)   /        
      DATA  NMSG1 / 20   /        
      DATA  MSG1  / 4H(34X  ,4H,45H   ,4HAN A   ,4HTTEM   ,4HPT H   ,   
     1              4HAS B  ,4HEEN    ,4HMADE   ,4H TO    ,4HDEFI   ,   
     2              4HNE M  ,4HORE    ,4HTHAN   ,4H ,I2   ,4H,17H   ,   
     3              4H DIS  ,4HTINC   ,4HT OR   ,4HIGIN   ,4HS)     /   
      DATA  NMSG2 / 20   /        
      DATA  MSG2  / 4H(30X  ,4H,34H   ,4HAN U   ,4HNREC   ,4HOGNI   ,   
     1              4HZABL  ,4HE PL   ,4HOT P   ,4HARAM   ,4HETER   ,   
     2              4H (,2  ,4HA4,2   ,4H9H)    ,4HHAS    ,4HBEEN   ,   
     3              4H DET  ,4HECTE   ,4HD -    ,4HIGNO   ,4HRED)   /   
      DATA  NMSG4 / 22   /        
      DATA  MSG4  / 4H(25X  ,4H,4HP   ,4HEN ,   ,4HI4,6   ,4H9H I   ,   
     1              4HS NO  ,4HT A    ,4HLEGA   ,4HL PE   ,4HN NU   ,   
     2              4HMBER  ,4H FOR   ,4H THI   ,4HS PL   ,4HOTTE   ,   
     3              4HR. P  ,4HEN 1   ,4H WIL   ,4HL BE   ,4H RED   ,   
     4              4HEFIN  ,4HED.)    /        
      DATA  TEST  / .FALSE. /        
C        
C        
C     COMMENTS FROM G.CHAN/UNISYS ABOUT THE NOFIND FLAG       11/1990   
C        
C     THE NOFIND FLAG WAS TOO CONFUSING BEFORE. I'M SETTING THE NEW RULE
C     HERE        
C        
C     NOFIND FLAG IS USED IN PARAM AND PLOT ROUTINES ONLY. ITS USE IS   
C     TO INDICATE WHETHER SUBROUTINE FIND SHOULD BE CALLED.        
C     (SUBROUTINE FIND COMPUTES THE NEW ORIGIN, FRAME SIZE, NEW VIEW,   
C     VANTAGE POINT ETC. DUE TO CERTAIN PLOT PARAMETERS).        
C     NOFIND FLAG CAN BE SET BY USER VIA THE FIND AND NOFIND COMMANDS,  
C     OR IT IS SET AUTOMATICALLY BY THIS PARAM SUBROUTINE.        
C        
C      NOFIND                  ACTION        
C     --------    ----------------------------------------------------  
C        -1       FIND ROUTINE SHOULD BE CALLED IN NEXT OPPORTUNITY     
C                 BEFORE THE ACTUAL PLOTTING        
C        +1       (1) A NOFIND CARD WAS ENCOUNTERED. USER WANTS TO KEEP 
C                 ALL PARAMETERS AS IN THE PREVIOUS PLOT CASE, OR       
C                 (2) FIND ROUTINE WAS JUST CALLED. PROGRAM SHOULD NOT  
C                 CALL FIND AGAIN        
C         0       THE CURRENT STATUS OF ALL PARAMETERS THAT WERE FOUND  
C                 BY PREVIOUS FIND REMAIN UNCHANGED. HOWEVER, ANY       
C                 CHANGE IN THE PLOT PARAMETERS BY THE USER (SCALE,     
C                 CSCALE, VIEW, VENTAGE POINT, REGION, ORIGIN, PLOTTER, 
C                 MAX.DEFORMATION, PROJECTION AND PAPER SIZE) WILL      
C                 CHANGE NOFIND FLAG TO -1        
C        
C     IF A FIND COMMAND IS ENCOUNTERED, SUBROUTINE FIND IS CALLED       
C     IMMEDIATELY AND UNCONDISIONALLY, THEN NOFIND FLAG IS SET TO +1    
C        
C     IF USER HAS ALREADY ONE OR MORE ORIGINS, AND IF HE USES A FIND    
C     CARD TO FIND ANOTHER ORIGIN, BUT THE NEXT PLOT CARD DOES NOT USE  
C     THIS NEWLY DEFINED ORIGIN, A WARNING MESSAGE SHOULD BE ISSUED TO  
C     INFORM THE USER THAT THE DEFAULT ORIGIN, WHICH IS THE FIRST       
C     DEFINDED ORIGIN, IS GOING TO BE USED, NOT THE ONE HE JUST DEFINED 
C        
      NOFIND = -1        
      LASSET = 0        
      CALL PLTSET        
      BUF1 = BUF4 + 3*BUFSIZ        
C        
C     SAVE THE TITLE, SUBTITLE AND LABEL IF DEFORMED PLOTS ...        
C        
      IF (PRNT .GE. 0) GO TO 30        
      DO 10 I = 1,96        
   10 SAVTIT(I) = TITLE(I)        
   20 NOFIND = 0        
   30 CALL RDMODX (PARM,MODE,WORD)        
   40 CALL READ (*1800,*1800,PARM,MODE,1,0,I)        
      IF (MODE) 50,40,60        
   50 I = 1        
      IF (MODE .EQ. -4) I = 2        
      CALL FREAD (PARM,0,-I,0)        
      GO TO 40        
   60 IF (MODE .LT. EOR) GO TO 70        
      CALL FREAD (PARM,0,0,1)        
      GO TO 40        
   70 MODE = MODE + 1        
      CALL RDWORD (MODE,WORD)        
      CALL RDWORD (MODE,WORD)        
      IF (AWRD(1) .NE. HPLOT(1)) GO TO 160        
      IF (AWRD(2) .EQ.    BLANK) GO TO 110        
      IF (AWRD(2) .EQ. HPLOT(2)) GO TO 900        
      GO TO 1750        
C        
C     FIND        
C        
  100 CALL FIND (MODE,BUF1,BUF4,SETID,XX)        
      NOFIND = +1        
      IF (MODE .GE. 0) GO TO 30        
      MODE = MODEX        
      GO TO 130        
C        
C     PLOT        
C        
  110 IF (TEST) GO TO 130        
C        
C         WHEN PLOTTER OR PROJECTION WERE HIT        
C              FSCALE=FOR=FVP=1        
C              PROJECTION=KWRD-4, SOME NUMBER        
C         WHEN SCALE IS HIT,       FSCALE SET TO 0        
C         WHEN VANTAGE POINT IS HEIT, FVP SET TO 0        
C         WHEN ORIGIN IS HIT,         ORG SET TO 0        
C        
      IF (FSCALE.NE.0 .OR. FOR.NE.0) GO TO 120        
      IF (PRJECT.EQ.1 .OR. FVP.EQ.0) GO TO 130        
  120 MODEX = MODE        
      MODE  = -1        
      ORG   = MAX0(1,ORG)        
      GO TO 100        
  130 CALL PLOT (MODE,BUF1,BUF4,SETID,XX,NOFIND)        
      OESX = OES1        
      IF (NOFIND .EQ. -1) ORG = MAX0(1,ORG)        
      GO TO 20        
C        
C     PLOT PARAMETER CARD.        
C        
  140 IF (MODE .LE. 0) CALL RDMODE (*140,*150,*40,MODE,WORD)        
  150 CALL RDWORD (MODE,WORD)        
  160 I = NKWD(PRJECT)        
      DO 170 KWRD = 1,I        
      IF (HKEY(KWRD) .EQ. WORD) GO TO 200        
  170 CONTINUE        
      GO TO 1750        
C        
  200 GO TO (100, 1230,  250,  500,  230,  230,  230, 1300,  400,  700, 
     1       800,  440,  600, 1120, 1700, 1100, 1720,  520, 1200), KWRD 
C        
C           FIND  VIEW  AXES  MAXI  ORTH  PERS  STER  CONT  CAME  PAPE  
C    1       PEN  BLAN  ORIG  SCAL  CSCA  PROJ  PTIT  OCUL  VANT        
C        
C        
C     RECHECK IF PROJECTION CARD        
C        
  210 DO 220 KWRD = 5,7        
      IF (WORD .EQ. HKEY(KWRD)) GO TO 230        
  220 CONTINUE        
      GO TO 1750        
C        
C     PROJECTION        
C        
  230 PRJECT    = KWRD-4        
      VANGLE(1) = 0.        
      VANGLE(2) =-1.E10        
      VANGLE(3) = 34.27        
      FSCALE    = 1        
      FVP = 1        
      FOR = 1        
      IF (NOFIND .EQ. 0) NOFIND = -1        
      CALL RDWORD (MODE,WORD)        
      IF (WORD .NE. HKEY(16)) GO TO 140        
C        
C     READ SECOND WORD OF ORTHO.,PERS.,OR STERO. SHOULD BE PROJECTION   
C        
      IF (ORG .EQ. 0) GO TO 140        
      DO 240 I  = 1,ORG        
      EDGE(I,1) = 0.        
      EDGE(I,2) = 0.        
      EDGE(I,3) = 1.        
      EDGE(I,4) = 1.        
  240 CONTINUE        
      ORG = 0        
      GO TO 140        
C        
C     AXES        
C        
  250 DO 290 J = 1,3        
      IF (MODE .EQ. 0) CALL RDMODE (*140,*260,*40,MODE,WORD)        
  260 CALL RDWORD (MODE,WORD)        
      DO 270 I = 1,7        
      IF (WORD .EQ. AXISD(I)) GO TO 280        
  270 CONTINUE        
      GO TO 310        
  280 AXIS(J) = I - 4        
  290 CONTINUE        
      IF (MODE .EQ. 0) CALL RDMODE (*320,*300,*320,MODE,WORD)        
  300 CALL RDWORD (MODE,WORD)        
  310 IF (WORD .EQ. ANTI) GO TO 330        
  320 K = 1        
      GO TO 340        
  330 K = -1        
  340 DO 350 J = 1,3        
      DAXIS(J) = K*AXIS(J)        
  350 CONTINUE        
      IF (MODE .GE. EOR) GO TO 40        
      IF (MODE.LT.0 .OR. WORD.EQ.SYMM .OR. WORD.EQ.ANTI) GO TO 140      
      GO TO 160        
C        
C     CAMERA        
C        
  400 ASSIGN 420 TO TRA        
      IF (MODE .LE. 0) CALL RDMODE (*1910,*410,*40,MODE,WORD)        
  410 CALL RDWORD (MODE,WORD)        
      N = 2        
      IF (WORD .EQ. FILM) N = 1        
      IF (WORD .EQ. PAPE) N = 2        
      IF (WORD .EQ. BOTH) N = 3        
      IF (N) 430,1750,430        
  420 N = IWRD        
  430 CAMERA = N        
      GO TO 140        
C        
C     BLANK FRAMES        
C        
  440 IF (MODE .EQ. 0) GO TO 1750        
      CALL RDWORD (MODE,WORD)        
      IF (WORD.NE.FRAM .OR. MODE.NE.0) GO TO 1750        
      ASSIGN 450 TO TRA        
      GO TO 1900        
  450 BFRAMS = IWRD        
      GO TO 140        
C        
C     MAXIMUM DEFORMATION        
C        
  500 IF (MODE .LE. 0) GO TO 1750        
      CALL RDWORD (MODE,WORD)        
      IF (WORD.NE.DEFO .OR. MODE.NE.0) GO TO 1750        
      ASSIGN 510 TO TRA        
      GO TO 1940        
  510 MAXDEF = FWRD        
      GO TO 140        
C        
C     OCULAR SEPARATION        
C        
  520 IF (MODE .LE. 0) GO TO 1750        
      CALL RDWORD (MODE,WORD)        
      IF (WORD.NE.SEPA .OR. MODE.NE.0) GO TO 1750        
      ASSIGN 530 TO TRA        
      GO TO 1940        
  530 S0S = FWRD        
      GO TO 140        
C        
C     ORIGIN        
C        
  600 IF (MODE .NE. 0) GO TO 1750        
      ASSIGN 610 TO TRA        
      GO TO 1900        
C        
C     ORIGIN ID        
C        
  610 ID = IWRD        
      ASSIGN 620 TO TRA        
      GO TO 1940        
C        
C     HORIZONTAL LOCATION (LEFT EYE - STEREO)        
C        
  620 X = FWRD*CNTSIN        
      ASSIGN 630 TO TRA        
      GO TO 1940        
C        
C     VERTICAL LOCATION        
C        
  630 Y = FWRD*CNTSIN        
      IF (ORG .EQ. 0) GO TO 670        
      DO 640 J = 1,ORG        
      IF (ORIGIN(J) .EQ. ID) GO TO 680        
  640 CONTINUE        
      IF (ORG .LT. NORG) GO TO 670        
      IF (PRNT .LT.   0) GO TO 650        
      ERR(1) = 1        
      ERR(2) = NORG        
      CALL WRTPRT (MERR,ERR,MSG1,NMSG1)        
  650 ORG = NORG        
      DO 660 I = 1,2        
      EDGE(ORG+1,I+0) = 0.        
      EDGE(ORG+1,I+2) = 1.        
  660 CONTINUE        
  670 ORG = ORG + 1        
      J   = ORG        
      ORIGIN(J) = ID        
      IF (NOFIND .EQ. 0) NOFIND = -1        
  680 XY(J,1) = X        
      XY(J,3) = Y        
      FOR = 0        
      ASSIGN 690 TO TRA        
      GO TO 1940        
C        
C     HORIZONTAL LOCATION (RIGHT EYE - STEREO)        
C        
  690 XY(J,2) = FWRD*CNTSIN        
      GO TO 140        
C        
C     PAPER SIZE, TYPE        
C        
  700 IF (MODE .LE. 0) GO TO 1750        
      CALL RDWORD (MODE,WORD)        
      IF (WORD .EQ. TYPE) GO TO 760        
      IF (WORD.NE.SIZE .OR. MODE.NE.0) GO TO 1750        
      ASSIGN 710 TO TRA        
      GO TO 1940        
  710 X = FWRD        
      CALL RDMODE (*730,*720,*40,MODE,WORD)        
  720 CALL RDWORD (MODE,WORD)        
      IF (WORD.NE.BY .AND. WORD.NE.HX) GO TO 1750        
      IF (MODE .NE. 0) GO TO 1750        
  730 ASSIGN 740 TO TRA        
      GO TO 1940        
  740 PAPSIZ(1) = X        
      PAPSIZ(2) = FWRD        
      CALL PLTSET        
      CALL RDMODE (*140,*750,*40,MODE,WORD)        
  750 CALL RDWORD (MODE,WORD)        
      IF (WORD .NE. TYPE) GO TO 160        
C        
C     PAPER TYPE        
C        
  760 IF (MODE .EQ. 0) GO TO 1750        
      CALL RDWORD (MODE,WORD)        
      PAPTYP(1) = AWRD(1)        
      PAPTYP(2) = AWRD(2)        
      IF (MODE) 140,140,700        
C        
C     PEN SIZE / COLOR        
C        
  800 IF (MODE .NE. 0) GO TO 1750        
      ASSIGN 810 TO TRA        
      GO TO 1900        
  810 IF (IWRD.NE.1 .AND. IWRD.LE. NPENS) GO TO 820        
      ERR(1) = 1        
      ERR(2) = IWRD        
      CALL WRTPRT (MERR,ERR,MSG4,NMSG4)        
      IWRD = 1        
  820 ID = IWRD        
  830 CALL RDMODE (*140,*840,*40,MODE,WORD)        
  840 CALL RDWORD (MODE,WORD)        
      IF (WORD .EQ. SIZE) GO TO 850        
      IF (WORD .NE. COLO) GO TO 160        
      IF (MODE .EQ.    0) GO TO 1750        
      CALL RDWORD (MODE,WORD)        
      PENCLR(ID,1) = AWRD(1)        
      PENCLR(ID,2) = AWRD(2)        
      IF (MODE) 140,830,840        
C        
C     PEN SIZE        
C        
  850 IF (MODE .NE. 0) GO TO 1750        
      ASSIGN 860 TO TRA        
      GO TO 1900        
  860 PENSIZ(ID) = IWRD        
      GO TO 830        
C        
C     PLOTTER        
C        
  900 IF (MODE .EQ. 0) GO TO 1750        
      CALL RDWORD (MODE,WORD)        
      PLTNAM(1) = AWRD(1)        
      PLTNAM(2) = AWRD(2)        
      PLTMOD(1) = 0        
      PLTMOD(2) = 0        
      CAMERA = 2        
      FSCALE = 1        
      FVP = 1        
      FOR = 1        
      IF (ORG .EQ. 0) GO TO 920        
      DO 910 I  = 1,ORG        
      EDGE(I,1) = 0.        
      EDGE(I,2) = 0.        
      EDGE(I,3) = 1.        
      EDGE(I,4) = 1.        
  910 CONTINUE        
      ORG = 0        
C        
C     CHECK FOR A MODEL NUMBER        
C        
  920 ASSIGN 960 TO TRA        
      J = 1        
      IF (MODE .LE. 0) CALL RDMODE (*1910,*930,*970,MODE,WORD)        
  930 CALL RDWORD (MODE,WORD)        
      IF (WORD .EQ. DENS ) GO TO 970        
      IF (WORD .NE. HMODE) GO TO 960        
  940 IF (MODE .LE. 0) CALL RDMODE (*1910,*950,*970,MODE,WORD)        
  950 CALL RDWORD (MODE,WORD)        
      IF (WORD .EQ. DENS) GO TO 970        
  960 PLTMOD(J) = WORD        
      J = J + 1        
      IF (J .EQ. 2) GO TO 940        
  970 CALL FNDPLT (ID,N,PLTMOD)        
      PLOTER = ID        
      MODEL  = N        
      CALL PLTSET        
      IF (WORD .EQ. DENS) GO TO 1000        
      IF (MODE .GE.  EOR) GO TO 40        
C        
C     TAPE DENSITY ON PLOTTER CARD        
C        
  980 IF (MODE .LE. 0) CALL RDMODE (*980,*990,*40,MODE,WORD)        
  990 CALL RDWORD (MODE,WORD)        
 1000 IF (WORD .NE. DENS) GO TO 160        
      IF (MODE .NE.    0) GO TO 140        
      ASSIGN 1010 TO TRA        
      GO TO 1900        
 1010 TAPDEN = IWRD        
      CALL RDMODE (*140,*1020,*40,MODE,WORD)        
 1020 CALL RDWORD (MODE,WORD)        
      IF (WORD .EQ. BPI) GO TO 140        
      GO TO 160        
C        
C     PROJECTION PLANE SEPARATION        
C        
 1100 IF (MODE .EQ. 0) GO TO 1750        
      CALL RDWORD (MODE,WORD)        
C        
C     USER MAY HAVE REVERSE ENGLISH        
C        
      IF (WORD .NE. PLAN) GO TO 210        
      IF (MODE .EQ.    0) GO TO 1750        
      CALL RDWORD (MODE,WORD)        
      IF (MODE.NE.0 .OR. WORD.NE.SEPA) GO TO 1750        
      ASSIGN 1110 TO TRA        
      GO TO 1940        
 1110 IF (PRJECT .EQ. 2) D02 = FWRD        
      IF (PRJECT .EQ. 3) D03 = FWRD        
      GO TO 140        
C        
C     SCALE        
C        
 1120 IF (MODE .NE. 0) GO TO 1750        
      ASSIGN 1130 TO TRA        
      GO TO 1940        
 1130 IF (FWRD  .EQ. 0.) GO TO 1140        
      IF (PRJECT .NE. 3) SCALE(1) = CNTSIN*FWRD        
      IF (PRJECT .EQ. 3) SCALE(1) = CNTIN3*FWRD        
 1140 FSCALE = 0        
      ASSIGN 1150 TO TRA        
      GO TO 1940        
 1150 IF (FWRD  .NE. 0.) SCALE(2) = FWRD        
      IF (NOFIND .EQ. 0) NOFIND = -1        
      GO TO 140        
C        
C     VANTAGE POINT        
C        
 1200 IF (MODE .EQ. 0) GO TO 1750        
      CALL RDWORD (MODE,WORD)        
      IF (WORD.NE.POIN .OR. MODE.NE.0) GO TO 1750        
      ASSIGN 1220 TO TRA        
      J = 0        
 1210 J = J + 1        
      IF (J .EQ. 3) J = 4        
      IF (PRJECT.EQ.3 .AND. J.EQ.6) J = 3        
      GO TO 1940        
 1220 VANPNT(J) = FWRD        
      IF ((PRJECT.NE.3 .AND. J.NE.5) .OR. (PRJECT.EQ.3 .AND. J.NE.3))   
     1   GO TO 1210        
      FVP =  0        
      IF (NOFIND .EQ. 0) NOFIND = -1        
      GO TO 140        
C        
C     VIEW        
C        
 1230 IF (MODE .NE. 0) GO TO 1750        
      ASSIGN 1250 TO TRA        
      J = 4        
 1240 J = J - 1        
      GO TO 1940        
 1250 VANGLE(J) = FWRD        
      IF (NOFIND .EQ. 0) NOFIND = -1        
      IF (J-1) 1240,140,1240        
C        
C     CONTOUR        
C        
C     RESTORE DEFAULTS        
C        
 1300 ICNTVL = 1        
      NCNTR  = 10        
C     COLOR  = 0 - NO COLOR CONTOUR        
      COLOR  = 0        
      LAYER  = 0        
      WHERE  = 1        
      DIRECT = 2        
      CNTR(1)= 0.0        
      CNTR(2)= 0.0        
C        
C     FLAG AND LASSET SET IN PLOT AND CONPLT        
C        
 1310 IF (MODE .LE. 0) CALL RDMODE (*1310,*1320,*40,MODE,WORD)        
 1320 CALL RDWORD (MODE,WORD)        
      IF (WORD.EQ.COLO .OR. WORD.EQ.FILL .OR. WORD.EQ.LAYE) GO TO 1340  
      IF (WORD .NE. EVEN) GO TO 1370        
      ASSIGN 1330 TO TRA        
      GO TO 1900        
 1330 NCNTR = MIN0 (50,IWRD)        
      GO TO 1310        
 1340 IF (WORD .EQ. COLO) ASSIGN 1350 TO TRA        
      IF (WORD .EQ. FILL) ASSIGN 1360 TO TRA        
      IF (WORD .EQ. LAYE) GO TO 1600        
      GO TO 1900        
 1350 COLOR = IWRD        
      GO TO 1310        
 1360 COLOR = -IWRD        
      GO TO 1310        
C        
 1370 IF (WORD .NE. LIST) GO TO 1500        
      IF (MODE .GT.    0) GO TO 1580        
      NCNTR = 0        
      ASSIGN 1390 TO TRA        
 1380 CALL RDMODE (*1950,*1320,*40,MODE,WORD)        
 1390 IF (NCNTR .LT. 50) GO TO 1400        
      IF (PRNT  .LT.  0) GO TO 1380        
      ERR(1) = 1        
      ERR(2) = IWRD        
      CALL WRTPRT (MERR,ERR,MSG5,NMSG5)        
      GO TO 1380        
 1400 NCNTR = NCNTR + 1        
      CNTR(NCNTR) = FWRD        
      GO TO 1380        
C        
 1500 IF (WORD .EQ. Z1  ) GO TO 1510        
      IF (WORD .EQ. Z2  ) GO TO 1520        
      IF (WORD .EQ. MAX ) GO TO 1530        
      IF (WORD .EQ. MID ) GO TO 1540        
      IF (WORD .EQ. COMM) GO TO 1550        
      IF (WORD .EQ. DISP) GO TO 1310        
      IF (WORD .EQ. STRE) GO TO 1310        
      IF (WORD .NE. LOCA) GO TO 1560        
      DIRECT = 1        
      GO TO 1310        
 1510 WHERE  = 1        
      GO TO 1310        
 1520 WHERE  =-1        
      GO TO 1310        
 1530 WHERE  = 2        
      GO TO 1310        
 1540 WHERE  = 3        
      GO TO 1310        
 1550 DIRECT = 2        
      GO TO 1310        
C        
 1560 DO 1570 J = 1,20        
      IF (WORD .EQ. ICNDA(J)) GO TO 1590        
 1570 CONTINUE        
 1580 IF (PRNT .LT. 0) GO TO 1310        
      ERR(1) = 2        
      ERR(2) = AWRD(1)        
      ERR(3) = AWRD(2)        
      CALL WRTPRT (MERR,ERR,MSG2,NMSG2)        
      GO TO 1310        
C        
 1590 ICNTVL = J        
C        
C     SET STRESS FILE TO STRAIN FILE        
C        
      IF (ICNTVL .EQ. 20) OESX = ONRGY1        
      GO TO 1310        
C        
C     ASSIGN LAYER NUMBER HERE FOR COMPOSITS        
C        
 1600 ASSIGN 1610 TO TRA        
C        
C     SET STRESS FILE TO LAYER STRESS        
C        
      OESX = OES1L        
      GO TO 1900        
 1610 LAYER = IWRD        
      GO TO 1310        
C        
C     CSCALE        
C        
 1700 IF (MODE .NE. 0) GO TO 1750        
      ASSIGN 1710 TO TRA        
      GO TO 1940        
 1710 CHRSCL = FWRD        
C     IF (NOFIND .EQ.   0) FSCALE =  0        
      IF (NOFIND .EQ.   0) NOFIND = -1        
      IF (CHRSCL .LT. 1.0) CHRSCL = 1.0        
C     IF (CHRSCL .GT. 1.0) CALL PLTSET        
      CALL PLTSET        
      GO TO 140        
C        
C     PTITLE        
C        
 1720 FPLTIT = 1        
      DO 1730 I = 1,17        
 1730 PLTITL(I) = BLANK4        
      J = COLOR        
      DO 1740 I = 1,17,2        
      CALL RDWORD (MODE,WORD)        
      PLTITL(I  ) = AWRD(1)        
      PLTITL(I+1) = AWRD(2)        
      IF (MODE .EQ. 0) GO TO 140        
 1740 CONTINUE        
      COLOR = J        
      IF (MODE .NE. 0) CALL RDWORD (MODE,WORD)        
      GO TO 140        
C        
C     UNRECOGNIZABLE PLOT PARAMETER.        
C        
 1750 IF (PRNT.LT. 0) GO TO 140        
      ERR(1) = 2        
      ERR(2) = AWRD(1)        
      ERR(3) = AWRD(2)        
      CALL WRTPRT (MERR,ERR,MSG2,NMSG2)        
      GO TO 140        
C        
C     END OF PLOT INPUT        
C        
 1800 IF (PRNT .GE. 0) GO TO 1820        
      DO 1810 I = 1,96        
 1810 TITLE(I) = SAVTIT(I)        
 1820 CONTINUE        
      RETURN        
C        
C        
C     READ AN INTEGER ON A PARAMETER CARD        
C        
 1900 CALL RDMODE (*1910,*140,*40,MODE,WORD)        
 1910 IF (MODE .EQ. -1) GO TO 1930        
      IF (MODE .EQ. -4) GO TO 1920        
      IWRD = FWRD        
      GO TO 1930        
 1920 IWRD = DWRD        
 1930 GO TO TRA, (420,450,610,810,860,1330,1350,1360,1610,960,1010)     
C        
C     READ A DECIMAL NUMBER ON A PARAMETER CARD        
C        
 1940 CALL RDMODE (*1950,*140,*40,MODE,WORD)        
 1950 IF (MODE .EQ. -4) GO TO 1960        
      IF (MODE .NE. -1) GO TO 1970        
      FWRD = IWRD        
      GO TO 1970        
 1960 FWRD = DWRD        
 1970 GO TO TRA, ( 510, 530, 620, 630, 690, 710, 740,1110,1130,1150,    
     1            1220,1250,1390,1710)        
C        
      END        
