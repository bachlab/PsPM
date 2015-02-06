function disp(obj)

% function disp(obj)
% Disp a configuration dependency
%
% This code is part of a batch job configuration system for MATLAB. See 
%      help matlabbatch
% for a general overview.
%_______________________________________________________________________
% Copyright (C) 2007 Freiburg Brain Imaging

% Volkmar Glauche
% $Id: disp.m 701 2015-01-22 14:36:13Z tmoser $

rev = '$Rev: 701 $'; %#ok

sz = size(obj);
fprintf('%s object: ', class(obj));
if length(sz)>4,
    fprintf('%d-D\n',length(sz));
else
    for i=1:(length(sz)-1),
        fprintf('%d-by-',sz(i));
    end;
    fprintf('%d\n',sz(end));
end;
if prod(sz)==1,
    so = struct(obj);
    disp(so);
end;
return;
