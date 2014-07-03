clear all; clc;

Fs=12800;
h  = fdesign.bandpass(30,42.5,57.5,70,50,1,50,Fs);
Hd = design(h, 'cheby1','MatchExactly', 'passband');

GAINS=Hd.ScaleValues;
COEFS=Hd.sosMatrix;
STAGES=size(Hd.states,2);

set(Hd,'arithmetic','single');



fname='mex\filter.h';
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
system('mex mex\mex_filter.cpp'); % compile mex
t=0:1/Fs:10; 
X=sin(2*t*50*pi);
FX=filter(Hd,X);
FX1=mex_filter(X);
plot(FX); hold on;plot(FX1,'r'); 
clear mex_filter; % unload from memory and unblock file on disk
