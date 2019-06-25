function pp_heart_data = pspm_cfg_pp_heart_data

% $Id$
% $Rev$

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

ecg2hb_chan_def      = cfg_const;
ecg2hb_chan_def.name = 'Default';
ecg2hb_chan_def.tag  = 'chan_def';
ecg2hb_chan_def.val  = {0};
ecg2hb_chan_def.help = {'First ECG channel.'};

ecg2hb_chan_nr         = cfg_entry;
ecg2hb_chan_nr.name    = 'Number';
ecg2hb_chan_nr.tag     = 'chan_nr';
ecg2hb_chan_nr.strtype = 'i';
ecg2hb_chan_nr.num     = [1 1];
ecg2hb_chan_nr.help    = {''};

ecg2hb_chan         = cfg_choice;
ecg2hb_chan.name    = 'Channel';
ecg2hb_chan.tag     = 'chan';
ecg2hb_chan.val     = {ecg2hb_chan_def};
ecg2hb_chan.values  = {ecg2hb_chan_def, ecg2hb_chan_nr};
ecg2hb_chan.help    = {'Number of ECG channel (default: first ECG channel).'};

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

ecg2hb_amri_chan_def      = cfg_const;
ecg2hb_amri_chan_def.name = 'Default';
ecg2hb_amri_chan_def.tag  = 'chan_def';
ecg2hb_amri_chan_def.val  = {'ecg'};
ecg2hb_amri_chan_def.help = {'Last ECG channel.'};

ecg2hb_amri_chan_nr         = cfg_entry;
ecg2hb_amri_chan_nr.name    = 'Number';
ecg2hb_amri_chan_nr.tag     = 'chan_nr';
ecg2hb_amri_chan_nr.strtype = 'i';
ecg2hb_amri_chan_nr.num     = [1 1];
ecg2hb_amri_chan_nr.help    = {'Channel ID of the ECG channel in the given PsPM file'};

ecg2hb_amri_chan         = cfg_choice;
ecg2hb_amri_chan.name    = 'Channel';
ecg2hb_amri_chan.tag     = 'chan';
ecg2hb_amri_chan.val     = {ecg2hb_amri_chan_def};
ecg2hb_amri_chan.values  = {ecg2hb_amri_chan_def, ecg2hb_amri_chan_nr};
ecg2hb_amri_chan.help    = {'ID of ECG channel (default: last ECG channel).'};

ecg2hb_amri_signal_to_use         = cfg_menu;
ecg2hb_amri_signal_to_use.name    = 'Signal to use';
ecg2hb_amri_signal_to_use.tag     = 'signal_to_use';
ecg2hb_amri_signal_to_use.val     = {'auto'};
ecg2hb_amri_signal_to_use.values  = {'ecg', 'teo', 'auto'};
ecg2hb_amri_signal_to_use.labels  = {'Filtered ECG signal', 'Filtered and TEO applied ECG signal',...
    'Choose automatically based on autocorrelation'};
ecg2hb_amri_signal_to_use.help    = {'Which signal to feed to the core heartbeat detection procedure.'};

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
ecg2hb_amri_ecg_bandpass.help    = {'Define the cutoff frequencies for bandpass filter applied to raw ECG signal'};

ecg2hb_amri_teo_bandpass         = cfg_entry;
ecg2hb_amri_teo_bandpass.name    = 'TEO bandpass filter';
ecg2hb_amri_teo_bandpass.tag     = 'teo_bandpass';
ecg2hb_amri_teo_bandpass.strtype = 'r';
ecg2hb_amri_teo_bandpass.num     = [1 2];
ecg2hb_amri_teo_bandpass.val     = {[8 40]};
ecg2hb_amri_teo_bandpass.help    = {['Define the cutoff frequencies for bandpass filter applied to filtered ECG',...
    ' signal before applying TEO']};

ecg2hb_amri_teo_order         = cfg_entry;
ecg2hb_amri_teo_order.name    = 'TEO order';
ecg2hb_amri_teo_order.tag     = 'teo_order';
ecg2hb_amri_teo_order.strtype = 'r';
ecg2hb_amri_teo_order.num     = [1 1];
ecg2hb_amri_teo_order.val     = {1};
ecg2hb_amri_teo_order.help    = {'Define the order of TEO'};

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
ecg2hb_amri.help    = {['Convert ECG data into Heart beat time stamps using the algorithm by AMRI. The algorithm',...
    ' performs template matching to classify candidate R-peaks after filtering the',...
    ' data and applying Teager Enery Operator (TEO)']};
