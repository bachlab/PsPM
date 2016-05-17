function [out] = scr_cfg_run_pupil_data_convert(job)

channel_action = job.channel_action;
fn = job.datafile{1};

for i=1:numel(job.conversion)
    options = struct();
    options.channel_action = channel_action;
    chan = job.conversion(i).channel;
    if isfield(job.conversion(i).mode, 'au2mm')
        options.offset = job.conversion(i).mode.au2mm.offset;
        options.multiplicator = job.conversion(i).mode.au2mm.multiplicator;
        scr_convert_au2mm(fn, chan, options);
    elseif isfield(job.conversion(i).mode, 'area2diameter')
        scr_convert_area2diameter(fn, chan, options);
    end;        
end;

out = 1;