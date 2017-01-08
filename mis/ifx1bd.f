      BLOCK DATA IFX1BD        
CIFX1BD        
C     DEFINITION OF VARIABLES IN /IFPX1/ AND /IFPX0/        
C*****        
C        
C     COMMON /IFPX1/        
C     --------------        
C        
C     N          = TOTAL NUMBER OF PAIRED ENTRIES IN THE IBD AND        
C                  IPR ARRAYS        
C                = (TOTAL DIMENSION OF IBD + ACTIVE IPR ARRAYS)/2       
C        
C     IBD ARRAYS = ARRAYS CONTAINING PAIRED ENTRIES OF BULK DATA        
C                  CARD NAMES        
C        
C     IPR ARRAYS = ARRAYS CONTAINING PAIRED ENTRIES OF BULK DATA        
C                  PARAMETER NAMES        
C        
C     CAUTION 1 -- THE TOTAL DIMENSION OF THE IBD AND IPR ARRAYS        
C                  MUST BE A MULTIPLE OF 62 (OR, IN OTHER WORDS,        
C                  AN EVEN MULTIPLE OF 31)        
C        
C                  SEE NOTES 1 AND 2 BELOW        
C        
C     ICC ARRAYS = ARRAYS CONTAINING PAIRED ENTRIES OF CASE CONTROL     
C                  FLAG NAMES FOR USE IN RESTART RUNS        
C        
C     CAUTION 2 -- THE TOTAL DIMENSION OF THE ICC ARRAYS MUST BE A      
C                  MULTIPLE OF 62 (OR, IN OTHER WORDS, AN EVEN        
C                  MULTIPLE OF 31)        
C        
C                  SEE NOTE 3 BELOW        
C        
C     NOTES        
C     -----        
C        
C              1.  IF NEW BULK DATA CARD NAMES ARE TO BE ADDED,        
C                  USE THE EXISTING PADDING WORDS (OF THE 4H****        
C                  TYPE) IN THE IBD ARRAYS.  IF NECESSARY, EXPAND       
C                  THE IBD ARRAYS KEEPING CAUTION 1 IN MIND.        
C        
C              2.  IF NEW BULK DATA PARAMETER NAMES ARE TO BE ADDED,    
C                  USE THE EXISTING PADDING WORDS (OF THE 4H****        
C                  TYPE) IN THE IPR ARRAYS.  IF NECESSARY, EXPAND       
C                  THE IPR ARRAYS KEEPING CAUTION 1 IN MIND.        
C        
C              3.  IF NEW CASE CONTROL FLAG NAMES ARE TO BE ADDED,      
C                  USE THE EXISTING PADDING WORDS (OF THE 4H****        
C                  TYPE) IN THE ICC ARRAYS.  IF NECESSARY, EXPAND       
C                  THE ICC ARRAYS KEEPING CAUTION 2 IN MIND.        
C        
C              4.  THE IBD ARRAYS ARE IN SYSCHRONIZTION WITH THE I ARRAY
C                  IN IFX2BD, IFX3BD, IFX4BD, IFX5BD, AND IFX6BD        
C                  (E.G. CONM1 POSITIONS IN IBD2, CONTINUATION 3, THE DA
C                  FOR CONM1 IN IFX2BD IS IN I2, CONTINUATION 3 CARD)   
C*****        
C        
C     COMMON /IFPX0/        
C     --------------        
C        
C     LBDPR      = (TOTAL DIMENSION OF THE IBD AND IPR ARRAYS)/62       
C        
C     LCC        = (TOTAL DIMENSION OF THE ICC ARRAYS)/62        
C        
C     IWRDS      = ARRAY WHOSE DIMENSION IS EQUAL TO (LBDPR + LCC).     
C                  ALL (LBDPR + LCC) WORDS IN THE ARRAY INITIALLY       
C                  SET TO ZERO.        
C        
C     IPARPT     = POINTER THAT POINTS TO THE PAIRED ENTRY IN THE       
C                  IBD AND IPR ARRAYS THAT CONTAINS THE FIRST        
C                  BULK DATA PARAMETER NAME.  AS PER THE DIFINITIONS    
C                  OF THE VARIABLES IN COMMON /IFPX1/, THIS POINTS      
C                  TO THE FIRST WORD OF THE IPR1 ARRAY.  HENCE, WE      
C                  HAVE --        
C        
C                  IPARPT = 1 + (TOTAL DIMENSION OF IBD ARRAYS)/2       
C        
      COMMON /IFPX0 /    LBDPR    , LCC      , IWRDS(18), IPARPT        
      COMMON /IFPX1 / N, IBD1(100), IBD2(100), IBD3(100), IBD4(100),
     1                   IBD5(100), IBD6(100), IBD7(100), IBD8(100),    
     2                   IPR1(100), IPR2( 92),        
     3                   ICC1(100), ICC2( 24)        
