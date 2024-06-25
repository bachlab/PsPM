function display = pspm_cfg_display

%% Data file
datafile         = pspm_cfg_selector_datafile;
datafile.help    = {'Specify data file to display.'};

%% Executable branch
display      = cfg_exbranch;
display.name = 'Display Data';
display.tag  = 'display';
display.val  = {datafile};
display.prog = @pspm_cfg_run_display;
display.help = pspm_cfg_help_format('pspm_display');


    function pspm_cfg_run_display(job)
        pspm_display(job.datafile{1});
    end
end
