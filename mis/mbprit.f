      SUBROUTINE MBPRIT(AW,AC,AT)
C
C     SUBROUTINE TO PRINT GEOMETRY DATA
C
      LOGICAL  CNTRL2 , CNTRL1 , CRANK1 , CRANK2 , ASYM
      COMMON /SYSTEM/ SYS,N6
      COMMON /MBOXA/ X(12),Y(12),TANG(10),ANG(10),COTANG(10)
      COMMON /MBOXC/ NJJ ,CRANK1,CRANK2,CNTRL1,CNTRL2,NBOX,
     *  NPTS0,NPTS1,NPTS2,ASYM,GC,CR,MACH,BETA,EK,EKBAR,EKM,
     *  BOXL,BOXW,BOXA ,NCB,NSB,NSBD,NTOTE,KC,KC1,KC2,KCT,KC1T,KC2T
C
      WRITE  (N6 , 200 )  CNTRL2 , CNTRL1 , CRANK1 , CRANK2 , ASYM
 200  FORMAT  ( 1H1 , 35X , 27HSUPERSONIC MACH BOX PROGRAM / 1H0 , 43X  
     *        , 12HCONTROL DATA / L20 , 9X , 6HCNTRL2 / L20 , 9X        
     *        , 6HCNTRL1 / L20 , 9X , 21HCRANK  (LEADING EDGE)          
     *        / L20 , 9X , 22HCRANK  (TRAILING EDGE) / L20 , 9X         
     *        , 14HANTI-SYMMETRIC / L20 )                               
C                                                                       
      WRITE  (N6 , 300 )   ( I , X(I) , Y(I) , TANG(I) , ANG(I) , I=1,7)
 300  FORMAT  (1H- , 42X , 13HGEOMETRY DATA / 1H0 , 8X , 1HN , 11X , 1HX
     *        , 17X , 1HY , 16X , 4HTANG , 14X , 3HANG / ( I10          
     *        , 4E18.6 ) )                                              
C                                                                       
      WRITE  (N6 , 400 )  ( I , X(I) , Y(I) , TANG(I) , I = 8 , 10)
     *                  , ( I , X(I) , Y(I) , I = 11 , 12 )
 400  FORMAT(I10,3E18.6/I10,3E18.6/I10,3E18.6/(I10,2E18.6))             
C                                                                       
      WRITE  (N6 , 500 )   AW , AC , AT
 500  FORMAT  ( 1H0 , 5X , 23HAREA OF MAIN (SEMISPAN) , 11X             
     *        , 15HAREA OF CNTRL1                                       
     *       , 18X , 14HAREA OF CNTRL2 / E22.6,E34.6,E29.6)             
      RETURN
      END
