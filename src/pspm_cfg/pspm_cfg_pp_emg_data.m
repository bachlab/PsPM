function [pp_emg] = pspm_cfg_pp_emg_data
% * Description
%   function to process emg data which leads to emg_proc data
% * History
%   Updated in 2024 by Teddy

% Initialise
global settings
if isempty(settings), pspm_init; end

% Data File
datafile         = cfg_files;
datafile.name    = 'Data File';
datafile.tag     = 'datafile';
datafile.num     = [1 1];
%datafile.filter  = '.*\.(mat|MAT)$';
datafile.help    = {['Specify the PsPM datafile containing ', ...
    'the EMG data channel.'],' ',settings.datafilehelp};

% Custom channel
cust_chan                = cfg_entry;
cust_chan.name           = 'Specify channel ID';
cust_chan.tag            = 'cust_channel';
cust_chan.strtype        = 'i';
cust_chan.num            = [1 1];
cust_chan.help           = {['']};

% First emg channel
first_chan              = cfg_const;
first_chan.name         = 'First EMG channel';
first_chan.tag          = 'first_channel';
first_chan.val          = {'emg'};
first_chan.help         = {['']};

% Channel
chan                    = cfg_choice;
chan.name               = 'Channel';
chan.tag                = 'channel';
chan.val                = {first_chan};
chan.values             = {first_chan, cust_chan};
chan.help               = {['Channel ID of the channel containing the ', ...
    'unprocessed EMG data.']};

% Mains frequency
mains                   = cfg_entry;
mains.name              = 'Mains frequency';
mains.tag               = 'mains_freq';
mains.strtype           = 'r';
mains.num               = [1 1];
mains.val               = {50};
mains.help              = {['The frequency of the alternating current (AC)',...
    ' which will be filtered out using bandstop filter.']};

% Channel action
chan_action             = cfg_menu;
chan_action.name        = 'Channel action';
chan_action.tag         = 'chan_action';
chan_action.values      = {'add', 'replace'};
chan_action.labels      = {'Add', 'Replace'};
chan_action.val         = {'add'};
chan_action.help        = {['Defines whether the processed data should be ', ...
    'added as a new channel or replace the last existing channel of the ', ...
    'same data type. After preprocessing the data will be stored ', ...
    'as ''emg_pp'' channel. ']};

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
