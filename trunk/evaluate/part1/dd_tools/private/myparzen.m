function F = myparzen(a,h,b)

[nra,dim] = size(a);
if (nargin<3)
  F = [];
  return
else
  nrb = size(b,1);
end
if (nrb==0)
  F = [];
  return;
end

alf=sqrt(2*pi)^dim;
[num,n] = myprmem(nrb,nra);
F = ones(nrb,1);
for i = 0:num-1
    if i == num-1
      nn = nrb - num*n + n;
    else
      nn = n;
    end
    range = [i*n+1:i*n+nn];
%    if nargin < 3
    if isequal(a,b)  % hak hak hark  Dxd
      D = distm(a(range,:),a);
      % set distances to itself at inf:
      D(i*n+1:nra+1:i*n+nn*nra) = inf*ones(1,nn);
    else
      D = distm(b(range,:),a);
    end
    F(range) = sumc(exp(-D*0.5./(h.^2)))'./(nra*alf*h^dim);

end

F = F + realmin;

return

