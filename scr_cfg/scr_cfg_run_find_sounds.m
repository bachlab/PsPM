function [out] = scr_cfg_run_find_sounds(job)

out = NaN;

file = job.datafile{1};

if isfield(job.chan, 'chan_nr')
   options.sndchannel = job.chan.chan_nr;
end;

options.threshold = job.threshold;

f = fieldnames(job.output);
switch f{1}
    case 'new_chan'
        
        options.addchannel = true;
        options.diagnostics = false;
        [sts, infos] = scr_find_sounds(file, options);
        out = infos.channel;
        
    case 'diagnostic'
        d = job.output.diagnostic;
        if d.new_corrected_chan
            options.addchannel = true;
            options.channeloutput = 'corrected';
        end;
        
        if isfield(d.marker_chan, 'marker_nr')
            options.trigchannel = d.marker_nr;
        end;
        
        options.maxdelay = d.max_delay;
        
        diag_out = fieldnames(d.diag_output);
        switch diag_out{1}
            case 'hist_plot'
                options.plot = true;
            case 'text_only'
                options.plot = false;
        end;
        
        [sts, infos] = scr_find_sounds(file, options);
        if isfield(infos, 'channel')
            out = infos.channel;
        end;
        
end;


