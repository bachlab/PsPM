function out = pspm_cfg_run_trim(job)

% $Id$
% $Rev$


options = struct;
options.overwrite = job.overwrite;

if isfield(job.ref,'ref_file')
    from = job.ref.ref_file.from;
    to = job.ref.ref_file.to;
    ref = 'file';
elseif isfield(job.ref,'ref_mrk')
    from = job.ref.ref_mrk.from;
    to = job.ref.ref_mrk.to;
    ref = 'marker';
    if isfield(job.ref.ref_mrk.mrk_chan,'chan_nr')
        options.marker_chan_num = job.ref.ref_mrk.mrk_chan.chan_nr;
    end
elseif isfield(job.ref,'ref_any_mrk')
    from = job.ref.ref_any_mrk.from.mrksec;
    to = job.ref.ref_any_mrk.to.mrksec;
    ref = [job.ref.ref_any_mrk.from.mrkno ...
        job.ref.ref_any_mrk.to.mrkno];
    if isfield(job.ref.ref_any_mrk.mrk_chan,'chan_nr')
        options.marker_chan_num = job.ref.ref_any_mrk.mrk_chan.chan_nr;
    end
elseif isfield(job.ref,'ref_mrk_vals')
    from =job.ref.ref_mrk_vals.from.mrksec;
    to =job.ref.ref_mrk_vals.to.mrksec;
    ref = {job.ref.ref_mrk_vals.from.mrval,...
        job.ref.ref_mrk_vals.to.mrval};
    if isfield(job.ref.ref_mrk_vals.mrk_chan,'chan_nr')
        options.marker_chan_num = job.ref.ref_mrk_vals.mrk_chan.chan_nr;
    end
else
    error('Reference invalid');
end

if ~isfield(options,'marker_chan_num')
    options.marker_chan_num = 0; % Default value
end

out = pspm_trim(job.datafile, from, to, ref, options);
if ~iscell(out)
    out = {out};
end