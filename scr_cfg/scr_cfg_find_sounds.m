function [find_sounds] = scr_cfg_find_sounds(job)
% function [find_sounds] = scr_cfg_find_sounds
%
% Matlabbatch function specifies the scr_cfg_find_sounds.
% 
%__________________________________________________________________________
% PsPM 3.0
% (C) 2015 Tobias Moser (University of Zurich)

% $Id$
% $Rev$

% Initialise
global settings
if isempty(settings), scr_init; end;

%% Select file / datafile
datafile         = cfg_files;
datafile.name    = 'Data File(s)';
datafile.tag     = 'datafile';
datafile.num     = [1 Inf];
datafile.help    = {['Specify the PsPM datafile containing the imported ', ...
    'sound data. The marker events will be written to a new ', ...
    'channel in this file.']};

%% Options

% Channel
chan_def         = cfg_const;
chan_def.name    = 'Default';
chan_def.tag     = 'chan_def';
chan_def.val     = {0};
chan_def.help    = {'First sound channel'};

chan_nr         = cfg_entry;
chan_nr.name    = 'Number';
chan_nr.tag     = 'chan_nr';
chan_nr.strtype = 'i';
chan_nr.num     = [1 1];
chan_nr.help    = {''};

chan         = cfg_choice;
chan.name    = 'Channel';
chan.tag     = 'chan';
chan.val     = {chan_def};
chan.values  = {chan_def,chan_nr};
chan.help    = {'Number of sound channel (default: first sound channel).'};

% Threshold
threshold            = cfg_entry;
threshold.name    = 'Threshold';
threshold.tag     = 'threshold';
threshold.strtype = 'r';
threshold.num     = [1 1];
threshold.val     = {0.1};
threshold.help    = {['Percent of the maximum amplitude still being accepted ', ... 
    'as a sound event. Default: 0.1 (= 10%)']};

options         = cfg_branch;
options.name    = 'Options';
options.tag     = 'options';
options.val     = {chan, threshold};
options.help    = {''};

%% Executable branch
find_sounds      = cfg_exbranch;
find_sounds.name = 'Translate sounds to marker events';
find_sounds.tag  = 'find_sounds';
find_sounds.val  = {datafile, options};
find_sounds.prog = @scr_cfg_run_find_sounds;
find_sounds.vout = @scr_cfg_vout_find_sounds;
find_sounds.help = {['Translate continuous sound data into an event marker', ... 
    ' channel. The function adds a new marker channel to the given data ', ...
    'file containing the sound data and returns the added channel number.', ...
    ' The option threshold, passed in percent to the maximum amplitude of ', ...
    'the sound data, allows to specify the minimum amplitude of a sound ', ...
    'to be accepted as an event.']};

function vout = scr_cfg_vout_find_sounds(job)
vout = cfg_dep;
vout.sname      = 'Output Channel';
% this can be entered into any entry
vout.tgt_spec   = cfg_findspec({{'class','cfg_entry'}, {'strtype', 'i'}});
vout.src_output = substruct('()',{':'});