function dcm = pspm_cfg_dcm
% DCM

% $Id: pspm_cfg_dcm.m 626 2019-02-20 16:14:40Z lciernik $
% $Rev: 626 $

% Initialise
global settings
if isempty(settings), pspm_init; end;

% Datafile
datafile         = cfg_files;
datafile.name    = 'Data File';
datafile.tag     = 'datafile';
datafile.num     = [1 1];
datafile.filter  = '.*\.(mat|MAT)$';
datafile.help    = {['Add the data file containing the SCR data. If you ',...
                     'have trimmed your data, add the file containing the' ,...
                     'trimmed data.'],' ',settings.datafilehelp};

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
chan.name    = 'SCR channel';
chan.tag     = 'chan';
chan.val     = {chan_def};
chan.values  = {chan_def,chan_nr};
chan.help    = {['Indicate the channel containing the SCR data.'], ['By default ' ...
    'the first SCR channel is assumed to contain the data for this model.'], ['If the first ' ...
    'SCR channel does not contain the data for this model (e. g. there are two SCR channels), ' ...
    'indicate the the channel number (within the SCR file) that contains the data for this model.']};

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

% Parameter estimation
timingfile         = cfg_files;
timingfile.name    = 'Timing File';
timingfile.tag     = 'timingfile';
timingfile.num     = [1 1];
%timingfile.filter  = '.*\.(mat|MAT)$';
timingfile.help    = {['The timing file has to be a .mat file containing a cell array called "epochs". ' ...
    'For a design with n trials and m events per trial (n x m events in total), the cell array has to be ' ...
    'structured in the following way:'], '', ['Create m cells in the cell array (one per event ' ...
    'type that occurs in each trial). Each cell defines either a fixed or a flexible event type.', ...
    'A cell that defines a fixed event type has to contain a vector with n entries, i.e. one time point per ' ...
    'trial, in seconds, samples or markers.'], ['A cell that defines a flexible type has to contain an ' ...
    'array with n rows and two columns. The first column specifies the onsets of the time windows for each trial, ' ...
    'while the second column specifies the offsets of the time windows.'] ,'', ['It is assumed that ' ...
    'all trials have the same structure, i.e. the same number of fixed and flexible event types. For individual ' ...
    'trials with a different structure you can enter negative values as time information to omit estimation of a ' ...
    'response.'], '', ['For later comparison between trials of different conditions, it is absolutely mandatory ' ...
    'that they contain the same types of events, to avoid bias. Hence, if one condition omits an event (e. g. ' ...
    'unreinforced trials in conditioning experiments), the omitted event needs to be modelled as well.']};

name         = cfg_entry;
name.name    = 'Name';
name.tag     = 'name';
name.strtype = 's';
name.val     = {''};
name.help    = {'Optional: Enter a name of the event.  This name can later be used for display and export.'};

onsets         = cfg_entry;
onsets.name    = 'Onsets';
onsets.tag     = 'onsets';
onsets.strtype = 'r';
onsets.num     = [Inf Inf];
onsets.help    = {['For events with a fixed response, specify a vector of onsets. The length of the ' ...
    'vector corresponds to the number of trials (n).'], '', ['For events with a flexible response, ' ...
    'specify a two column array. The first column defines the onset of the time window in which the ' ...
    'response occurs. The second column defines the offset. The number of rows of the array corresponds ' ...
    'to the number of trials (n).'], '', ['All timings have to be indicated in seconds.']};


timing_man       = cfg_branch;
timing_man.name  = 'Event';
timing_man.tag   = 'timing_man';
timing_man.val   = {name, onsets};
timing_man.help  = {''};

timing_man_rep        = cfg_repeat;
timing_man_rep.name   = 'Enter Timing Manually';
timing_man_rep.tag    = 'timing_man_rep';
timing_man_rep.values = {timing_man};
timing_man_rep.num   = [1 Inf];
timing_man_rep.help   = {['In the DCM framework, a session is structured in n individual trials. Each trial ' ...
    'contains m fixed and/or flexible event types. All trials need to have the same structure.'], '', ...
    'Create m event types to define the structure of a trial and enter the timings for all events.'};


