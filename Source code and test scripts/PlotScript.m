function PlotScript(resultFile,labels)


load(resultFile);


figure('name','HGGM_Kleinzicken');
G = digraph(Arnold_Output_adj,lable_10);
H=plot(G,'ko-','Layout','circle','Linewidth',1);
set(gca,'Visible','off')
title('TCML');
highlight(H,[1:10], 'Nodecolor','b')
highlight(H,[11:20], 'Nodecolor',[1 0.6  0])
highlight(H,[1:20])

% figure('name',strcat('Lag_',num2str(L)));
% 
% subplot(2,2,1);
% G = digraph(adj_AD,labels);
% plot(G,'Layout','circle');
% set(gca,'Visible','off')
% title('HGGM');
% 
% subplot(2,2,2);
% G = digraph(Arnold_Output_adj,labels);
% plot(G,'Layout','circle');
% set(gca,'Visible','off')
% title('TCML');
% 
% subplot(2,2,3);
% G = digraph(Output_adj_Kim,labels);
% plot(G,'Layout','circle');
% set(gca,'Visible','off')
% title('SFGC');



resultFile=erase(resultFile,'.mat');
PlotName=strcat(resultFile,'.pdf');
saveas(gcf,PlotName);
