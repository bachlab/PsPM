function [pp_pupil_size_convert] = pspm_cfg_pupil_size_convert
% function [pp_pupil_size_convert] = pspm_cfg_pupil_size_convert(job)
%
% Matlabbatch function for pupil size conversion
%__________________________________________________________________________
% PsPM 4.3
% (C) 2016 Sam Maxwell (University College London)


%% Standard items
datafile         = pspm_cfg_selector_datafile;
channel          = pspm_cfg_selector_channel('pupil_both');
channel_action   = pspm_cfg_selector_channel_action;

%% Specific items
%% area2diameter
area2diameter       = cfg_const;
area2diameter.name  = 'Area to diameter';
area2diameter.tag   = 'area2diameter';
area2diameter.val   = {'area2diameter'};
area2diameter.help  = {['']};
               
%% Mode
mode                = cfg_choice;
mode.name           = 'Mode';
mode.tag            = 'mode';
mode.val            = {area2diameter};
mode.values         = {area2diameter};
mode.help           = {['Choose conversion mode.']};


%% Executable branch
pp_pupil_size_convert        = cfg_exbranch;
pp_pupil_size_convert.name   = 'Pupil size convert';
pp_pupil_size_convert.tag    = 'pupil_size_convert';
pp_pupil_size_convert.val    = {datafile, channel, channel_action, mode};
pp_pupil_size_convert.prog   = @pspm_cfg_run_pupil_size_convert;
pp_pupil_size_convert.vout   = @pspm_cfg_vout_outchannel;
pp_pupil_size_convert.help   = {['Provides conversion functions for the specified ', ...
    'data (e.g. pupil size data). Currently only area to diameter conversion is ',...
    'available.']};