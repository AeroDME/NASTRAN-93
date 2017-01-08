      SUBROUTINE KTETRA (IOPT,JTYPE)        
C        
C     ELEMENT STIFFNESS MATRIX GENERATOR FOR THE TETRAHEDRON SOLID      
C     ELEMENT        
C        
C     LOOKING DOWN ON THIS ELEMENT, GRIDS 1,2,3 ARE THE BASE AND MUST BE
C     LABELED COUNTERCLOCKWISE. GRID 4 MUST BE ABOVE THE PLANE FORMED BY
C     GRIDS 1,2,3 AND CLOSEST TO THIS OBSERVER.        
C        
C     ECPT FOR THE TETRAHEDRON SOLID ELEMENT        
C     --------------------------------------        
C     ECPT( 1) = ELEMENT  ID        
C     ECPT( 2) = MATERIAL ID (MAT1 MATERIAL TYPE)        
C     ECPT( 3) = SIL GRID POINT 1        
C     ECPT( 4) = SIL GRID POINT 2        
C     ECPT( 5) = SIL GRID POINT 3        
C     ECPT( 6) = SIL GRID POINT 4        
C     ECPT( 7) = COORD SYS ID GRID PT 1        
C     ECPT( 8) = X1        
C     ECPT( 9) = Y1        
C     ECPT(10) = Z1        
C     ECPT(11) = COORD SYS ID GRID PT 2        
C     ECPT(12) = X2        
C     ECPT(13) = Y2        
C     ECPT(14) = Z2        
C     ECPT(15) = COORD SYS ID GRID PT 3        
C     ECPT(16) = X3        
C     ECPT(17) = Y3        
C     ECPT(18) = Z3        
C     ECPT(19) = COORD SYS ID GRID PT 4        
C     ECPT(20) = X4        
C     ECPT(21) = Y4        
C     ECPT(22) = Z4        
C     ECPT(23) = ELEMENT TEMPERATURE        
C        
C     JTYPE = 1 FOR WEDGE, = 2 FOR HEXA1, = 3 FOR HEXA2, AND = 0 TETRA  
C     IF JTYPE IS NEGATIVE, THIS IS LAST CALL FROM KSOLID        
C        
C        
      LOGICAL         NOGO    ,HEAT      ,HYDRO        
      INTEGER         OUT     ,NECPT(4)  ,DIREC    ,EL(2,4)  ,SCR4      
      REAL            NU      ,MATBUF        
      DOUBLE PRECISION C      ,G         ,H        ,TEMP     ,HDETER  , 
     1                TEMP1   ,T         ,CT       ,KIJ      ,GCT       
      CHARACTER       UFM*23        
      COMMON /XMSSG / UFM        
      COMMON /BLANK / SKIP(16) ,VOLUME   ,SURFAC        
      COMMON /SMA1ET/ ECPT(100)        
      COMMON /SMA1DP/ C(72)    ,G(36)    ,H(16)    ,TEMP(12) ,T(9)    , 
     1                CT(18)   ,GCT(18)  ,KIJ(36)  ,HDETER   ,TEMP1   , 
     2                NGPT     ,DIREC    ,KOUNT    ,TVOL        
      COMMON /SMA1HT/ HEAT        
      COMMON /HYDROE/ HYDRO        
      COMMON /MATIN / MATID    ,INFLAG   ,ELTEMP        
      COMMON /MATOUT/ E        ,GG       ,NU       ,RHO      ,ALPHA   , 
     1                TSUB0    ,GSUBE    ,SIGT     ,SIGC     ,SIGS      
      COMMON /HMTOUT/ MATBUF(7)        
      COMMON /SMA1CL/ IOPT4    ,K4GGSW   ,NPVT     ,ISKP(17) ,NOGOO     
      COMMON /SMA1IO/ DUM1(10) ,IFKGG    ,DUM2(1)  ,IF4GG    ,DUM3(23)  
      COMMON /SYSTEM/ SYSBUF   ,OUT      ,NOGO        
      EQUIVALENCE     (NECPT(1),ECPT(1))        
      DATA    IDFLAG/ 0 /,    SCR4    /   304 /        
      DATA    EL    / 4HCWED, 4HGE  , 4HCHEX, 4HA1  , 4HCHEX, 4HA2  ,   
     1                4HCTET, 4HRA    /        
C        
C     FILL THE 4 X 4 H MATRIX.        
C        
      IF (NECPT(1) .EQ. IDFLAG) GO TO 100        
      IDFLAG = NECPT(1)        
      DIREC  = 0        
      KOUNT  = 0        
      TVOL   = 0.0        
      NGPT   = 99        
      IF (VOLUME.LE.0.0 .AND. SURFAC.LE.0.0) GO TO 100        
      NGPT   = 8        
      IF (IABS(JTYPE) .EQ. 1) NGPT = 6        
      IF (JTYPE .EQ. 0) NGPT  = 4        
  100 IF (JTYPE .LE. 0) KOUNT = KOUNT + 1        
