function [series,coef] = final_dataGenerator(traning_data_size,Constant,numOfTS, I_n, I_p,I_g,I_B,strength,Dep,Fname)

%     for strength=0.2:0.1:0.9
for strength=strength:0.1:strength
    %     for strength=0.4:0.1:0.4
    %         for dependency=round(numOfTS/2):1:round(numOfTS*2)
    for dependency=Dep:1:Dep
        
        clc;
        % traning_data_size=1000; Constant=1;
        
        %             I_n=[1,2]; I_p=[3,4];
        
        numOfTS= size(I_n,2)+size(I_p,2)+size(I_g,2)+ size(I_B,2);
        %             proportion= size(I_n,2)/numOfTS;
        %             Filename = strcat( 'NewSynthetic_', num2str(proportion),'_Proportion.mat');
        Filename = Fname;
        
        series = zeros(numOfTS,traning_data_size,Constant);
        Mean_training_file = zeros(numOfTS,traning_data_size,Constant);
        series(1,1,1)=inf;
        ISEMPTY=isempty(find(isinf(series))>0);
        ISBIG = 201;
        flag=1;
        % Generae random coefficients regarding mean value equations
        %               e.g. mean(t+1)= coeff_1*x_1 + coeff_2*x_2 + ....
        coef = zeros(numOfTS,numOfTS);
        
        %             while(ISEMPTY==0 || nnz(coef)~=dependency)
        while(ISEMPTY==0 || ISBIG>200 || flag==1)
            clc;
            series = zeros(numOfTS,traning_data_size,Constant);
            
            %     Generate random values for sigma corresponding to any normal
            %     time series
            sigma_value=1*rand(1,numOfTS);
            
            %Set the parameters for a gamma time series
            Shape=3+rand(1,numOfTS);
            
            %     coef = (1).*rand(numOfTS,numOfTS) -0.5;
            indices=randperm(numOfTS*numOfTS,dependency);
            coef = zeros(numOfTS,numOfTS);
            for index=1:numOfTS*numOfTS
                if ismember(index, indices)==1
                    coef(index)= strength + (0.1).*rand(1,1);
                end
            end         
            
            itr=0;
            
            for count=1:1:Constant
                
                itr=itr+1;
                
                for TS=1:numOfTS
                    
                    if ismember(TS, I_n)==1
                        series(TS,1,itr)=0;
                        while(series(TS,1,itr)<=0)
                            series(TS,1,itr)= randn;
                        end
                        while(series(TS,2,itr)<=0)
                            series(TS,2,itr)= randn;
                        end
                        while(series(TS,3,itr)<=0)
                            series(TS,3,itr)= randn;
                        end
                    end
                    
                    if ismember(TS, I_p)==1
                        series(TS,1,itr)= poissrnd(1);
                        series(TS,2,itr)= poissrnd(1);
                        series(TS,3,itr)= poissrnd(TS);
                    end
                    
                    if ismember(TS, I_B)==1
                        series(TS,1,itr)= binornd(1,0.5);
                        series(TS,2,itr)= binornd(1,0.5);
                        series(TS,3,itr)= binornd(1,0.5);
                    end
                    
                    if ismember(TS, I_g)==1
                        series(TS,1,itr)=0;
                        while(series(TS,1,itr)<=0 )
                            series(TS,1,itr)= 3+randn;
                        end
                        while(series(TS,2,itr)<=0 )
                            series(TS,2,itr)= 3+randn;
                        end
                        while(series(TS,3,itr)<=0 )
                            series(TS,3,itr)= 3+randn;
                        end
                    end
                    
                    Mean_training_file(TS,1,itr)= series(TS,1,itr);
                end
                
                flag=0;
                for i=3:traning_data_size
                     if max(max(series))>200
                         break;
                     end
                    
                    if(flag==1)
                        break;
                    end
                    for j=1:numOfTS
                        
                        Mean_training_file(j,i,itr)=count;
                        
                        if ismember(j, I_p)==1
                            Mean_training_file(j,i,itr) = count/20;
                        end
                                             
                        for k=1:numOfTS
                            if(coef(j,k)>0)
                                Mean_training_file(j,i,itr)= Mean_training_file(j,i,itr)+coef(j,k)*series(k,i-2,itr);
                            end
                        end
                        
                        if ismember(j, I_p)==1
                            Mean_training_file(j,i,itr) = exp(Mean_training_file(j,i,itr));
                        end
                        
                        if ismember(j, I_B)==1
                            Mean_training_file(j,i,itr) = exp(Mean_training_file(j,i,itr))...
                                /(1+exp(Mean_training_file(j,i,itr)));
                        end
                        
                        if ismember(j, I_g)==1
                            Mean_training_file(j,i,itr) = 1/(Mean_training_file(j,i,itr));
                        end
                        
                        
                        if ismember(j, I_n)==1
                            series(j,i,itr)=0;
                            while (isnan(series(j,i,itr)) || series(j,i,itr)<=0 || series(j,i,itr) >1 ) %|| series(j,i,itr) >100
                                series(j,i,itr)= Mean_training_file(j,i,itr)*randn + sigma_value(1,j);
                            end
                        end                  
                        
                        if ismember(j, I_p)==1
                            series(j,i,itr)=101;
                            Flag_Count=0;
                            while (series(j,i,itr)>5 && Flag_Count <20000)
                                Flag_Count = Flag_Count+1;
                                series(j,i,itr)= poissrnd(Mean_training_file(j,i,itr));
                            end
                        end
                                              
                         if ismember(j, I_B)==1
                                series(j,i,itr)= binornd(1,Mean_training_file(j,i,itr));
                        end
                        
                        if ismember(j, I_g)==1
                            if(Mean_training_file(j,i,itr)==0)
                                flag=1;
                                break;
                            end
                            series(j,i,itr)=0;
                            while (series(j,i,itr)==0 || isnan(series(j,i,itr)))
                                series(j,i,itr)= gamrnd(Shape(1,j),Mean_training_file(j,i,itr)*Shape(1,j));
                            end
                        end
                        
                    end
                    
                end
                %         disp(series(:,:,itr));
            end
            ISEMPTY=isempty(find(isinf(series))>0);
            ISBIG = max(max(series));
            
            %     disp(series());
            %                 save(Filename);
        end
        save(Filename);
        %             disp(series());
        
        
        fileID = fopen(strcat(Fname,'.txt'),'w');
        formatSpec='';
        first_line='';
        for i=1:numOfTS
            if ismember(i,I_n)
                %         series(i,1)=1;
                formatSpec= strcat(formatSpec,'%f\t');
                first_line = strcat(first_line,'n');
            end
            
            if ismember(i,I_p)
                %         series(index_i,1)=2;
                formatSpec= strcat(formatSpec,'%f\t');
                first_line = strcat(first_line,'i');
            end
            if ismember(i,I_g)
                %         series(index_i,1)=3;
                formatSpec=strcat(formatSpec,'%f\t');
                first_line = strcat(first_line,'n');
            end
            if ismember(i,I_B)
                %         series(index_i,1)=4;
                formatSpec= strcat(formatSpec,'%f\t');
                first_line = strcat(first_line,'b');
            end
            
            if i<numOfTS
                first_line = strcat(first_line,'\t');
            else
                first_line = strcat(first_line,'\n');
            end
        end
        formatSpec=strcat(formatSpec,'\n');
        fprintf(fileID,first_line);
        fprintf(fileID,formatSpec,series);
        fclose(fileID);
    end
end