function [flag] = isweird(X)
% true if matrix X contains any Infs, NaNs or non real entries
% function [flag] = isweird(X)
% IN:
%   - X: N-D matrix (or cell array of matrices) to be checked
% OUT:
%   - flag: 1 id X is weird, 0 if not, -1 if not numeric (e.g. string)

if iscell(X)
%     ok = 1;
%     for i=1:numel(X)
%         ok = ok & ~isweird(X{i});
%     end
%     flag = ~ok;
    flag = any(cell2mat(cellfun(@isweird,X,'UniformOutput',false)));
elseif isstruct(X)
    ok = 1;
    fn = fieldnames(X);
    for i=1:length(fn)
        ok = ok & ~isweird(getfield(X,fn{i}));
    end
    flag = 1*(~ok);
elseif isnumeric(X) || islogical(X)
    flag = 0;
    if any(isinf(X(:)) | isnan(X(:)) | ~isreal(X(:)))
        flag = 1;
    end
else
    flag = -1;
end

