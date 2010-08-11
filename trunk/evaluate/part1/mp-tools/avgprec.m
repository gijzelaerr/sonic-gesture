% AVGPREC Compute Average Precision of classified dataset (a*w) 
%       + Rows are objects and columns are posteriors per class
%       + For two-class problems also only one column may be used, 
%         where negative and positive values differentiate the 
%         classes.

function ap=avgprec(b)

    ap=0;

    if exist('isocset')==2 && isocset(b)
        trueLab=getoclab(b);
    else
        trueLab=getlabels(b);        
    end
    
    if ~all(trueLab ==-1 | trueLab == 1) & ~all(trueLab == 0 | trueLab == 1)
        error('Not a proper one-class problem');
    end

    %if sum(trueLab == -1) < sum(trueLab == 1) | sum(trueLab == 0) < sum(trueLab == 1)
    %    error('More outliers than targets');
    %end

    x=+b;

    if size(x,2)>2
        error('Average precision is not defined for more than 2 classes');
    end

    % Make ordered index of relevant labeled objects
    if size(x,2)==2
        [y,I]=sort(-x(:,2)); 
    else
        [y,I]=sort(-x);      
    end
    
    % I is sorted index of relevant labeled objects; most relevant first

    %%% c=find(trueLab(I)==1);   % indexes of sorted correctly relevant labeled objects

    %%% ??????
    
    c=find(trueLab(I)==1);   % indexes of sorted correctly relevant labeled objects

    
    if length(c)>0      % any objects labeled correctly?
                        % compute mean ranked sum
        ap=mean((1:length(c))' ./ c);
    end
return


