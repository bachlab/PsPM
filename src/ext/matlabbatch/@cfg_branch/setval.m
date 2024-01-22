function item = setval(item, val, dflag)

% function item = setval(item, val, dflag)
% prevent changes to item.val via setval for branches
%
% This code is part of a batch job configuration system for MATLAB. See 
%      help matlabbatch
% for a general overview.
%_______________________________________________________________________
% Copyright (C) 2007 Freiburg Brain Imaging

% Volkmar Glauche
% $Id: setval.m 380 2016-11-08 07:47:23Z tmoser $

rev = '$Rev: 380 $'; %#ok

cfg_message('matlabbatch:setval', 'Setting val{} of branch items via setval() not permitted.');