C        
C*****        
C     INITIALIZATION OF VARIABLES IN COMMON /IFPX1/        
C*****        
C        
      DATA N / 496 /        
C*****        
C     THE IBD ARRAYS CONTAIN PAIRED ENTRIES OF BULK DATA CARD NAMES     
C*****        
      DATA IBD1 /        
     1     4HGRID,4H    , 4HGRDS,4HET  , 4HADUM,4H1   , 4HSEQG,4HP   ,  
     *     4HCORD,4H1R  , 4HCORD,4H1C  , 4HCORD,4H1S  , 4HCORD,4H2R  ,  
     *     4HCORD,4H2C  , 4HCORD,4H2S  , 4HPLOT,4HEL  , 4HSPC1,4H    ,  
     3     4HSPCA,4HDD  , 4HSUPO,4HRT  , 4HOMIT,4H    , 4HSPC ,4H    ,  
     *     4HMPC ,4H    , 4HFORC,4HE   , 4HMOME,4HNT  , 4HFORC,4HE1  ,  
     *     4HMOME,4HNT1 , 4HFORC,4HE2  , 4HMOME,4HNT2 , 4HPLOA,4HD   ,  
     5     4HSLOA,4HD   , 4HGRAV,4H    , 4HTEMP,4H    , 4HGENE,4HL   ,  
     *     4HPROD,4H    , 4HPTUB,4HE   , 4HPVIS,4HC   , 4HADUM,4H2   ,  
     *     4HPTRI,4HA1  , 4HPTRI,4HA2  , 4HPTRB,4HSC  , 4HPTRP,4HLT  ,  
     7     4HPTRM,4HEM  , 4HPQUA,4HD1  , 4HPQUA,4HD2  , 4HPQDP,4HLT  ,  
     *     4HPQDM,4HEM  , 4HPSHE,4HAR  , 4HPTWI,4HST  , 4HPMAS,4HS   ,  
     *     4HPDAM,4HP   , 4HPELA,4HS   , 4HCONR,4HOD  , 4HCROD,4H    ,  
     9     4HCTUB,4HE   , 4HCVIS,4HC   /        
      DATA IBD2 /        
     1     4HADUM,4H3   , 4HCTRI,4HA1  , 4HCTRI,4HA2  , 4HCTRB,4HSC  ,  
     *     4HCTRP,4HLT  , 4HCTRM,4HEM  , 4HCQUA,4HD1  , 4HCQUA,4HD2  ,  
     *     4HCQDP,4HLT  , 4HCQDM,4HEM  , 4HCSHE,4HAR  , 4HCTWI,4HST  ,  
     3     4HCONM,4H1   , 4HCONM,4H2   , 4HCMAS,4HS1  , 4HCMAS,4HS2  ,  
     *     4HCMAS,4HS3  , 4HCMAS,4HS4  , 4HCDAM,4HP1  , 4HCDAM,4HP2  ,  
     *     4HCDAM,4HP3  , 4HCDAM,4HP4  , 4HCELA,4HS1  , 4HCELA,4HS2  ,  
     5     4HCELA,4HS3  , 4HCELA,4HS4  , 4HMAT1,4H    , 4HMAT2,4H    ,  
     *     4HCTRI,4HARG , 4HCTRA,4HPRG , 4HDEFO,4HRM  , 4HPARA,4HM   ,  
     *     4HMPCA,4HDD  , 4HLOAD,4H    , 4HEIGR,4H    , 4HEIGB,4H    ,  
     7     4HEIGC,4H    , 4HADUM,4H4   , 4H    ,4H    , 4HMATS,4H1   ,  
     *     4HMATT,4H1   , 4HOMIT,4H1   , 4HTABL,4HEM1 , 4HTABL,4HEM2 ,  
     *     4HTABL,4HEM3 , 4HTABL,4HEM4 , 4HTABL,4HES1 , 4HTEMP,4HD   ,  
     9     4HADUM,4H5   , 4HADUM,4H6   /        
      DATA IBD3 /        
     1     4HADUM,4H7   , 4HMATT,4H2   , 4HADUM,4H8   , 4HCTOR,4HDRG ,  
     *     4HSPOI,4HNT  , 4HADUM,4H9   , 4HCDUM,4H1   , 4HCDUM,4H2   ,  
     *     4HCDUM,4H3   , 4HCDUM,4H4   , 4HCDUM,4H5   , 4HCDUM,4H6   ,  
     3     4HCDUM,4H7   , 4HCDUM,4H8   , 4HCDUM,4H9   , 4HPDUM,4H1   ,  
     *     4HPDUM,4H2   , 4HPDUM,4H3   , 4HDMI ,4H    , 4HDMIG,4H    ,  
     *     4HPTOR,4HDRG , 4HMAT3,4H    , 4HDLOA,4HD   , 4HEPOI,4HNT  ,  
     5     4HFREQ,4H1   , 4HFREQ,4H    , 4HNOLI,4HN1  , 4HNOLI,4HN2  ,  
     *     4HNOLI,4HN3  , 4HNOLI,4HN4  , 4HRLOA,4HD1  , 4HRLOA,4HD2  ,  
     *     4HTABL,4HED1 , 4HTABL,4HED2 , 4HSEQE,4HP   , 4HTF  ,4H    ,  
     7     4HTIC ,4H    , 4HTLOA,4HD1  , 4HTLOA,4HD2  , 4HTABL,4HED3 ,  
     *     4HTABL,4HED4 , 4HTSTE,4HP   , 4HDSFA,4HCT  , 4HAXIC,4H    ,  
     *     4HRING,4HAX  , 4HCCON,4HEAX , 4HPCON,4HEAX , 4HSPCA,4HX   ,  
     9     4HMPCA,4HX   , 4HOMIT,4HAX  /        
      DATA IBD4 /        
     1     4HSUPA,4HX   , 4HPOIN,4HTAX , 4HSECT,4HAX  , 4HPRES,4HAX  ,  
     *     4HTEMP,4HAX  , 4HFORC,4HEAX , 4HMOMA,4HX   , 4HEIGP,4H    ,  
     *     4HPDUM,4H4   , 4HPDUM,4H5   , 4HPDUM,4H6   , 4HTABD,4HMP1 ,  
     3     4HPDUM,4H7   , 4HPDUM,4H8   , 4HPDUM,4H9   , 4HFREQ,4H2   ,  
     *     4HCONC,4HT1  , 4HCONC,4HT   , 4HTRAN,4HS   , 4HRELE,4HS   ,  
     *     4HLOAD,4HC   , 4HSPCS,4HD   , 4HSPCS,4H1   , 4HSPCS,4H    ,  
     5     4HBDYC,4H    , 4HMPCS,4H    , 4HBDYS,4H    , 4HBDYS,4H1   ,  
     *     4HBARO,4HR   , 4HCBAR,4H    , 4HPBAR,4H    , 4HDARE,4HA   ,  
     *     4HDELA,4HY   , 4HDPHA,4HSE  , 4HPLFA,4HCT  , 4HGNEW,4H    ,  
     7     4HGTRA,4HN   , 4HTABR,4HNDG , 4HMATT,4H3   , 4HRFOR,4HCE  ,  
     *     4HTABR,4HND1 , 4HPLOA,4HD4  , 4HUSET,4H    , 4HUSET,4H1   ,  
     *     4HRAND,4HPS  , 4HRAND,4HT1  , 4HRAND,4HT2* , 4HPLOA,4HD1  ,  
     9     4HPLOA,4HD2  , 4HDTI ,4H    /        
      DATA IBD5 /        
     1     4HTEMP,4HP1  , 4HTEMP,4HP2  , 4HTEMP,4HP3  , 4HTEMP,4HRB  ,  
     *     4HGRID,4HB   , 4HFSLI,4HST  , 4HRING,4HFL  , 4HPRES,4HPT  ,  
     *     4HCFLU,4HID2 , 4HCFLU,4HID3 , 4HCFLU,4HID4 , 4HAXIF,4H    ,  
     3     4HBDYL,4HIST , 4HFREE,4HPT  , 4HASET,4H    , 4HASET,4H1   ,  
     *     4HCTET,4HRA  , 4HCWED,4HGE  , 4HCHEX,4HA1  , 4HCHEX,4HA2  ,  
     *     4HDMIA,4HX   , 4HFLSY,4HM   , 4HAXSL,4HOT  , 4HCAXI,4HF2  ,  
     5     4HCAXI,4HF3  , 4HCAXI,4HF4  , 4HCSLO,4HT3  , 4HCSLO,4HT4  ,  
     *     4HGRID,4HF   , 4HGRID,4HS   , 4HSLBD,4HY   , 4HCHBD,4HY   ,  
     *     4HQHBD,4HY   , 4HMAT4,4H    , 4HMAT5,4H    , 4HPHBD,4HY   ,  
     7     4HMATT,4H4   , 4HMATT,4H5   , 4HQBDY,4H1   , 4HQBDY,4H2   ,  
     *     4HQVEC,4HT   , 4HQVOL,4H    , 4HRADL,4HST  , 4HRADM,4HTX  ,  
     *     4HSAME,4H    , 4HNOSA,4HME  , 4HINPU,4HT   , 4HOUTP,4HUT  ,  
     9     4HCQDM,4HEM1 , 4HPQDM,4HEM1 /        
      DATA IBD6 /        
     1     4HCIHE,4HX1  , 4HCIHE,4HX2  , 4HCIHE,4HX3  , 4HPIHE,4HX   ,  
     *     4HPLOA,4HD3  , 4HSPCD,4H    , 4HCYJO,4HIN  , 4HCNGR,4HNT  ,  
     *     4HCQDM,4HEM2 , 4HPQDM,4HEM2 , 4HCQUA,4HD4  , 4HMAT8,4H    ,  
     3     4HCAER,4HO1  , 4HPAER,4HO1  , 4HAERO,4H    , 4HSPLI,4HNE1 ,  
     *     4HSPLI,4HNE2 , 4HSET1,4H    , 4HSET2,4H    , 4HMKAE,4HRO2 ,  
     *     4HMKAE,4HRO1 , 4HFLUT,4HTER , 4HAEFA,4HCT  , 4HFLFA,4HCT  ,  
     5     4HCBAR,4HAO  , 4HPLIM,4HIT  , 4HPOPT,4H    , 4HPLOA,4HDX  ,  
     *     4HCRIG,4HD1  , 4HPCOM,4HP   , 4HPCOM,4HP1  , 4HPCOM,4HP2  ,  
     *     4HPSHE,4HLL  , 4HCRIG,4HD2  , 4HCTRI,4HAAX , 4HPTRI,4HAAX ,  
     7     4HCTRA,4HPAX , 4HPTRA,4HPAX , 4HVIEW,4H    , 4HVARI,4HAN  ,  
     *     4HCTRI,4HM6  , 4HPTRI,4HM6  , 4HCTRP,4HLT1 , 4HPTRP,4HLT1 ,  
     *     4HTEMP,4HG   , 4HTEMP,4HP4  , 4HCRIG,4HDR  , 4HCRIG,4HD3  ,  
     9     4HCTRS,4HHL  , 4HPTRS,4HHL  /        
      DATA IBD7 /        
     1     4HCAER,4HO2  , 4HCAER,4HO3  , 4HCAER,4HO4  , 4HPAER,4HO2  ,  
     *     4HPAER,4HO3  , 4HPAER,4HO4  , 4HSPLI,4HNE3 , 4HGUST,4H    ,  
     *     4HCAER,4HO5  , 4HPAER,4HO5  , 4HDARE,4HAS  , 4HDELA,4HYS  ,  
     3     4HDPHA,4HSES , 4HTICS,4H    , 4HMATP,4HZ1  , 4HMATP,4HZ2  ,  
     *     4HMTTP,4HZ1  , 4HMTTP,4HZ2  , 4HMAT6,4H    , 4HMATT,4H6   ,  
     *     4HCEML,4HOOP , 4HSPCF,4HLD  , 4HCIS2,4HD8  , 4HPIS2,4HD8  ,  
     5     4HGEML,4HOOP , 4HREMF,4HLUX , 4HBFIE,4HLD  , 4HMDIP,4HOLE ,  
     *     4HPROL,4HATE , 4HPERM,4HBDY , 4HCFFR,4HEE  , 4HCFLS,4HTR  ,  
     *     4HCFHE,4HX1  , 4HCFHE,4HX2  , 4HCFTE,4HTRA , 4HCFWE,4HDGE ,  
     7     4HMATF,4H    , 4HCELB,4HOW  , 4HPELB,4HOW  , 4HNOLI,4HN5  ,  
     *     4HNOLI,4HN6  , 4HCFTU,4HBE  , 4HPFTU,4HBE  , 4HNFTU,4HBE  ,  
     *     4HSTRE,4HAML1, 4HSTRE,4HAML2, 4HCRRO,4HD   , 4HCRBA,4HR   ,  
     9     4HCRTR,4HPLT , 4HCRBE,4H1   /        
      DATA IBD8 /        
     1     4HCRBE,4H2   , 4HCRBE,4H3   , 4HCRSP,4HLINE, 4HCTRI,4HA3  ,  
     *     4HTABL,4HEM5 , 4HCPSE,4H2   , 4HCPSE,4H3   , 4HCPSE,4H4   ,  
     *     4HPPSE,4H    , 82*4H****    /                                
