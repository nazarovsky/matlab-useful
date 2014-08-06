clear all; clc;
% script designes weighting filter cascade
% (block 3 of standard flickermeter GOST R 51317.4.15-2012)
% then produces c code, compiles it to mex-function
% and compares results with matlab filter
% [added part 2 - sumulation of flickermeter work]
% Nazarovsky A.E. 05.08.2014 11:35
%
SAMPLING_FREQUENCY=12800; % basic measurement sampling frequency
FL_DECIMATE_FACTOR=10; % decimation factor 

fs2=SAMPLING_FREQUENCY/FL_DECIMATE_FACTOR; % sampling frequency of flickermeter
LAMPTYPE='230v50hz';  % '120v50hz' or '230v50hz' or '120v60hz' or '230v60hz'
FLTYPE='float'; % 'float' or 'double'

% weighting filter characteristics (p 5.4 and 5.5 GOST R 51317.4.15-2012)
switch LAMPTYPE
    case '230v50hz'
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
    case '120v50hz'
        % HPF 1st ord        
        HIGHPASS_ORDER  = 1;
        HIGHPASS_CUTOFF = 0.05;
        % LPF 6th ord
        LOWPASS_ORDER = 6;
        LOWPASS_CUTOFF = 35;        
        % BPF 4th ord for 120 V lamp
        K = 1.6357;
        LAMBDA = 2 * pi * 4.167375;
        OMEGA1 = 2 * pi * 9.07169;
        OMEGA2 = 2 * pi * 2.939902;
        OMEGA3 = 2 * pi * 1.394468;
        OMEGA4 = 2 * pi * 17.31512;
    case '230v60hz'
        % HPF 1st ord
        HIGHPASS_ORDER  = 1;
        HIGHPASS_CUTOFF = 0.05;
        % LPF 6th ord
        LOWPASS_ORDER = 6;
        LOWPASS_CUTOFF = 42;
        % BPF 4th ord for 230 V lamp
        K = 1.74802;
        LAMBDA = 2 * pi * 4.05981;
        OMEGA1 = 2 * pi * 9.15494;
        OMEGA2 = 2 * pi * 2.27979;
        OMEGA3 = 2 * pi * 1.22535;
        OMEGA4 = 2 * pi * 21.9;
    case '120v60hz'
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
       fprintf(fid,'const FloatType g%d=%1.17e;',k,g0);
    end;
    if (a0~=1)
       fprintf(fid,'const FloatType a%d0=%1.17e;',k,a0);
    end;
    if (a1~=1)
       fprintf(fid,'const FloatType a%d1=%1.17e;',k,a1);   
    end;
    if (a2~=1)
       fprintf(fid,'const FloatType a%d2=%1.17e;',k,a2);
    end;
    if (b0~=1)
       fprintf(fid,'const FloatType b%d0=%1.17e;',k,b0);
    end;
    if (b1~=1)
       fprintf(fid,'const FloatType b%d1=%1.17e;',k,b1);
    end;
    if (b2~=1)
       fprintf(fid,'const FloatType b%d2=%1.17e;\n',k,b2);
    end;
    
    fprintf(fid,'FloatType z%d1=0.0;',k);    fprintf(fid,'FloatType z%d2=0.0;\n',k);
    fprintf(fid,'FloatType x%d=0.0;',k);    fprintf(fid,'FloatType y0%d=0.0;\n',k);
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


% lpf block 4
LOWPASS_2_ORDER  = 1;
LOWPASS_2_CUTOFF = 1 / (2 * pi * 300e-3);  % time constant 300 msec
[b_lp, a_lp] = butter(LOWPASS_2_ORDER, LOWPASS_2_CUTOFF / (fs2 / 2), 'low');
fname='mex_flicker\lpfilter.h';
fid = fopen(fname, 'w');
fprintf(fid,'// lowpass Butterworth \n');
fprintf(fid,'const FloatType a_lp[]={ %1.17e,  %1.17e}; \n',a_lp(1), a_lp(2));
fprintf(fid,'const FloatType b_lp[]={ %1.17e,  %1.17e}; \n',b_lp(1), b_lp(2));
fprintf(fid,'FloatType z_lp; \n');
fprintf(fid,'\n');
fprintf(fid,'FloatType lp_filter(FloatType x) { \n');
fprintf(fid,' // returns one filtered value and updates internal "delayed" values \n');
fprintf(fid,'   FloatType y;\n');
fprintf(fid,'   y	   =  b_lp[0] * x + z_lp;\n');
fprintf(fid,'   z_lp   =  b_lp[1] * x - a_lp[1]*y;\n');
fprintf(fid,'   return y; \n');
fprintf(fid,'} \n\n');
fclose(fid);

