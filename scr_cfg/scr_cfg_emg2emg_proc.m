function emg2emg_proc = scr_cfg_emg2emg_proc
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
datafile.help    = {['Specify data file. Specify data file. The processed' ...
    'data will be written to a new channel in this file.']};

% Executable Branch
emg2emg_proc = cfg_exbranch;
emg2emg_proc.name = 'Convert EMG to EMG processed';
emg2emg_proc.tag  = 'emg2emg_proc';
emg2emg_proc.val  = {datafile};
emg2emg_proc.prog = @scr_cfg_run_emg2emg_proc;
emg2emg_proc.vout = @scr_cfg_vout_emg2emg_proc;
emg2emg_proc.help = {''};

function vout = scr_cfg_vout_emg2emg_proc(job)
vout = cfg_dep;
vout.sname      = 'Output File';
vout.tgt_spec = cfg_findspec({{'class','cfg_files'}});
vout.src_output = substruct('()',{':'});