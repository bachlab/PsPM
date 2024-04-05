function split_sessions = pspm_cfg_split_sessions
    % Updated 11-03-2024 by Teddy
    % Initialise
    global settings
    if isempty(settings)
        pspm_init;
    end
    %% Data file
    datafile         = cfg_files;
    datafile.name    = 'Data File';
    datafile.tag     = 'datafile';
    datafile.num     = [1 1];
    %datafile.filter  = '\.(mat|MAT)$';
    datafile.help    = {[settings.datafilehelp,...
        ' Split sessions can handle only one data file.']};

    %% Marker channel
    mrk_chan         = pspm_cfg_channel_selector('marker');
    
    %% split auto
    split_auto          = cfg_const;
    split_auto.name     = 'Automatic';
    split_auto.tag      = 'auto';
    split_auto.val      = {0};
    split_auto.help     = {['Detect sessions according to longest distances ', ...
    'between markers.']};

    %% split manual
    split_manual        = cfg_entry;
    split_manual.name   = 'Marker';
    split_manual.tag    = 'marker';
    split_manual.strtype = 'i';
    split_manual.num    = [1 inf];
    split_manual.help   = {'Split sessions according to given marker id''s.'};

    %% Split behaviour
    split_behavior         = cfg_choice;
    split_behavior.name    = 'Split behavior';
    split_behavior.tag     = 'split_behavior';
    split_behavior.values  = {split_auto, split_manual};
    split_behavior.val     = {split_auto};
    split_behavior.help    = {['Choose whether sessions should be detected ', ...
    'automatically or if sessions should be split according to ', ...
    'given marker id''s.']};

    %% Missing epochs
    miss_epoch_false          = cfg_const;
    miss_epoch_false.name     = 'No missing epochs file';
    miss_epoch_false.tag      = 'no';
    miss_epoch_false.val      = {0};
    miss_epoch_false.help     = {'No missing epochs file to be processed.'};

    miss_epoch_true          = cfg_files;
    miss_epoch_true.name     = 'Add missing epochs file';
    miss_epoch_true.tag      = 'name';
    miss_epoch_true.num      = [1 1];
    miss_epoch_true.help     = {['The selected missing epochs file will be ',...
    'split as well.'], ['The input must be the name of a file containing missing ',...
    'epochs in seconds.']};

    missing_epoch         = cfg_choice;
    missing_epoch.name    = 'Missing epoch';
    missing_epoch.tag     = 'missing_epochs_file';
    missing_epoch.values  = {miss_epoch_false, miss_epoch_true};
    missing_epoch.val     = {miss_epoch_false};
    missing_epoch.help = {['A missing epochs file can be added here '...
    'and will be split in the same way as the PsPM data file. '...
    'Split sessions can handle up to one missing epoch file.']};

    %% Overwrite file
    overwrite         = cfg_menu;
    overwrite.name    = 'Overwrite Existing File';
    overwrite.tag     = 'overwrite';
    overwrite.val     = {false};
    overwrite.labels  = {'No', 'Yes'};
    overwrite.values  = {false, true};
    overwrite.help    = {'Overwrite if a file with the same name has existed?'};


    %% Executable branch
    split_sessions      = cfg_exbranch;
    split_sessions.name = 'Split Sessions';
    split_sessions.tag  = 'split_sessions';
    split_sessions.val  = {datafile,mrk_chan,split_behavior,missing_epoch,overwrite};
    split_sessions.prog = @pspm_cfg_run_split_sessions;
    split_sessions.vout = @pspm_cfg_vout_split_sessions;
    split_sessions.help = {['Split sessions, defined by trains of of markers. This function ' ...
    'is most commonly used to split fMRI sessions when a (slice or volume) pulse from the ' ...
    'MRI scanner has been recorded. In automatic mode, the function will identify trains of markers and detect ' ...
    'breaks in these marker sequences. In manual model, you can provide a vector of markers that are used ', ...
    'to split the file. The individual sessions will be written to new files ' ...
    'with a suffix ''_sn'', and the session number. You can choose one datafile and, optionally, ' ...
    'one missing epochs file, which will be split at the same points. By default, the function will use ', ...
    'the first marker channel. Alternatively, you can choose a marker channel number.']};

    function vout = pspm_cfg_vout_split_sessions(job)
        vout = cfg_dep;
        vout.sname      = 'Output File(s)';
        % this can be entered into any file selector
        vout.tgt_spec   = cfg_findspec({{'class','cfg_files'}});
        vout.src_output = substruct('()',{':'});
    end

    function out = pspm_cfg_run_split_sessions(job)
        datafile = job.datafile{1,1};
        markerchannel = pspm_cfg_channel_selector('run', job.chan);
        options = struct();
        options.overwrite = job.overwrite;
        if isfield(job.missing_epochs_file,'name')
            options.missing = job.missing_epochs_file.name{1,1};
        end
        % options.missing has a default value in pspm_options if
        % unspecified.
        if isfield(job.split_behavior, 'auto')
            options.splitpoints = [];
        elseif isfield(job.split_behavior, 'marker')
            options.splitpoints = job.split_behavior.marker;
        end
        out = pspm_split_sessions(datafile, markerchannel, options);
        if ~iscell(out)
            out = {out};
        end
    end
end
