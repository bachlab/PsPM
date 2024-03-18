function [pp_scr] = pspm_cfg_pp_scr
    % function for pre processing (PP) skin conductance response (SCR)
    %

    % $Id$
    % $Rev$

    % Initialise
    global settings
    if isempty(settings)
        pspm_init;
    end

    help_chan = 'Choose whether to add the new channels or replace a channel previously added by this method.';

    % Data File
    datafile         = cfg_files;
    datafile.name    = 'Data File';
    datafile.tag     = 'datafile';
    datafile.num     = [1 1];
    %datafile.filter  = '.*\.(mat|MAT)$';
    datafile.help    = {['Specify the PsPM datafile containing ', ...
    'the SCR data channel.'],' ',settings.datafilehelp};

    %% simple SCR quality correction
    scr_min          = cfg_entry;
    scr_min.name     = 'Minimum value';
    scr_min.tag      = 'min';
    scr_min.strtype  = 'r';
    scr_min.num      = [1 1];
    scr_min.val      = {0.05};
    scr_min.help     = {'Minimum SCR value in microsiemens.'};

    scr_max          = cfg_entry;
    scr_max.name     = 'Maximum value';
    scr_max.tag      = 'max';
    scr_max.strtype  = 'r';
    scr_max.num      = [1 1];
    scr_max.val      = {60};
    scr_max.help     = {'Maximum SCR value in microsiemens.'};

    scr_slope          = cfg_entry;
    scr_slope.name     = 'Maximum slope';
    scr_slope.tag      = 'slope';
    scr_slope.strtype  = 'r';
    scr_slope.num      = [1 1];
    scr_slope.val      = {10};
    scr_slope.help     = {'Maximum SCR slope in microsiemens per second.'};

    % Options
    missing_epochs_no_filename          = cfg_const;
    missing_epochs_no_filename.name     = 'Do not write to file';
    missing_epochs_no_filename.tag      = 'no_missing_epochs';
    missing_epochs_no_filename.val      = {0};
    missing_epochs_no_filename.help     = {'Do not store artefacts epochs to file'};

    missing_epochs_file_name          = cfg_entry;
    missing_epochs_file_name.name     = 'File name';
    missing_epochs_file_name.tag      = 'filename';
    missing_epochs_file_name.strtype  = 's';
    missing_epochs_file_name.num      = [ 1 Inf ];
    missing_epochs_file_name.help     = {['Specify the name of the file where to store artefact epochs. ',...
                                        'Provide only the name and not the extension, ',...
                                        'the file will be stored as a .mat file']};

    missing_epochs_file_path         = cfg_files;
    missing_epochs_file_path.name    = 'Output Directory';
    missing_epochs_file_path.tag     = 'outdir';
    missing_epochs_file_path.filter  = 'dir';
    missing_epochs_file_path.num     = [1 1];
    missing_epochs_file_path.help    = {'Specify the directory where the .mat file with artefact epochs will be written.'};

    missing_epochs_file      = cfg_exbranch;
    missing_epochs_file.name = 'Write to filename';
    missing_epochs_file.tag  = 'write_to_file';
    missing_epochs_file.val  = {missing_epochs_file_name, missing_epochs_file_path};
    missing_epochs_file.help = {['If you choose to store the artefact epochs please specify a filename ',...
                                'as well as an output directory. When giving the filename do not specify ',...
                                'any extension, the artefact epochs will be stored as .mat file.']};

    missing_epochs         = cfg_choice;
    missing_epochs.name    = 'Missing epochs file';
    missing_epochs.tag     = 'missing_epochs';
    missing_epochs.val     = {missing_epochs_no_filename};
    missing_epochs.values  = {missing_epochs_no_filename, missing_epochs_file};
    missing_epochs.help    = {'Specify if you want to store the artefact epochs in a separate file of not.', ...
                            'Default: artefact epochs are not stored.'};

    scr_deflection_threshold         = cfg_entry;
    scr_deflection_threshold.name    = 'Deflection threshold';
    scr_deflection_threshold.tag     = 'deflection_threshold';
    scr_deflection_threshold.strtype = 'r';
    scr_deflection_threshold.num     = [1 1];
    scr_deflection_threshold.val     = {0.1};
    scr_deflection_threshold.help    = {['Define an threshold in original data units for a slope to pass to be considerd in the filter. ', ...
                                        'This is useful, for example, with oscillatory wave data. ', ...
                                        'The slope may be steep due to a jump between voltages but we ', ...
                                        'likely do not want to consider this to be filtered. ', ...
                                        'A value of 0.1 would filter oscillatory behaviour with threshold less than 0.1v but not greater.' ],...
                                        'Default: 0.1', ...
                                        };

    scr_data_island_threshold         = cfg_entry;
    scr_data_island_threshold.name    = 'Data island threshold';
    scr_data_island_threshold.tag     = 'data_island_threshold';
    scr_data_island_threshold.strtype = 'r';
    scr_data_island_threshold.num     = [1 1];
    scr_data_island_threshold.val     = {0};
    scr_data_island_threshold.help    = {['A float in seconds to determine the maximum length of unfiltered data between epochs. ', ...
                                        'If an island exists for less than the threshold it will also be filtered'], ...
                                        'Default: 0 s - will take no effect on filter', ...
                                        };

    scr_expand_epochs         = cfg_entry;
    scr_expand_epochs.name    = 'Expand epochs';
    scr_expand_epochs.tag     = 'expand_epochs';
    scr_expand_epochs.strtype = 'r';
    scr_expand_epochs.num     = [1 1];
    scr_expand_epochs.val     = {0.5};
    scr_expand_epochs.help    = {'A float in seconds to determine by how much data on the flanks of artefact epochs will be removed.', ...
                                'Default: 0.5 s', ...
                                };

    % Channel
    chan                    = pspm_cfg_channel_selector('SCR');

    % Step size for clipping detection
    clipping_step_size                   = cfg_entry;
    clipping_step_size.name              = 'Step size for clipping detection';
    clipping_step_size.tag               = 'clipping_step_size';
    clipping_step_size.strtype           = 'r';
    clipping_step_size.num               = [1 1];
    clipping_step_size.val               = {2};
    clipping_step_size.help              = {['A numerical value specifying the step size in moving average algorithm for detecting clipping'], ...
                                            'Default: 2 s'};

    % Threshold for clipping detection
    clipping_threshold                   = cfg_entry;
    clipping_threshold.name              = 'Threshold for clipping detection';
    clipping_threshold.tag               = 'clipping_threshold';
    clipping_threshold.strtype           = 'r';
    clipping_threshold.num               = [1 1];
    clipping_threshold.val               = {0.1};
    clipping_threshold.help              = {['A float between 0 and 1 specifying the proportion of local maximum in a step'],...
                                            'Default: 0.1'};

    clipping_detection         = cfg_exbranch;
    clipping_detection.name    = 'Clipping detection';
    clipping_detection.tag     = 'clipping_detection';
    clipping_detection.val     = {clipping_step_size, clipping_threshold};
    clipping_detection.help    = {'Specify parameters for clipping detection.'};

    % Channel action
    chan_action             = cfg_menu;
    chan_action.name        = 'Channel action';
    chan_action.tag         = 'chan_action';
    chan_action.values      = {'add', 'replace'};
    chan_action.labels      = {'Add', 'Replace'};
    chan_action.val         = {'replace'};
    chan_action.help        = {help_chan};

    % Executable Branch
    pp_scr              = cfg_exbranch;
    pp_scr.name         = 'Preprocessing SCR';
    pp_scr.tag          = 'pp_scr';
    pp_scr.val          = {datafile, ...
                            scr_min, ...
                            scr_max, ...
                            scr_slope, ...
                            scr_deflection_threshold, ...
                            scr_data_island_threshold, ...
                            scr_expand_epochs, ...
                            chan, ...
                            clipping_detection, ...
                            missing_epochs, ...
                            chan_action,...
                            };
    pp_scr.prog         = @pspm_cfg_run_scr_pp;
    pp_scr.vout         = @pspm_cfg_vout_scr_pp;
    pp_scr.help         = {'Pre processing (PP) skin conductance response (SCR).',...
    ['See I. R. Kleckner et al., "Simple, Transparent, and' ...
    'Flexible Automated Quality Assessment Procedures for Ambulatory Electrodermal Activity Data," in ' ...
    'IEEE Transactions on Biomedical Engineering, vol. 65, no. 7, pp. 1460--1467, July 2018.']};

    function vout = pspm_cfg_vout_scr_pp(~)
        vout = cfg_dep;
        vout.sname      = 'Output Channel';
        vout.tgt_spec = cfg_findspec({{'class','cfg_entry'}});
        vout.src_output = substruct('()',{':'});
    end

    function out = pspm_cfg_run_scr_pp(job)
        scr_pp_datafile = job.datafile{1};
        scr_pp_options = struct();
        scr_pp_options.min = job.min;
        scr_pp_options.max = job.max;
        scr_pp_options.slope = job.slope;
        scr_pp_options.deflection_threshold = job.deflection_threshold;
        scr_pp_options.expand_epochs = job.expand_epochs;
        scr_pp_options.channel = pspm_cfg_channel_selector('run', job.channel);
        scr_pp_options.clipping_step_size = job.clipping_detection.clipping_step_size;
        scr_pp_options.clipping_threshold = job.clipping_detection.clipping_threshold;
        if isfield(job.missing_epochs, 'write_to_file')
            scr_pp_options.missing_epochs_filename = [job.missing_epochs.write_to_file.outdir{1},...
                '/', job.missing_epochs.write_to_file.filename, '.mat'];
            length_temp = length(scr_pp_options.missing_epochs_filename);
            if length_temp > 7
                if strcmp((scr_pp_options.missing_epochs_filename(length_temp-7: length_temp)),'.mat.mat')
                    scr_pp_options.missing_epochs_filename(length_temp-3:length_temp) = [];
                end
            end

        end
        scr_pp_options.channel_action = job.chan_action;
        [sts, output] = pspm_scr_pp(scr_pp_datafile, scr_pp_options);
        if sts == 1
            % out = {output.channel};
            out = output{1};
        else
            out = {-1};
        end
    end

end
