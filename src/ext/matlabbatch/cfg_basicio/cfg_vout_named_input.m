function dep = cfg_vout_named_input(job)

% Define virtual output for cfg_run_named_input. This input can be assigned
% to any cfg_entry input item.
%
% This code is part of a batch job configuration system for MATLAB. See 
%      help matlabbatch
% for a general overview.
%_______________________________________________________________________
% Copyright (C) 2007 Freiburg Brain Imaging

% Volkmar Glauche
% $Id: cfg_vout_named_input.m 380 2016-11-08 07:47:23Z tmoser $

rev = '$Rev: 380 $'; %#ok

dep = cfg_dep;
dep.sname = job.name;
dep.src_output = substruct('.','input');
dep.tgt_spec   = cfg_findspec({{'class','cfg_entry'}});