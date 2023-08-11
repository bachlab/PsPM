function sf = pspm_cfg_sf

% $Id$
% $Rev$

% Initialise
global settings
if isempty(settings), pspm_init; end;

%% Data file
datafile         = cfg_files;
datafile.name    = 'Data File';
datafile.tag     = 'datafile';
datafile.num     = [1 1];
datafile.filter  = '.*\.(mat|MAT)$';
datafile.help    = {['Add the data file containing the SCR data (and potential marker information). '...
    'If you have trimmed your data, add the file containing the trimmed data.'],...
    ' ',settings.datafilehelp};

%% Output directory
outdir         = cfg_files;
outdir.name    = 'Output Directory';
outdir.tag     = 'outdir';
outdir.filter  = 'dir';
outdir.num     = [1 1];
outdir.help    = {'Specify directory where the mat file with the resulting model will be written.'};

%% Filenames for model output
modelfile         = cfg_entry;
modelfile.name    = 'Model Filename';
modelfile.tag     = 'modelfile';
modelfile.strtype = 's';
modelfile.help    = {'Specify file name for the resulting model.'};

%% Method
method         = cfg_menu;
method.name    = 'Method';
method.tag     = 'method';
method.labels  = {'AUC', 'SCL', 'DCM', 'MP', 'all'};
method.values  = {'auc', 'scl', 'dcm', 'mp', 'all'};
method.help    = {['Choose the method for estimating tonic sympathetic arousal: AUC ', ...
                   '(equivalent to number x amplitude of spontaneous fluctuations), SCL ', ...
                   '(tonic skin conductance level), DCM or MP. The latter two estimate the number of ', ...
                   'spontaneous fluctuations, requiring absolute data units as they implements an ', ...
                   'absolute amplitude threshold. In theory, DCM provides highest sensitivity but is slow (Bach, ', ...
                   'Daunizeau et al, 2011, Psychophysiology). MP is a very fast approximation to the ', ...
                   'DCM results, and comparable in sensitivity for analysis of empirical data ', ...
                   '(Bach & Staib, 2015, Psychophysiology). ', ...
                   'In simulations, it is less accurate when the expected ', ...
                   'number of SF exceeds 10/min.']};

% Filter
disable        = cfg_const;
disable.name   = 'Disable';
disable.tag    = 'disable';
disable.val    = {0};
disable.help   = {''};

% Low pass
lpfreq         = cfg_entry;
lpfreq.name    = 'Cutoff Frequency';
lpfreq.tag     = 'freq';
lpfreq.strtype = 'r';
if isfield(settings.dcm{1,2}.filter,'lpfreq')
    lpfreq.val = {settings.dcm{1,2}.filter.lpfreq};
end
lpfreq.num     = [1 1];
lpfreq.help    = {'Specify the low-pass filter cutoff in Hz.'};

lporder         = cfg_entry;
lporder.name    = 'Filter Order';
lporder.tag     = 'order';
lporder.strtype = 'i';
if isfield(settings.dcm{1,2}.filter,'lporder')
    lporder.val = {settings.dcm{1,2}.filter.lporder};
end
lporder.num     = [1 1];
lporder.help    = {'Specify the low-pass filter order.'};

enable_lp        = cfg_branch;
enable_lp.name   = 'Enable';
enable_lp.tag    = 'enable';
enable_lp.val    = {lpfreq, lporder};
enable_lp.help   = {''};

lowpass        = cfg_choice;
lowpass.name   = 'Low-Pass Filter';
lowpass.tag    = 'lowpass';
lowpass.val    = {enable_lp};
lowpass.values = {enable_lp, disable};
lowpass.help   = {''};

% High pass
hpfreq         = cfg_entry;
hpfreq.name    = 'Cutoff Frequency';
hpfreq.tag     = 'freq';
hpfreq.strtype = 'r';
if isfield(settings.dcm{1,2}.filter,'hpfreq')
    hpfreq.val = {settings.dcm{1,2}.filter.hpfreq};
end
hpfreq.num     = [1 1];
hpfreq.help    = {'Specify the high-pass filter cutoff in Hz.'};

hporder         = cfg_entry;
hporder.name    = 'Filter Order';
hporder.tag     = 'order';
hporder.strtype = 'i';
if isfield(settings.dcm{1,2}.filter,'hporder')
    hporder.val = {settings.dcm{1,2}.filter.hporder};
end
hporder.num     = [1 1];
hporder.help    = {'Specify the high-pass filter order.'};

enable_hp        = cfg_branch;
enable_hp.name   = 'Enable';
enable_hp.tag    = 'enable';
enable_hp.val    = {hpfreq, hporder};
enable_hp.help   = {''};

highpass        = cfg_choice;
highpass.name   = 'High-Pass Filter';
highpass.tag    = 'highpass';
highpass.val    = {enable_hp};
highpass.values = {enable_hp, disable};
highpass.help   = {''};

