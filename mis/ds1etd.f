      SUBROUTINE DS1ETD (ELID,TI,GRIDS)        
C        
C     THIS ROUTINE (CALLED BY -DS1-) READS ELEMENT TEMPERATURE        
C     DATA FROM A PRE-POSITIONED RECORD        
C        
C     ELID   = ID OF ELEMENT FOR WHICH DATA IS DESIRED        
C     TI     = BUFFER DATA IS TO BE RETURNED IN        
C     GRIDS  = 0 IF EL-TEMP FORMAT DATA IS TO BE RETURNED        
C            = NO. OF GRID POINTS IF GRID POINT DATA IS TO BE RETURNED. 
C     ELTYPE = ELEMENT TYPE TO WHICH -ELID- BELONGS        
C     OLDEL  = ELEMENT TYPE CURRENTLY BEING WORKED ON (INITIALLY 0)     
C     OLDEID = ELEMENT ID FROM LAST CALL        
C     EORFLG =.TRUE. WHEN ALL DATA HAS BEEN EXHAUSTED IN RECORD        
C     ENDID  =.TRUE. WHEN ALL DATA HAS BEEN EXHAUSTED WITHIN AN ELEMENT 
C              TYPE.        
C     BUFFLG = NOT USED        
C     ITEMP  = TEMPERATURE LOAD SET ID        
C     IDEFT  = NOT USED        
C     IDEFM  = NOT USED        
C     RECORD =.TRUE. IF A RECORD OF DATA IS INITIALLY AVAILABLE        
C     DEFALT = THE DEFALT TEMPERATURE VALUE OR -1 IF IT DOES NOT EXIST  
C     AVRAGE = THE AVERAGE ELEMENT TEMPERATURE        
C        
      LOGICAL         EORFLG   ,ENDID    ,BUFFLG   ,RECORD        
      INTEGER         TI(2)    ,OLDEID   ,GRIDS    ,ELID     ,ELTYPE   ,
     1                OLDEL    ,NAME(2)  ,GPTT     ,DEFALT        
      CHARACTER       UFM*23        
      COMMON /XMSSG / UFM        
      COMMON /SYSTEM/ DUM      ,IOUT        
      COMMON /DS1ETT/ ELTYPE   ,OLDEL    ,EORFLG   ,ENDID    ,BUFFLG   ,
     1                ITEMP    ,DEFALT   ,IBACK    ,RECORD   ,OLDEID    
      DATA    NAME  / 4HDS1E,4HTD  /,  MAXWDS / 33 /,  GPTT  / 102 /    
C        
      IF (OLDEID .EQ. ELID) RETURN        
      OLDEID = ELID        
C        
      IF (ITEMP .GT. 0) GO TO 20        
      DO 10 I = 1,MAXWDS        
   10 TI(I) =-1        
      RETURN        
C        
   20 IF (.NOT.RECORD .OR. EORFLG) GO TO 50        
   15 IF (ELTYPE .NE. OLDEL) GO TO 30        
      IF (ENDID) GO TO 50        
C        
C     HERE WHEN ELTYPE IS AT HAND AND END OF THIS TYPE DATA        
C     HAS NOT YET BEEN REACHED.  READ AN ELEMENT ID        
C        
   35 CALL READ (*5002,*5001,GPTT,ID,1,0,FLAG)        
      IF (ID) 40,50,40        
   40 IF (IABS(ID) .EQ. ELID) IF (ID) 51,51,70        
      IF (ID) 35,35,45        
   45 CALL READ (*5002,*5001,GPTT,TI,NWORDS,0,FLAG)        
      GO TO 35        
C        
C     MATCH ON ELEMNT ID MADE AND IT WAS WITH DATA        
C        
   70 CALL READ (*5002,*5001,GPTT,TI,NWORDS,0,FLAG)        
      RETURN        
C        
C     NO MORE DATA FOR THIS ELEMENT TYPE        
C        
   50 ENDID = .TRUE.        
C        
C     NO DATA FOR ELEMENT ID DESIRED, THUS USE DEFALT        
C        
   51 IF (DEFALT .EQ. -1) GO TO 100        
      IF (GRIDS  .GT.  0) GO TO 75        
      DO 80 I = 2,MAXWDS        
   80 TI(I) = 0        
      TI(1) = DEFALT        
      IF (ELTYPE .EQ. 34) TI(2) = DEFALT        
      RETURN        
C        
   75 DO 76 I = 1,GRIDS        
   76 TI(I) = DEFALT        
      TI(GRIDS+1) = DEFALT        
      RETURN        
C        
C     NO TEMP DATA OR DEFALT        
C        
  100 WRITE  (IOUT,301) UFM,ELID,ITEMP        
  301 FORMAT (A23,' 4016, THERE IS NO TEMPERATURE DATA FOR ELEMENT',I9, 
     1       ' IN SET',I9)        
      CALL MESAGE (-61,0,0)        
C        
C     LOOK FOR MATCH ON ELTYPE (FIRST SKIP ANY UNUSED ELEMENT DATA)     
C        
   30 IF (ENDID) GO TO 32        
   31 CALL READ (*5002,*5001,GPTT,ID,1,0,FLAG)        
      IF (ID) 31,32,33        
   33 CALL READ (*5002,*5001,GPTT,TI,NWORDS,0,FLAG)        
      GO TO 31        
C        
C     READ ELTYPE AND COUNT        
C        
   32 CALL READ (*5002,*300,GPTT,TI,2,0,FLAG)        
      OLDEL  = TI(1)        
      NWORDS = TI(2)        
      ENDID  = .FALSE.        
      IBACK  = 1        
      GO TO 15        
C        
C     END OF RECORD HIT        
C        
  300 EORFLG = .TRUE.        
      GO TO 50        
 5002 CALL MESAGE (-2,GPTT,NAME)        
 5001 CALL MESAGE (-3,GPTT,NAME)        
      RETURN        
      END        