C        
C     RETURN IF SUB-TETRA DOES NOT CONTRIBUTE TO PIVOT STIFFNESS AND NO 
C     GEOMETRY TESTS ARE BEING MADE ON IT.        
C        
      IF (IOPT .GE. 100) GO TO 140        
      DO 131 I = 3,6        
      IF (NPVT .EQ. NECPT(I)) GO TO 140        
  131 CONTINUE        
      IF (KOUNT.EQ.NGPT .AND. JTYPE.NE.0) GO TO 910        
      RETURN        
C        
  140 H( 1) = 1.0D0        
      H( 2) = ECPT( 8)        
      H( 3) = ECPT( 9)        
      H( 4) = ECPT(10)        
      H( 5) = 1.0D0        
      H( 6) = ECPT(12)        
      H( 7) = ECPT(13)        
      H( 8) = ECPT(14)        
      H( 9) = 1.0D0        
      H(10) = ECPT(16)        
      H(11) = ECPT(17)        
      H(12) = ECPT(18)        
      H(13) = 1.0D0        
      H(14) = ECPT(20)        
      H(15) = ECPT(21)        
      H(16) = ECPT(22)        
C        
C     INVERT H AND GET THE DETERMINANT        
C        
      ISING = 0        
      CALL INVERD (4,H(1),4,DUM,0,HDETER,ISING,TEMP(1))        
C        
C     IF THE DETERMINANT IS .LE. 0 THE TETRAHEDRON HAS BAD OR REVERSE   
C     GEOMETRY WHICH IS AN ERROR CONDITION.        
C        
      IF (ISING .EQ.  2) GO TO 149        
      IF (IOPT .LT. 100) GO TO 200        
      IOPT = IOPT - 100        
      IF (DIREC .NE.  0) GO TO 148        
      DIREC = 1        
      IF (HDETER .LT.0.0D0) DIREC = -1        
      GO TO 200        
  148 IF (DIREC.EQ. 1 .AND. HDETER.GT.0.0D0) GO TO 200        
      IF (DIREC.EQ.-1 .AND. HDETER.LT.0.0D0) GO TO 200        
  149 WRITE  (OUT,150) UFM,NECPT(1)        
  150 FORMAT (A23,' 4004, MODULE SMA1 DETECTS BAD OR REVERSE GEOMETRY ',
     1       'FOR ELEMENT ID',I10)        
      NOGOO = 1        
      RETURN        
C        
C     SKIP SUB-TETRAHEDRON IF IT DOES NOT CONTRIBUTE TO PIVOT STIFFNESS 
C        
  200 DO 201 I = 3,6        
      IF (NPVT .EQ. NECPT(I)) GO TO 209        
  201 CONTINUE        
      IF (KOUNT.EQ.NGPT .AND. JTYPE.NE.0) GO TO 910        
      RETURN        
C        
C     AT THIS POINT BRANCH ON HEAT OR STRUCTURE PROBLEM.        
C        
  209 HDETER = DABS(HDETER)        
      IF (HEAT ) GO TO 1010        
      IF (HYDRO) GO TO 1060        
C        
C     GET THE MATERIAL DATA AND FILL THE 6X6 G MATERIAL STRESS-STRAIN   
C     MATRIX.        
C        
      INFLAG = 1        
      MATID  = NECPT(2)        
      ELTEMP = ECPT(23)        
      CALL MAT (NECPT(1))        
      DO 210 I = 1,36        
  210 G(I)  = 0.0D0        
      TEMP1 = (1.0+NU)*(1.0-2.0*NU)        
      IF (DABS(TEMP1) .GT. 1.0D-6) GO TO 240        
      WRITE  (OUT,230) UFM,MATID,ECPT(1)        
  230 FORMAT (A23,' 4005, AN ILLEGAL VALUE OF -NU- HAS BEEN SPECIFIED ',
     1       'UNDER MATERIAL ID',I10,' FOR ELEMENT ID',I10)        
      NOGOO = 1        
      RETURN        
C        
  240 G( 1) = E*(1.0-NU)/TEMP1        
      G( 8) = G(1)        
      G(15) = G(1)        
      G( 2) = E*NU/TEMP1        
      G( 3) = G(2)        
      G( 7) = G(2)        
      G( 9) = G(2)        
      G(13) = G(2)        
      G(14) = G(2)        
      G(22) = GG        
      G(29) = GG        
      G(36) = GG        
