
function pp_heart_data = pspm_cfg_pp_heart_data

% Updated 27-Mar-2024 by Teddy

% Initialise
global settings
if isempty(settings), pspm_init; end

% Preprocess ECG data
% Data File
datafile         = cfg_files;
datafile.name    = 'Data File';
datafile.tag     = 'datafile';
datafile.num     = [1 1];
%datafile.filter  = '.*\.(mat|MAT)$';
datafile.help    = {'Specify data file.',' ',settings.datafilehelp};

ecg2hb_chan = pspm_cfg_channel_selector('ECG');

ecg2hb_minhr         = cfg_entry;
ecg2hb_minhr.name    = 'Min Heart Rate';
ecg2hb_minhr.tag     = 'minhr';
ecg2hb_minhr.strtype = 'r';
ecg2hb_minhr.num     = [1 1];
ecg2hb_minhr.val     = {30};
ecg2hb_minhr.help    = {''};
ecg2hb_minhr.hidden  = true;

ecg2hb_maxhr         = cfg_entry;
ecg2hb_maxhr.name    = 'Max Heart Rate';
ecg2hb_maxhr.tag     = 'maxhr';
ecg2hb_maxhr.strtype = 'r';
ecg2hb_maxhr.num     = [1 1];
ecg2hb_maxhr.val     = {200};
ecg2hb_maxhr.help    = {''};
ecg2hb_maxhr.hidden  = true;

ecg2hb_semi         = cfg_menu;
ecg2hb_semi.name    = 'Semi automatic mode';
ecg2hb_semi.tag     = 'semi';
ecg2hb_semi.val     = {0};
ecg2hb_semi.values  = {0,1};
ecg2hb_semi.labels  = {'Off', 'On'};
ecg2hb_semi.help    = {'Allows manual correction of all potential beat intervals.'};

ecg2hb_twthresh     = cfg_entry;
ecg2hb_twthresh.name = 'T wave threshold';
ecg2hb_twthresh.tag = 'twthresh';
ecg2hb_twthresh.strtype = 'r';
ecg2hb_twthresh.num = [1 1];
ecg2hb_twthresh.val = {0.36};
ecg2hb_twthresh.hidden = true;
ecg2hb_twthresh.help = {'Threshold to perform the T wave check.'};

ecg2hb_opt          = cfg_branch;
ecg2hb_opt.name     = 'Options';
ecg2hb_opt.tag      = 'opt';
ecg2hb_opt.val      = {ecg2hb_minhr, ecg2hb_maxhr, ...
    ecg2hb_semi, ecg2hb_twthresh};
ecg2hb_opt.help     = {''};

ecg2hb              = cfg_exbranch;
ecg2hb.name         = 'Convert ECG to Heart Beat (Pan & Tompkins)';
ecg2hb.tag          = 'ecg2hb';
ecg2hb.help         = {'Convert ECG data into Heart beat time stamps using Pan & Tompkins algorithm'};
ecg2hb.val          = {ecg2hb_chan, ecg2hb_opt};

ecg2hb_amri_chan         = pspm_cfg_channel_selector('ECG');

ecg2hb_amri_signal_to_use         = cfg_menu;
ecg2hb_amri_signal_to_use.name    = 'Signal to use';
ecg2hb_amri_signal_to_use.tag     = 'signal_to_use';
ecg2hb_amri_signal_to_use.val     = {'auto'};
ecg2hb_amri_signal_to_use.values  = {'ecg', 'teo', 'auto'};
ecg2hb_amri_signal_to_use.labels  = {'Filtered ECG signal', 'Filtered and TEO applied ECG signal',...
    'Choose automatically based on autocorrelation'};
