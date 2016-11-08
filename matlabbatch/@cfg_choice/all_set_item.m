function ok = all_set_item(item)

% function ok = all_set_item(item)
% Perform within-item all_set check. For choices, this is true, if item.val
% has one element.
%
% This code is part of a batch job configuration system for MATLAB. See
%      help matlabbatch
% for a general overview.
%_______________________________________________________________________
% Copyright (C) 2007 Freiburg Brain Imaging

% Volkmar Glauche
% $Id$

rev = '$Rev$'; %#ok
ok = numel(item.cfg_item.val) == 1;
