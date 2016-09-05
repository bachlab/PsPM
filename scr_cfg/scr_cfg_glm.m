function [glm] = scr_cfg_glm(vars)
% function [glm] = scr_cfg_glm(vars)
%
% Matlabbatch function specifies the basic glm_module.
% Its called by scr_cfg_glm_<modalities> where modality specific settings
% are set. Then the struct is passed on to the next higher level of the
% matlabbatch configuration set.
%
% vars is a struct of text-variables. current vars are:
%   - modality
%   - modspec
%   - glmref
%   - glmhelp
%__________________________________________________________________________
% PsPM 3.0
% (C) 2015 Tobias Moser (University of Zurich)

% $Id$
% $Rev$

% Initialise
global settings
if isempty(settings), scr_init; end;

%% Modality undependent items
% Datafile
datafile         = cfg_files;
datafile.name    = 'Data File';
datafile.tag     = 'datafile';
datafile.num     = [1 1];
datafile.filter  = '.*\.(mat|MAT)$';
datafile.help    = {['Add the data file containing the ', vars.modality, ...
    ' data (and potential marker information). '...
    'If you have trimmed your data, add the file containing the trimmed data.']};

% Modelfile name
modelfile         = cfg_entry;
modelfile.name    = 'Model Filename';
modelfile.tag     = 'modelfile';
modelfile.strtype = 's';
modelfile.help    = {'Specify file name for the resulting model.'};

% Output directory
outdir         = cfg_files;
outdir.name    = 'Output Directory';
outdir.tag     = 'outdir';
outdir.filter  = 'dir';
outdir.num     = [1 1];
outdir.help    = {'Specify directory where the mat file with the resulting model will be written.'};

% Missing epochs
no_epochs         = cfg_const;
no_epochs.name    = 'No Missing Epochs';
no_epochs.tag     = 'no_epochs';
no_epochs.val     = {0};
no_epochs.help    = {'The whole time series will be analyzed.'};

epochfile         = cfg_files;
epochfile.name    = 'Missing Epoch File';
epochfile.tag     = 'epochfile';
epochfile.num     = [1 1];
epochfile.filter  = '.*\.(mat|MAT|txt|TXT)$';
epochfile.help    = {['Indicate an epoch file specifying the start and end points of missing epochs (m). ' ...
    'The mat file has to contain a variable ‘epochs’, which is an m x 2 array, where m is the number of ' ...
    'missing epochs. The first column marks the start points of the epochs that are excluded from the ' ...
    'analysis and the second column the end points.']};

epochentry         = cfg_entry;
epochentry.name    = 'Enter Missing Epochs Manually';
epochentry.tag     = 'epochentry';
epochentry.strtype = 'i';
epochentry.num     = [Inf 2];
epochentry.help    = {'Enter the start and end points of missing epochs (m) manually.', ...
    ['Specify an m x 2 array, where m is the number of missing epochs. The first column marks the ' ...
    'start points of the epochs that are excluded from the analysis and the second column the end points.']};

epochs        = cfg_choice;
epochs.name   = 'Define Missing Epochs';
epochs.tag    = 'epochs';
epochs.values = {epochfile, epochentry};
epochs.help   = {['Define the start and end points of the missing epochs either as epoch files ' ...
    'or manually. Missing epochs will be excluded from the design matrix. Start and end points ' ...
    'have to be defined in seconds starting from the beginning of the session.']};

missing        = cfg_choice;
missing.name   = 'Missing Epochs';
missing.tag    = 'missing';
missing.val    = {no_epochs};
missing.values = {no_epochs, epochs};
missing.help   = {['Indicate epochs in your data in which the ', vars.modality ...
    ,' signal is missing or corrupted (e.g., due to artifacts). NaN values ', ...
    'in the signal will be interpolated for filtering and downsampling ', ...
    'and later automatically removed from data and design matrix. ']};