C*****        
C     THE IPR ARRAYS CONTAIN PAIRED ENTRIES OF BULK DATA PARAMETER NAMES
C*****        
      DATA IPR1 /        
     1     4HGRDP,4HNT  , 4HWTMA,4HSS  , 4HIRES,4H    , 4HLFRE,4HQ   ,  
     5     4HHFRE,4HQ   , 4HLMOD,4HES  , 4HG   ,4H    , 4HW3  ,4H    ,  
     9     4HW4  ,4H    , 4HMODA,4HCC  , 4HCOUP,4HMASS, 4HCPBA,4HR   ,  
     3     4HCPRO,4HD   , 4HCPQU,4HAD1 , 4HCPQU,4HAD2 , 4HCPTR,4HIA1 ,  
     7     4HCPTR,4HIA2 , 4HCPTU,4HBE  , 4HCPQD,4HPLT , 4HCPTR,4HPLT ,  
     1     4HCPTR,4HBSC , 4HMAXI,4HT   , 4HEPSH,4HT   , 4HTABS,4H    ,  
     5     4HSIGM,4HA   , 4HBETA,4H    , 4HRADL,4HIN  , 4HBETA,4HD   ,  
     9     4HNT  ,4H    , 4HEPSI,4HO   , 4HCTYP,4HE   , 4HNSEQ,4HS   ,  
     3     4HNLOA,4HD   , 4HCYCI,4HO   , 4HCYCS,4HEQ  , 4HKMAX,4H    ,  
     7     4HKIND,4HEX  , 4HNODJ,4HE   , 4HP1  ,4H    , 4HP2  ,4H    ,  
     1     4HP3  ,4H    , 4HVREF,4H    , 4HPRIN,4HT   , 4HISTA,4HRT  ,  
     5     4HKDAM,4HP   , 4HGUST,4HAERO, 4HIFTM,4H    , 4HMACH,4H    ,  
     9     4HQ   ,4H    , 4HHOPT,4H    /        
      DATA IPR2 /        
     1     4HGRDE,4HQ   , 4HSTRE,4HSS  , 4HSTRA,4HIN  , 4HNINT,4HPTS ,  
     5     4HASET,4HOUT , 4HAUTO,4HSPC , 4HVOLU,4HME  , 4HSURF,4HACE ,  
     9     4HKTOU,4HT   , 4HAPRE,4HSS  , 4HATEM,4HP   , 4HSTRE,4HAML ,  
     3     4HPGEO,4HM   , 4HSIGN,4H    , 4HZORI,4HGN  , 4HFXCO,4HOR  ,  
     7     4HFYCO,4HOR  , 4HFZCO,4HOR  , 4HKGGI,4HN   , 4HIREF,4H    ,  
     1     4HMINM,4HACH , 4HMAXM,4HACH , 4HMTYP,4HE   , 4H****,4H****,  
     5     44*4H****    /        
