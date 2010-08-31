% load data;
close all;
clear;
C = load('data.txt');


% make img
CN = NormalizeRows(C);
figure;
imagesc(CN);
colorbar;
title('Confusion Matrix');
xlabel('Predicted');
ylabel('True value');

% label bij elk symbool
set(gca,'XTick',1:28);
set(gca,'YTick',1:28);
%set(gca,'XTickLabel',{'a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z','I','II'});
%set(gca,'YTickLabel',{'a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z','I','II'});
set(gca, 'XTickLabel',{'do1','di1','re1','ri1','mi1','fa1','fi1','sol1','si1','la1','li1','ti1','do2','di2','re2','ri2','mi2','fa2','fi2','sol2','si2','la2','li2','ti2','I','II','III','IV'});
set(gca, 'YTickLabel',{'do1','di1','re1','ri1','mi1','fa1','fi1','sol1','si1','la1','li1','ti1','do2','di2','re2','ri2','mi2','fa2','fi2','sol2','si2','la2','li2','ti2','I','II','III','IV'});
set(gcf,'Resize', 'off');
%set(gcf, 'Position', [1 1 2000 600]);
set(gca, 'FontSize', 7);



% saveit
saveas(gcf,'confusion.jpg');
