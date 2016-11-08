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
% $Id$

rev = '$Rev$'; %#ok

cfg_message('matlabbatch:setval', 'Setting val{} of branch items via setval() not permitted.');