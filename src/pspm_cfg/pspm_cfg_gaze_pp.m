function [gaze_pp] = pspm_cfg_gaze_pp(job)
% function [gaze_pp] = pspm_cfg_gaze_pp(job)
%
% Matlabbatch function for gaze_pp
%__________________________________________________________________________
% PsPM 7.0
% (C) 2024 Dominik Bach (Uni Bonn)


%% Standard items
datafile         = pspm_cfg_selector_datafile;
channel          = pspm_cfg_selector_channel('gaze_pair');
channel_action   = pspm_cfg_selector_channel_action;
           
%% Executable branch
gaze_pp        = cfg_exbranch;
gaze_pp.name   = 'Gaze preprocessing';
gaze_pp.tag    = 'gaze_pp';
gaze_pp.val    = {datafile, channel, channel_action};
gaze_pp.prog   = @pspm_cfg_run_gaze_pp;
gaze_pp.vout   = @pspm_cfg_vout_outchannel;
gaze_pp.help   = pspm_cfg_help_format('pspm_gaze_pp');