% Condition file
condfile         = cfg_files;
condfile.name    = 'Condition File';
condfile.tag     = 'condfile';
condfile.num     = [1 1];
condfile.filter  = '.*\.(mat|MAT)$';
condfile.help    = {['Create a file with the following variables:'],
    ['– names: a cell array of string for the names of the experimental conditions'],
    ['– onsets: a cell array of number vectors for the onsets of events for '...
    'each experimental condition, expressed in seconds, marker numbers, '...
    'or samples, as specified in timeunits'],
    ['– durations (optional, default 0): a cell array of vectors for '...
    '  the duration of each event. You need to use ''seconds'' or ''samples'' as time units'],
    ['– pmod: this is used to specify regressors that specify how responses '...
    'in an experimental condition depend on a parameter to model the '... 
    'effect e.g. of habituation, reaction times, or stimulus ratings. pmod '...
    'is a struct array corresponding to names and onsets and containing the fields'],
    ['  * name: cell array of names for each parametric modulator for this condition'],
    ['  * param: cell array of vectors for each parameter for this condition, '...
    'containing as many numbers as there are onsets'],
    ['  * poly (optional, default 1): specifies the polynomial degree'],
    [' – e.g. produce a simple multiple condition file by typing: '...
    'names = {''condition a'', ''condition b''}; onsets = {[1 2 3], [4 5 6]}; '... 
    'save(''testfile'', ''names'', ''onsets'');']};

% Name
name         = cfg_entry;
name.name    = 'Name';
name.tag     = 'name';
name.strtype = 's';
%name.num     = [1 1];
name.help    = {'Specify the name of the parametric modulator.'}; % Help text for name of pmod

% Onsets
onsets         = cfg_entry;
onsets.name    = 'Onsets';
onsets.tag     = 'onsets';
onsets.strtype = 'r';
onsets.num     = [1 Inf];
onsets.help    = {['Specify a vector of onsets. The length of the vector corresponds to ' ...
    'the number of events included in this condition. Onsets have to be indicated in the ' ...
    'specified time unit (‘seconds’, ‘markers’, or ‘samples’).']};

% Parameter
param         = cfg_entry;
param.name    = 'Parameter Values';
param.tag     = 'param';
param.strtype = 'r';
param.num     = [1 Inf];
param.help    = {'Specify a vector with the same length as the vector for onsets.'};

% Polynomial degree
poly= cfg_entry;
poly.name    = 'Polynomial Degree';
poly.tag     = 'poly';
poly.strtype = 'r';
poly.num     = [1 1];
poly.val     = {1};
poly.help    = {['Specify an exponent that is applied to the parametric modulator. A value of 1 ' ...
    'leaves the parametric modulator unchanged and thus corresponds to a linear change over the ' ...
    'values of the parametric modulator (first-order). Higher order modulation introduces further ' ...
    'columns that contain the non-linear parametric modulators [e.g., second-order: (squared), third-order (cubed), etc].']};

% Name
pmodname         = cfg_entry;
pmodname.name    = 'Name';
pmodname.tag     = 'name';
pmodname.strtype = 's';
pmodname.help    = {'Specify the name of the parametric modulator.'};

% Pmod
pmod         = cfg_branch;
pmod.name    = 'Parametric Modulator';
pmod.tag     = 'pmod';
pmod.val     = {pmodname, poly, param};
pmod.help    = {''};

pmod_rep         = cfg_repeat;
pmod_rep.name    = 'Parametric Modulator(s)';
pmod_rep.tag     = 'pmod_rep';
pmod_rep.values  = {pmod};
pmod_rep.num     = [0 Inf];
pmod_rep.help    = {['If you want to include a parametric modulator, specify a vector with the same ' ...
    'length as the vector for onsets.'], ['For example, parametric modulators can model ' ...
    'reaction times, ratings of stimuli, or habituation effects over time. For each parametric ' ...
    'modulator a new regressor is included in the design matrix. The normalized parameters are ' ...
    'multiplied with the respective onset regressors.']};

