function sf = pspm_cfg_sf

%% Initialise
global settings

%% Standard items
datafile            = pspm_cfg_selector_datafile;
channel             = pspm_cfg_selector_channel('SCR');
[modelfile, outdir] = pspm_cfg_selector_outputfile('model');
filter              = pspm_cfg_selector_filter(settings.dcm{2});
overwrite           = pspm_cfg_selector_overwrite;
% (see below for timeunits, requires specification of epochs item first)

%% Specific items
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

timeunits           = pspm_cfg_selector_timeunits('sf', epochs);

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


missingepoch_file         = cfg_files;
missingepoch_file.name    = 'Missing epoch file';
missingepoch_file.tag     = 'missingepoch_file';
missingepoch_file.num     = [1 1];
missingepoch_file.filter  = '.*\.(mat|MAT)$';
missingepoch_file.help    = {['Missing (e.g. artefact) epochs in the data file, where ',...
                  'data must always be specified in seconds.']};

missingepoch_none        = cfg_const;
missingepoch_none.name   = 'Do not add';
missingepoch_none.tag    = 'missingepoch_none';
missingepoch_none.val    = {0};
missingepoch_none.help   = {'Do not add missing epochs.'};

missingepoch_include         = cfg_branch;
missingepoch_include.name    = 'Add';
missingepoch_include.tag     = 'missingepoch_include';
missingepoch_include.val     = {missingepoch_file};
missingepoch_include.help    = {'Add missing epoch file'};

missing        = cfg_choice;
missing.name   = 'Missing Epoch Settings';
missing.tag    = 'missing';
missing.val    = {missingepoch_none};
missing.values = {missingepoch_none, missingepoch_include};
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
sf.val  = {datafile, modelfile, outdir, method, timeunits, filter, channel, overwrite, threshold, missing, theta, fresp, dispwin, dispsmallwin};
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
