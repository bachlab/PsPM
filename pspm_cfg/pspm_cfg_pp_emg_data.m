function [pp_emg] = pspm_cfg_pp_emg_data
% function to process emg data which leads to emg_proc data
% 

% $Id$
% $Rev$

% Data File
datafile         = cfg_files;
datafile.name    = 'Data File';
datafile.tag     = 'datafile';
datafile.num     = [1 1];
%datafile.filter  = '.*\.(mat|MAT)$';
datafile.help    = {['Specify the PsPM datafile containing the EMG data channel.']};

% Custom channel
cust_chan                = cfg_entry;
cust_chan.name           = 'Specify channel number';
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
chan_action.help        = {'Should the processed data be added as a new ', ...
    'channel or replace the last existing channel of the same channel type?'};

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
pp_emg.help = {['Preprocess startle eyeblink EMG data for further analysis. ', ...
    'Mains frequency will be removed and the output data will ', ...
    'be rectified and smoothed. The applied filter settings ', ...
    'are according to the literature.'], ...
    'References:', 'Khemka, Tzovara, Quednow & Bach (2016) Psychophysiology'};

function vout = pspm_cfg_vout_pp_emg_data(job)
vout = cfg_dep;
vout.sname      = 'Output Channel';
vout.tgt_spec = cfg_findspec({{'class','cfg_entry'}});
vout.src_output = substruct('()',{':'});
