x = load('heilige_perf.txt');
plot(x(:,1), x(:,2));
title('labels of arbitrary movie');
xlabel('Frame number');
ylabel('Label');
saveas(gcf,'heilige.jpg');


x = load('anne1_stable_perf.txt');
plot(x(:,1), x(:,2));
title('labels of anne1 with stabilizer');
xlabel('Frame number');
ylabel('Label');
saveas(gcf,'anne1_stable.jpg');


x = load('anne1_unstable_perf.txt');
plot(x(:,1), x(:,2));
title('labels of anne1 withouth stabilizer');
xlabel('Frame number');
ylabel('Label');
saveas(gcf,'anne1_unstable.jpg');
