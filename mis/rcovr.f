      SUBROUTINE RCOVR        
C        
C     MAIN DRIVER FOR PHASE 2 SUBSTRUCTURING RECOVER OPERATION        
C        
C     THIS MODULE WILL CALCULATE THE DISPLACEMENT AND REACTION MATRICES 
C     FOR ANY OF THE SUBSTRUCTURES COMPOSING THE FINAL SOLUTION STRUC-  
C     TURE.  OUTPUT DATA MAY BE PLACED ON OFP PRINT FILES OR SAVED ON   
C     THE SOF FOR SUBSEQUENT PROCESSING.        
C        
C     DMAP CALLING SEQUENCES        
C        
C     RIGID FORMATS 1 AND 2  (STATIC ANALYSIS)        
C        
C     RCOVR   CASESS,GEOM4,KGG,MGG,PG,UGV,,,,,/OUGV1,OPG1,OQG1,U1,      
C             U2,U3,U4,U5/DRY/ILOOP/STEP/FSS/RFNO/0/LUI/U1NM/U2NM/      
C             U3NM/U4NM/U5NM/S,N,NOSORT2/V,Y,UTHRESH/V,Y,PTHRESH/       
C             V,Y,QTHRESH $        
C        
C     RIGID FORMAT 3  (MODAL ANALYSIS)        
C        
C     RCOVR   CASESS,LAMA,KGG,MGG,,PHIG,,,,,/OPHIG,,OQG1,U1,U2,U3,      
C             U4,U5/DRY/ILOOP/STEP/FSS/RFNO/NEIGV/LUI/U1NM/U2NM/        
C             U3NM/U4NM/U5NM/S,N,NOSORT2/V,Y,UTHRESH/V,Y,PTHRESH/       
C             V,Y,QTHRESH $        
C        
C     RIGID FORMAT 8  (FREQUENCY ANALYSIS)        
C        
C     RCOVR   CASESS,GEOM4,KGG,MGG,PPF,UPVC,DIT,DLT,BGG,K4GG,PPF/       
C             OUGV1,OPG1,OQG1,U1,U2,U3,U4,U5/DRY/ILOOP/STEP/FSS/        
C             RFNO/0/LUI/U1NM/U2NM/U3NM/U4UN/U5NM/S,N,NOSORT2/        
C             V,Y,UTHRESH/V,Y,PTHRESH/V,Y,QTHRESH $        
C        
C     RIGID FORMAT 9  (TRANSIENT ANALYSIS)        
C        
C     RCOVR   CASESS,GEOM4,KGG,MGG,PPT,UPV,DIT,DLT,BGG,K4GG,TOL/        
C             OUGV1,OPG1,OQG1,U1,U2,U3,U4,U5/DRY/ILOOP/STEP/FSS/        
C             RFNO/0/LUI/U1NM/U2NM/U3NM/U4UN/U5NM/S,N,NOSORT2/        
C             V,Y,UTHRESH/V,Y,PTHRESH/V,Y,QTHRESH $        
C        
C     MRECOVER  (ANY RIGID FORMAT)        
C        
C     RCOVR   ,,,,,,,,,,/OPHIG,,OQG1,U1,U2,U3,U4,U5/DRY/ILOOP/        
C             STEP/FSS/3/NEIGV/LUI/U1NM/U2NM/U3NM/U4NM/U5NM/        
C             S,N,NOSORT2/V,Y,UTHRESH/V,Y,PTHRESH/V,Y,QTHRESH $        
C        
C     MAJOR SUBROUTINES FOR RCOVR ARE -        
C        
C     RCOVA - COMPUTES THE SOLN ITEM FOR THE FINAL SOLUTION STRUCTURE   
C     RCOVB - PERFORMS BACK-SUBSTITUTION TO RECOVER DISPLACEMENTS OF    
C             LOWER LEVEL SUBSTRUCTURES FROM THOSE OF THE FINAL SOLUTION
C             STRUCTURE        
C     RCOVC - COMPUTES REACTION MATRICES AND WRITES OUTPUT DATA BLOCKS  
C             FOR THE OFP        
C     RCOVO - PROCESS CASESS FOR THE RCOVER COMMAND AND ANY OUTPUT      
C             REQUESTS SPECIFIED        
C     RCOVE - COMPUTES MODAL ENERGIES AND ERRORS FOR A MODAL REDUCED    
C             SUBSTRUCTURE        
C        
C     JUNE 1977        
C        
      INTEGER ENERGY        
      COMMON /BLANK / DRY        ,LOOP       ,STEP       ,FSS(2)     ,  
     1                RFNO       ,NEIGV      ,LUI        ,UINMS(2,5) ,  
     2                NOSORT     ,UTHRES     ,PTHRES     ,QTHRES        
      COMMON /RCOVCM/ MRECVR     ,UA         ,PA         ,QA         ,  
     1                IOPT       ,RSS(2)     ,ENERGY     ,UIMPRO     ,  
     2                RANGE(2)   ,IREQ       ,LREQ       ,LBASIC        
C        
      NOSORT = -1        
      CALL RCOVO        
      CALL RCOVA        
      IF (IOPT .LT. 0) GO TO 10        
      CALL RCOVB        
      IF (IOPT .LE. 0) GO TO 10        
      CALL RCOVC        
      IF (ENERGY .NE. 0) CALL RCOVE        
   10 RETURN        
      END        
