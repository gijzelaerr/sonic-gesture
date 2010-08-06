function [ result ] = major( knnConfusion )
%MAJOR transforms confusion for full scale to major scale
%   Detailed explanation goes here



c1 = sum(knnConfusion(:,1:2),2);
d1 = sum(knnConfusion(:,3:4),2);
e1 = knnConfusion(:,5);
f1 = sum(knnConfusion(:,6:7),2);
g1 = sum(knnConfusion(:,8:9),2);
a1 = sum(knnConfusion(:,10:11),2);
b1 = knnConfusion(:,12);

c2 = sum(knnConfusion(:,13:14),2);
d2 = sum(knnConfusion(:,15:16),2);
e2 = knnConfusion(:,17);
f2 = sum(knnConfusion(:,18:19),2);
g2 = sum(knnConfusion(:,20:21),2);
a2 = sum(knnConfusion(:,22:23),2);
b2 = knnConfusion(:,24);

rest = sum(knnConfusion(:,25:28),2);

l = [c1 d1 e1 f1 g1 a1 b1 c2 d2 e2 f2 g2 a2 b2];

c1 = sum(l(1:2,:),1);
d1 = sum(l(3:4,:),1);
e1 = l(5,:);
f1 = sum(l(6:7,:),1);
g1 = sum(l(8:9,:),1);
a1 = sum(l(10:11,:),1);
b1 = l(12,:);

c2 = sum(l(13:14,:),1);
d2 = sum(l(15:16,:),1);
e2 = l(17,:);
f2 = sum(l(18:19,:),1);
g2 = sum(l(20:21,:),1);
a2 = sum(l(22:23,:),1);
b2 = l(24,:);

rest = sum(l(25:28,:),1);

result = [c1; d1; e1; f1; g1; a1; b1; c2; d2; e2; f2; g2; a2; b2];