function artefact_rm = pspm_cfg_artefact_rm
% Updated 29-Mar-2024 by Teddy
% Initialise
global settings
if isempty(settings)
  pspm_init;
end
%% Global items
chan_nr                   = pspm_cfg_channel_selector('any');
%% Median filter
nr_time_pt                = cfg_entry;
nr_time_pt.name           = 'Number of Time Points';
nr_time_pt.tag            = 'nr_time_pt';
nr_time_pt.strtype        = 'i';
nr_time_pt.num            = [1 1];
nr_time_pt.help           = {'Number of time points over which the median is taken.'};
% Median filter
filter_median             = cfg_branch;
filter_median.name        = 'Median Filter';
filter_median.tag         = 'median';
filter_median.val         = {nr_time_pt};
filter_median.help        = {''};
%% Butterworth LP frequency
freq_low_pass_none        = cfg_const;
freq_low_pass_none.name   = 'none';
freq_low_pass_none.tag    = 'freqLPnone';
freq_low_pass_none.val    = {'none'};
freq_low_pass_none.help   = {'No sample rate defined.'};
freq_low_pass_num         = cfg_entry;
freq_low_pass_num.name    = 'number';
freq_low_pass_num.tag     = 'freqLPnum';
freq_low_pass_num.strtype = 'r';
freq_low_pass_num.num     = [1 1];
freq_low_pass_num.help    = {'Define the low-pass filter frequency as a number.'};
freq_low_pass             = cfg_choice;
freq_low_pass.name        = 'Low-pass filter frequency';
freq_low_pass.tag         = 'freqLP';
freq_low_pass.values      = {freq_low_pass_none, freq_low_pass_num};
freq_low_pass.help        = {['Frequency of the low pass filter. ',...
                            'It must be a number or "none" (default value).']};
%% Butterworth LP order
order_low_pass            = cfg_entry;
order_low_pass.name       = 'Low-pass filter order';
order_low_pass.tag        = 'orderLP';
order_low_pass.strtype    = 'r';
order_low_pass.val        = {1};
order_low_pass.num        = [1 1];
order_low_pass.help       = {['Order of the low pass filter. ',...
                            'It must be a non-zero integer. ',...
                            'The default value is 1.']};
%% Butterworth HP frequency
freq_high_pass_none       = cfg_const;
freq_high_pass_none.name  = 'none';
freq_high_pass_none.tag   = 'freqHPnone';
freq_high_pass_none.val   = {'none'};
freq_high_pass_none.help  = {'No sample rate defined.'};
freq_high_pass_num        = cfg_entry;
freq_high_pass_num.name   = 'number';
freq_high_pass_num.tag    = 'freqHPnum';
freq_high_pass_num.strtype= 'r';
freq_high_pass_num.num    = [1 1];
freq_high_pass_num.help   = {'Define the high-pass filter frequency as a number.'};
freq_high_pass            = cfg_choice;
freq_high_pass.name       = 'High-pass filter frequency';
freq_high_pass.tag        = 'freqHP';
freq_high_pass.values     = {freq_high_pass_none, freq_high_pass_num};
freq_high_pass.help       = {['Frequency of the high pass filter. ',...
                            'It must be a number or "none" (default value).']};
%% Butterworth HP order
order_high_pass           = cfg_entry;
order_high_pass.name      = 'High-pass filter order';
order_high_pass.tag       = 'orderHP';
order_high_pass.strtype   = 'r';
order_high_pass.val       = {1};
order_high_pass.num       = [1 1];
order_high_pass.help      = {['Order of the high pass filter. ',...
                            'It must be a non-zero integer. ',...
                            'The default value is 1.']};
%% Butterworth filter direction
filter_direction          = cfg_menu;
filter_direction.name     = 'Direction';
filter_direction.tag      = 'direction';
filter_direction.val      = {'uni'};
filter_direction.labels   = {'Uni', 'Bi'};
filter_direction.values   = {'uni', 'bi'};
filter_direction.help     = {['Direction of the filter. ',...
                            'Can be either "uni" or "bi".']};
