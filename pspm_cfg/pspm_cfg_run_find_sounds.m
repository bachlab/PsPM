function [out] = pspm_cfg_run_find_sounds(job)

% $Id$
% $Rev$

out = NaN;

file = job.datafile{1};

if isfield(job.chan, 'chan_nr')
   options.sndchannel = job.chan.chan_nr;
end

if isfield(job.roi, 'region')
    options.roi = job.roi.region;
end

options.threshold = job.threshold;
options.channel_action = 'none';

f = fieldnames(job.output);
switch f{1}
    case 'create_chan'
        options.diagnostics = false;
        options.channel_action = job.output.create_chan.channel_action;
        
        [~, infos] = pspm_find_sounds(file, options);
        out = infos.channel;
        
    case 'diagnostic'
        d = job.output.diagnostic;
        if isfield(d.create_corrected_chan, 'yes')
            options.channel_action = d.create_corrected_chan.yes.channel_action;
            options.channel_output = 'corrected';
        end
        
        if isfield(d.marker_chan, 'marker_nr')
            options.trigchannel = d.marker_nr;
        end
        
        if job.output.diagnostic.n_sounds > 0
            options.expectedSoundCount = job.output.diagnostic.n_sounds;
        end
        
        options.maxdelay = d.max_delay;
        
        diag_out = fieldnames(d.diag_output);
        switch diag_out{1}
            case 'hist_plot'
                options.plot = true;
            case 'text_only'
                options.plot = false;
        end
        
        [~, infos] = pspm_find_sounds(file, options);
        if isfield(infos, 'channel')
            out = infos.channel;
        end
        
end