timing        = cfg_choice;
timing.name   = 'Design';
timing.tag    = 'timing';
timing.values = {timingfile, timing_man_rep};
timing.help   = {['Specify the timings of individual events from your design either by creating a timing file ' ...
    'or by entering the timings manually.'], 'The DCM framework allows you to specify two types of events:', '', ...
    ['Fixed latency (evoked): An event is assumed to elicit an immediate response. The amplitude of the sympathetic ' ...
    'arousal will be estimated, while the timing latency  and duration of the response are fixed. This event type ' ...
    'is meant to model evoked responses.'], '', ['Flexible latency and duration (event-related): An event is ' ...
    'assumed to elicit sympathetic arousal within a known response window, but with unknown amplitude, latency and ' ...
    'duration. For each event of this type, specify a time window in which the response is expected. PsPM will ' ...
    'then estimate the amplitude, duration and latency of the response. An example for this type of event is an ' ...
    'anticipatory response which might vary in timing between trials (e. g. in fear conditioning).']};

% Condition name
condname         = cfg_entry;
condname.name    = 'Name';
condname.tag     = 'name';
condname.strtype = 's';
condname.help    = {'Specify the name of the condition.'};

% Condition index
condindex         = cfg_entry;
condindex.name    = 'Index';
condindex.tag     = 'index';
condindex.strtype = 'i';
condindex.num     = [1 Inf];
condindex.help    = {['Specify a vector of trial indices between 1 and n. The length of the vector ' ...
    'corresponds to the number of events included in this condition.']};

% Conditions
condition         = cfg_branch;
condition.name    = 'Condition';
condition.tag     = 'condition';
condition.val     = {condname, condindex};
condition.help    = {''};

condition_rep         = cfg_repeat;
condition_rep.name    = 'Condition names';
condition_rep.tag     = 'condition_rep';
condition_rep.values  = {condition};
condition_rep.num     = [0 Inf];
condition_rep.check   = @pspm_cfg_dcm_check_conditions;
condition_rep.help    = {['Optional: Specify the conditions that the individual trials belong to.'], ['This information ' ...
    'is not used for the parameter estimation of the DCM routine, but it allows you to later access the ' ...
    'conditions in the contrast manager.']};

% Missing epochs
no_epochs         = cfg_const;
no_epochs.name    = 'No Missing Epochs';
no_epochs.tag     = 'no_epochs';
no_epochs.val     = {0};
no_epochs.help    = {['Missing epochs are detected automatically ', ...
    'according to the data option ''Subsession threshold''.']};

epochfile         = cfg_files;
epochfile.name    = 'Missing Epoch File';
epochfile.tag     = 'epochfile';
epochfile.num     = [1 1];
epochfile.filter  = '.*\.(mat|MAT|txt|TXT)$';
epochfile.help    = {['Indicate an epoch file specifying the start and ', ...
    'end points of missing epochs (m). The mat file has to contain a ', ...
    'variable ''epochs'', which is an m x 2 array, where m is the number of' ...
    ' missing epochs. The first column marks the start points ', ...
    'of the epochs that are excluded from the ' ...
    'analysis and the second column the end points.']};

epochentry         = cfg_entry;
epochentry.name    = 'Enter Missing Epochs Manually';
epochentry.tag     = 'epochentry';
epochentry.strtype = 'i';
epochentry.num     = [Inf 2];
epochentry.help    = {['Enter the start and end points of missing epochs ', ...
    '(m) manually.'], ['Specify an m x 2 array, where m is the number ', ...
    'of missing epochs. The first column marks the ' ...
    'start points of the epochs that are excluded from the analysis ', ...
    'and the second column the end points.']};

epochs        = cfg_choice;
epochs.name   = 'Define Missing Epochs';
epochs.tag    = 'epochs';
epochs.values = {epochfile, epochentry};
epochs.help   = {['Define the start and end points of the missing ', ...
    'epochs either as epoch files or manually. Start and end ', ...
    'points have to be defined in seconds starting from the ', ...
    'beginning of the session.']};

missing        = cfg_choice;
missing.name   = 'Missing Epochs';
missing.tag    = 'missing';
missing.val    = {no_epochs};
missing.values = {no_epochs, epochs};
missing.help   = {['Indicate epochs in your data in which the ', ...
    'signal is missing or corrupted (e.g., due to artifacts). ', ...
    'Data around missing epochs are split into subsessions and ', ...
    'are evaluated independently if the missing epoch is at least as long ', ...
    'as subsession threshold. NaN periods within the ', ...
    'evaluated subsessions will be interpolated for averages ', ...
    'and principal response components.'], ...
    ['Note: pspm_dcm calculates the inter-trial intervals as the ',...
    'duration between the end of a trial and the start of the next ',...
    'one. ITI value for the last trial in a session is calculated as ',...
    'the duration between the end of the last trial and the end of ',...
    'the whole session. Since this value may differ significantly ',...
    'from the regular ITI duration values, it is not used when computing ',...
    'the minimum ITI duration of a session.'], ...
    ['Minimum of session specific min ITI values is used'], ...
    ['  1. when computing mean SCR signal'], ...
    ['  2. when computing the PCA from all the trials in all the sessions.'],...
    ['In case of case (2), after each trial, all the samples in the period ',...
    'with duration equal to the just mentioned overall min ITI value is used ',...
    'as a row of the input matrix. Since this minimum does not use the min ',...
    'ITI value of the last trial in each session, the sample period may be ',...
    'longer than the ITI value of the last trial. In such a case, pspm_dcm ',...
    'is not able to compute the PCA and emits a warning. ',...
    'The rationale behind this behaviour is that we observed that ITI value ',...
    'of the last trial in a session might be much smaller than the usual ITI ',...
    'values. For example, this can happen when a long missing data section ',...
    'starts very soon after the beginning of a trial. If this very small ITI ',...
    'value is used to define the sample periods after each trial, nearly all ',...
    'the trials use much less than available amount of samples in both case (1) ',...
    'and (2). Instead, we aim to use as much data as possible in (1), and ',...
    'perform (2) only if this edge case is not present.']};

