clear all; clc;
% script designes weighting filter cascade
% (block 3 of standard flickermeter GOST R 51317.4.15-2012)
% then produces c code, compiles it to mex-function
% and compares results with matlab filter
% Nazarovsky A.E. 01.08.2014 10:51
%

fs2=1280; % sampling frequency of flickermeter
lamptype='230v'; % '120v' or '230v'
FLTYPE='float'; % 'float' or 'double'

% weighting filter characteristics (p 5.4 and 5.5 GOST R 51317.4.15-2012)
switch lamptype
    case '230v'
        % HPF 1st ord
        HIGHPASS_ORDER  = 1;
        HIGHPASS_CUTOFF = 0.05;
        % LPF 6th ord
        LOWPASS_ORDER = 6;
        LOWPASS_CUTOFF = 35;
        % BPF 4th ord for 230 V lamp
        K = 1.74802;
        LAMBDA = 2 * pi * 4.05981;
        OMEGA1 = 2 * pi * 9.15494;
        OMEGA2 = 2 * pi * 2.27979;
        OMEGA3 = 2 * pi * 1.22535;
        OMEGA4 = 2 * pi * 21.9;
        
        
    case '120v'
        % HPF 1st ord        
        HIGHPASS_ORDER  = 1;
        HIGHPASS_CUTOFF = 0.05;
        % LPF 6th ord
        LOWPASS_ORDER = 6;
        LOWPASS_CUTOFF = 42;        
        % BPF 4th ord for 120 V lamp
        K = 1.6357;
        LAMBDA = 2 * pi * 4.167375;
        OMEGA1 = 2 * pi * 9.07169;
        OMEGA2 = 2 * pi * 2.939902;
        OMEGA3 = 2 * pi * 1.394468;
        OMEGA4 = 2 * pi * 17.31512;
    otherwise
        error('Wrong lamptype specified (should be 120v or 230v)');
end
num1 = [K * OMEGA1, 0];
den1 = [1, 2 * LAMBDA, OMEGA1.^2];
num2 = [1 / OMEGA2, 1];
den2 = [1 / (OMEGA3 * OMEGA4), 1 / OMEGA3 + 1 / OMEGA4, 1];


[b_hp, a_hp] = butter(HIGHPASS_ORDER, HIGHPASS_CUTOFF / (fs2 / 2), 'high');
[b_bw, a_bw] = butter(LOWPASS_ORDER, LOWPASS_CUTOFF / (fs2 / 2), 'low');
[b_w, a_w]   = bilinear(conv(num1, num2), conv(den1, den2), fs2);

[z1,p1,k1] = butter(HIGHPASS_ORDER, HIGHPASS_CUTOFF / (fs2 / 2), 'high');
[z2,p2,k2] = butter(LOWPASS_ORDER, LOWPASS_CUTOFF / (fs2 / 2), 'low');
[z3,p3,k3] = tf2zp(b_w,a_w);

[H1,G1]=zp2sos(z1,p1,k1);
[H2,G2]=zp2sos(z2,p2,k2);
[H3,G3]=zp2sos(z3,p3,k3);

% [ b01 b11 b21 1 a11 a21];
COEFS=[H1;H2;H3];
GAINS=[G1 G2 1 1 G3 1];
STAGES=6;
[b,a]=sos2tf(COEFS,GAINS);

fname='mex_flicker\filter.h';
fid = fopen(fname, 'w');
fprintf(fid,'typedef %s FloatType;\n',FLTYPE);

