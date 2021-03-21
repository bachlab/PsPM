function [pp_scr] = pspm_cfg_scr_pp
% function for pre processing (PP) skin conductance response (SCR)
% 

% $Id$
% $Rev$

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
    'the SCR data channel.'],' ',settings.datafilehelp};

% Custom channel
cust_chan                = cfg_entry;
cust_chan.name           = 'Specify channel ID';
cust_chan.tag            = 'cust_channel';
cust_chan.strtype        = 'i';
cust_chan.num            = [1 1];
cust_chan.help           = {['']};

% First scr channel
first_chan              = cfg_const;
first_chan.name         = 'First SCR channel';
first_chan.tag          = 'first_channel';
first_chan.val          = {'scr'};
first_chan.help         = {['']};

% Channel
chan                    = cfg_choice;
chan.name               = 'Channel';
chan.tag                = 'channel';
chan.val                = {first_chan};
chan.values             = {first_chan, cust_chan};
chan.help               = {['Channel ID of the channel containing the ', ...
    'unprocessed SCR data.']};

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
chan_action.help        = {['Help (TBD).']};

% Options
options             = cfg_branch;
options.name        = 'Options';
options.tag         = 'options';
options.val         = {chan, mains, chan_action};
options.help        = {'Help (TBD).'};

% Executable Branch
pp_scr = cfg_exbranch;
pp_scr.name = 'Preprocessing SCR';
pp_scr.tag  = 'scr_pp';
pp_scr.val  = {datafile, options};
pp_scr.prog = @pspm_cfg_run_scr_pp;
pp_scr.vout = @pspm_cfg_vout_scr_pp;
pp_scr.help = {'Help (TBD).'};

function vout = pspm_cfg_vout_scr_pp(~)
vout = cfg_dep;
vout.sname      = 'Output Channel';
vout.tgt_spec = cfg_findspec({{'class','cfg_entry'}});
vout.src_output = substruct('()',{':'});
