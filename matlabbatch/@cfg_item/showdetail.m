function str = showdetail(item)

% function str = showdetail(item)
% Generic showdetail function for cfg_item classes. It displays the
% name, tag, class and default function call for this item..
%
% This code is part of a batch job configuration system for MATLAB. See 
%      help matlabbatch
% for a general overview.
%_______________________________________________________________________
% Copyright (C) 2007 Freiburg Brain Imaging

% Volkmar Glauche
% $Id: showdetail.m 701 2015-01-22 14:36:13Z tmoser $

rev = '$Rev: 701 $'; %#ok

str{1,1} = sprintf('Name   : %s', item.name);
str{2,1} = sprintf('Tag    : %s', gettag(item));
if ~isempty(item.def)
    str{3} = sprintf('Default: %s', func2str(item.def));
end
