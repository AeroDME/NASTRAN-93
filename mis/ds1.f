      SUBROUTINE DS1 (IARG)        
C        
C     THIS ROUTINE CREATES THE SCRATCH FILE ECPTDS BY APPENDING TO EACH 
C     ELEMENT IN THE ECPT AN ELEMENT DEFORMATION, AN AVERAGE ELEMENT    
C     LOADING TEMPERATURE, AND THE PROPER COMPONENTS OF THE DISPLACEMENT
C     VECTORS. SUBROUTINE DS1A READS THE ECPTDS IN THE SAME WAY AS SMA1A
C     READS THE ECPT IN ORDER TO CREATE A SECOND ORDER APPROXIMATION TO 
C     THE KGG, WHICH IS CALLED KGGD.        
C     IF DS1 CANNOT FIND ANY ELEMENTS IN THE ECPT WHICH ARE IN THE SET  
C     OF ELEMENTS FOR WHICH DIFFERENTIAL STIFFNESS IS DEFINED, IARG IS  
C     RETURNED CONTAINING A ZERO TO THE CALLING ROUTINE, DSMG1.        
C        
      EXTERNAL        RSHIFT        
      LOGICAL         DSTYPE,EORFLG,ENDID,RECORD        
      INTEGER         BUFFR1,BUFFR2,EOR,CLSRW,OUTRW,CASECC,GPTT,EDT,    
     1                UGV,ECPT,ECPTDS,FILE,TSETNO,DSETNO,TMPSET,        
     2                RECNO,EDTLOC,EDTBUF,ELTYPE,ELID,BUFLOC,DFMSET,    
     3                RSHIFT,JSIL(2),OLDEL,CCBUF,OLDEID,BUFFR3        
C     INTEGER         TWOPWR,DSARY        
      DIMENSION       TGRID(33),IZ(1),XECPT(328),IECPT(328),CCBUF(2),   
     1                GPTBF3(3),NAME(2),EDTBUF(3),EDTLOC(2),MCBUGV(7)   
      CHARACTER       UFM*23,UWM*25,UIM*29,SFM*25        
      COMMON /XMSSG / UFM,UWM,UIM,SFM        
      COMMON /MACHIN/ MACH,IHALF        
      COMMON /GPTA1 / NELEMS,LAST,INCR,NE(1)        
      COMMON /SYSTEM/ ISYS,SYSDUM(25),MN,XXX18(18),NDUM(9)        
CZZ   COMMON /ZZDS1X/ Z(1)        
      COMMON /ZZZZZZ/ Z(1)        
      COMMON /UNPAKX/ ITYPEB,IUNPK,JUNPK,INCUPK        
      COMMON /DS1ETT/ ELTYPE,OLDEL,EORFLG,ENDID,BUFFLG,TSETNO,FDFALT,   
     1                IBACK,RECORD,OLDEID        
      COMMON /BLANK / DSCSET        
      EQUIVALENCE     (Z(1),IZ(1))       ,(XECPT(1),IECPT(1)),        
     1                (GPTBF3(1),TMPSET) ,(GPTBF3(2),IDFALT) ,        
     2                (GPTBF3(3),RECNO)  ,(EDTBUF(1),DFMSET) ,        
     3                (EDTBUF(2),ELID)   ,(EDTBUF(3),DEFORM) ,        
     4                (IOUTPT,SYSDUM(1))        
      DATA            EDTLOC/104,1 /,     NSKIP/ 137  /        
      DATA            CASECC,GPTT,EDT,UGV,ECPT,ECPTDS /        
     1                101,   102, 104,105,108, 301    /        
      DATA            NAME  /4HDS1 ,4H         /        
      DATA            INRW,OUTRW,EOR,NEOR,CLSRW/ 0,1,1,0,1 /        
C        
C     SET IARG TO ZERO        
C        
      CALL DELSET        
      IARG = 0        
C        
C     DETERMINE SIZE OF AVAILABLE CORE, DEFINE 2 BUFFERS AND INITIALIZE 
C     OPEN CORE POINTERS AND COUNTERS.        
C        
      IZMAX  = KORSZ(Z)        
      BUFFR1 = IZMAX  - ISYS        
      BUFFR2 = BUFFR1 - ISYS        
      BUFFR3 = BUFFR2 - ISYS        
      BUFLOC = IZMAX  - ISYS - 3        
      ILEFT  = BUFFR3 - 1        
      LEFT   = ILEFT  - NELEMS - 2        
      ISIL   = 0        
      NSIL   = 0        
      IEDT   = 0        
      NEDT   = 0        
