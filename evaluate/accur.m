function [ accuracy ] = accuracy( confusion )

s = size(confusion,1);
good = sum(sum(eye(s).*confusion));
total = sum(sum(confusion));
accuracy = 100/total * good;