% Durations vector
durations         = cfg_entry;
durations.name    = 'Durations';
durations.tag     = 'durations';
durations.strtype = 'r';
durations.num     = [1 Inf];
durations.val     = {0};
durations.help    = {['Typically, a duration of 0 is used to model an event onset. If all ' ...
    'events included in this condition have the same length specify just a single number. ' ...
    'If events have different durations, specify a vector with the same length as the vector for onsets.']};

% Name
condname         = cfg_entry;
condname.name    = 'Name';
condname.tag     = 'name';
condname.strtype = 's';
condname.help    = {'Specify the name of the condition.'}; % Help text for name of condition

% Conditions
condition         = cfg_branch;
condition.name    = 'Condition';
condition.tag     = 'condition';
condition.val     = {condname, onsets, durations, pmod_rep};
condition.help    = {''};

condition_rep         = cfg_repeat;
condition_rep.name    = 'Enter conditions manually';
condition_rep.tag     = 'condition_rep';
condition_rep.values  = {condition};
condition_rep.num     = [1 Inf];
condition_rep.help    = {'Specify the conditions that you want to include in your design matrix.'};

no_condition        = cfg_const;
no_condition.name   = 'No condition';
no_condition.tag    = 'no_condition';
no_condition.val    = {0};
no_condition.help   = {['If there is no condition, it is mandatory to ', ...
    'specify a nuisance file. (e. g. for illuminance GLM).']};

% Timing
timing         = cfg_choice;
timing.name    = 'Design';
timing.tag     = 'data_design';
timing.values  = {condfile, condition_rep, no_condition};
timing.help    = {['Specify the timing of the events within the design matrix. Timing can '...
    'be specified in ‘seconds’, ‘markers’ or ‘samples’ with respect to the beginning of the ' ...
    'data file. See ‘Time Units’ settings. Conditions can be specified manually or by using ' ...
    'multiple condition files (i.e., an SPM-style mat file).']};

% Nuisance
nuisancefile         = cfg_files;
nuisancefile.name    = 'Nuisance File';
nuisancefile.tag     = 'nuisancefile';
nuisancefile.num     = [0 1];
nuisancefile.val{1}  = {''};
nuisancefile.filter  = '.*\.(mat|MAT|txt|TXT)$';
nuisancefile.help    = {['You can include nuisance parameters such as motion parameters in ' ...
    'the design matrix. Nuisance parameters are not convolved with the canonical response function. ', ...
    'This is also used for the illuminance GLM.'], ...
    ['The file has to be either a .txt file containing the regressors in columns, or a .mat file containing ' ...
    'the regressors in a matrix variable called R. There must be as many values for each column of R as there ' ...
    'are data values in your data file. PsPM will call the regressors pertaining to the different columns R1, R2, ...']};

% Sessions
session        = cfg_branch;
session.name   = 'Session';
session.tag    = 'session';
session.val    = {datafile, missing, timing, nuisancefile};
session.help   = {''};

session_rep         = cfg_repeat;
session_rep.name    = 'Data & Design';
session_rep.tag     = 'session_rep';
session_rep.values  = {session};
session_rep.num     = [1 Inf];
session_rep.help    = {'Add the appropriate number of sessions here. These will be concatenated.'};

% Marker Channel
mrk_chan         = cfg_entry;
mrk_chan.name    = 'Marker Channel';
mrk_chan.tag     = 'mrk_chan';
mrk_chan.strtype = 'i';
mrk_chan.val     = {0};
mrk_chan.num     = [1 1];
mrk_chan.help    = {['Indicate the marker channel. By default the first marker channel is ' ...
    'assumed to contain the relevant markers.'], ['Markers are only used if you have ' ...
    'specified the time units as ‘markers’.']};

% Timeunits
seconds         = cfg_const;
seconds.name    = 'Seconds';
seconds.tag     = 'seconds';
seconds.val     = {'seconds'};
seconds.help    = {''};

