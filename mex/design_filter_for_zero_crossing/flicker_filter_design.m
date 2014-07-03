clear all; clc;

fs2=1280;

K = 1.74802;
LAMBDA = 2 * pi * 4.05981;
OMEGA1 = 2 * pi * 9.15494;
OMEGA2 = 2 * pi * 2.27979;
OMEGA3 = 2 * pi * 1.22535;
OMEGA4 = 2 * pi * 21.9;
num1 = [K * OMEGA1, 0];
den1 = [1, 2 * LAMBDA, OMEGA1.^2];
num2 = [1 / OMEGA2, 1];
den2 = [1 / (OMEGA3 * OMEGA4), 1 / OMEGA3 + 1 / OMEGA4, 1];
HIGHPASS_ORDER  = 1;
HIGHPASS_CUTOFF = 0.05;
LOWPASS_ORDER = 6;
LOWPASS_CUTOFF = 35;

[b_hp, a_hp] = butter(HIGHPASS_ORDER, HIGHPASS_CUTOFF / (fs2 / 2), 'high');
[b_bw, a_bw] = butter(LOWPASS_ORDER, LOWPASS_CUTOFF / (fs2 / 2), 'low');
[b_w, a_w]   = bilinear(conv(num1, num2), conv(den1, den2), fs2);

[z1,p1,k1] = butter(HIGHPASS_ORDER, HIGHPASS_CUTOFF / (fs2 / 2), 'high');
[z2,p2,k2] = butter(LOWPASS_ORDER, LOWPASS_CUTOFF / (fs2 / 2), 'low');
[z3,p3,k3] = tf2zp(b_w,a_w);

[H1,G1]=zp2sos(z1,p1,k1);
[H2,G2]=zp2sos(z2,p2,k2);
[H3,G3]=zp2sos(z3,p3,k3);
COEFS=[H1;H2;H3];
GAINS=[G1 G2 1 1 G3 1];
STAGES=6;
[b,a]=sos2tf(COEFS,GAINS);


fname='mex_flicker\filter.h';
fid = fopen(fname, 'w');


for k=1:STAGES
    g0=GAINS(k);
    b0=COEFS(k,1);
    b1=COEFS(k,2);
    b2=COEFS(k,3);
    a0=COEFS(k,4);
    a1=COEFS(k,5);
    a2=COEFS(k,6);
    fprintf(fid,'const float g%d=%1.8ef;',k,g0);
    fprintf(fid,'const float a%d0=%1.8ef;',k,a0);
    fprintf(fid,'const float a%d1=%1.8ef;',k,a1);
    fprintf(fid,'const float a%d2=%1.8ef;',k,a2);
    fprintf(fid,'const float b%d0=%1.8ef;',k,b0);
    fprintf(fid,'const float b%d1=%1.8ef;',k,b1);
    fprintf(fid,'const float b%d2=%1.8ef;\n',k,b2);
    
    fprintf(fid,'float z%d1=0.0f;',k);    fprintf(fid,'float z%d2=0.0f;\n',k);
    fprintf(fid,'float x%d=0.0f;',k);    fprintf(fid,'float y0%d=0.0f;\n',k);
end;
fprintf(fid,'\n');
fprintf(fid,'float filter(float x) {\n');
for k=1:STAGES
    if (k==1)
        fprintf(fid,'x1=g1*x;\n');
    else
        fprintf(fid,'x%d=g%d*y0%d;\n',k,k,k-1);
    end
    fprintf(fid,' y0%d  = b%d0*x%d + z%d1; \n',k,k,k,k);
    fprintf(fid,' z%d1  = b%d1*x%d + z%d2 - a%d1*y0%d; \n',k,k,k,k,k,k);
    fprintf(fid,' z%d2  = b%d2*x%d       - a%d2*y0%d; \n',k,k,k,k,k);
    fprintf(fid,'\n');
end;
fprintf(fid,'return y0%d;\n',k);
fprintf(fid,'}\n');
fclose(fid);



% %
system('mex mex_flicker\mex_flicker.cpp'); % compile mex
t=0:1/fs2:10; 
X=sin(2*t*50*pi);
u_hp = filter(b_hp, a_hp, X);
u_bw = filter(b_bw, a_bw, u_hp);
FX  = filter(b_w, a_w, u_bw);
FX1=mex_flicker(X);
plot(FX); hold on;plot(FX1,'r'); 
clear mex_flicker; % unload from memory and unblock file on disk
