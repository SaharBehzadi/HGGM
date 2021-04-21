clear all;
close all;
clc;

addpath('C:\Users\saharb63cs\Desktop\HeteroGrangerAD_AdaptiveLassoApproach\fitmethis');
addpath('C:\Users\saharb63cs\Desktop\HeteroGrangerAD_AdaptiveLassoApproach\fitmethis');
addpath('C:\Users\saharb63cs\Desktop\HeteroGrangerAD_AdaptiveLassoApproach\gcpp\Real data');
addpath('C:\Users\saharb63cs\Desktop\HeteroGrangerAD_AdaptiveLassoApproach\gcpp\Simulation');
addpath('C:\Users\saharb63cs\Desktop\HeteroGrangerAD_AdaptiveLassoApproach\penalized\models');
addpath('C:\Users\saharb63cs\Desktop\HeteroGrangerAD_AdaptiveLassoApproach\penalized\penalties');

% series = csvread('P_and_R_TS.csv');
% series = csvread('P_and_R_42Station_MissingValue.csv');
series = csvread('P_and_R_42Station_MissingValue.csv');

% Filename = 'P_and_R_42Station_MissingValue.mat';
Filename = 'P_and_R_42Station_MissingValue.mat';
save(Filename);

[N,T1]=size(series);

% [ I_p,I_n ,I_g,I_B]= StatisticalFitting(series);

I_n=[33];
I_p=[43:84];
I_g=[1:32,34:42];
I_B=[];

Max_lambda = 4;
Max_Lag = 15;

ComaringTable= zeros(Max_Lag*Max_lambda,18);

count=1;
for L=15:Max_Lag
    %% AD
    
    [AD_coeffs, AD_runtime] = AD(series, L, 1:T1,Max_lambda, I_n, I_p, I_g,I_B);
    
    %% Arnold
    
    [Arnold_coeffs, Arnold_runtime] = Arnold(series, L, 1:T1,Max_lambda, I_n, I_p, I_g,I_B);
    
    %% Kim and Brown
    
    %                 Randomly generating a corresponding lag for any feature
    %                     ht=2*randi([1,floor(L/2)],1,N);
    
    if(rem(L,2)==0)
        ht=randi([L,L],1,N);
    else
        ht=randi([L-1,L-1],1,N);
    end
    [Output_adj_Kim,Kim_runtime]=ComparisonToHGGM_function(Filename, I_n, I_p, I_g, I_B,ht, L, T1);
    
    [Kim_Out_Size,Kim_Out_Size]=size(Output_adj_Kim);
    for i=1:Kim_Out_Size
        for j=1:Kim_Out_Size
            if(i==j)
                Output_adj_Kim(i,j)=0;
            end
        end
    end
    
    Output_adj_Kim=Output_adj_Kim';
    
    
    %% AD coeffs with AD function
    
    Thrsh=zeros(N,1);
    Thrsh_zero=zeros(N,1);
    Thrsh_mean=zeros(N,1);
    for i=1:N
        Thrsh(i,1)=max(AD_coeffs{i,1}(:))+min(AD_coeffs{i,1}(:))/2;
        Thrsh_mean(i,1)=mean2(AD_coeffs{i,1}(:));
    end
    
    %                     adj_AD=OutputAdj(AD_coeffs,Thrsh_zero);
    adj_AD=OutputAdj_pairwise(AD_coeffs,Thrsh_zero);
    adj_Thrsh_AD=OutputAdj(AD_coeffs,Thrsh);
    adj_Thrsh_mean_AD=OutputAdj(AD_coeffs,Thrsh_mean);
    
    %% Arnold Output
    
    %                     Arnold_Output_adj=OutputAdj(Arnold_coeffs,Thrsh_zero);
    Arnold_Output_adj=OutputAdj_pairwise(Arnold_coeffs,Thrsh_zero);
    
    %% F_measure
    
    F_measure_AD=Fmeasure(adj_AD,Ground_Truth);
    F_measure_AD_Thrsh=Fmeasure(adj_Thrsh_AD,Ground_Truth);
    F_measure_AD_Thrsh_mean=Fmeasure(adj_Thrsh_mean_AD,Ground_Truth);
    
    F_measure_Arnold=Fmeasure(Arnold_Output_adj,Ground_Truth);
    
    F_measure_Kim=Fmeasure(Output_adj_Kim,Ground_Truth);
    
    ComparingTable(count,:)= [strength dependency L F_measure_AD F_measure_AD_Thrsh_mean F_measure_Arnold F_measure_Kim];
    
    count=count+1;
end


%         ComparingTable((itr-1)*(TS_length)+count,:)= [itr TS_length F_measure_AD F_measure_AD_Thrsh_mean F_measure_Arnold F_measure_Kim ...
%             AD_runtime Arnold_runtime Kim_runtime];

% mean_F_measure_AD = mean (ComparingTable(count-9:count-1,4));
% mean_F_measure_AD_Thrsh_mean = mean (ComparingTable(count-9:count-1,5));
% mean_F_measure_Arnold = mean (ComparingTable(count-9:count-1,6));
% mean_F_measure_Kim =  mean (ComparingTable(count-9:count-1,7));
% meanTable((proportion*10-1)*(50)+itr,:)= [itr proportion mean_F_measure_AD ...
%     mean_F_measure_Arnold mean_F_measure_Kim AD_runtime Arnold_runtime Kim_runtime];

% FinalResult = strcat( '',num2str(size(I_n,2)/10),'Proportion');
% % Mean_FinalResult = strcat( 'NewSynthetic_',num2str(size(I_n,2)/10),'Proportion_mean');
% save([FinalResult  '_HGGM_Result.mat']);
% xlswrite([FinalResult '_HGGM_Result.xlsx'],ComparingTable,1);
% xlswrite([Mean_FinalResult '_HGGM_Result.xlsx'],meanTable,1);


Filename=strcat('Zamg_42Stations');
xlswrite([Filename '_Lag15_Results.xlsx'],ComparingTable,1);
save([Filename '_Lag15_Results.mat']);


disp('Done ...');