C        
C     FILL 4 C-MATRICES. (6X3) EACH.        
C        
      DO 400 I = 1,72        
  400 C(I) = 0.0D0        
      DO 500 I = 1,4        
      J = 18*I - 18        
      C(J+ 1) = H(I+ 4)        
      C(J+ 5) = H(I+ 8)        
      C(J+ 9) = H(I+12)        
      C(J+11) = H(I+12)        
      C(J+12) = H(I+ 8)        
      C(J+13) = H(I+12)        
      C(J+15) = H(I+ 4)        
      C(J+16) = H(I+ 8)        
      C(J+17) = H(I+ 4)        
  500 CONTINUE        
C        
C     DIVIDE DETERMINANT BY 6.0, AND BY AN ADDITIONAL 2.0 IF A SUB-TETRA
C     FOR THE HEXA-10 ELEMENT.        
C     FOR WEDGES, 1ST 6 CONFIGURATUONS ARE MULTIPLIED BY 2.        
C     ALL CONFIGURATIONS ARE DIVIDED BY 6.        
C        
      IF (IOPT) 602,601,602        
  601 HDETER = HDETER/6.0D0        
      GO TO 610        
  602 IF (IOPT.GE.11 .AND. IOPT.LE.22) GO TO 603        
      HDETER = HDETER/12.0D0        
      GO TO 610        
C        
C     WEDGES        
C        
  603 HDETER = HDETER/36.0D0        
      IF (IOPT .LE. 16) HDETER = HDETER*2.0D0        
  610 DO 700 I = 1,36        
  700 KIJ(I) = 0.0D0        
C        
C     DETERMINE THE PIVOT POINT        
C        
      DO 720 I = 2,5        
      KA = 4*I - 1        
      NPOINT = 18*I - 35        
      IF (NECPT(I+1) .NE. NPVT) GO TO 720        
      GO TO 740        
  720 CONTINUE        
      CALL MESAGE (-30,34,ECPT(1))        
C        
C     PICK UP PIVOT TRANSFORMATION IF CSID IS NON-ZERO.        
C        
  740 IF (NECPT(KA)) 750,760,750        
  750 CALL TRANSD (NECPT(KA),T)        
      CALL GMMATD (T(1),3,3,1, C(NPOINT),6,3,1, CT(1))        
      GO TO 778        
C        
C                     T  T        
C     AT THIS POINT  T  C  IS STORED AS A 3X6 IN THE CT ARRAY.        
C                     I  I        
C        
C                                                T T        
C     NOW MULTIPLY ON THE RIGHT BY G   TO FORM  T C G   (3X6)        
C                                   E            I I E        
C        
  760 CALL GMMATD (C(NPOINT),6,3,1, G(1),6,6,0, GCT(1))        
      GO TO 781        
  778 CALL GMMATD (CT(1),3,6,0, G(1),6,6,0, GCT(1))        
  781 DO 790 I = 1,18        
      GCT(I) = GCT(I)*HDETER        
  790 CONTINUE        
C        
C     LOOP THROUGH THE 4 POINTS INSERTING THE STIFFNESS MATRIX FOR      
C     EACH WITH RESPECT TO THE PIVOT POINT.        
C        
      DO 900 I = 1,4        
      IF (NECPT(4*I+3)) 810,820,810        
  810 CALL TRANSD (NECPT(4*I+3),T)        
      CALL GMMATD (C(18*I-17),6,3,0, T(1),3,3,0, CT(1))        
      CALL GMMATD (GCT(1),3,6,0, CT(1),6,3,0, T(1))        
      GO TO 830        
C        
C     NO TRANSFORMATION        
C        
  820 CALL GMMATD (GCT(1),3,6,0, C(18*I-17),6,3,0, T(1))        
C        
C     INSERT 3X3 KIJ INTO 6X6 KIJ AND CALL SMA1B FOR INSERTION.        
C        
  830 KIJ( 1) = T(1)        
      KIJ( 2) = T(2)        
      KIJ( 3) = T(3)        
      KIJ( 7) = T(4)        
      KIJ( 8) = T(5)        
      KIJ( 9) = T(6)        
      KIJ(13) = T(7)        
      KIJ(14) = T(8)        
      KIJ(15) = T(9)        
C        
      CALL SMA1B (KIJ(1),NECPT(I+2),-1,IFKGG,0.0D0)        
      TEMP1 = GSUBE        
      IF (IOPT4) 840,900,840        
  840 IF (GSUBE) 850,900,850        
  850 CALL SMA1B (KIJ(1),NECPT(I+2),-1,IF4GG,TEMP1)        
C        
  900 CONTINUE        