% %
system('mex mex_flicker\mex_flicker.cpp'); % compile mex
t=0:1/fs2:10;
switch LAMPTYPE
    case {'230v50hz','120v50hz'}
        X=sin(2*t*50*pi);
    case {'230v60hz','120v60hz'}
        X=sin(2*t*60*pi);
end;
 u_hp = filter(b_hp, a_hp, X);
 u_bw = filter(b_bw, a_bw, u_hp);
 FX  = filter(b_w, a_w, u_bw);
%FX = filter(b,a,X);
FX1=mex_flicker(X);
% plot(FX); hold on;plot(FX1,'r'); 
disp(['Total error between compiled and MATLAB version = ' num2str(sum((FX-FX1).^2))]);
clear mex_flicker; % unload from memory and unblock file on disk

system('mex mex_flicker\mex_weighting_filter.cpp'); % compile final version of filters
% they are exactly the same, 
% but because of filters internal memory should be used on each phase separately
system('copy mex_weighting_filter.mexw64 mex_weighting_filterA.mexw64'); 
system('copy mex_weighting_filter.mexw64 mex_weighting_filterB.mexw64'); 
system('copy mex_weighting_filter.mexw64 mex_weighting_filterC.mexw64'); 

% part 2 of simulation
% test flicker filter according to 61000-4-15 
% test of the Pinst according to Table 1b and 2b 61000-4-15


%F0=50;
SIGNAL_DURATION=60; % duration of generated signal in seconds
INIT_PERIOD=30; % delay for filters to set up from initial transient

% sinusoidal modulation (table 1b)

switch LAMPTYPE
    case '230v50hz'
        RMS_FL=230;
        f=50;
        F_fl=[0.5 1 1.5 2.0 2.5 3.0 3.5 4.0 4.5 5.0 5.5 6 6.5 7.0 7.5 8 8.8 9.5 10.0 ...
            10.5 11.0 11.5 12.0 13.0 14.0 15.0 16.0 17.0 18.0 19.0 20.0 21.0 22.0 23.0 24.0 25.0 33.33333];
        
        A_fl=[2.325 1.397 1.067 0.879 0.747 0.645 0.564 0.497 0.442 0.396 0.357 0.325 ...
            0.300 0.280 0.265 0.256 0.250 0.254 0.261 0.271 0.283 0.298 0.314 0.351 0.393 0.438 0.486 ...
            0.537 0.590 0.646 0.704 0.764 0.828 0.894 0.964 1.037 2.128 ];
    case '120v50hz'
        RMS_FL=120;
        f=50;
        F_fl=[0.5 1 1.5 2.0 2.5 3.0 3.5 4.0 4.5 5.0 5.5 6 6.5 7.0 7.5 8 8.8 9.5 10.0 ...
            10.5 11.0 11.5 12.0 13.0 14.0 15.0 16.0 17.0 18.0 19.0 20.0 21.0 22.0 23.0 24.0 25.0 33.33333];
        
        A_fl=[2.453 1.465 1.126 0.942 0.815 0.717 0.637 0.570 0.514 0.466 0.426 0.393 0.366 0.346 0.332 0.323 ...
            0.321 0.329 0.341 0.355 0.373 0.394 0.417 0.469 0.528 0.592 0.660 0.734 0.811 0.892 0.978 1.068 1.162 ...
            1.261 1.365 1.476 3.111 ];
    case '230v60hz'
        RMS_FL=230;
        f=60;
        F_fl=[0.5 1 1.5 2.0 2.5 3.0 3.5 4.0 4.5 5.0 5.5 6 6.5 7.0 7.5 8 8.8 9.5 10.0 ...
            10.5 11.0 11.5 12.0 13.0 14.0 15.0 16.0 17.0 18.0 19.0 20.0 21.0 22.0 23.0 24.0 25.0 33.33333 40.0];
        
        A_fl=[2.325 1.397 1.067 0.879 0.747 0.645 0.564 0.497 0.442 0.396 0.357 0.325 0.300 0.280 0.265 0.256 ...
            0.250 0.254 0.261 0.271 0.283 0.298 0.314 0.351 0.393 0.438 0.486 0.537 0.590 0.645 0.703 0.764 ...
            0.826 0.892 0.959 1.029 1.758 2.963 ];
    case '120v60hz'
        RMS_FL=120;
        f=60;
        F_fl=[0.5 1 1.5 2.0 2.5 3.0 3.5 4.0 4.5 5.0 5.5 6 6.5 7.0 7.5 8 8.8 9.5 10.0 ...
            10.5 11.0 11.5 12.0 13.0 14.0 15.0 16.0 17.0 18.0 19.0 20.0 21.0 22.0 23.0 24.0 25.0 33.33333 40.0];
        
        A_fl=[2.453 1.465 1.126 0.942 0.815 0.717 0.637 0.570 0.514 0.466 0.426 0.393 0.366 0.346 0.332 0.323 ...
            0.321 0.329 0.341 0.355 0.373 0.394 0.417 0.469 0.528 0.592 0.660 0.734 0.811 0.892 0.977 1.067 ...
            1.160 1.257 1.359 1.464 2.570 4.393 ];        
    otherwise
        error('Wrong lamptype specified');
