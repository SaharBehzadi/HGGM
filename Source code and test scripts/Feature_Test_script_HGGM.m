clear all;
close all;
clc;

warning off;


Final_result= zeros(1,6);
meanTable=zeros(1,4);
ComparingTable= zeros(1,5);

Max_Constant = 1;
count=1;
strength=0.5;
traning_data_size=1000;
Proportion = 0.7;

for Features=2:1:10
    
    I_n=[];
    I_g=[round(Features*Proportion)+1:Features];
    I_p=[1:round(Features*Proportion)];
    I_B=[];
    
    dependency=round(Features/2)+1;
    
    for itr=1:50
        
        Filename = strcat( 'Features_', num2str(Proportion*100),'Poisson_',num2str(100-Proportion*100),'Gamma.mat');
        
        [series, Ground_Truth]= final_dataGenerator(traning_data_size,Max_Constant,Features,I_n,I_p,I_g,...
            I_B,strength,dependency,Filename);
        
     
        disp(strcat('Num Of Features = ',num2str(Features)));
        disp(strcat('Itr = ',num2str(itr)));
      
        a = load(Filename);
        
        series = a.series;
        [N,T1,Max_Constant]=size(series);
        
        Max_Constant = 1;
        I_n=a.I_n;
        I_p=a.I_p;
        I_g=a.I_g;
        I_B=a.I_B;
        
        
        % Maximum Lamnda
        Max_lambda = 4;
        
        % set lag
        Max_Lag = 10;
        
        %% Ground Truth:
        
        Ground_Truth=a.coef;
        for i=1:N
            for j=1:N
                
                if(Ground_Truth(i,j)>0)
                    Ground_Truth(i,j)=1;
                else
                    Ground_Truth(i,j)=0;
                end
            end
        end
               
        
        for Constant=1:Max_Constant

            for L=2:Max_Lag
                disp(strcat('Lag = ',num2str(L)));
                for lambda=Max_lambda:Max_lambda
                    %% AD
                    
                    [AD_coeffs, AD_runtime] = AD(series(:,:,Constant), L, 1:T1,lambda, I_n, I_p, I_g,I_B);
                    
                    %% AD coeffs with AD function
                    
                    Thrsh_zero=zeros(N,1);
                    adj_AD=OutputAdj(AD_coeffs,Thrsh_zero);
                    %% F_measure
                    
                    F_measure_AD=Fmeasure(adj_AD,Ground_Truth);
                    ComparingTable(count,:)= [Features dependency L F_measure_AD AD_runtime];
                    
                end
                count=count+1;
            end
        end
        
        mean_F_measure_AD = mean (ComparingTable(count-8:count-1,4));
        mean_Runtime_AD=  mean (ComparingTable(count-8:count-1,5));
        meanTable((Features-2)*(50)+itr,:)= [itr Features mean_F_measure_AD mean_Runtime_AD];
        
        Filename=erase(Filename,".mat");
        FinalResult = Filename;
        Mean_FinalResult = strcat( Filename,'_mean');
        save([FinalResult  '_HGGM_Result.mat']);
        xlswrite([FinalResult '_HGGM_Result.xlsx'],ComparingTable,1);
        xlswrite([Mean_FinalResult '_HGGM_Result.xlsx'],meanTable,1);
    end
        
end
