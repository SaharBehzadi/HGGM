function [ I_p,I_n ,I_g,I_B] = StatisticalFitting( series )
%STATISTICALFITTING Summary of this function goes here
%   Detailed explanation goes here

% exponential_Family = {'normal'; 'exponential'; 'gamma'; 'logistic'; ...
% 		  'rayleigh'; 'beta';'inversegaussian'; ...
% 		 'loglogistic'; 'lognormal'; 'weibull';'binomial';'geometric';'poisson'};
     
     exponential_Family = {'normal'; 'gamma'; 'binomial';'poisson'};

I_p = [];
I_n = [];
I_g = [];
I_B = [];
[N , T]=size(series);
for i=1:N
        
    
    FF= fitmethis(series(i,:));

    count=1;
    for j= 1:length(FF)
        if(ismember (FF(j).name,exponential_Family))
            Fit_Exponential_distributions(count)=FF(j);
            count=count+1;
        else
                        continue
        end
    end
    
	fprintf('\n\t\t\t\tName\t\tPar1\t\tPar2\t\tPar3\t\tLogL\t\tAIC\n')
	for j= 1:size(Fit_Exponential_distributions,2)
		switch numel(Fit_Exponential_distributions(j).par)
			case 1
				fprintf('%20s \t%10.3e \t\t\t\t\t\t\t%10.3e \t%10.3e\n',Fit_Exponential_distributions(j).name,Fit_Exponential_distributions(j).par,Fit_Exponential_distributions(j).LL,Fit_Exponential_distributions(j).aic)
			case 2
				fprintf('%20s \t%10.3e \t%10.3e \t\t\t\t%10.3e \t%10.3e\n',Fit_Exponential_distributions(j).name,Fit_Exponential_distributions(j).par,Fit_Exponential_distributions(j).LL,Fit_Exponential_distributions(j).aic)
			case 3
				fprintf('%20s \t%10.3e \t%10.3e \t%10.3e \t%10.3e \t%10.3e\n',Fit_Exponential_distributions(j).name,Fit_Exponential_distributions(j).par,Fit_Exponential_distributions(j).LL,Fit_Exponential_distributions(j).aic)
		end
	end

    
    if(strcmp(FF(1).name,'poisson'))
        I_p=[I_p(),i];
    end
    
    if(strcmp(FF(1).name,'normal'))
        I_n=[I_n(),i];
    end
    
    if(strcmp(FF(1).name,'gamma'))
        I_g=[I_g(),i];
    end
    
    if(strcmp(FF(1).name,'binomial'))
        I_B=[I_B(),i];
    end

    for j=1:length(Fit_Exponential_distributions)
        Fit_Exponential_distributions(1)=[];
    end
    
end

end

