function [ accuracy ] = accuracy( confu )
    s = size(confu, 1);
    good = sum(sum(eye(s).*confu));
    bad = sum(sum((ones(s)-eye(s)) .* confu));
    total = sum(sum(confu));
    accuracy = 100/total * good;
end

