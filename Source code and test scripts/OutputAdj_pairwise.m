function Output=OutputAdj_pairwise(HGGM_Output,Thrsh)

                N=size(Thrsh,1);
                Output=zeros(N,N);
                                
                for i=1:N
                    for j=1:N                       
                        if(find(HGGM_Output{i,1}(j,:)>Thrsh(i,1))>0)
                            Output(i,j)=1;
                        else
                            Output(i,j)=0;
                        end
                        
                    end
                end
                
                for i=1:N
                    for j=1:N
                        if(i==j)
                            Output(i,j)=0;
                        end
                    end
                end
                
                Output=Output';
                
                %                 GLM_Lasso_Output_adj = GLM_Lasso_Output_adj';
