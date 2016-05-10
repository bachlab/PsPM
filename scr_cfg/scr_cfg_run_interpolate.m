function out = scr_cfg_run_interpolate(job)

options = struct();
fn = job.datafiles;

if isfield(job.mode, 'file')
    options.overwrite = job.mode.file.overwrite;
    options.newfile = true;
elseif isfield(job.mode, 'channel')
    options.channels = cell(size(job.datafiles));
    options.channels{:} = job.mode.channel.source_chan;
    options.newfile = false;
    
    if isfield(job.mode.channel.mode, 'new_chan')
        options.replace_channels = false;
    elseif isfield(job.mode.channel.mode, 'replace_chan')
        options.replace_channels = true;
    end;
    
end;

options.extrapolate = job.extrapolate;

[sts, out] = scr_interpolate(fn, options);