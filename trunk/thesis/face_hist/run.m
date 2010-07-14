load('histvals.txt');
h = bar3(histvals);
title('Histogram of face colors');
xlabel('Hue');
ylabel('Saturation');
zlabel('Normalized pixel count');
colormap hsv
saveas(gcf,'histobar.jpg');