C        
C     IF USER REQUESTED VOLUME AND SURFACE CALCULATIONS, WE NEED TO SAVE
C     IN SCR4 THE FOLLOWING        
C     WORDS 1,2 = ELEM. BCD NAME        
C             3 = ELEM. ID        
C             4 = VOLUME        
C             5 = MASS        
C             6 = NO. OF GRID POINTS, NGPT        
C           7 THRU 6+NGPT = GRID POINTS        
C           7+NGPT THRU 7+5*NGPT = BGPDT DATA        
C        
      TVOL = TVOL + HDETER/4.0D+0        
      IF (KOUNT .LT. NGPT) GO TO 950        
  910 IF (JTYPE .GT. 0) GO TO 950        
      ECPT(2) = TVOL*VOLUME        
      IF (JTYPE.EQ.0 .AND. SURFAC.GT.0.0) GO TO 920        
      J = IABS(JTYPE)        
      ECPT(3) = TVOL        
      IF (RHO .GT. 0.0) ECPT(3) = TVOL*RHO        
      NECPT(4) = NGPT        
      CALL WRITE (SCR4,EL(1,J),2,0)        
      CALL WRITE (SCR4,ECPT(1),4,0)        
      IF (SURFAC .LE. 0.0) GO TO 950        
      J = NGPT*5        
      CALL WRITE (SCR4,ECPT(53),J,1)        
      GO TO 950        
  920 CALL WRITE (SCR4,EL(1,4),2,0)        
      CALL WRITE (SCR4,ECPT(1),2,0)        
      IF (RHO .GT. 0.0) TVOL = TVOL*RHO        
      ECPT (1) = TVOL        
      NECPT(2) = NGPT        
      CALL WRITE (SCR4,ECPT(1),22,1)        
C        
  950 RETURN        
C        
C     HEAT PROBLEM LOGIC FOR 1 PIVOT ROW OF 1 TETRAHEDRON.        
C        
C     OBTAIN G  MATERIAL MATRIX FROM HMAT ROUTINE        
C             E        
C        
 1010 MATID  = NECPT(2)        
      INFLAG = 3        
      ELTEMP = ECPT(23)        
      CALL HMAT (NECPT)        
      G( 1)  = 0.0D0        
      G( 2)  = 0.0D0        
      G( 3)  = 0.0D0        
      G( 4)  = 0.0D0        
      G( 5)  = 0.0D0        
      G( 6)  = MATBUF(1)        
      G( 7)  = MATBUF(2)        
      G( 8)  = MATBUF(3)        
      G( 9)  = 0.0D0        
      G(10)  = MATBUF(2)        
      G(11)  = MATBUF(4)        
      G(12)  = MATBUF(5)        
      G(13)  = 0.0D0        
      G(14)  = MATBUF(3)        
      G(15)  = MATBUF(5)        
      G(16)  = MATBUF(6)        
C        
C     OBTAIN THE FOUR CONDUCTIVITY VALUES NEEDED FOR PIVOT ROW BEING    
C     INSERTED.        
C        
 1020 CONTINUE        
      CALL GMMATD (G(1),4,4,0, H(1),4,4,0, C(5))        
      IHCOL   = I - 2        
      TEMP(1) = H(IHCOL  )        
      TEMP(2) = H(IHCOL+4)        
      TEMP(3) = H(IHCOL+8)        
      TEMP(4) = H(IHCOL+12)        
      CALL GMMATD (TEMP(1),1,4,0, C(5),4,4,0, C(1))        
C        
C     DIVIDE CONDUCTIVITY BY 2.0 IF THIS IS A SUB-TETRA OF A HEXA2      
C     ELEMENT.        
C        
      IF (IOPT) 1045,1040,1045        
 1040 HDETER = HDETER/6.0D0        
      GO TO 1046        
 1045 IF (IOPT.GE.11 .AND. IOPT.LE.22) GO TO 1048        
      HDETER = HDETER/12.0D0        
      GO TO 1046        
C        
C     WEDGES        
C        
 1048 HDETER = HDETER/36.0D0        
      IF (IOPT .LE. 16) HDETER = HDETER*2.0D0        
 1046 DO 1047 I = 1,4        
      C(I) = C(I)*HDETER        
 1047 CONTINUE        
C        
C     INSERT THE PIVOT ROW.        
C        
      DO 1050 I = 1,4        
      CALL SMA1B (C(I),NECPT(I+2),NPVT,IFKGG,0.0D0)        
 1050 CONTINUE        
      RETURN        
C        
C     HYDROELASTIC PROBLEM, OBTAIN DENSITY AND RETURN        
C        
 1060 MATID  = NECPT(2)        
      INFLAG = 11        
      CALL MAT (NECPT(1))        
      DO 1070 IDLH = 1,16        
 1070 G(IDLH) = 0.0D0        
      G(6)  = 1.0D0/DBLE(RHO)        
      G(11) = G(6)        
      G(16) = G(6)        
      GO TO 1020        
      END        
