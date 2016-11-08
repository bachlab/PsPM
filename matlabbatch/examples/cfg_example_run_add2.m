function out = cfg_example_run_add2(job)
% Example function that returns the sum of two numbers given in job.a in
% out. The output is referenced as out(1), this is defined in
% cfg_example_vout_add2.
%
% This code is part of a batch job configuration system for MATLAB. See 
%      help matlabbatch
% for a general overview.
%_______________________________________________________________________
% Copyright (C) 2007 Freiburg Brain Imaging

% Volkmar Glauche
% $Id$

rev = '$Rev$'; %#ok

out = sum(job.a);