ecg2hb_amri_signal_to_use.help    = {['Which signal to feed to the core heartbeat detection procedure. ',...
    '''ecg'' corresponds to filtered ECG signal. ''teo'' corresponds to the signal obtained by filtering ',...
    'the ECG signal even more and applying the Teager Enery Operator. ''auto'' option picks the one of ',...
    'these two options that results in higher autocorrelation']};

ecg2hb_amri_hrrange         = cfg_entry;
ecg2hb_amri_hrrange.name    = 'Feasible heartrate range';
ecg2hb_amri_hrrange.tag     = 'hrrange';
ecg2hb_amri_hrrange.strtype = 'r';
ecg2hb_amri_hrrange.num     = [1 2];
ecg2hb_amri_hrrange.val     = {[20 200]};
ecg2hb_amri_hrrange.help    = {'Define the minimum and maximum possible heartrates for your data'};

ecg2hb_amri_ecg_bandpass         = cfg_entry;
ecg2hb_amri_ecg_bandpass.name    = 'ECG bandpass filter';
ecg2hb_amri_ecg_bandpass.tag     = 'ecg_bandpass';
ecg2hb_amri_ecg_bandpass.strtype = 'r';
ecg2hb_amri_ecg_bandpass.num     = [1 2];
ecg2hb_amri_ecg_bandpass.val     = {[0.5 40]};
ecg2hb_amri_ecg_bandpass.help    = {'Define the cutoff frequencies (Hz) for bandpass filter applied to raw ECG signal'};

ecg2hb_amri_teo_bandpass         = cfg_entry;
ecg2hb_amri_teo_bandpass.name    = 'TEO bandpass filter';
ecg2hb_amri_teo_bandpass.tag     = 'teo_bandpass';
ecg2hb_amri_teo_bandpass.strtype = 'r';
ecg2hb_amri_teo_bandpass.num     = [1 2];
ecg2hb_amri_teo_bandpass.val     = {[8 40]};
ecg2hb_amri_teo_bandpass.help    = {['Define the cutoff frequencies (Hz) for bandpass filter applied to filtered ECG',...
    ' signal before applying TEO']};

ecg2hb_amri_teo_order         = cfg_entry;
ecg2hb_amri_teo_order.name    = 'TEO order';
ecg2hb_amri_teo_order.tag     = 'teo_order';
ecg2hb_amri_teo_order.strtype = 'r';
ecg2hb_amri_teo_order.num     = [1 1];
ecg2hb_amri_teo_order.val     = {1};
ecg2hb_amri_teo_order.help    = {['Define the order k of TEO. Note that for signal x(t),'],...
    ['TEO[x(t); k] = x(t)x(t) - x(t-k)x(t+k)']};

ecg2hb_amri_min_cross_corr         = cfg_entry;
ecg2hb_amri_min_cross_corr.name    = 'Minimum cross correlation';
ecg2hb_amri_min_cross_corr.tag     = 'min_cross_corr';
ecg2hb_amri_min_cross_corr.strtype = 'r';
ecg2hb_amri_min_cross_corr.num     = [1 1];
ecg2hb_amri_min_cross_corr.val     = {0.5};
ecg2hb_amri_min_cross_corr.help    = {['Define the minimum cross correlation between a candidate R-peak',...
    ' and the found template such that the candidate is classified as an R-peak']};

ecg2hb_amri_min_relative_amplitude         = cfg_entry;
ecg2hb_amri_min_relative_amplitude.name    = 'Minimum relative amplitude';
ecg2hb_amri_min_relative_amplitude.tag     = 'min_relative_amplitude';
ecg2hb_amri_min_relative_amplitude.strtype = 'r';
ecg2hb_amri_min_relative_amplitude.num     = [1 1];
ecg2hb_amri_min_relative_amplitude.val     = {0.4};
ecg2hb_amri_min_relative_amplitude.help    = {['Define the minimum relative amplitude of a candidate R-peak',...
    ' such that it is classified as an R-peak']};

ecg2hb_amri_opt      = cfg_branch;
ecg2hb_amri_opt.name = 'Options';
ecg2hb_amri_opt.tag  = 'opt';
ecg2hb_amri_opt.val  = {ecg2hb_amri_signal_to_use, ecg2hb_amri_hrrange, ...
    ecg2hb_amri_ecg_bandpass, ecg2hb_amri_teo_bandpass, ecg2hb_amri_teo_order,...
    ecg2hb_amri_min_cross_corr, ecg2hb_amri_min_relative_amplitude};
ecg2hb_amri_opt.help = {'Define various options that change the procedure''s behaviour'};

ecg2hb_amri         = cfg_exbranch;
ecg2hb_amri.name    = 'Convert ECG to Heart Beat (AMRI)';
ecg2hb_amri.tag     = 'ecg2hb_amri';
ecg2hb_amri.help    = {['Convert ECG data into heart beat time stamps using the algorithm by AMRI. The algorithm',...
    ' performs template matching to classify candidate R-peaks after filtering the',...
    ' data and applying Teager Energy Operator (TEO)'],...
    ['Reference: Liu, Zhongming, et al. "Statistical feature extraction for artifact removal ',...
    'from concurrent fMRI-EEG recordings." Neuroimage 59.3 (2012): 2073-2087.']};
ecg2hb_amri.val     = {ecg2hb_amri_chan, ecg2hb_amri_opt};

hb2hp_sr            = cfg_entry;
hb2hp_sr.name       = 'Sample rate';
hb2hp_sr.tag        = 'sr';
hb2hp_sr.help       = {'Sample rate for the interpolated time series. Default: 10 Hz.'};
hb2hp_sr.num        = [1 1];
hb2hp_sr.val        = {10};
hb2hp_sr.strtype    = 'r';

hb2hp_chan          = pspm_cfg_channel_selector('heart beat');

limit_upper         = cfg_entry;
limit_upper.name    = 'Upper limit';
limit_upper.tag     = 'upper';
limit_upper.strtype = 'r';
limit_upper.num     = [1 1];
limit_upper.val     = {2};
limit_upper.help    = {'Values bigger this value (in seconds) will be ignored and interpolated.'};

limit_lower         = cfg_entry;
limit_lower.name    = 'Lower limit';
limit_lower.tag     = 'lower';
limit_lower.strtype = 'r';
limit_lower.num     = [1 1];
limit_lower.val     = {.2};
limit_lower.help    = {'Values bigger than this value (in seconds) will be ignored and interpolated.'};

limit               = cfg_branch;
limit.name          = 'Limit';
limit.tag           = 'limit';
limit.val           = {limit_upper, limit_lower};
limit.help          = {'Define unrealistic values which should be ignored and interpolated.'};

hb2hp               = cfg_exbranch;
hb2hp.name          = 'Convert Heart Beat to Heart Period';
hb2hp.tag           = 'hb2hp';
hb2hp.val           = {hb2hp_sr, hb2hp_chan, limit};
hb2hp.help          = {['Convert heart beat time stamps into interpolated ', ...
    'heart period time series. You can use the output of the ECG to ', ...
    'Heart beat conversion, or directly work on heart beat time stamps, ', ...
    'for example obtained by a pulse oxymeter.']};

%% ppg2hb
ppg2hb_py_auto          = cfg_const;
ppg2hb_py_auto.name     = 'Automatically detect Python';
ppg2hb_py_auto.tag      = 'ppg2hb_py_auto';
ppg2hb_py_auto.val      = {0};
ppg2hb_py_auto.help     = {['This only works if a Python environment ',...
                            'already exists in Matlab, created by ',...
                            'previous PsPM function calls or manually.']};

ppg2hb_py_path          = cfg_files;
ppg2hb_py_path.name     = 'Manually define Python';
ppg2hb_py_path.tag      = 'ppg2hb_py_path';
ppg2hb_py_path.num      = [1 1];
ppg2hb_py_path.help     = {'Please specify python executable file on the computer.'};

ppg2hb_py_detect        = cfg_choice;
ppg2hb_py_detect.name   = 'HeartPy';
ppg2hb_py_detect.tag    = 'heart_py';
ppg2hb_py_detect.val    = {ppg2hb_py_auto};
ppg2hb_py_detect.values = {ppg2hb_py_auto, ppg2hb_py_path};
ppg2hb_py_detect.help   = {'Mode of detecting python path in the operating system.'};

ppg2hb_classic          = cfg_const;
ppg2hb_classic.name     = 'Classic';
ppg2hb_classic.tag      = 'ppg2hb_classic';
ppg2hb_classic.val      = {0};
ppg2hb_classic.help     = {'Classic mode.'};

ppg2hb_method           = cfg_choice;
ppg2hb_method.name      = 'Select the method of converting the data';
ppg2hb_method.tag       = 'ppg2hb_convert';
ppg2hb_method.val       = {ppg2hb_classic};
ppg2hb_method.values    = {ppg2hb_classic, ppg2hb_py_detect};
ppg2hb_method.help      = {['Convert the PPG data into heart rate by using the ', ...
                          'selected method.']};

ppg2hb_chan         = pspm_cfg_channel_selector('peripheral pulse oxymetry');
ppg2hb_chan.help    = {['Number of peripheral pulse oximetry channel ', ...
     '(default: last peripheral puls oximetry channel)']};

ppg2hb              = cfg_exbranch;
ppg2hb.name         = 'Convert peripheral pulse oximetry to Heart Beat';
ppg2hb.tag          = 'ppg2hb';
ppg2hb.val          = {ppg2hb_chan, ppg2hb_method};
ppg2hb.help          = {['Convert Peripheral pulse oximetry to ', ...
    'Heart Beat events.']};

ecg2hp              = cfg_exbranch;
ecg2hp.name         = 'Convert ECG to Heart Period';
ecg2hp.tag          = 'ecg2hp';
% re-use already defined variables
ecg2hp.val          = {ecg2hb_chan,ecg2hb_opt,hb2hp_sr, limit};
ecg2hp.help         = {['Convert ECG data into Heart period time series.']};

pp_type             = cfg_choice;
pp_type.name        = 'Type of preprocessing';
pp_type.tag         = 'pp_type';
pp_type.values      = {ecg2hb, ecg2hb_amri, hb2hp, ppg2hb, ecg2hp};
pp_type.help        = {'Specify the type of preprocessing.'};

pp                  = cfg_repeat;
pp.name             = 'Preprocessing';
pp.tag              = 'pp';
pp.values           = {pp_type};
pp.num              = [1 Inf];
pp.help             = {['Add different preprocessing steps here. ', ...
    'The converted data will be written into a new channel in the same file.']};

% define channel_action
% ------------------------------------------------------
channel_action = cfg_menu;
channel_action.name = 'Channel action';
channel_action.tag  = 'channel_action';
channel_action.values = {'add', 'replace'};
channel_action.labels = {'Add', 'Replace'};
channel_action.val = {'replace'};
channel_action.help = {'Choose whether to add the new channels or replace a channel previously added by this method.'};

% Executable Branch
pp_heart_data      = cfg_exbranch;
pp_heart_data.name = 'Preprocess heart data';
pp_heart_data.tag  = 'pp_heart_data';
pp_heart_data.val  = {datafile, pp, channel_action};
pp_heart_data.prog = @pspm_cfg_run_pp_heart_data;
pp_heart_data.vout = @pspm_cfg_vout_pp_heart_data;
pp_heart_data.help = {['Convert ECG to heart beat using Pan & Tompkins detects QRS complexes in ', ...
    'ECG data and write timestamps of detected R spikes into a new ', ...
    'heart beat channel. This function uses an algorithm adapted from ', ...
    'Pan & Tompkins (1985). Hidden options for minimum and maximum heart ', ...
    'rate become visible when the job is saved as a script and ', ...
    'should only be used if the algorithm fails.'], ['Convert ECG to heart beat using ',...
    'AMRI algorithm similarly detects QRS complexes in ECG data. This function uses the algorithm ',...
    'described in Liu, Zhongming, et al. "Statistical feature extraction for artifact removal ',...
    'from concurrent fMRI-EEG recordings." Neuroimage 59.3 (2012): 2073-2087.'], ['Convert Heart Beat ', ...
    'to heart period interpolates heart beat time stamps into ', ...
    'continuous heart period data and writes to a new channel. ', ...
    'This function uses heart period rather than heart rate because heart ',...
    'period varies linearly with ANS input into the heart.'], ...
    ['Convert Peripheral pulse oximetry to heart beat first creates a template from ', ...
    'non-ambiguous heart beats. The signal is then cross correlated ', ...
    'with the template and maxima are identified as heart beats.'], ...
    ['Convert ECG to heart period allows to directly convert continuous ', ...
    'ECG data into continuous heart period data. This function is a ', ...
    'combination of the two functions "Convert ECG to heart beat" ', ...
    'and "Convert Heart Beat to heart period".']};

function vout = pspm_cfg_vout_pp_heart_data(job)
vout = cfg_dep;
vout.sname      = 'Output File';
vout.tgt_spec = cfg_findspec({{'class','cfg_files'}});
vout.src_output = substruct('()',{':'});