% Sampling rate
down         = cfg_entry;
down.name    = 'New Sampling Rate';
down.tag     = 'down';
down.strtype = 'r';
if isfield(settings.dcm{1,2}.filter,'down')
    down.val = {settings.dcm{1,2}.filter.down};
end
down.num     = [1 1];
down.help    = {'Specify the sampling rate in Hz to down sample SCR data. Enter NaN to leave the sampling rate unchanged.'};

% Filter direction
direction         = cfg_menu;
direction.name    = 'Filter Direction';
direction.tag     = 'direction';
direction.val     = {'bi'};
direction.labels  = {'Unidirectional', 'Bidirectional'};
direction.values  = {'uni', 'bi'};
direction.help    = {['A unidirectional filter is applied twice in the forward direction. ' ...
    'A "bidirectional" filter is applied once in the forward direction and once in the ' ...
    'backward direction to correct the temporal shift due to filtering in forward direction.']};

filter_edit        = cfg_branch;
filter_edit.name   = 'Edit Settings';
filter_edit.tag    = 'edit';
filter_edit.val    = {lowpass, highpass, down, direction};
filter_edit.help   = {'Create your own filter (discouraged).'};

filter_def        = cfg_const;
filter_def.name   = 'Default';
filter_def.tag    = 'def';
filter_def.val    = {0};
filter_def.help   = {['Standard settings for the Butterworth bandpass filter.']};

filter        = cfg_choice;
filter.name   = 'Filter Settings';
filter.tag    = 'filter';
filter.val    = {filter_def};
filter.values = {filter_def, filter_edit};
filter.help   = {'Specify how you want filter the SCR data.'};



%% Epochs
epochfile         = cfg_files;
epochfile.name    = 'Epoch File';
epochfile.tag     = 'epochfile';
epochfile.num     = [1 1];
epochfile.filter  = '.*\.(mat|MAT|txt|TXT)$';
epochfile.help    = {''};

epochentry         = cfg_entry;
epochentry.name    = 'Enter Epochs Manually';
epochentry.tag     = 'epochentry';
epochentry.strtype = 'r';
epochentry.num     = [Inf 2];
epochentry.help    = {''};

epochs        = cfg_choice;
epochs.name   = 'Epochs';
epochs.tag    = 'epochs';
epochs.values = {epochfile, epochentry};
epochs.help   = {''};

%% Marker Channel
mrk_chan         = cfg_entry;
mrk_chan.name    = 'Marker Channel';
mrk_chan.tag     = 'mrk_chan';
mrk_chan.strtype = 'i';
mrk_chan.val     = {0};
mrk_chan.num     = [1 1];
mrk_chan.help    = {['Indicate the marker channel. By default (value 0) the first marker channel is ' ...
    'assumed to contain the relevant markers.'], ['Markers are only used if you have ' ...
    'specified the time units as "markers".']};


%% Timeunits
seconds         = cfg_branch;
seconds.name    = 'Seconds';
seconds.tag     = 'seconds';
seconds.val     = {epochs};
seconds.help    = {''};

samples         = cfg_branch;
samples.name    = 'Samples';
samples.tag     = 'samples';
samples.val     = {epochs};
samples.help    = {''};

markers         = cfg_branch;
markers.name    = 'Markers';
markers.tag     = 'markers';
markers.val     = {epochs, mrk_chan};
markers.help    = {''};

whole         = cfg_const;
whole.name    = 'Whole';
whole.tag     = 'whole';
whole.val     = {'whole'};
whole.help    = {''};

timeunits         = cfg_choice;
timeunits.name    = 'Time Units';
timeunits.tag     = 'timeunits';
timeunits.values  = {seconds, samples, markers, whole};
timeunits.help    = {['Indicate the time units on which the specification of the conditions will be based. ' ...
    'Time units can be specified in "seconds", number of "markers", or number of data "samples". Time units ' ...
    'refer to the beginning of the data file and not to the beginning of the original recordings e.g. if ' ...
    'data were trimmed.']};

%% Channel nr
% Channel number default
chan_def         = cfg_const;
chan_def.name    = 'Default';
chan_def.tag     = 'chan_def';
chan_def.val     = {0};
chan_def.help    = {''};

% Channel number
chan_nr         = cfg_entry;
chan_nr.name    = 'Number';
chan_nr.tag     = 'chan_nr';
chan_nr.strtype = 'r';
chan_nr.num     = [1 1];
chan_nr.help    = {''};

% Channel
chan        = cfg_choice;
chan.name   = 'Channel';
chan.tag    = 'chan';
chan.val    = {chan_def};
chan.values = {chan_def, chan_nr};
chan.help   = {'Indicate the channel containing the SCR data.', ['By default the first SCR channel is ' ...
    'assumed to contain the data for this model.'], ['If the first SCR channel does not contain the data ' ...
    'for this model (e. g. there are two SCR channels), indicate the channel number (within the SCR file) ' ...
    'that contains the data for this model.']};

