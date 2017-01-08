      FUNCTION ITCODE (ITEMX)        
C        
C     THE FUNCTION RETURNS AN INTEGER CODE NUMBER FOR ITEM.  THE CODE   
C     NUMBER IS USED IN UPDATING THE MDI.  IF AN INCORRECT ITEM NAME IS 
C     USED, THE VALUE RETURNED WILL BE -1.        
C        
      COMMON /ITEMDT/ NITEM,ITEM(7,1)        
      COMMON /SYS   / SYS(5),IFRST        
C        
      DO 10 I = 1,NITEM        
      IF (ITEMX .EQ. ITEM(1,I)) GO TO 20        
   10 CONTINUE        
C        
C     INVALID ITEM - RETURN -1        
C        
      ITCODE = -1        
      RETURN        
C        
C     ITEM FOUND - RETURN MDI POSITION POINTER        
C        
   20 ITCODE = I + IFRST - 1        
      RETURN        
      END        