C        
C     SET DIFFERENTIAL STIFFNESS FLAGS FOR ALL ELEMENT TYPES TO ZERO    
C        
      DO 10 I = 1,NELEMS        
      IZ(LEFT+I) = 0        
   10 CONTINUE        
C        
C     OPEN CASECC, SKIP HEADER, SKIP 5 WORDS AND READ DEFORMATION SET   
C     NUMBER AND LOADING TEMPERATURE SET NUMBER.        
C        
      CALL GOPEN (CASECC,Z(BUFFR1),INRW)        
      CALL FREAD (CASECC,0,-5,NEOR)        
      CALL FREAD (CASECC,CCBUF,2,NEOR)        
      DSETNO = CCBUF(1)        
      TSETNO = CCBUF(2)        
C        
C     STORE THE DIFFERENTIAL STIFFNESS COEFFICIENT (BETA) SET NUMBER    
C     IN COMMON.  THIS WORD IS THE 138TH WORD OF THE 2ND RECORD OF CASE 
C     CONTROL.        
C        
      FILE = CASECC        
      CALL FWDREC (*400,CASECC)        
      CALL FREAD  (CASECC,0,-NSKIP,NEOR)        
      CALL FREAD  (CASECC,DSCSET,1,NEOR)        
      CALL CLOSE  (CASECC,CLSRW)        
C        
C     IS THERE A TEMPERATURE LOAD        
C        
      RECORD =.FALSE.        
      IBACK  = 0        
      IF (TSETNO .LE. 0) GO TO 60        
C        
C     THERE IS. OPEN THE GPTT, SKIP FIRST TWO WORDS OF THE HEADER RECORD
C     AND READ 3 WORD ENTRIES OF THE HEADER RECORD UNTIL A SET NUMBER   
C     MATCHES THE SET NUMBER READ IN THE CASE CONTROL RECORD.        
C        
      FILE = GPTT        
      CALL OPEN  (*400,GPTT,Z(BUFFR3),INRW)        
      CALL FREAD (GPTT,0,-2,NEOR)        
   20 CALL FREAD (GPTT,GPTBF3,3,NEOR)        
      IF (TMPSET .EQ. TSETNO) GO TO 30        
      GO TO 20        
   30 FDFALT = GPTBF3(2)        
      IF (RECNO  .NE.  0) GO TO 40        
      IF (IDFALT .EQ. -1) CALL MESAGE (-30,29,TSETNO)        
      CALL CLOSE (GPTT,CLSRW)        
      GO TO 60        
C        
C     POSITION GPTT TO DESIRED TEMPERATURE RECORD        
C        
   40 CALL REWIND (GPTT)        
      DO 50 I = 1,RECNO        
      CALL FWDREC (*410,GPTT)        
   50 CONTINUE        
      RECORD =.TRUE.        
C        
C     READ SETID AND VERIFY FOR CORRECTNESS        
C        
      CALL FREAD (GPTT,IDSET,1,0)        
      IF (TSETNO .NE. IDSET) CALL MESAGE (-30,29,TSETNO)        
C        
C     INITIALIZE /DS1ETT/ VARIABLES        
C        
      OLDEID = 0        
      OLDEL  = 0        
      EORFLG =.FALSE.        
      ENDID  =.TRUE.        
C        
C     DETERMINE IF AN ENFORCED DEFORMATION SET IS CALLED FOR.        
C        
   60 IEDT = ISIL        
      I    = ISIL        
      IF (DSETNO .LE. 0) GO TO 90        
      FILE = EDT        
      CALL PRELOC (*90,Z(BUFLOC),EDT)        
      CALL LOCATE (*450,Z(BUFLOC),EDTLOC,IFLAG)        
   70 CALL READ (*410,*80,EDT,EDTBUF,3,NEOR,IFLAG)        
      IF (DFMSET .NE. DSETNO) GO TO 70        
      IZ(I+1) = ELID        
      Z (I+2) = DEFORM        
      NEDT = NEDT + 2        
      I    = I + 2        
      LEFT = LEFT - 2        
      IF (LEFT .LE. 0) CALL MESAGE (-8,0,NAME)        
      GO TO 70        
   80 CALL CLOSE (EDT,CLSRW)        
      LOW = IEDT + 1        
      LIM = IEDT + NEDT        
