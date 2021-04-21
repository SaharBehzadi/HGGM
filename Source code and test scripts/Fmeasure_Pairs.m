function f_measure=Fmeasure_Pairs(Output_adj,Ground_Truth)
                %% Precision and recall
                [N,M]=size(Output_adj);
                same=0;
              
                for i=1:N
                    for j=1:M
                        if(Output_adj(i,j)==1 && Ground_Truth(i,j)==1)
                            same=same+1;
                        end
%                         if(Output_adj(i,j)==0 && Ground_Truth(i,j)==0)
%                             same=same+1;
%                         end
                    end
                end
                
                %precision
                
                for i=1:N
                    for j=1:M
                        if(Ground_Truth(i,j)==2)
                            Output_adj(i,j)=2;
                        end
                    end
                end
                
                NumOfNonZero_Output=sum(Output_adj(:) == 1);
                
                
                if (NumOfNonZero_Output==0)
                    p=0;
                else
                    p= same/NumOfNonZero_Output;
                end
                 
                % recall
                NumOfNonZero_Truth=sum(Ground_Truth(:) == 1);
                r= same/NumOfNonZero_Truth;
                
                % F-measure
                
                if(p==0 && r==0)
                    f_measure=0;
                else
                    f_measure=(2*p*r)/(p+r);
                end
                