%% Downsampling rate
downsamp_rate_none        = cfg_const;
downsamp_rate_none.name   = 'none';
downsamp_rate_none.tag    = 'down';
downsamp_rate_none.val    = {'none'};
downsamp_rate_none.help   = {'No sample rate defined.'};
downsamp_rate_num         = cfg_entry;
downsamp_rate_num.name    = 'number';
downsamp_rate_num.tag     = 'down';
downsamp_rate_num.strtype = 'r';
downsamp_rate_num.num     = [1 1];
downsamp_rate_num.help    = {['Define the post-downsampling sampling ',...
                            'rate as a number.']};
downsamp_rate             = cfg_choice;
downsamp_rate.name        = 'Sampling rate after downsampling';
downsamp_rate.tag         = 'down';
downsamp_rate.values      = {downsamp_rate_none, downsamp_rate_num};
downsamp_rate.help        = {['Sample rate in Hz after downsampling. ',...
                            'It must be a number or "none" (default value).']};
%% Butterworth filtering
filter_butter             = cfg_branch;
filter_butter.name        = 'Butterworth Filter';
filter_butter.tag         = 'butter';
filter_butter.val         = {order_low_pass, freq_low_pass, ...
                            order_high_pass, freq_high_pass, ...
                            filter_direction, downsamp_rate};
filter_butter.help        = {'Butterworth Filter.'};
%% Data file
datafile                  = cfg_files;
datafile.name             = 'Data File';
datafile.tag              = 'datafile';
datafile.num              = [1 1];
%datafile.filter          = '\.mat$';
datafile.help             = {settings.datafilehelp};
%% Filter type
filter_type               = cfg_choice;
filter_type.name          = 'Filter Type';
filter_type.tag           = 'filtertype';
filter_type.values        = {filter_median,filter_butter};
filter_type.help          = {['Currently, median and butterworth ',...
                           'filters are implemented. A median filter is ',...
                           'recommended for short spikes, generated ',...
                           'for example in MRI scanners by gradient ',...
                           'switching. A butterworth filter is applied ',...
                           'in most models; check there to see whether ',...
                           'an additional filtering is meaningful.']};
%% Overwrite file
overwrite                 = cfg_menu;
overwrite.name            = 'Overwrite Existing File';
overwrite.tag             = 'overwrite';
overwrite.val             = {false};
overwrite.labels          = {'No', 'Yes'};
overwrite.values          = {false, true};
overwrite.help            = {'Overwrite if a file with the same name has existed?'};
%% Executable branch
artefact_rm               = cfg_exbranch;
artefact_rm.name          = 'Artefact Removal';
artefact_rm.tag           = 'artefact_rm';
artefact_rm.val           = {datafile,chan_nr,filter_type,overwrite};
artefact_rm.prog          = @pspm_cfg_run_artefact_rm;
artefact_rm.vout          = @pspm_cfg_vout_artefact;
artefact_rm.help          = {['This module offers a few basic ',...
                            'artefact removal functions. Currently, ',...
                            'a median filter and a butterworth low ',...
                            'pass filter are implemented. The median ',...
                            'filter is useful to remove short ',...
                            '"spikes" in the data, for example ',...
                            'from gradient switching in MRI. ',...
                            'The Butterworth filter can be used to ',...
                            'get rid of high frequency noise that is ',...
                            'not sufficiently filtered away by the ',...
                            'filters implemented on-the-fly during ',...
                            'first level modelling.']};

  % Not sure about the function below was executed
  function [sts, val] =  pspm_cfg_check_artefact_rm_freq(val)
    sts = [];
    if val < 20
      sts = 'Cutoff Frequency hast to be at least 20Hz';
    end
    if ~isempty(sts)
      uiwait(msgbox(sts));
    end
  end

  function vout = pspm_cfg_vout_artefact(~)
    vout = cfg_dep;
    vout.sname      = 'Output File';
    % this can be entered into any file selector
    vout.tgt_spec   = cfg_findspec({{'class','cfg_files'}});
    vout.src_output = substruct('()',{':'});
  end
end
