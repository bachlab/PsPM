function checkstr = subsasgn_checkstr(item, subs)

% function checkstr = subsasgn_checkstr(item, subs)
% Preformat a warning message suitable for all subsasgn_check functions
%
% This code is part of a batch job configuration system for MATLAB. See 
%      help matlabbatch
% for a general overview.
%_______________________________________________________________________
% Copyright (C) 2007 Freiburg Brain Imaging

% Volkmar Glauche
% $Id: subsasgn_checkstr.m 380 2016-11-08 07:47:23Z tmoser $

rev = '$Rev: 380 $'; %#ok

checkstr = sprintf('Item ''%s'', field ''%s''', subsref(item,substruct('.','name')), subs(1).subs);
