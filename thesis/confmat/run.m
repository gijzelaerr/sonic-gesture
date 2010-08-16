%% load data;
close all;
clear;
C = load('data.txt');


%% make img
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
set(gca,'XTickLabel',{'a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z','I','II'});
set(gca,'YTickLabel',{'a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z','I','II'});
set(gcf,'Resize', 'off');
set(gcf, 'Position', [1 1 1000 600]);



%% saveit
saveas(gcf,'confusion.jpg');