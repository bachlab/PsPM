function [out] = pspm_cfg_run_pupil_preprocess(job)
    % Matlabbatch run function for pspm_pupil_pp
    %__________________________________________________________________________
    % (C) 2019 Eshref Yozdemir (University of Zurich)

    fn = job.datafile{1};
    options = struct();

    chankey = fieldnames(job.chan);
    chankey = chankey{1};
    options.chan = job.chan.(chankey);

    chankey = fieldnames(job.chan_combine);
    chankey = chankey{1};
    options.chan_combine = job.chan_combine.(chankey);

    settkey = fieldnames(job.settings);
    settkey = settkey{1};
    if strcmp(settkey, 'custom_settings')
        options.custom_settings = job.settings.custom_settings;
    end

    options.segments = {};
    for i = 1:numel(job.segments)
        options.segments{end + 1} = job.segments(i);
    end

    options.chan_action = job.chan_action;
    options.plot_data = job.plot_data;

    [sts, out{1}] = pspm_pupil_pp(fn, options);
end