C        
C     READ THE UGV INTO CORE.        
C        
   90 CALL GOPEN (UGV,Z(BUFFR1),INRW)        
      IDISP = IEDT + NEDT        
      MCBUGV(1) = UGV        
      CALL RDTRL (MCBUGV(1))        
      IF (LEFT .LT. MCBUGV(3)) CALL MESAGE (-8,0,NAME(1))        
      ITYPEB = 1        
      IUNPK  = 1        
      JUNPK  = MCBUGV(3)        
      INCUPK = 1        
      CALL UNPACK (*460,UGV,Z(IDISP+1))        
      CALL CLOSE  (UGV,CLSRW)        
C        
C     OPEN THE ECPTDS AND ECPT FILES.        
C        
      CALL GOPEN (ECPTDS,Z(BUFFR2),OUTRW)        
      CALL GOPEN (ECPT,Z(BUFFR1),INRW)        
C        
C     READ THE PIVOT POINT (1ST WORD).        
C        
  100 FILE   = ECPT        
      IMHERE = 100        
      ELTYPE = -1        
      J      = -1        
      CALL READ (*390,*430,ECPT,NPVT,1,NEOR,IFLAG)        
      IND = 0        
  110 DSTYPE =.FALSE.        
C        
C     READ ELEMENT TYPE (2ND WORD)        
C        
      CALL READ (*410,*370,ECPT,ELTYPE,1,NEOR,IFLAG)        
      IF (ELTYPE.LT.1 .OR. ELTYPE.GT.NELEMS) GO TO 480        
C        
C     READ ELEMENT ID (3RD WORD, BEGINNING OF J NO. OF WORDS)        
C        
      IMHERE = 115        
      CALL READ (*410,*430,ECPT,IECPT,1,NEOR,IFLAG)        
C     IF (IBACK.EQ.0 .OR. (ELTYPE.EQ.OLDEL .AND. IECPT(1).GE.OLDEID))   
C    1    GO TO 120        
      IF (IBACK .EQ. 0) GO TO 120        
      IF (ELTYPE.EQ.OLDEL .AND. IECPT(1).GE.OLDEID) GO TO 130        
      CALL BCKREC (GPTT)        
C        
C     RESET /DS1ETT/ VARIABLES        
C        
      IBACK  = 0        
      OLDEID = 0        
      OLDEL  = 0        
      EORFLG =.FALSE.        
      ENDID  =.TRUE.        
      CALL READ (*410,*420,GPTT,IDSET,1,0,FLAG)        
      IF (TSETNO .NE. IDSET) CALL MESAGE (-30,29,TSETNO)        
C        
  120 IDX = (ELTYPE-1)*INCR        
      NTEMP = 1        
C                IS2D8              IHEX1              IHEX3        
      IF (ELTYPE.EQ.80 .OR. (ELTYPE.GE.65 .AND. ELTYPE.LE.67))        
     1    NTEMP = NE(IDX+15) - 1        
C        
C     READ ECPT ENTRY FOR THIS ELEMENT (J-1 WORDS)        
C        
  130 J = NE(IDX+12)        
      IF (NE(IDX+24) .NE. 0) DSTYPE = .TRUE.        
      IMHERE = 130        
      CALL READ (*410,*430,ECPT,XECPT(2),J-1,NEOR,IFLAG)        
C        
C     IS THIS ELEMENT IN THE SET OF DS ELEMENTS.        
C        
      IF (DSTYPE) GO TO 150        
      IF (IZ(LEFT+ELTYPE) .EQ. 1) GO TO 110        
      IZ(LEFT+ELTYPE) = 1        
      CALL PAGE2 (-2)        
      WRITE  (IOUTPT,140) UWM,NE(IDX+1),NE(IDX+2),ELTYPE        
  140 FORMAT (A25,' 3117, DIFFERENTIAL STIFFNESS CAPABILITY NOT DEFINED'
     1,      ' FOR ',2A4,' ELEMENTS (ELEMENT TYPE ',I3,2H).)        
      GO TO 110        
  150 IARG = 1        
C        
C     DETERMINE IF THE ELEMENT IS A CONE.  IF IT IS, IT MUST HAVE A     
C     NONZERO MEMBRANE THICKNESS FOR IT TO BE ADMISSIBLE TO THE ECPTDS. 
C        
      IF (ELTYPE .NE. 35) GO TO 170        
C                 CONEAX        
      NTEMP = 2        
      IF (XECPT(5) .EQ. 0.0) GO TO 110        
