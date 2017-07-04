function ltop = cfg_ui_getListboxTop(obj, val, maxval)
% Get a safe value for ListboxTop property while keeping previous settings
% if possible.
% obj     handle of Listbox object
% val     new Value property
% maxval  new number of lines in obj
%
% This code is part of a batch job configuration system for MATLAB. See 
%      help matlabbatch
% for a general overview.
%_______________________________________________________________________
% Copyright (C) 2007 Freiburg Brain Imaging

% Volkmar Glauche
% $Id: cfg_ui_getListboxTop.m 380 2016-11-08 07:47:23Z tmoser $

rev = '$Rev: 380 $';  %#ok<NASGU>

oltop = get(obj, 'ListboxTop');
ltop  = min([max(oltop,1), max(val-1,1), maxval]);

