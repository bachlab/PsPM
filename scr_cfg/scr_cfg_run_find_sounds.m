function [out] = scr_cfg_run_find_sounds(job)

options = struct();

file = job.datafile;
options.addChannel = true;
options.threshold = job.options.threshold;

if isfield(job.options.chan, 'chan_nr')
   options.sndchannel = job.chan.chan_nr;
end;

scr_find_sounds(file);