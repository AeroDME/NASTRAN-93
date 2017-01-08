      SUBROUTINE XLNKDD        
C        
C     LINK SPECIFICATION TABLE        
C        
C     A LINK TABLE ENTRY CONTAINS AN EXECUTABLE DMAP INSTRUCTION NAMES, 
C     THEIR CORRESPONDING SUBROUTINE ENTRY POINT NAMES, AND THE LINK OR 
C     LINKS WHERE THEY RESIDE        
C     EACH BIT IN THE LINK FLAG SPECIFIES A LINK NUMBER. BIT 1 (RIGHT   
C     MOST) SPECIFIES LINK ONE, BIT 2 SPECIFIES LINK 2, ETC.        
C     BIT ON SPECIFIES MODULE IS IN THAT LINK, BIT OFF MEANS IT IS NOT. 
C     EXAMPLE - SUPPOSE MODULE X IS IN LINKS 2,4 AND 5. ITS LINK        
C               FLAG=32(8).        
C        
C     LLINK = LENGTH OF LINK TABLE.        
C        
C     SET SENSE SWITCH 28 TO GENERATE ALL FORTRAN CODE BELOW.        
C        
      DIMENSION       LINK (960),        
     1                LINK01(90), LINK02(90), LINK03(90),LINK04(90),    
     2                LINK05(90), LINK06(90), LINK07(90),LINK08(90),    
     3                LINK09(90), LINK10(90), LINK11(70)        
      COMMON /XLKSPC/ LLINK     , KLINK(970)        
      EQUIVALENCE     (LINK(  1), LINK01(1)), (LINK( 91),LINK02(1)),    
     1                (LINK(181), LINK03(1)), (LINK(271),LINK04(1)),    
     2                (LINK(361), LINK05(1)), (LINK(451),LINK06(1)),    
     3                (LINK(541), LINK07(1)), (LINK(631),LINK08(1)),    
     4                (LINK(721), LINK09(1)), (LINK(811),LINK10(1)),    
     5                (LINK(901), LINK11(1))        
      DATA    LLINKX / 970 /        
      DATA    LINK01 / 4HCHKP,4HNT  , 4HXCHK,4H    , 32767 ,        
     1                 4HREPT,4H    , 4HXCEI,4H    , 32767 ,        
     2                 4HJUMP,4H    , 4HXCEI,4H    , 32767 ,        
     3                 4HCOND,4H    , 4HXCEI,4H    , 32767 ,        
     4                 4HSAVE,4H    , 4HXSAV,4HE   , 32766 ,        
     5                 4HPURG,4HE   , 4HXPUR,4HGE  , 32767 ,        
     6                 4HEQUI,4HV   , 4HXEQU,4HIV  , 32767 ,        
     7                 4HEND ,4H    , 4HXCEI,4H    , 32767 ,        
     8                 4HEXIT,4H    , 4HXCEI,4H    , 32767 ,        
     9                 4HADD ,4H    , 4HDADD,4H    , 72    ,        
     O                 4HADD5,4H    , 4HDADD,4H5   , 64    ,        
     1                 4HAMG ,4H    , 4HAMG ,4H    , 256   ,        
     2                 4HAMP ,4H    , 4HAMP ,4H    , 256   ,        
     3                 4HAPD ,4H    , 4HAPD ,4H    , 256   ,        
     4                 4HBMG ,4H    , 4HBMG ,4H    , 512   ,        
     5                 4HCASE,4H    , 4HCASE,4H    , 512   ,        
     6                 4HCEAD,4H    , 4HCEAD,4H    , 1024  ,        
     7                 4HCYCT,4H1   , 4HCYCT,4H1   , 64    /        
      DATA    LINK02 / 4HCYCT,4H2   , 4HCYCT,4H2   , 64    ,        
     1                 4HDDR ,4H    , 4HDDR ,4H    , 128   ,        
     2                 4HDDR1,4H    , 4HDDR1,4H    , 2048  ,        
     3                 4HDDR2,4H    , 4HDDR2,4H    , 2048  ,        
     4                 4HDDRM,4HM   , 4HDDRM,4HM   , 2048  ,        
     5                 4HDECO,4HMP  , 4HDDCO,4HMP  , 64    ,        
     6                 4HDIAG,4HONAL, 4HDIAG,4HON  , 16384 ,        
     7                 4HDPD ,4H    , 4HDPD ,4H    , 32    ,        
     8                 4HDSCH,4HK   , 4HDSCH,4HK   , 64    ,        
     9                 4HDSMG,4H1   , 4HDSMG,4H1   , 4096  ,        
     O                 4HDSMG,4H2   , 4HDSMG,4H2   , 8     ,        
     1                 4HDUMM,4HOD1 , 4HDUMO,4HD1  , 4     ,        
     2                 4HDUMM,4HOD2 , 4HDUMO,4HD2  , 64    ,        
     3                 4HDUMM,4HOD3 , 4HDUMO,4HD3  , 64    ,        
     4                 4HDUMM,4HOD4 , 4HDUMO,4HD4  , 64    ,        
     5                 4HEMA1,4H    , 4HEMA1,4H    , 128   ,        
     6                 4HEMG ,4H    , 4HEMG ,4H    , 128   ,        
     7                 4HFA1 ,4H    , 4HFA1 ,4H    , 1024  /        
      DATA    LINK03 / 4HFA2 ,4H    , 4HFA2 ,4H    , 1024  ,        
     1                 4HFBS ,4H    , 4HDFBS,4H    , 64    ,        
     2                 4HFRLG,4H    , 4HFRLG,4H    , 512   ,        
     3                 4HFRRD,4H    , 4HFRRD,4H    , 512   ,        
     4                 4HGI  ,4H    , 4HGI  ,4H    , 256   ,        
     5                 4HGKAD,4H    , 4HGKAD,4H    , 512   ,        
     6                 4HGKAM,4H    , 4HGKAM,4H    , 512   ,        
     7                 4HGP1 ,4H    , 4HGP1 ,4H    , 2     ,        
     8                 4HGP2 ,4H    , 4HGP2 ,4H    , 2     ,        
     9                 4HGP3 ,4H    , 4HGP3 ,4H    , 2     ,        
     O                 4HGP4 ,4H    , 4HGP4 ,4H    , 8     ,        
     1                 4HGPCY,4HC   , 4HGPCY,4HC   , 64    ,        
     2                 4HGPFD,4HR   , 4HGPFD,4HR   , 4096  ,        
     3                 4HDUMM,4HOD5 , 4HDUMO,4HD5  , 64    ,        
     4                 4HGPWG,4H    , 4HGPWG,4H    , 8     ,        
     5                 4HINPU,4HT   , 4HINPU,4HT   , 2     ,        
     6                 4HINPU,4HTT1 , 4HINPT,4HT1  , 2     ,        
     7                 4HINPU,4HTT2 , 4HINPT,4HT2  , 2     /        
      DATA    LINK04 / 4HINPU,4HTT3 , 4HINPT,4HT3  , 2     ,        
     1                 4HINPU,4HTT4 , 4HINPT,4HT4  , 2     ,        
     2                 4HMATG,4HEN  , 4HMATG,4HEN  , 64    ,        
     3                 4HMATG,4HPR  , 4HMATG,4HPR  , 16    ,        
     4                 4HMATP,4HRN  , 4HMATP,4HRN  , 32766 ,        
     5                 4HMATP,4HRT  , 4HPRTI,4HNT  , 32766 ,        
     6                 4HMCE1,4H    , 4HMCE1,4H    , 8     ,        
     7                 4HMCE2,4H    , 4HMCE2,4H    , 8     ,        
     8                 4HMERG,4HE   , 4HMERG,4HE1  , 64    ,        
     9                 4HMODA,4H    , 4HMODA,4H    , 64    ,        
     O                 4HMODA,4HCC  , 4HMODA,4HCC  , 2048  ,        
     1                 4HMODB,4H    , 4HMODB,4H    , 64    ,        
     2                 4HMODC,4H    , 4HMODC,4H    , 64    ,        
     3                 4HMPYA,4HD   , 4HDMPY,4HAD  , 64    ,        
     4                 4HMTRX,4HIN  , 4HMTRX,4HIN  , 512   ,        
     5                 4HOFP ,4H    , 4HOFP ,4H    , 8192  ,        
     6                 4HOPTP,4HR1  , 4HOPTP,4HR1  , 2     ,        
     7                 4HOPTP,4HR2  , 4HOPTP,4HR2  , 128   /        
      DATA    LINK05 / 4HOUTP,4HUT  , 4HOUTP,4HT   , 8192  ,        
     1                 4HOUTP,4HUT1 , 4HOUTP,4HT1  , 8192  ,        
     2                 4HOUTP,4HUT2 , 4HOUTP,4HT2  , 8192  ,        
     3                 4HOUTP,4HUT3 , 4HOUTP,4HT3  , 8192  ,        
     4                 4HOUTP,4HUT4 , 4HOUTP,4HT4  , 8192  ,        
     5                 4HPARA,4HM   , 4HQPAR,4HAM  , 32766 ,        
     6                 4HPARA,4HML  , 4HPARA,4HML  , 32766 ,        
     7                 4HPARA,4HMR  , 4HQPAR,4HMR  , 32766 ,        
     8                 4HPART,4HN   , 4HPART,4HN1  , 64    ,        
     9                 4HMRED,4H1   , 4HMRED,4H1   , 16384 ,        
     O                 4HMRED,4H2   , 4HMRED,4H2   , 16384 ,        
     1                 4HCMRE,4HD2  , 4HCMRD,4H2   , 16384 ,        
     2                 4HPLA1,4H    , 4HPLA1,4H    , 4     ,        
     3                 4HPLA2,4H    , 4HPLA2,4H    , 4096  ,        
     4                 4HPLA3,4H    , 4HPLA3,4H    , 4096  ,        
     5                 4HPLA4,4H    , 4HPLA4,4H    , 4096  ,        
     6                 4HPLOT,4H    , 4HDPLO,4HT   , 2     ,        
     7                 4HPLTS,4HET  , 4HDPLT,4HST  , 2     /        
      DATA    LINK06 / 4HPLTT,4HRAN , 4HPLTT,4HRA  , 2     ,        
     1                 4HPRTM,4HSG  , 4HPRTM,4HSG  , 2     ,        
     2                 4HPRTP,4HARM , 4HPRTP,4HRM  , 128   ,        
     3                 4HRAND,4HOM  , 4HRAND,4HOM  , 8192  ,        
     4                 4HRMG ,4H    , 4HRMG ,4H    , 16    ,        
     5                 4HRBMG,4H1   , 4HRBMG,4H1   , 8     ,        
     6                 4HRBMG,4H2   , 4HRBMG,4H2   , 8     ,        
     7                 4HRBMG,4H3   , 4HRBMG,4H3   , 8     ,        
     8                 4HRBMG,4H4   , 4HRBMG,4H4   , 8     ,        
     9                 4HREAD,4H    , 4HREIG,4H    , 32    ,        
     O                 4HSCAL,4HAR  , 4HSCAL,4HAR  , 16384 ,        
     1                 4HSCE1,4H    , 4HSCE1,4H    , 8     ,        
     2                 4HSDR1,4H    , 4HSDR1,4H    , 2048  ,        
     3                 4HSDR2,4H    , 4HSDR2,4H    , 4096  ,        
     4                 4HSDR3,4H    , 4HSDR3,4H    , 8192  ,        
     5                 4HSDRH,4HT   , 4HSDRH,4HT   , 4096  ,        
     6                 4HSEEM,4HAT  , 4HSEEM,4HAT  , 2     ,        
     7                 4HSETV,4HAL  , 4HSETV,4HAL  , 32766 /        
      DATA    LINK07 / 4HSMA1,4H    , 4HSMA1,4H    , 4     ,        
     1                 4HSMA2,4H    , 4HSMA2,4H    , 4     ,        
     2                 4HSMA3,4H    , 4HSMA3,4H    , 8     ,        
     3                 4HSMP1,4H    , 4HSMP1,4H    , 8     ,        
     4                 4HSMP2,4H    , 4HSMP2,4H    , 8     ,        
     5                 4HSMPY,4HAD  , 4HSMPY,4HAD  , 64    ,        
     6                 4HSOLV,4HE   , 4HSOLV,4HE   , 64    ,        
     7                 4HSSG1,4H    , 4HSSG1,4H    , 16    ,        
     8                 4HSSG2,4H    , 4HSSG2,4H    , 16    ,        
     9                 4HSSG3,4H    , 4HSSG3,4H    , 16    ,        
     O                 4HSSG4,4H    , 4HSSG4,4H    , 16    ,        
     1                 4HSSGH,4HT   , 4HSSGH,4HT   , 16    ,        
     2                 4HTA1 ,4H    , 4HTA1 ,4H    , 2     ,        
     3                 4HCURV,4H    , 4HCURV,4H    , 4096  ,        
     4                 4HTABP,4HCH  , 4HTABP,4HCH  , 32766 ,        
     5                 4HTABP,4HRT  , 4HTABF,4HMT  , 32766 ,        
     6                 4HTABP,4HT   , 4HTABP,4HT   , 32766 ,        
     7                 4HTIME,4HTEST, 4HTIMT,4HST  , 256   /        
      DATA    LINK08 / 4HTRD ,4H    , 4HTRD ,4H    , 1024  ,        
     1                 4HTRHT,4H    , 4HTRHT,4H    , 1024  ,        
     2                 4HTRLG,4H    , 4HTRLG,4H    , 16    ,        
     3                 4HTRNS,4HP   , 4HDTRA,4HNP  , 64    ,        
     4                 4HUMER,4HGE  , 4HDUME,4HRG  , 64    ,        
     5                 4HUPAR,4HTN  , 4HDUPA,4HRT  , 64    ,        
     6                 4HVDR ,4H    , 4HVDR ,4H    , 2048  ,        
     7                 4HVEC ,4H    , 4HVEC ,4H    , 64    ,        
     8                 4HXYPL,4HOT  , 4HXYPL,4HOT  , 2     ,        
     9                 4HXYPR,4HNPLT, 4HXYPR,4HPT  , 8192  ,        
     O                 4HXYTR,4HAN  , 4HXYTR,4HAN  , 2     ,        
     1                 4HCOMB,4H1   , 4HCOMB,4H1   , 16384 ,        
     2                 4HCOMB,4H2   , 4HCOMB,4H2   , 16384 ,        
     3                 4HEXIO,4H    , 4HEXIO,4H    , 16384 ,        
     4                 4HRCOV,4HR   , 4HRCOV,4HR   , 16384 ,        
     5                 4HRCOV,4HR3  , 4HRCOV,4HR3  , 16384 ,        
     6                 4HREDU,4HCE  , 4HREDU,4HCE  , 16384 ,        
     7                 4HSGEN,4H    , 4HSGEN,4H    , 16384 /        
      DATA    LINK09 / 4HSOFI,4H    , 4HSOFI,4H    , 16384 ,        
     1                 4HSOFO,4H    , 4HSOFO,4H    , 16384 ,        
     2                 4HSOFU,4HT   , 4HSOFU,4HT   , 16384 ,        
     3                 4HSUBP,4HH1  , 4HSUBP,4HH1  , 16384 ,        
     4                 4HPLTM,4HRG  , 4HPLTM,4HRG  , 16384 ,        
     5                 4HCOPY,4H    , 4HCOPY,4H    , 64    ,        
     6                 4HSWIT,4HCH  , 4HSWIT,4HCH  , 64    ,        
     7                 4HMPY3,4H    , 4HMPY3,4H    , 64    ,        
     8                 4HSDCM,4HPS  , 4HDDCM,4HPS  , 64    ,        
     9                 4HLODA,4HPP  , 4HLODA,4HPP  , 16384 ,        
     O                 4HGPST,4HGEN , 4HGPST,4HGN  , 8     ,        
     1                 4HEQMC,4HK   , 4HEQMC,4HK   , 2048  ,        
     2                 4HADR ,4H    , 4HADR ,4H    , 512   ,        
     3                 4HFRRD,4H2   , 4HFRRD,4H2   , 512   ,        
     4                 4HGUST,4H    , 4HGUST,4H    , 512   ,        
     5                 4HIFT ,4H    , 4HIFT ,4H    , 512   ,        
     6                 4HLAMX,4H    , 4HLAMX,4H    , 256   ,        
     7                 4HEMA ,4H    , 4HEMA ,4H    , 128   /        
      DATA    LINK10 / 4HANIS,4HOP  , 4HANIS,4HOP  , 2     ,        
     1                 4HEMFL,4HD   , 4HEMFL,4HD   , 4096  ,        
     2                 4HGENC,4HOS  , 4HGENC,4HOS  , 4096  ,        
     3                 4HDDAM,4HAT  , 4HDDAM,4HAT  , 4096  ,        
     4                 4HDDAM,4HPG  , 4HDDAM,4HPG  , 4096  ,        
     5                 4HNRLS,4HUM  , 4HNRLS,4HUM  , 4096  ,        
     6                 4HGENP,4HART , 4HGENP,4HAR  , 4096  ,        
     7                 4HCASE,4HGEN , 4HCASE,4HGE  , 4096  ,        
     8                 4HDESV,4HEL  , 4HDESV,4HEL  , 4096  ,        
     9                 4HPROL,4HATE , 4HPROL,4HAT  , 4096  ,        
     O                 4HMAGB,4HDY  , 4HMAGB,4HDY  , 16    ,        
     1                 4HCOMB,4HUGV , 4HCOMU,4HGV  , 4096  ,        
     2                 4HFLBM,4HG   , 4HFLBM,4HG   , 8     ,        
     3                 4HGFSM,4HA   , 4HGFSM,4HA   , 8     ,        
     4                 4HTRAI,4HLER , 4HTRAI,4HL   , 8     ,        
     5                 4HSCAN,4H    , 4HSCAN,4H    , 8192  ,        
     6                 4HPLTH,4HBDY , 4HPTHB,4HDY  , 2     ,        
     7                 4HVARI,4HAN  , 4HVARI,4HAN  , 8192  /        
      DATA    LINK11 / 4HFVRS,4HTR1 , 4HFVRS,4HT1  , 64    ,        
     1                 4HFVRS,4HTR2 , 4HFVRS,4HT2  , 64    ,        
     2                 4HALG ,4H    , 4HALG ,4H    , 32    ,        
     3                 4HAPDB,4H    , 4HAPDB,4H    , 256   ,        
     4                 4HPROM,4HPT1 , 4HPROM,4HPT  , 8194  ,        
     5                 4HSITE,4HPLOT, 4HOLPL,4HOT  , 2     ,        
     6                 4HINPU,4HTT5 , 4HINPT,4HT5  , 2     ,        
     7                 4HOUTP,4HUT5 , 4HOUTP,4HT5  , 8192  ,        
     8                 4HPARA,4HMD  , 4HQPAR,4HMD  , 32766 ,        
     9                 4HGINO,4HFILE, 4HGINO,4HFL  , 32766 ,        
     O                 4HDATA,4HBASE, 4HDBAS,4HE   , 8202  ,        
     1                 4HNORM,4H    , 4HNORM,4HAL  , 16    ,        
     2                 4HVECG,4HRB  , 4HGRBV,4HEC  , 64    ,        
     3                 4HAUTO,4HASET, 4HAASE,4HT   , 8     /        
C        
C     INITIALIZE /XLKSPC/        
C        
      LLINK = LLINKX        
      DO 10 I = 1,LLINK        
   10 KLINK(I) = LINK(I)        
      RETURN        
      END        
