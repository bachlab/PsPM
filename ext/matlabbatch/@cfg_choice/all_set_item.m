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
% $Id: all_set_item.m 380 2016-11-08 07:47:23Z tmoser $

rev = '$Rev: 380 $'; %#ok
ok = numel(item.cfg_item.val) == 1;