C        
C     DETERMINE THE NUMBER OF RINGAX POINTS FROM THE 27TH WORD OF       
C     /SYSTEM/.        
C        
      NRNGAX = RSHIFT(MN,IHALF)        
C        
C     DETERMINE THE HARMONIC NUMBER, IHARM, FROM THE ELEMENT IDENT.     
C     NUMBER, IECPT(1)        
C        
      ITEMP = IECPT(1)/1000        
      IHARM = IECPT(1) - ITEMP*1000 - 1        
C        
C     DETERMINE THE SIL NUMBERS, SIL(1) AND SIL(2), WHICH WILL BE USED  
C     TO APPEND TEMPERATURES AND DISPLACEMENT VECTORS.        
C        
      IF (IHARM .NE. 0) GO TO 160        
      JSIL(1) = IECPT(2)        
      JSIL(2) = IECPT(3)        
      GO TO 180        
  160 ITEMP   = 6*IHARM*NRNGAX        
      JSIL(1) = IECPT(2) - ITEMP        
      JSIL(2) = IECPT(3) - ITEMP        
      GO TO 180        
C        
C     IF WE ARE DEALING WITH A TRIA1 OR QUAD1 ELEMENT, IT MUST HAVE A   
C     NONZERO MEMBRANE THICKNESS FOR IT TO BE ADMISSIBLE TO THE ECPTDS. 
C        
  170 IF (ELTYPE.NE.6 .AND. ELTYPE.NE.19) GO TO 180        
C               TRIA1              QUAD1        
      KK = 7        
      IF (ELTYPE .EQ. 19) KK = 8        
C                  QUAD1        
      IF (XECPT(KK) .EQ. 0.0) GO TO 110        
C        
C     WRITE PIVOT POINT        
C        
  180 IF (IND .EQ. 0) CALL WRITE (ECPTDS,NPVT,1,NEOR)        
      IND = 1        
      IF (ELTYPE .NE. 34) GO TO 200        
C                    BAR        
C        
C     THE ELEMENT IS A BAR.  THE ECPT ENTRY WILL BE REARRANGED SO THAT  
C     THE DBAR SUBROUTINE MAY BE CALLED IN SUBROUTINE DS1A.        
C        
      ELTYPE = 2        
C           BEAM        
C        
C     IF THE COUPLED MOMENT OF INERTIA TERM I12 (=ECPT(33)) IS NON-ZERO 
C     SET I12 = 0.0, WRITE WARNING MESSAGE AND PROCEED.        
C        
      IF (XECPT(33) .EQ. 0.0) GO TO 190        
      XECPT(33) = 0.0        
      CALL MESAGE (30,111,IECPT(1))        
  190 XECPT(47) = XECPT(42)        
      XECPT(46) = XECPT(41)        
      XECPT(45) = XECPT(40)        
      XECPT(44) = XECPT(39)        
      XECPT(43) = XECPT(38)        
      XECPT(42) = XECPT(37)        
      XECPT(41) = XECPT(36)        
      XECPT(40) = XECPT(35)        
      XECPT(39) = XECPT(34)        
      XECPT(29) = XECPT(31)        
      XECPT(30) = XECPT(32)        
      XECPT(28) = XECPT(21)        
      XECPT(27) = XECPT(20)        
      XECPT(25) = XECPT(19)        
      XECPT(24) = XECPT(18)        
      XECPT(21) = XECPT(17)        
      XECPT(20) = XECPT(16)        
      J = 47        
C        
C     WRITE ELEMENT TYPE        
C        
  200 CALL WRITE (ECPTDS,ELTYPE,1,NEOR)        
C        
C     ATTACH THE ELEMENT DEFORMATION TO THE XECPT ARRAY.        
C        
      J = J + 1        
      NOGPTS = NE(IDX+10)        
      XECPT(J) = 0.0        
      IF (DSETNO .GT. 0) GO TO 210        
      GO TO 230        
C        
C     SEARCH THE EDT TO FIND AN ELEMENT NO. IN THE TABLE CORRESPONDING  
C     TO THE CURRENT ELEMENT NO., IECPT(1).  IF IT CANNOT BE FOUND NOTE 
C     THE ELEMENT DEFORMATION, IECPT(J), HAS BEEN SET TO ZERO.        
C        
  210 DO 220 I = LOW,LIM,2        
      IF (IZ(I) .NE. IECPT(1)) GO TO 220        
      XECPT(J) = Z(I+1)        
      GO TO 230        
  220 CONTINUE        
