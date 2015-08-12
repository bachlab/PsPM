function split_sessions = scr_cfg_split_sessions

% $Id$
% $Rev$

%% Data file
datafile         = cfg_files;
datafile.name    = 'Data File';
datafile.tag     = 'datafile';
datafile.num     = [1 Inf];
%datafile.filter  = '\.(mat|MAT)$';
datafile.help    = {''};

%% Marker channel
chan_def         = cfg_const;
chan_def.name    = 'Default';
chan_def.tag     = 'chan_def';
chan_def.val     = {0};
chan_def.help    = {''};

chan_nr         = cfg_entry;
chan_nr.name    = 'Number';
chan_nr.tag     = 'chan_nr';
chan_nr.strtype = 'i';
chan_nr.num     = [1 1];
chan_nr.help    = {''};

mrk_chan         = cfg_choice;
mrk_chan.name    = 'Marker Channel';
mrk_chan.tag     = 'mrk_chan';
mrk_chan.val     = {chan_def};
mrk_chan.values  = {chan_def, chan_nr};
mrk_chan.help    = {['If you have more than one marker channel, choose the marker ' ...
    'channel used for splitting sessions (default: use first marker channel).']};

%% Overwrite file
overwrite         = cfg_menu;
overwrite.name    = 'Overwrite Existing File';
overwrite.tag     = 'overwrite';
overwrite.val     = {false};
overwrite.labels  = {'No', 'Yes'};
overwrite.values  = {false, true};
overwrite.help    = {'Overwrite existing file?'};


%% Executable branch
split_sessions      = cfg_exbranch;
split_sessions.name = 'Split Sessions';
split_sessions.tag  = 'split_sessions';
split_sessions.val  = {datafile,mrk_chan,overwrite};
split_sessions.prog = @scr_cfg_run_split_sessions;
split_sessions.vout = @scr_cfg_vout_split_sessions;
split_sessions.help = {['Split sessions, defined by trains of of markers. This function ' ...
    'is most commonly used to split fMRI sessions when a (slice or volume) pulse from the ' ...
    'MRI scanner has been recorded. The function will identify trains of markers and detect ' ...
    'breaks in these marker sequences. The individual sessions will be written to new files ' ...
    'with a suffix ''_sn'', and the session number. You can choose a marker channel if several were recorded.']};

function vout = scr_cfg_vout_split_sessions(job)
vout = cfg_dep;
vout.sname      = 'Output File(s)';
% this can be entered into any file selector
vout.tgt_spec   = cfg_findspec({{'class','cfg_files'}});
vout.src_output = substruct('()',{':'});