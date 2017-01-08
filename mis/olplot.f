      SUBROUTINE OLPLOT
C
C     DRIVER FOR USER SUPPLIED INTERACTIVE PLOTTER
C
C     NOTE - ALL FORTRAN STOPS MUST BE CHANGED TO RETURNS
C     OTHERWISE THE FORTRAN STOPS WILL KILL THE INTERACTIVE SESSION.
C
      INTEGER PLT2
      COMMON /SYSTEM/ IBUF,NOUT
      DATA PLT2/13/                                                     
C                                                                       
      WRITE (NOUT,10)
   10 FORMAT ('    USER MUST SUPPLY SITE DEPENDENT PLOTTING PACKAGE',   
     1       /4X, 'IN SUBROUTINE OLPLOT FOR INTERACTIVE PLOTS')         
C                                                                       
C                                                                       
      REWIND PLT2
C     CALL THE SITE DEPENDENT PLOTTING ROUTINES HERE.
C     CALL NASPLOT
      RETURN
      END
