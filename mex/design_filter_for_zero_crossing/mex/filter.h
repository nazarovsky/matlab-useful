const float g1=3.65876824e-03;const float a10=1.00000000e+00;const float a11=-1.99844979e+00;const float a12=9.99243764e-01;const float b10=1.00000000e+00;const float b11=0.00000000e+00;const float b12=-1.00000000e+00;
float z11=0.0;float z12=0.0;
float x1=0.0;float y01=0.0;
const float g2=3.65876824e-03;const float a20=1.00000000e+00;const float a21=-1.99900294e+00;const float a22=9.99439308e-01;const float b20=1.00000000e+00;const float b21=0.00000000e+00;const float b22=-1.00000000e+00;
float z21=0.0;float z22=0.0;
float x2=0.0;float y02=0.0;
const float g3=2.41011130e-03;const float a30=1.00000000e+00;const float a31=-1.99740965e+00;const float a32=9.98117817e-01;const float b30=1.00000000e+00;const float b31=0.00000000e+00;const float b32=-1.00000000e+00;
float z31=0.0;float z32=0.0;
float x3=0.0;float y03=0.0;
const float g4=2.41011130e-03;const float a40=1.00000000e+00;const float a41=-1.99794750e+00;const float a42=9.98436228e-01;const float b40=1.00000000e+00;const float b41=0.00000000e+00;const float b42=-1.00000000e+00;
float z41=0.0;float z42=0.0;
float x4=0.0;float y04=0.0;
const float g5=1.06465545e-03;const float a50=1.00000000e+00;const float a51=-1.99728250e+00;const float a52=9.97870689e-01;const float b50=1.00000000e+00;const float b51=0.00000000e+00;const float b52=-1.00000000e+00;
float z51=0.0;float z52=0.0;
float x5=0.0;float y05=0.0;

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

return y05;
}