C        
C     APPEND THE LOADING TEMPERATURE(S) TO THE XECPT ARRAY        
C        
  230 IF (ELTYPE .EQ. 2) ELTYPE = 34        
C                  BEAM          BAR        
      CALL DS1ETD (IECPT(1),TGRID,NTEMP)        
      IF (ELTYPE .NE. 34) GO TO 240        
C                    BAR        
      ELTYPE = 2        
      IF (TSETNO .LE. 0) GO TO 240        
      TGRID(1) = (TGRID(1) + TGRID(2))*0.5        
  240 III = 1        
      IF (ELTYPE .NE. 80) GO TO 250        
C                  IS2D8        
      J = J + 1        
      IECPT(J) = TSETNO        
      III = 2        
  250 CONTINUE        
      DO 260 I = III,NTEMP        
      J = J + 1        
      XECPT(J) = TGRID(I)        
  260 CONTINUE        
C        
C     NOW ATTACH THE DISPLACEMENT VECTORS        
C        
      J = J + 1        
      IF (ELTYPE .EQ. 35) GO TO 330        
C                 CONEAX        
      IF (ELTYPE.EQ. 2 .OR. ELTYPE.EQ.75) GO TO 290        
C                 BEAM             TRSHL        
      IF (ELTYPE.LT.53 .OR. ELTYPE.GT.61) GO TO 280        
C                 DUM1              DUM9        
C        
C        
C     DUMMY ELEMENTS        
C        
      IF (MOD(NDUM(ELTYPE-52),10) .EQ. 6) GO TO 290        
  280 NWDS = 3        
      GO TO 300        
  290 NWDS = 6        
  300 DO 320 I = 1,NOGPTS        
      INDEX = IDISP + IECPT(I+1)        
      DO 310 I1 = 1,NWDS        
      XECPT(J) = Z(INDEX)        
      INDEX = INDEX + 1        
  310 J = J + 1        
  320 CONTINUE        
      GO TO 360        
C        
C     APPEND THE ZERO HARMONIC COMPONENTS OF THE DISPLACEMENT VECTOR.   
C     NOTE THAT FOR A CONICAL SHELL ELEMENT DIRECT POINTERS INTO THE    
C     DISPLACEMENT VECTOR ARE SIL(1) AND SIL(2).        
C        
  330 DO 350 J1 = 1,2        
      DO 340 I  = 1,6        
      INDEX = IDISP + JSIL(J1) + I - 1        
      XECPT(J) = Z(INDEX)        
  340 J = J + 1        
  350 CONTINUE        
C        
C     THE APPENDED ECPT, ECPTDS, IS NOW COMPLETE.        
C        
  360 CALL WRITE (ECPTDS,XECPT,J-1,NEOR)        
      GO TO 110        
C        
C    IF IND = 0, THEN NO ELEMENTS IN THE CURRENT ECPT RECORD ARE IN THE 
C    DS ELEMENT SET.  WRITE A -1 FOR THIS PIVOT POINT.        
C        
  370 IF (IND .NE. 0) GO TO 380        
      CALL WRITE (ECPTDS,-1,1,EOR)        
      GO TO 100        
C        
C     WRITE AN EOR ON THE ECPTDS FILE        
C        
  380 CALL WRITE (ECPTDS,0,0,EOR)        
      GO TO 100        
C        
C     CLOSE BOTH FILES        
C        
  390 CALL CLOSE (ECPT,CLSRW)        
      CALL CLOSE (GPTT,CLSRW)        
      CALL CLOSE (ECPTDS,CLSRW)        
      RETURN        
C        
C     FATAL ERROR RETURNS        
C        
  400 J = -1        
      GO TO 470        
  410 J = -2        
      GO TO 470        
  420 FILE = GPTT        
  430 J = -3        
      IF (FILE .EQ. ECPT) WRITE (IOUTPT,440) IMHERE,ELTYPE,J        
  440 FORMAT (/,'0*** DS1/IMHERE,ELTYPE,J = ',3I5)        
      GO TO 470        
  450 J = -4        
      GO TO 470        
  460 CALL MESAGE (-30,83,NAME(1))        
  470 CALL MESAGE (J,FILE,NAME)        
  480 WRITE  (IOUTPT,490) SFM,ELTYPE        
  490 FORMAT (A25,' 2147, ILLEGAL ELEMENT TYPE =',I10,        
     1       ' ENCOUNTERED BY DSMG1 MODULE.')        
      CALL MESAGE (-61,0,NAME)        
      RETURN        
      END        
