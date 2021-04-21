clear all;
close all;
clc;

addpath('.\Real Data');
addpath('.\fitmethis');
addpath('.\gcpp\Real data');
addpath('.\gcpp\Simulation');
addpath('.\penalized\models');
addpath('.\penalized\penalties');


comparingTable=zeros(1,3);

% name of the data set
Dataset_name='marks';
% Dataset_name='DWD';

series=csvread( strcat(Dataset_name,'.csv'))';

%Adjacency matrix of the ground truth
GT_name=strcat(Dataset_name,'_Solution.txt')';
Ground_Truth=load (GT_name);  

[ I_p,I_n ,I_g,I_B]= StatisticalFitting(series);

[N,T1]=size(series);

% Maximum Lamnda
Max_lambda = 5;

% set lag
L = 15;

disp(strcat('Lag = ',num2str(L)));

%% AD

[AD_coeffs, AD_runtime] = AD(series, L, 1:T1,Max_lambda, I_n, I_p, I_g,I_B);

%% AD coeffs with AD function

Thrsh_zero=zeros(N,1);
adj_AD=OutputAdj_pairwise(AD_coeffs,Thrsh_zero);

%% F_measure

F_measure_AD=Fmeasure_Pairs(adj_AD,Ground_Truth);

comparingTable(1,:)= [L F_measure_AD AD_runtime ];

save(['Real Data/' Dataset_name  '_Result.mat']);
xlswrite(['Real Data/' Dataset_name '_Result.xlsx'],comparingTable,1);

disp('done ....')



