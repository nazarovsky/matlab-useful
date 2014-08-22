clear all;clc;

Z=[magic(5);magic(5)'];
i=mex_WriteMatrix(Z,'magic.txt');
clear mex_WriteMatrix;