function out = scr_cfg_run_emg2emg_proc(job)
% Executes scr_emg_pp

% $Id$
% $Rev$

scr_emg_pp(job.datafile);

out = job.datafile;