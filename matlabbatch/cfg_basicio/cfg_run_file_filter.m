function out = cfg_run_file_filter(job)

% Return filtered files.
%
% This code is part of a batch job configuration system for MATLAB. See 
%      help matlabbatch
% for a general overview.
%_______________________________________________________________________
% Copyright (C) 2007 Freiburg Brain Imaging

% Volkmar Glauche
% $Id: cfg_run_file_filter.m 701 2015-01-22 14:36:13Z tmoser $

rev = '$Rev: 701 $'; %#ok

out.files = cfg_getfile('filter', job.files, job.typ, job.filter, job.frames);
