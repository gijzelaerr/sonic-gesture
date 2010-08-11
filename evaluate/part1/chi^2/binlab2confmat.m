function [c, acc] = binlab2confmat(estimate, truth, printcOPT)

    printc = 0;
    if exist('printcOPT','var')
        printc = printcOPT;
    end

    c = zeros(size(truth,2),size(truth,2));
    for i = 1 : size(estimate,1)
        e = find(estimate(i,:));
        t = find(truth(i,:));
        for j = e
            c(t,e) = c(t,e) + 1;
        end
    end
    
    c = NormalizeRows(c);
    acc = sum(diag(c)) / numel(diag(c));

    if printc
        for i = 1 : size(c,1)
            for j = 1 : size(c,1)
                fprintf('%.2f\t',c(i,j));
            end
            fprintf('\n');
        end
    end
    
end