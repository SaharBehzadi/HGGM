clear all;
close all;
clc;

addpath('C:\Users\saharb63cs\Desktop\HeteroGrangerAD_AdaptiveLassoApproach\fitmethis');
addpath('C:\Users\saharb63cs\Desktop\HeteroGrangerAD_AdaptiveLassoApproach\gcpp\Real data');
addpath('C:\Users\saharb63cs\Desktop\HeteroGrangerAD_AdaptiveLassoApproach\gcpp\Simulation');
addpath('C:\Users\saharb63cs\Desktop\HeteroGrangerAD_AdaptiveLassoApproach\penalized\models');
addpath('C:\Users\saharb63cs\Desktop\HeteroGrangerAD_AdaptiveLassoApproach\penalized\penalties');


Final_result= zeros(1,6);
meanTable=zeros(1,8);
ComparingTable= zeros(1,9);

Max_Constant = 1;
count=1;
strength=0.5;
Features=3;
I_p=[1:round(Features*0.7)];
I_n=[round(Features*0.7)+1:Features];
I_g=[];
I_B=[];
dependency=3;


for length=1:1:1
    
    traning_data_size=length*1000;
    
    for itr=1:50
        
        Filename = strcat( 'Lag_Poisson',num2str(size(I_p,2)),'_Normal',num2str(size(I_g,2)),'_3.mat');
        
        [series, Ground_Truth]= final_dataGenerator(traning_data_size,Max_Constant,Features,I_n,I_p,I_g,...
            I_B,strength,dependency,Filename);
        
        disp(strcat('Itr = ',num2str(itr)));

        [N,T1,Max_Constant]=size(series);
        
        Max_Constant = 1;

        
        % Maximum Lamnda
        Max_lambda = 4;
        
        % set lag
        Max_Lag = 100;
        
        %% Ground Truth:
        
        for i=1:N
            for j=1:N
                
                if(Ground_Truth(i,j)>0)
                    Ground_Truth(i,j)=1;
                else
                    Ground_Truth(i,j)=0;
                end
            end
        end
        
        %     Ground_Truth=(Ground_Truth)';
        
        
        for Constant=1:Max_Constant
            %         disp(strcat('Constant = ',num2str(Constant)));
            for L=3:Max_Lag
                disp(strcat('Lag = ',num2str(L)));
                for lambda=Max_lambda:Max_lambda
                    %% AD
                    
                    [AD_coeffs, AD_runtime] = AD(series(:,:,1), L, 1:T1,Max_lambda, I_n, I_p, I_g,I_B);
                    
                    %% Arnold
                    
                    [Arnold_coeffs, Arnold_runtime] = Arnold(series(:,:,1), L, 1:T1,Max_lambda, I_n, I_p, I_g,I_B);
                    
                    %% Kim and Brown
                    
                    %                 Randomly generating a corresponding lag for any feature
                    %                     ht=2*randi([1,floor(L/2)],1,N);
                    
                    if(rem(L,2)==0)
                        ht=randi([L,L],1,N);
                    else
                        ht=randi([L-1,L-1],1,N);
                    end
                    [Output_adj_Kim,Kim_runtime]=ComparisonToHGGM_function(Filename, I_n, I_p, I_g, I_B,ht, L, traning_data_size);
                    
                    
                    %% AD coeffs with AD function
                    
%                     Thrsh=zeros(N,1);
                    Thrsh_zero=zeros(N,1);
%                     Thrsh_mean=zeros(N,1);
%                     for i=1:N
%                         Thrsh(i,1)=max(AD_coeffs{i,1}(:))+min(AD_coeffs{i,1}(:))/2;
%                         Thrsh_mean(i,1)=mean2(AD_coeffs{i,1}(:));
%                     end
                    
                    adj_AD=OutputAdj(AD_coeffs,Thrsh_zero);
%                     adj_Thrsh_AD=OutputAdj(AD_coeffs,Thrsh);
%                     adj_Thrsh_mean_AD=OutputAdj(AD_coeffs,Thrsh_mean);
                    
                    %% Arnold Output
                    
                    Arnold_Output_adj=OutputAdj(Arnold_coeffs,Thrsh_zero);
                    
                    
                    %% F_measure
                    
                    F_measure_AD=Fmeasure(adj_AD,Ground_Truth);
%                     F_measure_AD_Thrsh=Fmeasure(adj_Thrsh_AD,Ground_Truth);
%                     F_measure_AD_Thrsh_mean=Fmeasure(adj_Thrsh_mean_AD,Ground_Truth);
                    
                    F_measure_Arnold=Fmeasure(Arnold_Output_adj,Ground_Truth);
                    
                    F_measure_Kim=Fmeasure(Output_adj_Kim,Ground_Truth);
                    
                    ComparingTable((L-3)*(50)+itr,:)= [strength traning_data_size L F_measure_AD F_measure_Arnold F_measure_Kim ...
                        AD_runtime Arnold_runtime Kim_runtime];
                    
                end
                count=count+1;
                Filename=erase(Filename,".mat");
                FinalResult = Filename;
                save([FinalResult  '_HGGM_Result.mat']);
                xlswrite([FinalResult '_HGGM_Result.xlsx'],ComparingTable,1);
            end
        end
        
        %         ComparingTable((itr-1)*(TS_length)+count,:)= [itr TS_length F_measure_AD F_measure_AD_Thrsh_mean F_measure_Arnold F_measure_Kim ...
        %             AD_runtime Arnold_runtime Kim_runtime];
        
   %     mean_F_measure_AD = mean (ComparingTable(count-9:count-1,4));
   %     mean_F_measure_Arnold = mean (ComparingTable(count-9:count-1,5));
    %    mean_F_measure_Kim =  mean (ComparingTable(count-9:count-1,6));
    %    mean_Runtime_AD=  mean (ComparingTable(count-9:count-1,7));
    %    mean_Runtime_Arnold=  mean (ComparingTable(count-9:count-1,8));
     %   mean_Runtime_Kim=  mean (ComparingTable(count-9:count-1,9));
    %    meanTable((length-1)*(50)+itr,:)= [itr traning_data_size mean_F_measure_AD ...
     %       mean_F_measure_Arnold mean_F_measure_Kim mean_Runtime_AD mean_Runtime_Arnold mean_Runtime_Kim];
        
        Filename=erase(Filename,".mat");
        FinalResult = Filename;
        Mean_FinalResult = strcat( Filename,'_mean');
        save([FinalResult  '_HGGM_Result.mat']);
        xlswrite([FinalResult '_HGGM_Result.xlsx'],ComparingTable,1);
 %       xlswrite([Mean_FinalResult '_HGGM_Result.xlsx'],meanTable,1);
    end
    
end