% Sessions
session        = cfg_branch;
session.name   = 'Session';
session.tag    = 'session';
session.val    = {datafile, timing, condition_rep, missing};
session.help   = {''};

session_rep         = cfg_repeat;
session_rep.name    = 'Data & design';
session_rep.tag     = 'session_rep';
session_rep.values  = {session};
session_rep.num     = [1 Inf];
session_rep.help    = {'Add the appropriate number of sessions here.'};


%% Data options
% Normalization
norm         = cfg_menu;
norm.name    = 'Normalization';
norm.tag     = 'norm';
norm.labels  = {'No', 'Yes'};
norm.val     = {0};
norm.values  = {0,1};
norm.help    = {['Specify if you want to normalize the SCR data for each subject. For within-subjects designs, ' ...
    'this is highly recommended.']};

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
if isfield(settings.dcm{1,1}.filter,'lpfreq')
    lpfreq.val = {settings.dcm{1,1}.filter.lpfreq};
end
lpfreq.num     = [1 1];
lpfreq.help    = {'Specify the low-pass filter cutoff in Hz.'};

lporder         = cfg_entry;
lporder.name    = 'Filter Order';
lporder.tag     = 'order';
lporder.strtype = 'i';
if isfield(settings.dcm{1,1}.filter,'lporder')
    lporder.val = {settings.dcm{1,1}.filter.lporder};
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
if isfield(settings.dcm{1,1}.filter,'hpfreq')
    hpfreq.val = {settings.dcm{1,1}.filter.hpfreq};
end
hpfreq.num     = [1 1];
hpfreq.help    = {'Specify the high-pass filter cutoff in Hz.'};

hporder         = cfg_entry;
hporder.name    = 'Filter Order';
hporder.tag     = 'order';
hporder.strtype = 'i';
if isfield(settings.dcm{1,1}.filter,'hporder')
    hporder.val = {settings.dcm{1,1}.filter.hporder};
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
if isfield(settings.dcm{1,1}.filter,'down')
    down.val = {settings.dcm{1,1}.filter.down};
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
    'A ''bidirectional'' filter is applied once in the forward direction and once in the ' ...
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
filter_def.help   = {['Standard settings for the Butterworth bandpass filter. These are the optimal ' ...
    'settings from the paper by Staib, Castegnetti & Bach (2015).']};

filter        = cfg_choice;
filter.name   = 'Filter Settings';
filter.tag    = 'filter';
filter.val    = {filter_def};
filter.values = {filter_def, filter_edit};
filter.help   = {'Specify how you want filter the SCR data.'};

substhresh          = cfg_entry;
substhresh.name     = 'Subsession threshold';
substhresh.tag      = 'substhresh';
substhresh.val      = {2};
substhresh.strtype  = 'r';
substhresh.num      = [1 1];
substhresh.help     = {['Specify the minimum duration (in seconds) ', ...
    'of NaN periods to be considered as missing epochs. Data around ', ...
    'missing epochs is then split into subsessions, which are ', ...
    'evaluated independently. This setting is ignored for sessions ', ...
    'having set missing epochs manually.']};

% constrained model 
constrained_model       = cfg_entry;
constrained_model.name  ='Constrained model';
constrained_model.tag   ='constr_model';
constrained_model.val   = {0};
constrained_model.strtype = 'i';
constrained_model.num   = [1 1];
constrained_model.help = {['This option can be set to one if the flexible ', ...
                           'responses have fixed dispersion (0.3 s SD) but', ...
                           ' flexible latency.', ...
                           ' If the option is set, the value must be 0 or 1.',...
                           ' The default value is 0']};


