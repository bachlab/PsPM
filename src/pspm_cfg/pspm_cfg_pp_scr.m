function [pp_scr] = pspm_cfg_pp_scr
% function for pre processing (PP) skin conductance response (SCR)
% Initialise
global settings
if isempty(settings)
  pspm_init;
end
% Data File
datafile              = cfg_files;
datafile.name         = 'Data File';
datafile.tag          = 'datafile';
datafile.num          = [1 1];
%datafile.filter      = '.*\.(mat|MAT)$';
datafile.help         = {['Specify the PsPM datafile containing ', ...
                          'the SCR data channel.'],' ',...
                          settings.datafilehelp};
%% simple SCR quality correction
% SCR minimum value
scr_min               = cfg_entry;
scr_min.name          = 'Minimum value';
scr_min.tag           = 'min';
scr_min.strtype       = 'r';
scr_min.num           = [1 1];
scr_min.val           = {0.05};
scr_min.help          = {'Minimum SCR value in microsiemens.'};
% SCR maximum value
scr_max               = cfg_entry;
scr_max.name          = 'Maximum value';
scr_max.tag           = 'max';
scr_max.strtype       = 'r';
scr_max.num           = [1 1];
scr_max.val           = {60};
scr_max.help          = {'Maximum SCR value in microsiemens.'};
% SCR maximum slope
scr_slope             = cfg_entry;
scr_slope.name        = 'Maximum slope';
scr_slope.tag         = 'slope';
scr_slope.strtype     = 'r';
scr_slope.num         = [1 1];
scr_slope.val         = {10};
scr_slope.help        = {'Maximum SCR slope in microsiemens per second.'};
%% Options
% missing epoch no filename (do not write to file)
missepoch_no_fn       = cfg_const;
missepoch_no_fn.name  = 'Do not write to file';
missepoch_no_fn.tag   = 'no_missing_epochs';
missepoch_no_fn.val   = {0};
missepoch_no_fn.help  = {'Do not store artefacts epochs to file'};
% missing epoch filename
missepoch_fn          = cfg_entry;
missepoch_fn.name     = 'File name';
missepoch_fn.tag      = 'filename';
missepoch_fn.strtype  = 's';
missepoch_fn.num      = [ 1 Inf ];
missepoch_fn.help     = {['Specify the name of the file where to ',...
                          'store artefact epochs. Provide only ',...
                          'the name and not the extension, ',...
                          'the file will be stored as a .mat file']};
% missing epoch file path
missepoch_fp          = cfg_files;
missepoch_fp.name     = 'Output Directory';
missepoch_fp.tag      = 'outdir';
missepoch_fp.filter   = 'dir';
missepoch_fp.num      = [1 1];
missepoch_fp.help     = {['Specify the directory where the .mat ',...
                          'file with artefact epochs will be written.']};
% missing epoch file
missepoch_file        = cfg_exbranch;
missepoch_file.name   = 'Write to filename';
missepoch_file.tag    = 'write_to_file';
missepoch_file.val    = {missepoch_fn, missepoch_fp};
missepoch_file.help   = {['If you choose to store the artefact epochs ',...
                          'please specify a filename as well as an',...
                          'output directory. ',...
                          'When giving the filename do not specify ',...
                          'any extension, the artefact epochs ',...
                          'will be stored as .mat file.']};
% missing epoch
missepoch             = cfg_choice;
missepoch.name        = 'Missing epochs file';
missepoch.tag         = 'missing_epochs';
missepoch.val         = {missepoch_no_fn};
missepoch.values      = {missepoch_no_fn, missepoch_file};
missepoch.help        = {['Specify if you want to store the artefact ',...
                          'epochs in a separate file of not.'], ...
                          'Default: artefact epochs are not stored.'};
% SCR deflection threshold
scr_def_thr           = cfg_entry;
scr_def_thr.name      = 'Deflection threshold';
scr_def_thr.tag       = 'deflection_threshold';
scr_def_thr.strtype   = 'r';
scr_def_thr.num       = [1 1];
scr_def_thr.val       = {0.1};
scr_def_thr.help      = {['Define an threshold in original data units ',...
                          'for a slope to pass to be considerd in the ',...
                          'filter. ', ...
                          'This is useful, for example, with ',...
                          'oscillatory wave data. ', ...
                          'The slope may be steep due to a jump ',...
                          'between voltages but we likely do not want ',...
                          'to consider this to be filtered. ', ...
                          'A value of 0.1 would filter oscillatory ',...
                          'behaviour with threshold less than 0.1v but ',...
                          'not greater. '],...
                          'Default: 0.1' ...
                         };
