function [emg_pp] = scr_cfg_emg_pp
% function to process emg data which leads to emg_proc data
% 

% $Id$
% $Rev$

% Data File
datafile         = cfg_files;
datafile.name    = 'Data File';
datafile.tag     = 'datafile';
datafile.num     = [1 1];
%datafile.filter  = '.*\.(mat|MAT)$';
datafile.help    = {['Select data file. The processed ' ...
    'data will be written to a new file.']};

% Executable Branch
emg_pp = cfg_exbranch;
emg_pp.name = 'Preprocess startle eyeblink EMG';
emg_pp.tag  = 'emg_pp';
emg_pp.val  = {datafile};
emg_pp.prog = @scr_cfg_run_emg_pp;
emg_pp.vout = @scr_cfg_vout_emg_pp;
emg_pp.help = {'Preprocess startle eyeblink EMG ...'};

function vout = scr_cfg_vout_emg_pp(job)
vout = cfg_dep;
vout.sname      = 'Output File';
vout.tgt_spec = cfg_findspec({{'class','cfg_files'}});
vout.src_output = substruct('()',{':'});