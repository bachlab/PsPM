function [pp_emg] = pspm_cfg_pp_emg_data
% * Description
%   function to process emg data which leads to emg_pp data
% * History
%   Updated in 2024 by Teddy


%% Standard items
datafile         = pspm_cfg_selector_datafile;
chan             = pspm_cfg_selector_channel('EMG');
chan_action      = pspm_cfg_selector_channel_action;

% Channel

% Mains frequency
mains                   = cfg_entry;
mains.name              = 'Mains frequency';
mains.tag               = 'mains_freq';
mains.strtype           = 'r';
mains.num               = [1 1];
mains.val               = {50};
mains.help              = pspm_cfg_help_format('pspm_emg_pp', 'options.mains_freq');

% Options
options             = cfg_branch;
options.name        = 'Options';
options.tag         = 'options';
options.val         = {chan, mains, chan_action};
options.help        = {};

% Executable Branch
pp_emg = cfg_exbranch;
pp_emg.name = 'Preprocess startle eyeblink EMG';
pp_emg.tag  = 'pp_emg_data';
pp_emg.val  = {datafile, options};
pp_emg.prog = @pspm_cfg_run_pp_emg_data;
pp_emg.vout = @pspm_cfg_vout_outchannel;
pp_emg.help = pspm_cfg_help_format('pspm_emg_pp');