for k=1:STAGES
    g0=GAINS(k);
    b0=COEFS(k,1);
    b1=COEFS(k,2);
    b2=COEFS(k,3);
    a0=COEFS(k,4);
    a1=COEFS(k,5);
    a2=COEFS(k,6);
    
    
    if (g0~=1)
       fprintf(fid,'const FloatType g%d=%1.17ef;',k,g0);
    end;
    if (a0~=1)
       fprintf(fid,'const FloatType a%d0=%1.17ef;',k,a0);
    end;
    if (a1~=1)
       fprintf(fid,'const FloatType a%d1=%1.17ef;',k,a1);   
    end;
    if (a2~=1)
       fprintf(fid,'const FloatType a%d2=%1.17ef;',k,a2);
    end;
    if (b0~=1)
       fprintf(fid,'const FloatType b%d0=%1.17ef;',k,b0);
    end;
    if (b1~=1)
       fprintf(fid,'const FloatType b%d1=%1.17ef;',k,b1);
    end;
    if (b2~=1)
       fprintf(fid,'const FloatType b%d2=%1.17ef;\n',k,b2);
    end;
    
    fprintf(fid,'FloatType z%d1=0.0f;',k);    fprintf(fid,'FloatType z%d2=0.0f;\n',k);
    fprintf(fid,'FloatType x%d=0.0f;',k);    fprintf(fid,'FloatType y0%d=0.0f;\n',k);
end;
fprintf(fid,'\n');
fprintf(fid,'FloatType filter(FloatType x) {\n');
for k=1:STAGES
    fprintf(fid,'\n');
    if (k==1)
        if (GAINS(k)==1)
           fprintf(fid,'   x1=x;\n');
        else
           fprintf(fid,'   x1=g1*x;\n');
        end;
    else
        if (GAINS(k)==1)
           fprintf(fid,'   x%d=y0%d;\n',k,k-1);
        else
           fprintf(fid,'   x%d=g%d*y0%d;\n',k,k,k-1);
        end;
    end;
    
    if(COEFS(k,1)==1) % b0=1
       fprintf(fid,'    y0%d  =     x%d + z%d1; \n',k,k,k);
    else
       fprintf(fid,'    y0%d  = b%d0*x%d + z%d1; \n',k,k,k,k);
    end;
    
    switch COEFS(k,2) % b1
        case 1
            fprintf(fid,'    z%d1  =     x%d + z%d2 - a%d1*y0%d; \n',k,k,k,k,k);
        case 2
            fprintf(fid,'    z%d1  = x%d +x%d + z%d2 - a%d1*y0%d; \n',k,k,k,k,k,k);            
        case -1
            fprintf(fid,'    z%d1  =    -x%d + z%d2 - a%d1*y0%d; \n',k,k,k,k,k);            
        case -2
            fprintf(fid,'    z%d1  = -x%d -x%d+ z%d2 - a%d1*y0%d; \n',k,k,k,k,k,k);            
        otherwise
            fprintf(fid,'    z%d1  = b%d1*x%d + z%d2 - a%d1*y0%d; \n',k,k,k,k,k,k);
    end;
    
    if(COEFS(k,3)==1) % b2=1
       fprintf(fid,'    z%d2  =     x%d       - a%d2*y0%d; \n',k,k,k,k);
    else
       fprintf(fid,'    z%d2  = b%d2*x%d       - a%d2*y0%d; \n',k,k,k,k,k); 
    end
    fprintf(fid,'\n');
end;
fprintf(fid,'   return y0%d;\n',k);
fprintf(fid,'}\n');
fclose(fid);



% %
system('mex mex_flicker\mex_flicker.cpp'); % compile mex
t=0:1/fs2:10; 
X=sin(2*t*50*pi);
 u_hp = filter(b_hp, a_hp, X);
 u_bw = filter(b_bw, a_bw, u_hp);
 FX  = filter(b_w, a_w, u_bw);
%FX = filter(b,a,X);
FX1=mex_flicker(X);
plot(FX); hold on;plot(FX1,'r'); 
disp(['error = ' num2str(sum((FX-FX1).^2))]);
clear mex_flicker; % unload from memory and unblock file on disk

system('mex mex_flicker\mex_weighting_filter.cpp'); % compile final version of filters
system('copy mex_weighting_filter.mexw64 mex_weighting_filterA.mexw64'); 
system('copy mex_weighting_filter.mexw64 mex_weighting_filterB.mexw64'); 
system('copy mex_weighting_filter.mexw64 mex_weighting_filterC.mexw64'); 