function [out] = pspm_cfg_run_pupil_correct(job)
    % Matlabbatch run function for pspm_pupil_correct_eyelink
    %__________________________________________________________________________
    % (C) 2019 Eshref Yozdemir (University of Zurich)

    fn = job.datafile{1};
    options = struct();

    options.screen_size_px = job.screen_size_px;
    options.screen_size_mm = job.screen_size_mm;
    options.mode = fieldnames(job.mode);
    if strcmp(options.mode, 'auto')
        options.C_z = job.mode.auto.C_z;
    else
        options.C_x = job.mode.manual.C_x;
        options.C_y = job.mode.manual.C_y;
        options.C_z = job.mode.manual.C_z;
        options.S_x = job.mode.manual.S_x;
        options.S_y = job.mode.manual.S_y;
        options.S_z = job.mode.manual.S_z;
    end
    chan_key = fieldnames(job.channel);
    chan_key = chan_key{1};
    options.channel = job.channel.(chan_key);
    options.channel_action = job.channel_action;

    [sts, out{1}] = pspm_pupil_correct_eyelink(fn, options);
end