C*****        
C     THE ICC ARRAYS CONTAIN PAIRED ENTRIES OF CASE CONTROL FLAG NAMES  
C     FOR USE IN RESTART RUNS        
C*****        
      DATA ICC1 /        
     1     4HMPC$,4H    , 4HSPC$,4H    , 4HLOAD,4H$   , 4HMETH,4HOD$ ,  
     5     4HDEFO,4HRM$ , 4HTEMP,4HLD$ , 4HTEMP,4HMT$ , 4HIC$ ,4H    ,  
     9     4HAOUT,4H$   , 4HLOOP,4H$   , 4HLOOP,4H1$  , 4HDLOA,4HD$  ,  
     3     4HFREQ,4H$   , 4HTF$ ,4H    , 4HPLOT,4H$   , 4HTSTE,4HP$  ,  
     7     4HPOUT,4H$   , 4HTEMP,4HMX$ , 4HDSCO,4H$   , 4HK2PP,4H$   ,  
     1     4HM2PP,4H$   , 4HB2PP,4H$   , 4HCMET,4HHOD$, 4HSDAM,4HP$  ,  
     5     4HPLCO,4H$   , 4HNLFO,4HRCE$, 4HXYOU,4HT$  , 4HFMET,4HHOD$,  
     9     4HRAND,4HOM$ , 4HAXYO,4HUT$ , 4HNOLO,4HOP$ , 4HGUST,4H$   ,  
     3     4HQOUT,4H$   , 4HBOUT,4H$   ,        
     7     32*4H****    /        
      DATA ICC2 /        
     1     24*4H****    /        
C        
C*****        
C     INITIALIZATION OF VARIABLES IN COMMON /IFPX0/        
C*****        
C        
C     THE VALUES ASSIGNED BELOW TO THE VARIABLES IN COMMON /IFPX0/      
C     ARE AS PER THEIR DEFINITIONS GIVEN EARLIER IN THE COMMENTS        
C     AND ARE DERIVED FROM THE COMMON /IFPX1/ INFORMATION        
C*****        
      DATA LBDPR, LCC, IWRDS, IPARPT /16, 2, 18*0, 401/     
C
      END        