data_options         = cfg_branch;
data_options.name    = 'Data Options';
data_options.tag     = 'data_options';
data_options.val     = {norm, filter, substhresh,constrained_model};
data_options.help    = {''};


%% Response function options
% CRF update
crfupdate         = cfg_menu;
crfupdate.name    = 'CRF Update';
crfupdate.tag     = 'crfupdate';
crfupdate.labels  = {'Use Pre-Estimated Priors', 'Update CRF Priors to Observed SCRF'};
crfupdate.val     = {0};
crfupdate.values  = {0,1};
crfupdate.help    = {['Update the priors of the canonical response function to observed skin conductance ' ...
    'response function, or use pre-estimated priors (default)']};
crfupdate.hidden = true;

% Estimate the response function from the data
indrf         = cfg_menu;
indrf.name    = 'Estimate the Response Function from The Data';
indrf.tag     = 'indrf';
indrf.labels  = {'No', 'Yes'};
indrf.val     = {0};
indrf.values  = {0,1};
indrf.help    = {['A response function can be estimated from the data and used instead of the canonical ' ...
    'response function. This is not ' ...
    'normally recommended unless you have long inter trial intervals in the range of 20-30 s (see Staib, Castegnetti & Bach, 2015)']};

% Only estimate RF
getrf         = cfg_menu;
getrf.name    = 'Only Estimate RF (Do Not Do Trial-Wise DCM)';
getrf.tag     = 'getrf';
getrf.labels  = {'No', 'Yes'};
getrf.val     = {0};
getrf.values  = {0,1};
getrf.help    = {['This option can be used to estimate an individual response function to be used in ' ...
    'analysis of another experiment.']};

% Call External File to Provide Response Function
rf         = cfg_menu;
rf.name    = 'Use External File to Provide Response Function';
rf.tag     = 'rf';
rf.labels  = {'No', 'Yes'};
rf.val     = {0};
rf.values  = {0,1};
rf.help    = {['Call an external file to provide a response function, which was previously estimated ' ...
    'using the option "only estimate RF"']};

resp_options         = cfg_branch;
resp_options.name    = 'Response Function Options';
resp_options.tag     = 'resp_options';
resp_options.val     = {crfupdate, indrf, getrf, rf};
resp_options.help    = {''};


%% Inversion options
% No of trials to invert at the same time
depth         = cfg_entry;
depth.name    = 'Number of Trials to Invert at The Same Time';
depth.tag     = 'depth';
depth.strtype = 'i';
depth.num     = [1 1];
depth.val     = {2};
depth.help    = {['The iterative DCM algorithm accounts for response overlap by cosidering several trials at a time. ' ...
    'This can be set here.']};

% SF-free window before first event
sfpre         = cfg_entry;
sfpre.name    = 'SF-Free Window Before First Event [s]';
sfpre.tag     = 'sfpre';
sfpre.strtype = 'r';
sfpre.num     = [1 1];
sfpre.val     = {2};
sfpre.help    = {['The DCM algorithm automatically models spontaneous fluctuations in inter trial intervals. Here, you can ' ...
    'define a time window before the first event in every trial in which no spontaneous fluctuation will be estimated.']};

% SF-free window after last event
sfpost         = cfg_entry;
sfpost.name    = 'SF-Free Window After Last Event [s]';
sfpost.tag     = 'sfpost';
sfpost.strtype = 'r';
sfpost.num     = [1 1];
sfpost.val     = {5};
sfpost.help    = {['The DCM algorithm automatically models spontaneous fluctuations in inter trial intervals. Here, you can ' ...
    'define a time window after the last event in every trial in which no spontaneous fluctuation will be estimated.']};

% Maximum frequency of SF in ITIs
sffreq         = cfg_entry;
sffreq.name    = 'Maximum Frequency of SF in ITIs [Hz]';
sffreq.tag     = 'sffreq';
sffreq.strtype = 'r';
sffreq.num     = [1 1];
sffreq.val     = {0.5};
sffreq.help    = {['The DCM algorithm automatically models spontaneous fluctuations in inter trial intervals. Here you can ' ...
'define the minimal delay between two subsequent spontaneous fluctuations.']};

% SCL-change-free window before first event
sclpre         = cfg_entry;
sclpre.name    = 'SCL-Change-Free Window Before First Event [s]';
sclpre.tag     = 'sclpre';
sclpre.strtype = 'r';
sclpre.num     = [1 1];
sclpre.val     = {2};
sclpre.help    = {['The DCM algorithm automatically models baseline drifts in inter trial intervals. Here, you can ' ...
    'define a window before the first event in every trial in which no change of the skin conductance level will be assumed.']};

