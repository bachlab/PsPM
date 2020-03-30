function out = cfg_example_run_div(job)
% Example function that returns the mod and rem of two numbers given in
% job.a and job.b in out.mod and out.rem.
%
% This code is part of a batch job configuration system for MATLAB. See 
%      help matlabbatch
% for a general overview.
%_______________________________________________________________________
% Copyright (C) 2007 Freiburg Brain Imaging

% Volkmar Glauche
% $Id: cfg_example_run_div.m 380 2016-11-08 07:47:23Z tmoser $

rev = '$Rev: 380 $'; %#ok

out.mod = mod(job.a, job.b);
out.rem = rem(job.a, job.b);