% SCR data island threshold
scr_isl_thr           = cfg_entry;
scr_isl_thr.name      = 'Data island threshold';
scr_isl_thr.tag       = 'data_island_threshold';
scr_isl_thr.strtype   = 'r';
scr_isl_thr.num       = [1 1];
scr_isl_thr.val       = {0};
scr_isl_thr.help      = {['A float in seconds to determine the maximum ',...
                          'length of unfiltered data between epochs. ', ...
                          'If an island exists for less than the ',...
                          'threshold it will also be filtered. '], ...
                          'Default: 0 s - will take no effect on filter.'};
% SCR expand epoch
scr_exp_ep            = cfg_entry;
scr_exp_ep.name       = 'Expand epochs';
scr_exp_ep.tag        = 'expand_epochs';
scr_exp_ep.strtype    = 'r';
scr_exp_ep.num        = [1 1];
scr_exp_ep.val        = {0.5};
scr_exp_ep.help       = {['A float in seconds to determine by how much ',...
                          'data on the flanks of artefact epochs will ',...
                          'be removed.'], ...
                          'Default: 0.5 s'};
% Channel
chan                  = pspm_cfg_channel_selector('SCR');
% Step size for clipping detection
clip_det_step         = cfg_entry;
clip_det_step.name    = 'Step size for clipping detection';
clip_det_step.tag     = 'clipping_step_size';
clip_det_step.strtype = 'r';
clip_det_step.num     = [1 1];
clip_det_step.val     = {2};
clip_det_step.help    = {['A numerical value specifying the step ',...
                          'size in moving average algorithm for ',...
                          'detecting clipping. '], ...
                          'Default: 2 s.'};
% Threshold for clipping detection
clip_det_thr          = cfg_entry;
clip_det_thr.name     = 'Threshold for clipping detection';
clip_det_thr.tag      = 'clipping_threshold';
clip_det_thr.strtype  = 'r';
clip_det_thr.num      = [1 1];
clip_det_thr.val      = {0.1};
clip_det_thr.help     = {['A float between 0 and 1 specifying the ',...
                          'proportion of local maximum in a step.'],...
                          'Default: 0.1.'};
% Clipping detection
clip_det              = cfg_exbranch;
clip_det.name         = 'Clipping detection';
clip_det.tag          = 'clipping_detection';
clip_det.val          = {clip_det_step, clip_det_thr};
clip_det.help         = {'Specify parameters for clipping detection.'};
% Channel action
chan_action           = cfg_menu;
chan_action.name      = 'Channel action';
chan_action.tag       = 'chan_action';
chan_action.values    = {'add', 'replace'};
chan_action.labels    = {'Add', 'Replace'};
chan_action.val       = {'replace'};
chan_action.help      = {['Choose whether to add the new channels or ',...
                          'replace a channel previously added by ',...
                          'this method.']};
% Executable Branch
pp_scr                = cfg_exbranch;
pp_scr.name           = 'Preprocessing SCR';
pp_scr.tag            = 'pp_scr';
pp_scr.val            = {datafile, ...
                         scr_min, ...
                         scr_max, ...
                         scr_slope, ...
                         scr_def_thr, ...
                         scr_isl_thr, ...
                         scr_exp_ep, ...
                         chan, ...
                         clip_det, ...
                         missepoch, ...
                         chan_action};
pp_scr.prog           = @pspm_cfg_run_scr_pp;
pp_scr.vout           = @pspm_cfg_vout_scr_pp;
pp_scr.help           = {['Pre processing (PP) skin conductance ',...
                          'response (SCR).'],...
                         ['See I. R. Kleckner et al., "Simple, ' ...
                          'Transparent, and Flexible Automated ' ...
                          'Quality Assessment Procedures for ' ...
                          'Ambulatory Electrodermal Activity Data," ' ...
                          'in IEEE Transactions on Biomedical ' ...
                          'Engineering, vol. 65, no. 7, ' ...
                          'pp. 1460--1467, July 2018.']};
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
    scr_pp_options.channel = pspm_cfg_channel_selector('run', job.chan);
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