% SCL-change-free window after last event
sclpost         = cfg_entry;
sclpost.name    = 'SCL-Change-Free Window After Last Event [s]';
sclpost.tag     = 'sclpost';
sclpost.strtype = 'r';
sclpost.num     = [1 1];
sclpost.val     = {5};
sclpost.help    = {['The DCM algorithm automatically models baseline drifts in inter trial intervals. Here, you can ' ...
    'define a window after the last event in every trial in which no change of the skin conductance level will be assumed.']};

% minimum dispersion (standard deviation) for flexible responses
ascr_sigma_offset         = cfg_entry;
ascr_sigma_offset.name    = 'Minimum Dispersion (Standard Deviation) for Flexible Responses [s]';
ascr_sigma_offset.tag     = 'ascr_sigma_offset';
ascr_sigma_offset.strtype = 'r';
ascr_sigma_offset.num     = [1 1];
ascr_sigma_offset.val     = {0.1};
ascr_sigma_offset.help    = {['Responses in a flexible design are modeled as Gaussians with a flexible standard deviation ' ...
    '(while fixed responses assume a fixed standard deviation). While the maximum standard deviation is limited by half ' ...
    'the window size of the response window, the minimum standard deviation can be changed by the user.']};
ascr_sigma_offset.hidden = true;

inv_options         = cfg_branch;
inv_options.name    = 'Inversion Options';
inv_options.tag     = 'inv_options';
inv_options.val     = {depth, sfpre, sfpost, sffreq, sclpre, sclpost, ascr_sigma_offset};
inv_options.help    = {''};


%% Display options

% Display proress window
dispwin         = cfg_menu;
dispwin.name    = 'Display Progress Window';
dispwin.tag     = 'dispwin';
dispwin.labels  = {'Yes', 'No'};
dispwin.val     = {1};
dispwin.values  = {1,0};
dispwin.help    = {'Show a on-line diagnostic plot for each iteration of the estimation process.'};

% Display intermediate windows
dispsmallwin         = cfg_menu;
dispsmallwin.name    = 'Display Intermediate Windows';
dispsmallwin.tag     = 'dispsmallwin';
dispsmallwin.labels  = {'No', 'Yes'};
dispsmallwin.val     = {0};
dispsmallwin.values  = {0,1};
dispsmallwin.help    = {'Show small plots displaying the progress of each iteration in the estimation process.'};

disp_options         = cfg_branch;
disp_options.name    = 'Display Options';
disp_options.tag     = 'disp_options';
disp_options.val     = {dispwin, dispsmallwin};
disp_options.help    = {''};


%% Executable branch
dcm      = cfg_exbranch;
dcm.name = 'Non-Linear Model';
dcm.tag  = 'dcm';
dcm.val  = {modelfile, outdir, chan, session_rep, data_options, resp_options, inv_options, disp_options};
dcm.prog = @pspm_cfg_run_dcm;
dcm.vout = @pspm_cfg_vout_dcm;
dcm.help = {['Non-linear models for SCR are powerful if response timing is not precisely known and has to be ' ...
    'estimated. A typical example are anticipatory SCR in fear conditioning – they must occur at some point ' ...
    'within a time-window of several seconds duration, but that time point may vary over trials. Dynamic ' ...
    'causal modelling (DCM) is the framework for parameter estimation. PsPM implements an iterative ' ...
    'trial-by-trial algorithm. Different from GLM, response parameters are estimated per trial, not per ' ...
    'condition, and the algorithm must not be informed about the condition. Trial-by-trial response parameters ' ...
    'can later be summarized across trials, and compared between conditions, using the contrast manager.'], '', ...
    'References:', '', ...
    'Bach, Daunizeau et al. (2010) Biological Psychology (Model development)', '', ...
    'Staib et al. (2015) Journal of Neuroscience Methods (Optimising a model-based approach)'};

function vout = pspm_cfg_vout_dcm(job)
vout = cfg_dep;
vout.sname      = 'Output File';
% this can be entered into any file selector
vout.tgt_spec   = cfg_findspec({{'class','cfg_files'}});
vout.src_output = substruct('()',{':'});

function [sts, val] = pspm_cfg_dcm_check_conditions(val)
sts = [];
nrCond = size(val,2);
testVec = [];
for iCond=1:nrCond
    indexLength = length(val(1,iCond).index);
    testVec(end+1:end+indexLength) = val(1,iCond).index;
end
if length(testVec) ~= length(unique(testVec))
    sts = sprintf('At least one index is used more than once.\nPlease use each index only once.');
end
if ~isempty(sts) uiwait(msgbox(sts,'Index Error')); end
