function out = scr_cfg_run_emg_pp(job)
% Executes scr_emg_pp

% $Id$
% $Rev$

scr_emg_pp(job.datafile);

out = job.datafile;