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
mains.help              = {['The frequency of the alternating current (AC)',...
    ' which will be filtered out using bandstop filter.']};

% Options
options             = cfg_branch;
options.name        = 'Options';
options.tag         = 'options';
options.val         = {chan, mains, chan_action};
options.help        = {['']};

% Executable Branch
pp_emg = cfg_exbranch;
pp_emg.name = 'Preprocess startle eyeblink EMG';
pp_emg.tag  = 'pp_emg_data';
pp_emg.val  = {datafile, options};
pp_emg.prog = @pspm_cfg_run_pp_emg_data;
pp_emg.vout = @pspm_cfg_vout_pp_emg_data;
pp_emg.help = {['Preprocess startle eyeblink EMG data for further ', ...
    'analysis. Noise in EMG data will be removed in three steps: ', ...
    'Initially the data is filtered with a 4th order Butterworth filter ', ...
    'with cutoff frequencies 50 Hz and 470 Hz. Then, Mains frequency ', ...
    'will be removed using a notch filter at 50 Hz (can be changed). Finally, ', ...
    'the data is smoothed and rectified using a 4th order Butterworth ', ...
    'low-pass filter with a time constant of 3 ms (= cutoff at 53.05 Hz). ', ...
    'The applied filter settings are according to the literature.', ...
    'While the input data must be an ''emg'' channel, the output will ', ...
    'be an ''emg_pp'' channel which is the requirement for ', ...
    'startle eyeblink GLM.'], ...
    'References:', 'Khemka, Tzovara, Quednow & Bach (2016) Psychophysiology'};

function vout = pspm_cfg_vout_pp_emg_data(~)
vout = cfg_dep;
vout.sname      = 'Output Channel';
vout.tgt_spec = cfg_findspec({{'class','cfg_entry'}});
vout.src_output = substruct('()',{':'});