end
        
        
t=0:1/SAMPLING_FREQUENCY:SIGNAL_DURATION-1/SAMPLING_FREQUENCY;

for k=1:length(F_fl);
    afl=A_fl(k);
    ffl=F_fl(k);
    u=RMS_FL*sqrt(2)*sin(2*pi*f*t).*(1+afl/200*sin(2*pi*ffl*t));
    U_flicker_buf=mex_weighting_filterA((downsample(u,FL_DECIMATE_FACTOR)) / (RMS_FL*sqrt(2)));
    P_inst(k)=max(U_flicker_buf(SAMPLING_FREQUENCY/FL_DECIMATE_FACTOR*INIT_PERIOD:end));
    clear mex_weighting_filterA;
    fprintf('%3.2f ',ffl);
end;
fprintf('\n ');
P_inst_max=ones(1,length(F_fl))*1.08;
P_inst_min=ones(1,length(F_fl))*0.92;
hf=figure;
plot(F_fl,P_inst,'k-','LineWidth',2); hold on;
plot(F_fl,P_inst_max,'r--'); 
plot(F_fl,P_inst_min,'r--'); 
ylim([0.9 1.1])
grid;
title(['Table 1b : test flickermeter response ' LAMPTYPE ' for sinusoidal voltage fluctuations']);
xlabel('Modulation frequency, Hz');
ylabel('P_{inst}');
print(hf,'-dmeta','sinusoidal.emf')

