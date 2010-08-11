function dims=getdims(w)

if nargin<1|~ismapping(w)
    error('Trained mapping expected');
end
betaTruncateThreshold=1e-8;

numFeatures=get(w,'size_in');

d=+w;

if isfield(d,'beta')
    numSubspaces=1;
    if isfield(d,'numSubspaces')
        numSubspaces=d.numSubspaces;
    end
    dims=find(any(reshape(d.beta>betaTruncateThreshold,numFeatures,numSubspaces),2))';
else
    dims=1:numFeatures;
end

return