%% Overwrite file
overwrite         = cfg_menu;
overwrite.name    = 'Overwrite Existing File';
overwrite.tag     = 'overwrite';
overwrite.val     = {false};
overwrite.labels  = {'No', 'Yes'};
overwrite.values  = {false, true};
overwrite.help    = {'Specify whether you want to overwrite existing mat file.'};

%% Additional options for individual methods (hidden in GUI)
threshold         = cfg_entry;
threshold.name    = 'Threshold';
threshold.tag     = 'threshold';
threshold.strtype = 'r';
threshold.val     = {0.1};
threshold.help    = {'Threshold for SN detection.'};

theta         = cfg_entry;
theta.name    = 'Theta';
theta.tag     = 'theta';
theta.strtype = 'r';
theta.val     = {[]};
theta.help    = {'A (1 x 5) vector of theta values for f_SF.'};
theta.hidden  = true;

fresp         = cfg_entry;
fresp.name    = 'Response frequency';
fresp.tag     = 'fresp';
fresp.strtype = 'r';
fresp.val     = {[]};
fresp.help    = {'Frequency of responses to model.'};
fresp.hidden  = true;



missingepoch_none        = cfg_const;
missingepoch_none.name   = 'Not added';
missingepoch_none.tag    = 'missingdata';
missingepoch_none.val    = {0};
missingepoch_none.help   = {'Do not add missing epochs.'};

missingepoch_file         = cfg_files;
missingepoch_file.name    = 'Missing epoch file';
missingepoch_file.tag     = 'missingdata';
missingepoch_file.num     = [1 1];
missingepoch_file.filter  = '.*\.(mat|MAT)$';
missingepoch_file.help    = {['Missing (e.g. artefact) epochs in the data file, where ',...
                  'data must always be specified in seconds.']};

missing        = cfg_choice;
missing.name   = 'Missing Epoch Settings';
missing.tag    = 'missing';
missing.val    = {missingepoch_none};
missing.values = {missingepoch_none, missingepoch_file};
missing.help   = {'Specify whether you would like to include missing epochs.'};

% Show figures
dispwin         = cfg_menu;
dispwin.name    = 'Display Progress Window';
dispwin.tag     = 'dispwin';
dispwin.labels  = {'Yes', 'No'};
dispwin.val     = {1};
dispwin.values  = {1,0};
dispwin.help    = {['Show a on-line diagnostic plot for each iteration of the estimation process (DCM), ', ...
                   'or for the result of the estimation process (MP).']};

dispsmallwin         = cfg_menu;
dispsmallwin.name    = 'Display Intermediate Windows';
dispsmallwin.tag     = 'dispsmallwin';
dispsmallwin.labels  = {'No', 'Yes'};
dispsmallwin.val     = {0};
dispsmallwin.values  = {0,1};
dispsmallwin.help    = {'Show small plots displaying the progress of each iteration in the estimation process.'};

%% Executable branch
sf      = cfg_exbranch;
sf.name = 'SF';
sf.tag  = 'sf';
sf.val  = {datafile, modelfile, outdir, method, timeunits, filter, chan, overwrite, threshold, missing, theta, fresp, dispwin, dispsmallwin};
sf.prog = @pspm_cfg_run_sf;
sf.vout = @pspm_cfg_vout_sf;
sf.help = {['This suite of models is designed for analysing spontaneous fluctuations (SF) in skin conductance ' ...
    'as a marker for tonic arousal. SF are analysed over time windows that ' ...
    'typically last 60 s and should at least be 15 s long. PsPM implements 3 different models: '], '', ...
    '(1) Skin conductance level (SCL): this is the mean signal over the epoch', '', ...
    ['(2) Area under the curve (AUC): this is the time-integral of the above-minimum signal, divided by epoch ' ...
    'duration. This is designed to be independent from SCL and ideally represents the number x amplitude of ' ...
    'SF in this time window.'], '', ...
    ['(3) Number of SF estimated by DCM: this is a non-linear estimation of the number of SF, and is the most ' ...
    'ensitive indicator of tonic arousal. It relies on absolute data values as it implements and absolute ' ...
    'threshold for data peaks.'], '', 'References:', '', ...
    'Bach, Friston, Dolan (2010) International Journal of Psychophysiology (AUC)', '', ...
    'Bach, Daunizeau et al. (2011) Psychophysiology (DCM)', '', ...
    'Bach & Staib (2015) Psychophysiology (MP)'};

function vout = pspm_cfg_vout_sf(job)
vout = cfg_dep;
vout.sname      = 'Output File';
% this can be entered into any file selector
vout.tgt_spec   = cfg_findspec({{'class','cfg_files'}});
vout.src_output = substruct('()',{':'});
