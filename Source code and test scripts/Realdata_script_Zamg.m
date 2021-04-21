clear all;
close all;
clc;


series = csvread('Zamg_P_and_R.csv');


Filename = 'Zamg_P_and_R.mat';
save(Filename);


[N,T1]=size(series);

%Statistical fitting test to assign the distribution
[I_n,I_p,I_g,I_B]=StatisticalFitting(series);


%set the distribution of time series
I_n=[];     % List of Gaussian time series
I_p=11:20;      % List of Poisson time series
I_g=1:10;      % List of Gamma time series
I_B=[];      % List of Bernoulli time series

%set the parameters

Max_lambda = 4;
Max_Lag = 15;

comparingTable=zeros(1,7);

count=1;
for L=Max_Lag:Max_Lag
    %% HGGM
    
    [AD_coeffs, AD_runtime] = AD(series, L, 1:T1,Max_lambda, I_n, I_p, I_g,I_B);
    
    %% TCML
    
    [Arnold_coeffs, Arnold_runtime] = Arnold(series, L, 1:T1,Max_lambda, I_n, I_p, I_g,I_B);
    
    %% SFGC
    
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
    
    
    %% HGGM Output 
    
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
    
    %% TCML Output
   
    Arnold_Output_adj=OutputAdj_pairwise(Arnold_coeffs,Thrsh_zero);
       
    count=count+1;
end

Filename=strcat('Zamg_Result.mat');
save(Filename);

lable={'Eisenstadt_p','Feuerkogel_p','Kleinzicken_p','Lienz_p',...
            'Linz_p','Retz_p','Salzburg_p','St.Andre_p','Wien_p','Innsbruck_p',...
          'Eisenstadt','Feuerkogel','Kleinzicken','Lienz',...
          'Linz','Retz','Salzburg','St.Andre','Wien','Innsbruck'
          };


PlotScript(Filename,lable);

disp('Done ...');