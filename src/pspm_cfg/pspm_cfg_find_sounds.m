function [find_sounds] = pspm_cfg_find_sounds
% function [find_sounds] = pspm_cfg_find_sounds
%
% Matlabbatch function specifies the pspm_cfg_find_sounds.
%
%__________________________________________________________________________
% PsPM 3.0
% (C) 2015 Tobias Moser (University of Zurich)

%% Standard items
datafile         = pspm_cfg_selector_datafile;
chan             = pspm_cfg_selector_channel('sound');
chan_action      = pspm_cfg_selector_channel_action;
marker_chan      = pspm_cfg_selector_channel('marker');

%% Threshold
threshold            = cfg_entry;
threshold.name    = 'Threshold';
threshold.tag     = 'threshold';
threshold.strtype = 'r';
threshold.num     = [1 1];
threshold.val     = {0.1};
threshold.help    = {['Percent of the maximum sound amplitude still being accepted ', ...
    'as belonging to a sound (important for defining the sound onset). Default: 0.1 (= 10%)']};

%% Region
region                 = cfg_entry;
region.name            = 'Region';
region.tag             = 'region';
region.help            = {''};
region.strtype         = 'r';
region.num             = [1 2];

%% Whole region
whole               = cfg_const;
whole.name          = 'Whole file';
whole.tag           = 'whole';
whole.val           = {0};

%% Region of interest
roi                 = cfg_choice;
roi.name            = 'Region of interest';
roi.tag             = 'roi';
roi.val             = {whole};
roi.values          = {whole, region};
roi.help            = {['Region of interest for discovering sounds. ', ...
    'Only sounds between the 2 timestamps will be considered.']};

%% Create Channel
new_chan        = cfg_branch;
new_chan.name   = 'Create Channel';
new_chan.tag    = 'create_chan';
new_chan.val    = {chan_action};
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

%% no
no                 = cfg_const;
no.name            = 'No';
no.tag             = 'no';
no.val             = {0};
no.help            = {''};

%% yes
yes                = cfg_branch;
yes.name           = 'Yes';
yes.tag            = 'yes';
yes.val            = {chan_action};
yes.help           = {''};

%% New corrected channel
new_corrected_chan         = cfg_choice;
new_corrected_chan.name    = 'Create channel with specific sounds';
new_corrected_chan.tag     = 'create_corrected_chan';
new_corrected_chan.val     = {no};
new_corrected_chan.values  = {no, yes};
new_corrected_chan.help    = {['Create new data channel which contains ', ...
    'only marker onsets which could have been assigned to a ', ...
    'marker in the specified marker channel.']};

%% Max delay
max_delay        = cfg_entry;
max_delay.name   = 'Max delay';
max_delay.tag    = 'max_delay';
max_delay.strtype = 'r';
max_delay.num    = [1 1];
max_delay.val    = {3};
max_delay.help   = {['Upper limit in seconds of the window in which ', ...
    'sounds are accepted to belong to a marker. Default: 3s']};

%% Min delay
min_delay        = cfg_entry;
min_delay.name   = 'Min delay';
min_delay.tag    = 'min_delay';
min_delay.strtype = 'r';
min_delay.num    = [1 1];
min_delay.val    = {0};
min_delay.help   = {['Lower limit in seconds of the window in which ', ...
    'sounds are accepted to belong to a marker. Default: 0s']};

%% Expected sound count
n_sounds        = cfg_entry;
n_sounds.name   = 'Expected sound count';
n_sounds.tag    = 'n_sounds';
n_sounds.strtype = 'i';
n_sounds.num    = [1 1];
n_sounds.val    = {0};
n_sounds.help   = {['Checks for correct number of detected sounds. ', ...
    'If too few sounds are found, threshold is lowered until specified ', ...
    'count is reached.']};

%% Diagnostics
diagnostic        = cfg_branch;
diagnostic.name   = 'Diagnostic';
diagnostic.tag    = 'diagnostic';
diagnostic.val = {diag_output, new_corrected_chan, marker_chan, max_delay, ...
    min_delay, n_sounds};
diagnostic.help   = {['Analyze delays between existing marker channel ', ...
    'and detected sound onsets.']};

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
find_sounds.val  = {datafile, chan, threshold, roi, output};
find_sounds.prog = @pspm_cfg_run_find_sounds;
find_sounds.vout = @pspm_cfg_vout_find_sounds;
find_sounds.help = {['Translate continuous sound data into an event marker ', ...
    'channel. The function adds a new marker channel to the given data ', ...
    'file containing the sound data and returns the added channel number. ', ...
    'The option threshold, passed in percent to the maximum amplitude of ', ...
    'the sound data, allows to specify the minimum amplitude of a sound ', ...
    'to be accepted as an event.']};

function vout = pspm_cfg_vout_find_sounds(job)
vout = cfg_dep;
vout.sname      = 'Output Channel';
% this can be entered into any entry
vout.tgt_spec   = cfg_findspec({{'class','cfg_entry'}, {'strtype', 'i'}});
vout.src_output = substruct('()',{':'});