samples         = cfg_const;
samples.name    = 'Samples';
samples.tag     = 'samples';
samples.val     = {'samples'};
samples.help    = {''};

markers         = cfg_branch;
markers.name    = 'Markers';
markers.tag     = 'markers';
markers.val     = {mrk_chan};
markers.help    = {''};

timeunits         = cfg_choice;
timeunits.name    = 'Time Units';
timeunits.tag     = 'timeunits';
timeunits.values = {seconds, samples, markers};
timeunits.help    = {['Indicate the time units on which the specification of the conditions ' ...
    'will be based. Time units can be specified in ‘seconds’, number of ‘markers’, or number ' ...
    'of data ‘samples’ . Time units refer to the beginning of the data file and not to the ' ...
    'beginning of the original recordings e. g. if data were trimmed.']};

% Normalize
norm         = cfg_menu;
norm.name    = 'Normalize';
norm.tag     = 'norm';
norm.val     = {false};
norm.labels  = {'No', 'Yes'};
norm.values  = {false, true};
norm.help    = {['Specify if you want to z-normalize the ', vars.modality, ' data for each subject. For within-subjects ' ...
    'designs, this is highly recommended, but for between-subjects designs it needs to be set to "no". ']};

% Channel
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

chan         = cfg_choice;
chan.name    = [vars.modality, ' Channel'];
chan.tag     = 'chan';
chan.val     = {chan_def};
chan.values  = {chan_def,chan_nr};
chan.help    = {['Indicate the channel containing the ', vars.modality, ' data.'], ['By default ' ...
    'the first ', vars.modality ,' channel is assumed to contain the data for this model.'], ...
    ['If the first ', vars.modality, ' channel does not contain the data for this', ...
    ' model (e. g. there are two ', vars.modality, ' channels), ' ...
    'indicate the the channel number (within the ', vars.modality, ...
    ' file) that contains the data for this model.']};

% Overwrite File
overwrite         = cfg_menu;
overwrite.name    = 'Overwrite Existing File';
overwrite.tag     = 'overwrite';
overwrite.val     = {false};
overwrite.labels  = {'No', 'Yes'};
overwrite.values  = {false, true};
overwrite.help    = {'Specify whether you want to overwrite existing mat files.'};


%% Modality dependent items
% Basis function
% SCRF
for i=1:3
    scrf{i}        = cfg_const;
    scrf{i}.name   = ['SCRF ' num2str(i-1)];
    scrf{i}.tag    = ['scrf' num2str(i-1)];
    scrf{i}.val    = {i-1};
end
scrf{1}.help   = {'SCRF without derivatives.'};
scrf{2}.help   = {'SCRF with time derivative (default).'};
scrf{3}.help   = {'SCRF with time and dispersion derivative.'};

%FIR
n         = cfg_entry;
n.name    = 'N: Number of Time Bins';
n.tag     = 'n';
n.strtype = 'i';
n.num     = [1 1];
n.help    = {'Number of time bins.'};

d         = cfg_entry;
d.name    = 'D: Duration of Time Bins';
d.tag     = 'd';
d.strtype = 'r';
d.num     = [1 1];
d.help    = {'Duration of time bins (in seconds).'};

arg        = cfg_branch;
arg.name   = 'Arguments';
arg.tag    = 'arg';
arg.val    = {n, d};
arg.help   = {''};

fir        = cfg_branch;
fir.name   = 'FIR';
fir.tag    = 'fir';
fir.val    = {arg};
fir.help   = {'Uninformed finite impulse response (FIR) model: specify the number and duration of time bins to be estimated.'};

bf        = cfg_choice;
bf.name   = 'Basis Function';
bf.tag    = 'bf';
bf.val    = {scrf{2}};
bf.values = {scrf{:}, fir};
bf.help   = {['Basis functions. Standard is to use a canonical skin conductance response function ' ...
    '(SCRF) with time derivative for later reconstruction of the response peak.']};

