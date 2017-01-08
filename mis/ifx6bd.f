      BLOCK DATA IFX6BD        
CIFX6BD        
C        
C     THE FIRST  WORD DEFINES A CARD-TYPE IDENTIFICATION CODE, AND      
C     THE SECOND WORD DEFINES A BIT POSITION IN A 96-BIT 'TRAILER'      
C        
      COMMON /IFPX6/ I1(100),I2(100),I3(100),I4(100),I5(100),
     1               I6(100),I7(100),I8( 40)                            
      DATA I1/        
     1   4501,45,     0, 0,     0, 0,  5301,53,  1801,18,  1701,17,     
     *   1901,19,  2101,21,  2001,20,  2201,22,  5201,52,  5481,58,     
     3   5491,59,  5601,56,  5001,50,  5501,55,  4901,49,  4201,42,     
     *   4801,48,  4001,40,  4601,46,  4101,41,  4701,47,  5101,51,     
     5   5401,54,  4401,44,  5701,57,  4301,43,   902, 9,  1602,16,     
     *   1802,18,     0, 0,  1202,12,  1302,13,  1102,11,  1502,15,     
     7   1402,14,   702, 7,   802, 8,   602, 6,   502, 5,  1002,10,     
     *   1702,17,   402, 4,   202, 2,   302, 3,  1601,16,  3001,30,     
     9   3701,37,  3901,39/        
      DATA I2/        
     1      0, 0,  3301,33,  3401,34,  3201,32,  3601,36,  3501,35,     
     *   2801,28,  2901,29,  2701,27,  2601,26,  3101,31,  3801,38,     
     3   1401,14,  1501,15,  1001,10,  1101,11,  1201,12,  1301,13,     
     *    201, 2,   301, 3,   401, 4,   501, 5,   601, 6,   701, 7,     
     5    801, 8,   901, 9,   103, 1,   203, 2,  1708,17,  1808,18,     
     *    104, 1,     0, 0,  4891,60,  4551,61,   307, 3,   107, 1,     
     7    207, 2,     0, 0,     0, 0,   503, 5,   703, 7,  4951,63,     
     *    105, 1,   205, 2,   305, 3,   405, 4,  3105,31,  5641,65,     
     9      0, 0,     0, 0/        
      DATA I3/        
     1      0, 0,   803, 8,     0, 0,  1908,19,  5551,49,     0, 0,     
     *   6108,61,  6208,62,  6308,63,  6408,64,  6508,65,  6608,66,     
     3   6708,67,  6808,68,  6908,69,  6102,61,  6202,62,  6302,63,     
     *      0, 0,   114, 1,  2102,21,  1403,14,    57, 5,   707, 7,     
     5   1007,10,  1307,13,  3107,31,  3207,32,  3307,33,  3407,34,     
     *   5107,51,  5207,52,  1105,11,  1205,12,  5707,57,  6207,62,     
     7   6607,66,  7107,71,  7207,72,  1305,13,  1405,14,  8307,83,     
     *     53,10,   515, 5,  5615,56,  8515,85,   152,19,  6215,62,     
     9   4015,40,  4315,43/        
      DATA I4/        
     1   6415,64,  4915,49,  6315,63,  5215,52,  6815,68,  2115,21,     
     *   3815,38,   257, 4,  6402,64,  6502,65,  6602,66,    15,21,     
     3   6702,67,  6802,68,  6902,69,  1107,11,   110,41,   210, 2,     
     *    310, 3,   410, 4,   500, 5,   610, 6,   710, 7,   810, 8,     
     5    910, 9,  1110,11,  1210,12,  1310,13,     0, 0,  2408,24,     
     *     52,20,    27,17,    37,18,    77,19,  1103,11,  1410,14,     
     7   1510,15,    56,26,  1503,15,  5509,55,    55,25,  6709,67,     
     *    110, 1,   210, 2,  2107,21,  2207,22,  2307,23,  6909,69,     
     (   6809,68,     0, 0/        
      DATA I5/        
     1   8109,81,  8209,82,  8309,83,  8409,84,  8115,81,  8215,82,     
     *   8315,83,  8415,84,  7815,78,  7915,79,  8015,80,  8815,88,     
     3   8915,89,  9015,90,  5561,76,  5571,77,  5508,55,  5608,56,     
     *   5708,57,  5808,58,   214, 2,  9115,91,  1115,11,  2108,21,     
     5   2208,22,  2308,23,  4408,44,  4508,45,  1215,12,  1315,13,     
     *   1415,14,  4208,42,  4309,43,  2103,21,  2203,22,  2502,25,     
     7   2303,23,  2403,24,  4509,45,  4909,49,  5009,50,  5209,52,     
     *   2014,20,  3014,30,  7810,78,  7910,79,  1310,13,  1410,14,     
     9   2008,20,  2202,22/        
      DATA I6/        
     1   7108,71,  7208,72,  7308,73,  7002,70,  7109,71,  5110,51,     
     *   5210,52,  5008,50,  5308,53,  5302,53,  5408,54,   603, 6,     
     3   3002,30,  3102,31,  3202,32,  3302,33,  3402,34,  3502,35,     
     *   3602,36,  3702,37,  3802,38,  3902,39,  4002,40,  4102,41,     
     5   4001,40,   304, 3,   404, 4,  7001,70,  5310,53,  5502,55,     
     *   5602,56,  5702,57,  5802,58,  5410,54,  7012,70,  7032,85,     
     7   7042,74,  7052,95,  2606,26,  4202,42,  6101,81,  6201,82,     
     *   6301,83,  6401,84,  8509,85,  8609,86,  8210,82,  8310,83,     
     9   7501,75,  7601,76/        
      DATA I7/        
     1   4301,43,  4401,44,  4501,45,  4601,46,  4701,47,  4801,48,     
     *   4901,49,  1005,10,  5001,50,  5101,51,  9027,90,  9137,91,     
     3   9277,92,  9307,93,  1603,16,  1703,17,  1803,18,  1903,19,     
     *   2503,25,  2603,26,  3109,31,  3209,32,  2001,47,  2002,56,     
     5   3309,33,  3409,34,  3101,31,  3509,35,  4101,41,  4201,42,     
     *   4810,48,  7610,76,  9210,92,  9310,93,  8610,86,  8710,87,     
     7   5110,51,  5101,51,  5102,51,  3507,35,  3607,36,  8408,84,     
     *   8402,84,  3608,36,  3292,92,  3293,93,  6510,65,  6610,66,     
     9   6710,67,  6810,68/        
      DATA I8/        
     1   6910,69,  7010,70,  7110,71,  9108,91,   505, 5,  4302,77,     
     *   4802,48,  4902,94,  4303,43,    22* 0/                         
C
      END        
