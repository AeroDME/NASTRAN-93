      SUBROUTINE IFP5A (NUM)        
C        
C     IFP5A PRINTS MESSAGE NUMBER LINE ONLY.        
C     CALLING SUBROUTINE PRINTS THE MESSAGE.        
C        
      LOGICAL         NOGO        
      INTEGER         OUTPUT        
      CHARACTER       UFM*23        
      COMMON /XMSSG / UFM        
      COMMON /SYSTEM/ SYSBUF,OUTPUT,NOGO        
C        
      CALL PAGE2 (4)        
      I = NUM + 4080        
      WRITE  (OUTPUT,10) UFM,I        
   10 FORMAT (A23,I15,1H.)        
      NOGO = .TRUE.        
      RETURN        
      END        
