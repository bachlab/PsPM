function str = showdetail(item)

% function str = showdetail(item)
% Display details for a cfg_choice and all of its options.
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
str{end+1} = 'Class  : cfg_choice';
str{end+1} = ['Set one of the options listed as a struct with a ' ...
              'single field:'];
% Display detailed help for each cfg_choice value item
tags = tagnames(item, true);
for k = 1:numel(tags)
    str{end+1} = sprintf('.%s', tags{k});
end;