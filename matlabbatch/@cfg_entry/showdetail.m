function str = showdetail(item)

% function str = showdetail(item)
% Display details for a cfg_files item.
%
% This code is part of a batch job configuration system for MATLAB. See 
%      help matlabbatch
% for a general overview.
%_______________________________________________________________________
% Copyright (C) 2007 Freiburg Brain Imaging

% Volkmar Glauche
% $Id: showdetail.m 701 2015-01-22 14:36:13Z tmoser $

rev = '$Rev: 701 $'; %#ok

str = showdetail(item.cfg_item);
str{end+1} = 'Class  : cfg_entry';
str{end+1} = 'An input item.';
str = [str; gencode(item.strtype, 'strtype:')];
str = [str; gencode(item.num,     'num    :')];
if ~isempty(item.extras)
    str{end+1} = 'Its contents must match the following additional criteria:';
    str = [str; gencode(item.extras,  'extras :')'];
end