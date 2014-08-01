const float g1=9.99877297e-01f;const float a10=1.00000000e+00f;const float a11=-9.99754593e-01f;const float a12=0.00000000e+00f;const float b10=1.00000000e+00f;const float b11=-1.00000000e+00f;const float b12=0.00000000e+00f;
float z11=0.0f;float z12=0.0f;
float x1=0.0f;float y01=0.0f;
const float g2=2.92482051e-07f;const float a20=1.00000000e+00f;const float a21=-1.69126560e+00f;const float a22=7.16537070e-01f;const float b20=1.00000000e+00f;const float b21=2.00000000e+00f;const float b22=1.00000000e+00f;
float z21=0.0f;float z22=0.0f;
float x2=0.0f;float y02=0.0f;
const float g3=1.00000000e+00f;const float a30=1.00000000e+00f;const float a31=-1.75803001e+00f;const float a32=7.84299096e-01f;const float b30=1.00000000e+00f;const float b31=2.00000000e+00f;const float b32=1.00000000e+00f;
float z31=0.0f;float z32=0.0f;
float x3=0.0f;float y03=0.0f;
const float g4=1.00000000e+00f;const float a40=1.00000000e+00f;const float a41=-1.88705645e+00f;const float a42=9.15253494e-01f;const float b40=1.00000000e+00f;const float b41=2.00000000e+00f;const float b42=1.00000000e+00f;
float z41=0.0f;float z42=0.0f;
float x4=0.0f;float y04=0.0f;
const float g5=1.05800499e-03f;const float a50=1.00000000e+00f;const float a51=-1.89198527e+00f;const float a52=8.92597058e-01f;const float b50=1.00000000e+00f;const float b51=2.00000000e+00f;const float b52=1.00000000e+00f;
float z51=0.0f;float z52=0.0f;
float x5=0.0f;float y05=0.0f;
const float g6=1.00000000e+00f;const float a60=1.00000000e+00f;const float a61=-1.95896192e+00f;const float a62=9.60941017e-01f;const float b60=1.00000000e+00f;const float b61=-1.98887138e+00f;const float b62=9.88871377e-01f;
float z61=0.0f;float z62=0.0f;
float x6=0.0f;float y06=0.0f;

float filter(float x) {
x1=g1*x;
 y01  = b10*x1 + z11; 
 z11  = b11*x1 + z12 - a11*y01; 
 z12  = b12*x1       - a12*y01; 

x2=g2*y01;
 y02  = b20*x2 + z21; 
 z21  = b21*x2 + z22 - a21*y02; 
 z22  = b22*x2       - a22*y02; 

x3=g3*y02;
 y03  = b30*x3 + z31; 
 z31  = b31*x3 + z32 - a31*y03; 
 z32  = b32*x3       - a32*y03; 

x4=g4*y03;
 y04  = b40*x4 + z41; 
 z41  = b41*x4 + z42 - a41*y04; 
 z42  = b42*x4       - a42*y04; 

x5=g5*y04;
 y05  = b50*x5 + z51; 
 z51  = b51*x5 + z52 - a51*y05; 
 z52  = b52*x5       - a52*y05; 

x6=g6*y05;
 y06  = b60*x6 + z61; 
 z61  = b61*x6 + z62 - a61*y06; 
 z62  = b62*x6       - a62*y06; 

return y06;
}
