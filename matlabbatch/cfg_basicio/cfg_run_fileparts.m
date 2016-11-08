function out = cfg_run_fileparts(job)

% Run fileparts on a list of files.
%
% This code is part of a batch job configuration system for MATLAB. See 
%      help matlabbatch
% for a general overview.
%_______________________________________________________________________
% Copyright (C) 2007 Freiburg Brain Imaging

% Volkmar Glauche
% $Id$

rev = '$Rev$'; %#ok

[out.p, out.n, out.e] = cellfun(@fileparts, job.files, 'UniformOutput', false);
out.up = unique(out.p);