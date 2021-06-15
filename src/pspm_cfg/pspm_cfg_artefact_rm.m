function artefact_rm = pspm_cfg_artefact_rm

    % $Id$
    % $Rev$

    % Initialise
    global settings
    if isempty(settings)
        pspm_init;
    end

    %% Global items
    chan_nr         = cfg_entry;
    chan_nr.name    = 'Channel Number';
    chan_nr.tag     = 'chan_nr';
    chan_nr.strtype = 'i';
    chan_nr.num     = [1 Inf];
    chan_nr.help    = {''};

    %% Medianfilter
    nr_time_pt         = cfg_entry;
    nr_time_pt.name    = 'Number of Time Points';
    nr_time_pt.tag     = 'nr_time_pt';
    nr_time_pt.strtype = 'i';
    nr_time_pt.num     = [1 1];
    nr_time_pt.help    = {'Number of time points over which the median is taken.'};

    median         = cfg_branch;
    median.name    = 'Median Filter';
    median.tag     = 'median';
    median.val     = {nr_time_pt};
    median.help    = {''};

    %% 1st order butterworth LP filter
    freq         = cfg_entry;
    freq.name    = 'Cutoff Frequency';
    freq.tag     = 'freq';
    freq.strtype = 'r';
    freq.num     = [1 1];
    freq.check   = @pspm_cfg_check_artefact_rm_freq;
    freq.help    = {'Cutoff requency hast to be at least 20Hz.'};

    butter         = cfg_branch;
    butter.name    = 'Butterworth Lowpass Filter';
    butter.tag     = 'butter';
    butter.val  = {freq};
    butter.help    = {'1st Order Butterworth Low Pass Filter'};

    %% simple SCR quality correction
    scr_pp_min          = cfg_entry;
    scr_pp_min.name     = 'Minimum value';
    scr_pp_min.tag      = 'min';
    scr_pp_min.strtype  = 'r';
    scr_pp_min.num      = [1 1];
    scr_pp_min.val      = {0.05};
    scr_pp_min.help     = {'Minimum SCR value in microsiemens.'};

    scr_pp_max          = cfg_entry;
    scr_pp_max.name     = 'Maximum value';
    scr_pp_max.tag      = 'max';
    scr_pp_max.strtype  = 'r';
    scr_pp_max.num      = [1 1];
    scr_pp_max.val      = {60};
    scr_pp_max.help     = {'Maximum SCR value in microsiemens.'};

    scr_pp_slope          = cfg_entry;
    scr_pp_slope.name     = 'Maximum slope';
    scr_pp_slope.tag      = 'slope';
    scr_pp_slope.strtype  = 'r';
    scr_pp_slope.num      = [1 1];
    scr_pp_slope.val      = {10};
    scr_pp_slope.help     = {'Maximum SCR slope in microsiemens per second.'};

    scr_pp_missing_epochs_no_filename          = cfg_const;
    scr_pp_missing_epochs_no_filename.name     = 'Do not write to file';
    scr_pp_missing_epochs_no_filename.tag      = 'no_missing_epochs';
    scr_pp_missing_epochs_no_filename.val      = {0};
    scr_pp_missing_epochs_no_filename.help     = {'Do not store artefacts epochs to file'};

    scr_pp_missing_epochs_file_name          = cfg_entry;
    scr_pp_missing_epochs_file_name.name     = 'File name';
    scr_pp_missing_epochs_file_name.tag      = 'filename';
    scr_pp_missing_epochs_file_name.strtype  = 's';
    scr_pp_missing_epochs_file_name.num      = [ 1 Inf ];
    scr_pp_missing_epochs_file_name.help     = {['Specify the name of the file where to store artefact epochs. ',...
    'Provide only the name and not the extension, the file will be stored as a .mat file']};

    scr_pp_missing_epochs_file_path         = cfg_files;
    scr_pp_missing_epochs_file_path.name    = 'Output Directory';
    scr_pp_missing_epochs_file_path.tag     = 'outdir';
    scr_pp_missing_epochs_file_path.filter  = 'dir';
    scr_pp_missing_epochs_file_path.num     = [1 1];
    scr_pp_missing_epochs_file_path.help    = {'Specify the directory where the .mat file with artefact epochs will be written.'};

    scr_pp_missing_epochs_file      = cfg_exbranch;
    scr_pp_missing_epochs_file.name = 'Write to filename';
    scr_pp_missing_epochs_file.tag  = 'write_to_file';
    scr_pp_missing_epochs_file.val  = {scr_pp_missing_epochs_file_name, scr_pp_missing_epochs_file_path};
    scr_pp_missing_epochs_file.help = {['If you choose to store the artefact epochs please specify a filename ',...
    'as well as an output directory. When giving the filename do not specify ',...
    'any extension, the artefact epochs will be stored as .mat file.']};

    scr_pp_missing_epochs         = cfg_choice;
    scr_pp_missing_epochs.name    = 'Missing epochs file';
    scr_pp_missing_epochs.tag     = 'missing_epochs';
    scr_pp_missing_epochs.val     = {scr_pp_missing_epochs_no_filename};
    scr_pp_missing_epochs.values  = {scr_pp_missing_epochs_no_filename, scr_pp_missing_epochs_file};
    scr_pp_missing_epochs.help    = {'Specify if you want to store the artefact epochs in a separate file of not.', ...
    'Default: artefact epochs are not stored.'};

    scr_pp_deflection_threshold         = cfg_entry;
    scr_pp_deflection_threshold.name    = 'Deflection threshold';
    scr_pp_deflection_threshold.tag     = 'deflection_threshold';
    scr_pp_deflection_threshold.strtype = 'r';
    scr_pp_deflection_threshold.num     = [1 1];
    scr_pp_deflection_threshold.val     = {0.1};
    scr_pp_deflection_threshold.help    = {['Define an threshold in original data units for a slope to pass to be considerd in the filter. ', ...
    'This is useful, for example, with oscillatory wave data. ', ...
    'The slope may be steep due to a jump between voltages but we ', ...
    'likely do not want to consider this to be filtered. ', ...
    'A value of 0.1 would filter oscillatory behaviour with threshold less than 0.1v but not greater.' ],...
    'Default: 0.1', ...
    };

    scr_pp_data_island_threshold         = cfg_entry;
    scr_pp_data_island_threshold.name    = 'Data island threshold';
    scr_pp_data_island_threshold.tag     = 'data_island_threshold';
    scr_pp_data_island_threshold.strtype = 'r';
    scr_pp_data_island_threshold.num     = [1 1];
    scr_pp_data_island_threshold.val     = {0};
    scr_pp_data_island_threshold.help    = {['A float in seconds to determine the maximum length of unfiltered data between epochs.', ...
    ' If an island exists for less than the threshold it will also be filtered'], ...
    'Default: 0 s - will take no effect on filter', ...
    };

    scr_pp_expand_epochs         = cfg_entry;
    scr_pp_expand_epochs.name    = 'Expand epochs';
    scr_pp_expand_epochs.tag     = 'expand_epochs';
    scr_pp_expand_epochs.strtype = 'r';
    scr_pp_expand_epochs.num     = [1 1];
    scr_pp_expand_epochs.val     = {0.5};
    scr_pp_expand_epochs.help    = {'A float in seconds to determine by how much data on the flanks of artefact epochs will be removed.', ...
    'Default: 0.5 s', ...
    };


    scr_pp              = cfg_branch;
    scr_pp.name         = 'Preprocessing SCR';
    scr_pp.tag          = 'scr_pp';
    scr_pp.val          = {scr_pp_min, scr_pp_max, scr_pp_slope, scr_pp_missing_epochs, scr_pp_deflection_threshold, scr_pp_data_island_threshold,scr_pp_expand_epochs};
    scr_pp.help         = {['Preprocessing SCR. See I. R. Kleckner et al.,"Simple, Transparent, and' ...
    'Flexible Automated Quality Assessment Procedures for Ambulatory Electrodermal Activity Data," in ' ...
    'IEEE Transactions on Biomedical Engineering, vol. 65, no. 7, pp. 1460-1467, July 2018.']};

    %% Data file
    datafile         = cfg_files;
    datafile.name    = 'Data File';
    datafile.tag     = 'datafile';
    datafile.num     = [1 1];
    %datafile.filter  = '\.mat$';
    datafile.help    = {settings.datafilehelp};

    filtertype         = cfg_choice;
    filtertype.name    = 'Filter Type';
    filtertype.tag     = 'filtertype';
    filtertype.values  = {median,butter};
    filtertype.help    = {['Currently, median and butterworth filters are implemented. A median filter is ' ...
    'recommended for short spikes, generated for example in MRI scanners by gradient switching. A butterworth ' ...
    'filter is applied in most models; check there to see whether an additional filtering is meaningful.']};

    %% Overwrite file
    overwrite         = cfg_menu;
    overwrite.name    = 'Overwrite Existing File';
    overwrite.tag     = 'overwrite';
    overwrite.val     = {false};
    overwrite.labels  = {'No', 'Yes'};
    overwrite.values  = {false, true};
    overwrite.help    = {'Overwrite existing file?'};

    %% Executable branch
    artefact_rm      = cfg_exbranch;
    artefact_rm.name = 'Artefact Removal';
    artefact_rm.tag  = 'artefact_rm';
    artefact_rm.val  = {datafile,chan_nr,filtertype,overwrite};
    artefact_rm.prog = @pspm_cfg_run_artefact_rm;
    artefact_rm.vout = @pspm_cfg_vout_artefact;
    artefact_rm.help = {['This module offers a few basic artefact removal functions. Currently, ' ...
    'a median filter and a butterworth low pass filter are implemented. The median filter is ' ...
    'useful to remove short "spikes" in the data, for example from gradient switching in MRI. ' ...
    'The Butterworth filter can be used to get rid of high frequency noise that is not sufficiently ' ...
    'filtered away by the filters implemented on-the-fly during first level modelling.']};

    function [sts, val] =  pspm_cfg_check_artefact_rm_freq(val)
        sts = [];
        if val < 20
            sts = 'Cutoff Frequency hast to be at least 20Hz';
        end
        if ~isempty(sts)
            uiwait(msgbox(sts));
        end
    end

    function vout = pspm_cfg_vout_artefact(job)
        vout = cfg_dep;
        vout.sname      = 'Output File';
        % this can be entered into any file selector
        vout.tgt_spec   = cfg_findspec({{'class','cfg_files'}});
        vout.src_output = substruct('()',{':'});
    end
end
