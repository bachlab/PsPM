function out = pspm_cfg_run_emg_pp(job)
% Executes pspm_emg_pp

% $Id$
% $Rev$

pspm_emg_pp(job.datafile);

out = job.datafile;