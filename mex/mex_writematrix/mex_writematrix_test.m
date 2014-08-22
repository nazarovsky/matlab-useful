clear all;clc;

Z=[magic(5);magic(5)'];
mex_WriteMatrix('magic.txt',Z,'%10.10f',',');
clear mex_WriteMatrix;