% ---------------------------
% rectangular modulation (table 2b)
switch LAMPTYPE
    case '230v50hz'
        RMS_FL=230;
        f=50;
        F_fl=[0.5 1.0 1.5 2.0 2.5 3.0 3.5 4.0 4.5 5.0 5.5 6.0 6.5 7.0 7.5 8.0 8.8 9.5 10.0 ...
            10.5 11.0 11.5 12.0 13.0 14.0 15.0 16.0 17.0 18.0 19.0 20.0 21.0 21.5 22.0 23.0 24.0 ...
            25.0 25.5 28.0 30.5 33.33333];
        
        A_fl=[0.509 0.467 0.429 0.398 0.370 0.352 0.342 0.332 0.312 0.291 0.268 0.248 0.231 ...
            0.216 0.207 0.199 0.196 0.199 0.203 0.212 0.222 0.233 0.245 0.272 0.308 0.341 0.376 ...
            0.411 0.446 0.497 0.553 0.585 0.592 0.612 0.680 0.743 0.764 0.806 0.915 0.847 1.671];
    case '120v50hz'
        RMS_FL=120;
        f=50;
        F_fl=[0.5 1.0 1.5 2.0 2.5 3.0 3.5 4.0 4.5 5.0 5.5 6.0 6.5 7.0 7.5 8.0 8.8 9.5 10.0 ...
            10.5 11.0 11.5 12.0 13.0 14.0 15.0 16.0 17.0 18.0 19.0 20.0 21.0 21.5 22.0 23.0 24.0 ...
            25.0 25.5 28.0 30.5 33.33333];
        
        A_fl=[0.597 0.547 0.503 0.468 0.438 0.420 0.408 0.394 0.372 0.348 0.323 0.302 0.283 0.269 ...
            0.259 0.253 0.252 0.258 0.265 0.278 0.293 0.308 0.325 0.363 0.413 0.460 0.511 0.562 0.611 ...
            0.683 0.768 0.811 0.820 0.852 0.957 1.052 1.087 1.148 1.303 1.144 2.443 ];
     case '230v60hz'
        RMS_FL=230;
        f=60;
        F_fl=[0.5 1.0 1.5 2.0 2.5 3.0 3.5 4.0 4.5 5.0 5.5 6.0 6.5 7.0 7.5 8.0 8.8 9.5 10.0 ...
            10.5 11.0 11.5 12.0 13.0 14.0 15.0 16.0 17.0 18.0 19.0 20.0 21.0 21.5 22.0 23.0 24.0 ...
            25.0 25.5 28.0 30.5 33.33333 37.0 40.0];
        A_fl=[0.510 0.468 0.429 0.399 0.371 0.351 0.342 0.331 0.313 0.291 0.269 0.249 0.231 0.217 ...
            0.206 0.200 0.196 0.199 0.203 0.212 0.222 0.233 0.244 0.275 0.306 0.338 0.376 0.420 0.457 ...
            0.498 0.537 0.584 0.600 0.611 0.678 0.753 0.778 0.768 0.962 1.105 1.258 0.975 2.327 ];
     case '120v60hz'
        RMS_FL=120;
        f=60;
        F_fl=[0.5 1.0 1.5 2.0 2.5 3.0 3.5 4.0 4.5 5.0 5.5 6.0 6.5 7.0 7.5 8.0 8.8 9.5 10.0 ...
            10.5 11.0 11.5 12.0 13.0 14.0 15.0 16.0 17.0 18.0 19.0 20.0 21.0 21.5 22.0 23.0 24.0 ...
            25.0 25.5 28.0 30.5 33.33333 37.0 40.0];
        A_fl=[0.598 0.548 0.503 0.469 0.439 0.419 0.408 0.394 0.373 0.348 0.324 0.302 0.283 0.269 0.258 ...
            0.253 0.252 0.258 0.266 0.278 0.292 0.308 0.324 0.367 0.411 0.457 0.509 0.575 0.626 0.688 ... 
            0.746 0.815 0.837 0.851 0.946 1.067 1.088 1.072 1.383 1.602 1.823 1.304 3.451 ];
    otherwise
        error('Wrong lamptype specified');
end

t=0:1/SAMPLING_FREQUENCY:SIGNAL_DURATION-1/SAMPLING_FREQUENCY;

for k=1:length(F_fl);
    afl=A_fl(k);
    ffl=F_fl(k);
    u=RMS_FL*sqrt(2)*sin(2*pi*f*t).*(1+afl/200*sign(sin(2*pi*ffl*t)));
    U_flicker_buf=mex_weighting_filterA((downsample(u,FL_DECIMATE_FACTOR)) / (RMS_FL*sqrt(2)));
    P_inst(k)=max(U_flicker_buf(SAMPLING_FREQUENCY/FL_DECIMATE_FACTOR*INIT_PERIOD:end));
    clear mex_weighting_filterA;
    fprintf('%3.2f ',ffl);
end;
  fprintf('\n ');
P_inst_max=ones(1,length(F_fl))*1.08;
P_inst_min=ones(1,length(F_fl))*0.92;
hf=figure;
plot(F_fl,P_inst,'k-','LineWidth',2); hold on;
plot(F_fl,P_inst_max,'r--'); 
plot(F_fl,P_inst_min,'r--'); 
ylim([0.9 1.1])
grid;
title(['Table 2b : test flickermeter response ' LAMPTYPE ' for rectangular voltage fluctuations']);
xlabel('Modulation frequency, Hz');
ylabel('P_{inst}');
print(hf,'-dmeta','rectangular.emf')
% ---------------------------




