typedef float FloatType;
const FloatType g1=9.99877296594326560e-01f;const FloatType a11=-9.99754593188653010e-01f;const FloatType a12=0.00000000000000000e+00f;const FloatType b11=-1.00000000000000000e+00f;const FloatType b12=0.00000000000000000e+00f;
FloatType z11=0.0f;FloatType z12=0.0f;
FloatType x1=0.0f;FloatType y01=0.0f;
const FloatType g2=2.92482051101833750e-07f;const FloatType a21=-1.69126559727537810e+00f;const FloatType a22=7.16537069870652800e-01f;const FloatType b21=2.00000000000000000e+00f;FloatType z21=0.0f;FloatType z22=0.0f;
FloatType x2=0.0f;FloatType y02=0.0f;
const FloatType a31=-1.75803000680228360e+00f;const FloatType a32=7.84299096181354520e-01f;const FloatType b31=2.00000000000000000e+00f;FloatType z31=0.0f;FloatType z32=0.0f;
FloatType x3=0.0f;FloatType y03=0.0f;
const FloatType a41=-1.88705644727826140e+00f;const FloatType a42=9.15253494134742770e-01f;const FloatType b41=2.00000000000000000e+00f;FloatType z41=0.0f;FloatType z42=0.0f;
FloatType x4=0.0f;FloatType y04=0.0f;
const FloatType g5=1.05800499393515770e-03f;const FloatType a51=-1.89198526823119820e+00f;const FloatType a52=8.92597057752947070e-01f;const FloatType b51=2.00000000000299320e+00f;const FloatType b52=9.99999999997980730e-01f;
FloatType z51=0.0f;FloatType z52=0.0f;
FloatType x5=0.0f;FloatType y05=0.0f;
const FloatType a61=-1.95896192484015490e+00f;const FloatType a62=9.60941017483742390e-01f;const FloatType b61=-1.98887137662339080e+00f;const FloatType b62=9.88871376623233320e-01f;
FloatType z61=0.0f;FloatType z62=0.0f;
FloatType x6=0.0f;FloatType y06=0.0f;

FloatType filter(FloatType x) {

   x1=g1*x;
    y01  =     x1 + z11; 
    z11  =    -x1 + z12 - a11*y01; 
    z12  = b12*x1       - a12*y01; 


   x2=g2*y01;
    y02  =     x2 + z21; 
    z21  = x2 +x2 + z22 - a21*y02; 
    z22  =     x2       - a22*y02; 


   x3=y02;
    y03  =     x3 + z31; 
    z31  = x3 +x3 + z32 - a31*y03; 
    z32  =     x3       - a32*y03; 


   x4=y03;
    y04  =     x4 + z41; 
    z41  = x4 +x4 + z42 - a41*y04; 
    z42  =     x4       - a42*y04; 


   x5=g5*y04;
    y05  =     x5 + z51; 
    z51  = b51*x5 + z52 - a51*y05; 
    z52  = b52*x5       - a52*y05; 


   x6=y05;
    y06  =     x6 + z61; 
    z61  = b61*x6 + z62 - a61*y06; 
    z62  = b62*x6       - a62*y06; 

   return y06;
}
