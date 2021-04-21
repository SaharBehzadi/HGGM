clear all;
close all;
clc;

warning off;

meanTable=zeros(1,4);
ComparingTable= zeros(1,5);


Max_Constant = 1;
count=1;
strength=0.3;
traning_data_size=1000;
Features=5;
I_p=[1:round(Features*0.7)];
I_n=[round(Features*0.7)+1:Features];
I_B=[];
I_g=[];

for dependency=2:1:10
    
    for itr=1:50
        
        Filename = strcat( 'Dependency_',num2str(traning_data_size),'_Poisson',num2str(size(I_p,2)),'_Normal',num2str(size(I_B,2)),'_9.mat');
        
        [series, Ground_Truth]= final_dataGenerator(traning_data_size,Max_Constant,Features,I_n,I_p,I_g,...
            I_B,strength,dependency,Filename);
        
        disp(strcat('Dependency = ',num2str(dependency)));
        disp(strcat('Itr = ',num2str(itr)));        
                      
        a = load(Filename);
        
        series = a.series;
        [N,T1,Max_Constant]=size(series);
        
        Max_Constant = 1;
        I_p=a.I_p;
        I_B=a.I_B;
        I_n=a.I_n;
        I_g=a.I_g;
        
        
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
        
        %     Ground_Truth=(Ground_Truth)';
        
        
        for Constant=1:Max_Constant
            %         disp(strcat('Constant = ',num2str(Constant)));
            for L=2:Max_Lag
                disp(strcat('Lag = ',num2str(L)));
                for lambda=Max_lambda:Max_lambda
                    %% AD
                    
                    [AD_coeffs, AD_runtime] = AD(series(:,:,1), L, 1:T1,Max_lambda, I_n, I_p, I_g,I_B);
                        
                    %% AD coeffs with AD function
                    
                    Thrsh_zero=zeros(N,1);
                    adj_AD=OutputAdj(AD_coeffs,Thrsh_zero);
                    %% F_measure
                    
                    F_measure_AD=Fmeasure(adj_AD,Ground_Truth);
                   ComparingTable(count,:)= [strength dependency L F_measure_AD AD_runtime];
                    
                end
                count=count+1;
            end
        end

        mean_F_measure_AD = mean (ComparingTable(count-9:count-1,4));
        mean_Runtime_AD=  mean (ComparingTable(count-9:count-1,5));
        meanTable((dependency-2)*(50)+itr,:)= [itr dependency mean_F_measure_AD mean_Runtime_AD];
        
        Filename=erase(Filename,".mat");
        FinalResult = Filename;
        Mean_FinalResult = strcat( Filename,'_mean');
        save([FinalResult  '_HGGM_Result.mat']);
        xlswrite([FinalResult '_HGGM_Result.xlsx'],ComparingTable,1);
        xlswrite([Mean_FinalResult '_HGGM_Result.xlsx'],meanTable,1);
    end
    
end

