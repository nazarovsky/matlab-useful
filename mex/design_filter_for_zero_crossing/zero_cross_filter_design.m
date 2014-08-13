clear all; clc;

Fs=12800;
h  = fdesign.bandpass(30,42.5,57.5,70,50,1,50,Fs);
Hd = design(h, 'cheby1','MatchExactly', 'passband');

GAINS=Hd.ScaleValues;
COEFS=Hd.sosMatrix;
STAGES=size(Hd.states,2);

set(Hd,'arithmetic','single');



[z,p,k]=sos2zp(Hd.sosMatrix,Hd.ScaleValues);
[b,a]=sos2tf(Hd.sosMatrix,Hd.ScaleValues);
% figure;
% plot(p,'bx'); 
%%[b,a]=zp2tf(z,p,k);
hf=figure;
subplot(3,1,1);
[h,w]=freqz(Hd,Fs);
plot(Fs/(2*pi)*w,20*log(abs(h))),grid;
xlim([0 200])
ylim([-200 0])
title('Frequency response');
axis tight;
xlabel('f, Hz');
ylabel('Magnitude');

subplot(3,1,2);
plot(Fs/(2*pi)*w,unwrap(angle(h))),grid;
title('Phase response');
xlim([0 200])
ylabel('Phase, rad');
xlabel('f, Hz');

subplot(3,1,3);
[gd,w]=grpdelay(Hd,Fs);
plot(Fs/(2*pi)*w,gd),grid;
xlim([0 200])
xlabel('f, Hz');
ylabel('Delay, samples');
title('Group delay');

print(hf,'-dmeta','mex\filter.emf')


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
    fprintf(fid,'const float g%d=%1.8e;',k,g0);
    fprintf(fid,'const float a%d0=%1.8e;',k,a0);
    fprintf(fid,'const float a%d1=%1.8e;',k,a1);
    fprintf(fid,'const float a%d2=%1.8e;',k,a2);
    fprintf(fid,'const float b%d0=%1.8e;',k,b0);
    fprintf(fid,'const float b%d1=%1.8e;',k,b1);
    fprintf(fid,'const float b%d2=%1.8e;\r\n',k,b2);
    
    fprintf(fid,'float z%d1=0.0;',k);    fprintf(fid,'float z%d2=0.0;\r\n',k);
    fprintf(fid,'float x%d=0.0;',k);    fprintf(fid,'float y0%d=0.0;\r\n',k);
end;
fprintf(fid,'\r\n');
fprintf(fid,'float filter(float x) {\r\n');
for k=1:STAGES
    if (k==1)
        fprintf(fid,'x1=g1*x;\r\n');
    else
        fprintf(fid,'x%d=g%d*y0%d;\r\n',k,k,k-1);
    end
    fprintf(fid,' y0%d  = b%d0*x%d + z%d1; \r\n',k,k,k,k);
    fprintf(fid,' z%d1  = b%d1*x%d + z%d2 - a%d1*y0%d; \r\n',k,k,k,k,k,k);
    fprintf(fid,' z%d2  = b%d2*x%d       - a%d2*y0%d; \r\n',k,k,k,k,k);
    fprintf(fid,'\r\n');
end;
fprintf(fid,'return y0%d;\r\n',k);
fprintf(fid,'}\r\n');
fclose(fid);



% %
system('mex mex\mex_filter.cpp'); % compile mex
t=0:1/Fs:10; 
X=sin(2*t*50*pi);
FX=filter(Hd,X);
FX1=mex_filter(X);
figure;
plot(FX); hold on;plot(FX1,'r'); 
clear mex_filter; % unload from memory and unblock file on disk
