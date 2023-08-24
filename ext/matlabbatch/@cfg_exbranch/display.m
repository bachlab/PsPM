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
% $Id: display.m 380 2016-11-08 07:47:23Z tmoser $

rev = '$Rev: 380 $'; %#ok

disp(' ');
disp([inputname(1),' = ']);
disp(' ');
disp(item);
disp(' ');