ecg2hb_amri.val     = {ecg2hb_amri_chan, ecg2hb_amri_opt};

hb2hp_sr            = cfg_entry;
hb2hp_sr.name       = 'Sample rate';
hb2hp_sr.tag        = 'sr';
hb2hp_sr.help       = {'Sample rate for the interpolated time series. Default: 10 Hz.'};
hb2hp_sr.num        = [1 1];
hb2hp_sr.val        = {10};
hb2hp_sr.strtype    = 'r';

hb2hp_chan_def      = cfg_const;
hb2hp_chan_def.name = 'Default';
hb2hp_chan_def.tag  = 'chan_def';
hb2hp_chan_def.val  = {0};
hb2hp_chan_def.help = {'First Heart Beat channel.'};


hb2hp_chan_nr         = cfg_entry;
hb2hp_chan_nr.name    = 'Number';
hb2hp_chan_nr.tag     = 'chan_nr';
hb2hp_chan_nr.strtype = 'i';
hb2hp_chan_nr.num     = [1 1];
hb2hp_chan_nr.help    = {''};

hb2hp_proc_chan         = cfg_entry;
hb2hp_proc_chan.name    = 'Processed channel';
hb2hp_proc_chan.tag     = 'proc_chan';
hb2hp_proc_chan.strtype = 'i';
hb2hp_proc_chan.num     = [1 1];
hb2hp_proc_chan.help    = {['Convert a channel already preprocessed with ', ...
    'ECG to Heart beat. Specify the preprocessed channel with a number ', ...
    'corresponding to the position in the list of preprocessings.']};

hb2hp_chan          = cfg_choice;
hb2hp_chan.name     = 'Channel';
hb2hp_chan.tag      = 'chan';
hb2hp_chan.help     = {'Number of Heart Beat channel (default: first Heart Beat channel).'};
hb2hp_chan.val     = {hb2hp_chan_def};
hb2hp_chan.values  = {hb2hp_chan_def, hb2hp_chan_nr, hb2hp_proc_chan};

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

ppu2hb_chan_def     = cfg_const;
ppu2hb_chan_def.name = 'Default';
ppu2hb_chan_def.tag = 'chan_def';
ppu2hb_chan_def.val = {0};
ppu2hb_chan_def.help = {['First Peripheral pulse oximetry channel.']};

ppu2hb_chan_nr      = cfg_entry;
ppu2hb_chan_nr.name = 'Number';
ppu2hb_chan_nr.tag  = 'chan_nr';
ppu2hb_chan_nr.strtype = 'i';
ppu2hb_chan_nr.num  = [1 1];
ppu2hb_chan_nr.help = {''};

ppu2hb_chan         = cfg_choice;
ppu2hb_chan.name    = 'Channel';
ppu2hb_chan.tag     = 'chan';
ppu2hb_chan.val     = {ppu2hb_chan_def};
ppu2hb_chan.values  = {ppu2hb_chan_def, ppu2hb_chan_nr};
ppu2hb_chan.help    = {['Number of Peripheral pulse oximetry channel ', ...
    '(default: first Peripheral puls oximetry channel)']};

ppu2hb              = cfg_exbranch;
ppu2hb.name         = 'Convert Peripheral pulse oximetry to Heart Beat';
ppu2hb.tag          = 'ppu2hb';
ppu2hb.val          = {ppu2hb_chan};
ppu2hb.help          = {['Convert Peripheral pulse oximetry to ', ...
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
pp_type.values      = {ecg2hb, ecg2hb_amri, hb2hp, ppu2hb, ecg2hp};
pp_type.help        = {'Specify the type of preprocessing.'};

pp                  = cfg_repeat;
pp.name             = 'Preprocessing';
pp.tag              = 'pp';
pp.values           = {pp_type};
pp.num              = [1 Inf];
pp.help             = {['Add different preprocessing steps here. ', ...
    'The converted data will be written into a new channel in the same file.']};

replace_chan        = cfg_menu;
replace_chan.name   = 'Replace output channel';
replace_chan.tag    = 'replace_chan';
replace_chan.val    = {0};
replace_chan.labels = {'No', 'Yes'};
replace_chan.values = {0, 1};
replace_chan.help   = {['Replace existing conversion(s) with new ', ...
    'converted data. If no conversion exists, (a) new channel(s) ',...
    'will be created.']};

% Executable Branch
pp_heart_data      = cfg_exbranch;
pp_heart_data.name = 'Preprocess heart data';
pp_heart_data.tag  = 'pp_heart_data';
pp_heart_data.val  = {datafile, pp, replace_chan};
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
