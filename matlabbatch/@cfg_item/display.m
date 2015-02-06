function display(item)

% function display(item)
% Display a configuration object
%
% This code is part of a batch job configuration system for MATLAB. See 
%      help matlabbatch
% for a general overview.
%_______________________________________________________________________
% Copyright (C) 2007 Freiburg Brain Imaging

% Volkmar Glauche
% $Id: display.m 701 2015-01-22 14:36:13Z tmoser $

rev = '$Rev: 701 $'; %#ok

disp(' ');
disp([inputname(1),' = ']);
disp(' ');
disp(item);
disp(' ');
