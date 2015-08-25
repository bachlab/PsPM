function [find_sounds] = scr_cfg_find_sounds(job)
% function [find_sounds] = scr_cfg_find_sounds(job)
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
datafile.name    = 'Data File';
datafile.tag     = 'datafile';
datafile.num     = [1 Inf];
datafile.help    = {['Specify the PsPM datafile containing the imported ', ...
    'startle sound data.']};

%% Channel
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
chan.help    = {'Number of channel containing the startle sounds (default: first sound channel).'};

%% Threshold
threshold            = cfg_entry;
threshold.name    = 'Threshold';
threshold.tag     = 'threshold';
threshold.strtype = 'r';
threshold.num     = [1 1];
threshold.val     = {0.1};
threshold.help    = {['Percent of the maximum sound amplitude still being accepted ', ... 
    'as belonging to a sound (important for defining the sound onset). Default: 0.1 (= 10%)']};

%% New Channel
new_chan        = cfg_const;
new_chan.name   = 'New Channel';
new_chan.tag    = 'new_chan';
new_chan.val    = {0};
new_chan.help   = {['The new data channel contains by default all ', ...
    'marker onsets found in the specified data file. If you want ', ...
    'specific sounds defined by a marker, use the diagnostics option.']};

%% Text only
text_only       = cfg_const;
text_only.name  = 'Text only';
text_only.tag   = 'text';
text_only.val   = {1};
text_only.help  = {'Output delay statistics as text (amount, mean, stddev).'};

%% Plot
hist_plot       = cfg_const;
hist_plot.name  = 'Histogram & Plot';
hist_plot.tag   = 'hist_plot';
hist_plot.val   = {2};
hist_plot.help  = {['Display a histogram of the delays ', ...
    'found and a plot with the detected sound, the marker event ', ... 
    'and the onset of the sound events. Color codes are green ', ...
    '(smallest delay) and red (longest delay).']};

%% Diagnostics output
diag_output        = cfg_choice;
diag_output.name   = 'Diagnostics output';
diag_output.tag    = 'diag_output';
diag_output.val    = {text_only};
diag_output.values = {text_only, hist_plot};
diag_output.help   = {''};

%% New corrected channel
new_corrected_chan         = cfg_menu;
new_corrected_chan.name    = 'New channel with specific sounds';
new_corrected_chan.tag     = 'new_corrected_chan';
new_corrected_chan.val     = {false};
new_corrected_chan.labels  = {'No', 'Yes'};
new_corrected_chan.values  = {false, true};

%% Marker channel
mrk_chan_def         = cfg_const;
mrk_chan_def.name    = 'Default';
mrk_chan_def.tag     = 'marker_def';
mrk_chan_def.val     = {0};
mrk_chan_def.help    = {'First marker channel'};

mrk_chan_nr         = cfg_entry;
mrk_chan_nr.name    = 'Number';
mrk_chan_nr.tag     = 'marker_nr';
mrk_chan_nr.strtype = 'i';
mrk_chan_nr.num     = [1 1];
mrk_chan_nr.help    = {''};

marker_chan         = cfg_choice;
marker_chan.name    = 'Marker channel';
marker_chan.tag     = 'marker_chan';
marker_chan.val     = {mrk_chan_def};
marker_chan.values  = {mrk_chan_def,mrk_chan_nr};
marker_chan.help    = {''};

%% Max delay
max_delay        = cfg_entry;
max_delay.name   = 'Max delay';
max_delay.tag    = 'max_delay';
max_delay.strtype = 'i';
max_delay.num    = [1 1];
max_delay.val    = {3};
max_delay.help   = {['Size of window in seconds in which sounds are ', ...
    'accepted to belong to a marker. Default: 3s']};

%% Diagnostics
diagnostic        = cfg_branch;
diagnostic.name   = 'Diagnostic';
diagnostic.tag    = 'diagnostic';
diagnostic.val = {diag_output, new_corrected_chan, marker_chan, max_delay};

%% Output
output          = cfg_choice;
output.name     = 'Output';
output.tag      = 'output';
output.val      = {new_chan};
output.values   = {new_chan, diagnostic};
output.help     = {''};

%% Executable branch
find_sounds      = cfg_exbranch;
find_sounds.name = 'Find startle sound onsets';
find_sounds.tag  = 'find_sounds';
find_sounds.val  = {datafile, chan, threshold, output};
find_sounds.prog = @scr_cfg_run_find_sounds;
find_sounds.vout = @scr_cfg_vout_find_sounds;
find_sounds.help = {['Translate continuous sound data into an event marker ', ... 
    'channel. The function adds a new marker channel to the given data ', ...
    'file containing the sound data and returns the added channel number. ', ...
    'The option threshold, passed in percent to the maximum amplitude of ', ...
    'the sound data, allows to specify the minimum amplitude of a sound ', ...
    'to be accepted as an event.']};

function vout = scr_cfg_vout_find_sounds(job)
vout = cfg_dep;
vout.sname      = 'Output Channel';
% this can be entered into any entry
vout.tgt_spec   = cfg_findspec({{'class','cfg_entry'}, {'strtype', 'i'}});
vout.src_output = substruct('()',{':'});