%% Filter settings
% try to get default settings for filter
f = strcmpi({settings.glm.modelspec}, vars.modspec);
def_filt = settings.glm(f).filter;

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
if isfield(def_filt,'lpfreq')
    lpfreq.val = {def_filt.lpfreq};
end
lpfreq.num     = [1 1];
lpfreq.help    = {'Specify the low-pass filter cutoff in Hz.'};

lporder         = cfg_entry;
lporder.name    = 'Filter Order';
lporder.tag     = 'order';
lporder.strtype = 'i';
if isfield(def_filt,'lporder')
    lporder.val = {def_filt.lporder};
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
if isfield(def_filt,'hpfreq')
    hpfreq.val = {def_filt.hpfreq};
end
hpfreq.num     = [1 1];
hpfreq.help    = {'Specify the high-pass filter cutoff in Hz.'};

hporder         = cfg_entry;
hporder.name    = 'Filter Order';
hporder.tag     = 'order';
hporder.strtype = 'i';
if isfield(def_filt,'hporder')
    hporder.val = {def_filt.hporder};
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
if isfield(def_filt,'down')
    down.val = {def_filt.down};
end
down.num     = [1 1];
down.help    = {['Specify the sampling rate in Hz to down sample ', vars.modality, ' data.', ...
    ' Enter NaN to leave the sampling rate unchanged.']};

% Filter direction
direction         = cfg_menu;
direction.name    = 'Filter Direction';
direction.tag     = 'direction';
if isfield(def_filt, 'direction')
    direction.val = {def_filt.direction};
else
    direction.val     = {'uni'};
end;
direction.labels  = {'Unidirectional', 'Bidirectional'};
direction.values  = {'uni', 'bi'};
direction.help    = {['A unidirectional filter is applied twice in the forward direction. ' ...
    'A ‘bidirectional’ filter is applied once in the forward direction and once in the ' ...
    'backward direction to correct the temporal shift due to filtering in forward direction.']};

filter_edit        = cfg_branch;
filter_edit.name   = 'Edit Settings';
filter_edit.tag    = 'edit';
filter_edit.val    = {lowpass, highpass, down, direction};
filter_edit.help   = {'Create your own filter settings (discouraged).'};

filter_def        = cfg_const;
filter_def.name   = 'Default';
filter_def.tag    = 'def';
filter_def.val    = {0};
filter_def.help   = {['Standard settings for the Butterworth bandpass filter. These are the optimal ' ...
    'settings for ', vars.modality, ' data.']};

filter        = cfg_choice;
filter.name   = 'Filter Settings';
filter.tag    = 'filter';
filter.val    = {filter_def};
filter.values = {filter_def, filter_edit};
filter.help   = {['Specify how you want filter the ',vars.modality,' data.']};


%% Executable Branch
glm       = cfg_exbranch;
glm.name  = 'GLM';
glm.tag   = 'glm';
glm.val   = {modelfile, outdir, chan, timeunits, session_rep, bf, norm, filter, overwrite};
%glm_scr.prog  = ;
glm.vout  = @scr_cfg_vout_glm;
glm.help  = {...
    vars.glmhelp, ...
    ['General linear convolution models (GLM) are powerful for analysing evoked responses that ' ...
    'follow an event with (approximately) fixed latency. This is similar to standard analysis of fMRI data. ' ...
    'The user specifies events for different conditions. These are used to estimate the mean response amplitude ' ...
    'per condition. These mean amplitudes can later be compared, using the contrast manager.'], '', ...
    'References: ', '', ...
    vars.glmref{:} ...
    };

function vout = scr_cfg_vout_glm(job)
vout = cfg_dep;
vout.sname      = 'Output File';
% this can be entered into any file selector
vout.tgt_spec   = cfg_findspec({{'class','cfg_files'}});
vout.src_output = substruct('.','modelfile');
