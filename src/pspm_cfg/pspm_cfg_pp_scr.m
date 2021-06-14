function [pp_scr] = pspm_cfg_pp_scr
% function for pre processing (PP) skin conductance response (SCR)
%

% $Id$
% $Rev$

% Initialise
global settings
if isempty(settings)
    pspm_init; 
end

help_chan = 'Choose whether to add the new channels or replace a channel previously added by this method.';

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
cust_chan.help           = {'Customise the channel ID of the SCR for processing.'};

% First scr channel
first_chan              = cfg_const;
first_chan.name         = 'First SCR channel';
first_chan.tag          = 'first_channel';
first_chan.val          = {'scr'};
first_chan.help         = {'Use the default first channel of the SCR for processing.'};

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
chan_action.help        = {help_chan};

% Executable Branch
pp_scr              = cfg_exbranch;
pp_scr.name         = 'Preprocessing SCR';
pp_scr.tag          = 'pp_scr';
pp_scr.val          = {datafile, chan, mains, chan_action};
pp_scr.prog         = @pspm_cfg_run_scr_pp;
pp_scr.vout         = @pspm_cfg_vout_scr_pp;
pp_scr.help         = {['Preprocessing SCR. See I. R. Kleckner et al., "Simple, Transparent, and' ...
    'Flexible Automated Quality Assessment Procedures for Ambulatory Electrodermal Activity Data," in ' ...
    'IEEE Transactions on Biomedical Engineering, vol. 65, no. 7, pp. 1460--1467, July 2018.']};

    function vout = pspm_cfg_vout_scr_pp(~)
        vout = cfg_dep;
        vout.sname      = 'Output Channel';
        vout.tgt_spec = cfg_findspec({{'class','cfg_entry'}});
        vout.src_output = substruct('()',{':'});
    end

    function out = pspm_cfg_run_scr_pp(job)
        options = struct();
        options.mains_freq = job.options(1).mains_freq;
        options.channel_action = job.options(1).chan_action;
        if isfield(job.options(1).channel, 'cust_channel')
            options.channel = job.options(1).channel(1).cust_channel;
        elseif isfield(job.options(1).channel, 'first_channel')
            options.channel = job.options(1).channel(1).first_channel;
        end
        [sts, output] = pspm_scr_pp(job.datafile{1}, options);
        if sts == 1
            out = {output.channel};
        else
            out = {-1};
        end
    end

end
