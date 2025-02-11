function pp_heart_data = pspm_cfg_convert_cardiac

% Updated 27-Mar-2024 by Teddy

%% Standard items
datafile         = pspm_cfg_selector_datafile;
ecg_chan         = pspm_cfg_selector_channel('ECG');
hb_chan          = pspm_cfg_selector_channel('heart beat');
ppg_chan         = pspm_cfg_selector_channel('peripheral pulse oxymetry');
channel_action   = pspm_cfg_selector_channel_action;
ppg2hb_heartpy   = pspm_cfg_selector_python('HeartPy');

%% Specific items
ecg2hb_minhr         = cfg_entry;
ecg2hb_minhr.name    = 'Min Heart Rate';
ecg2hb_minhr.tag     = 'minhr';
ecg2hb_minhr.strtype = 'r';
ecg2hb_minhr.num     = [1 1];
ecg2hb_minhr.val     = {30};
ecg2hb_minhr.help    = pspm_cfg_help_format('pspm_convert_ecg2hb', 'options.minHR'); 
ecg2hb_minhr.hidden  = true;

ecg2hb_maxhr         = cfg_entry;
ecg2hb_maxhr.name    = 'Max Heart Rate';
ecg2hb_maxhr.tag     = 'maxhr';
ecg2hb_maxhr.strtype = 'r';
ecg2hb_maxhr.num     = [1 1];
ecg2hb_maxhr.val     = {200};
ecg2hb_maxhr.help    = pspm_cfg_help_format('pspm_convert_ecg2hb', 'options.maxHR'); 
ecg2hb_maxhr.hidden  = true;

ecg2hb_semi         = cfg_menu;
ecg2hb_semi.name    = 'Semi automatic mode';
ecg2hb_semi.tag     = 'semi';
ecg2hb_semi.val     = {0};
ecg2hb_semi.values  = {0,1};
ecg2hb_semi.labels  = {'Off', 'On'};
ecg2hb_semi.help    = pspm_cfg_help_format('pspm_convert_ecg2hb', 'options.semi'); 

ecg2hb_twthresh     = cfg_entry;
ecg2hb_twthresh.name = 'T wave threshold';
ecg2hb_twthresh.tag = 'twthresh';
ecg2hb_twthresh.strtype = 'r';
ecg2hb_twthresh.num = [1 1];
ecg2hb_twthresh.val = {0.36};
ecg2hb_twthresh.hidden = true;
ecg2hb_twthresh.help = pspm_cfg_help_format('pspm_convert_ecg2hb', 'options.twthresh'); 

ecg2hb_opt          = cfg_branch;
ecg2hb_opt.name     = 'Options';
ecg2hb_opt.tag      = 'opt';
ecg2hb_opt.val      = {ecg2hb_minhr, ecg2hb_maxhr, ...
    ecg2hb_semi, ecg2hb_twthresh};
ecg2hb_opt.help     = {''};

ecg2hb              = cfg_exbranch;
ecg2hb.name         = 'Convert ECG to heart beat (Pan & Tompkins)';
ecg2hb.tag          = 'ecg2hb';
ecg2hb.help         = pspm_cfg_help_format('pspm_convert_ecg2hb'); 
ecg2hb.val          = {ecg_chan, ecg2hb_opt};

ecg2hb_amri_signal_to_use         = cfg_menu;
ecg2hb_amri_signal_to_use.name    = 'Signal to use';
ecg2hb_amri_signal_to_use.tag     = 'signal_to_use';
ecg2hb_amri_signal_to_use.val     = {'auto'};
ecg2hb_amri_signal_to_use.values  = {'ecg', 'teo', 'auto'};
ecg2hb_amri_signal_to_use.labels  = {'Filtered ECG signal', 'Filtered and TEO applied ECG signal',...
    'Choose automatically based on autocorrelation'};
ecg2hb_amri_signal_to_use.help    = pspm_cfg_help_format('pspm_convert_ecg2hb_amri', 'options.signal_to_use');

ecg2hb_amri_hrrange         = cfg_entry;
ecg2hb_amri_hrrange.name    = 'Feasible heartrate range';
ecg2hb_amri_hrrange.tag     = 'hrrange';
ecg2hb_amri_hrrange.strtype = 'r';
ecg2hb_amri_hrrange.num     = [1 2];
ecg2hb_amri_hrrange.val     = {[20 200]};
ecg2hb_amri_hrrange.help    = pspm_cfg_help_format('pspm_convert_ecg2hb_amri', 'options.hrrange');

ecg2hb_amri_ecg_bandpass         = cfg_entry;
ecg2hb_amri_ecg_bandpass.name    = 'ECG bandpass filter';
ecg2hb_amri_ecg_bandpass.tag     = 'ecg_bandpass';
ecg2hb_amri_ecg_bandpass.strtype = 'r';
ecg2hb_amri_ecg_bandpass.num     = [1 2];
ecg2hb_amri_ecg_bandpass.val     = {[0.5 40]};
ecg2hb_amri_ecg_bandpass.help    = pspm_cfg_help_format('pspm_convert_ecg2hb_amri', 'options.ecg_bandpass');

ecg2hb_amri_teo_bandpass         = cfg_entry;
ecg2hb_amri_teo_bandpass.name    = 'TEO bandpass filter';
ecg2hb_amri_teo_bandpass.tag     = 'teo_bandpass';
ecg2hb_amri_teo_bandpass.strtype = 'r';
ecg2hb_amri_teo_bandpass.num     = [1 2];
ecg2hb_amri_teo_bandpass.val     = {[8 40]};
ecg2hb_amri_teo_bandpass.help    = pspm_cfg_help_format('pspm_convert_ecg2hb_amri', 'options.teo_bandpass');

ecg2hb_amri_teo_order         = cfg_entry;
ecg2hb_amri_teo_order.name    = 'TEO order';
ecg2hb_amri_teo_order.tag     = 'teo_order';
ecg2hb_amri_teo_order.strtype = 'r';
ecg2hb_amri_teo_order.num     = [1 1];
ecg2hb_amri_teo_order.val     = {1};
ecg2hb_amri_teo_order.help    = pspm_cfg_help_format('pspm_convert_ecg2hb_amri', 'options.teo_order');

ecg2hb_amri_min_cross_corr         = cfg_entry;
ecg2hb_amri_min_cross_corr.name    = 'Minimum cross correlation';
ecg2hb_amri_min_cross_corr.tag     = 'min_cross_corr';
ecg2hb_amri_min_cross_corr.strtype = 'r';
ecg2hb_amri_min_cross_corr.num     = [1 1];
ecg2hb_amri_min_cross_corr.val     = {0.5};
ecg2hb_amri_min_cross_corr.help    = pspm_cfg_help_format('pspm_convert_ecg2hb_amri', 'options.min_cross_corr');

ecg2hb_amri_min_relative_amplitude         = cfg_entry;
ecg2hb_amri_min_relative_amplitude.name    = 'Minimum relative amplitude';
ecg2hb_amri_min_relative_amplitude.tag     = 'min_relative_amplitude';
ecg2hb_amri_min_relative_amplitude.strtype = 'r';
ecg2hb_amri_min_relative_amplitude.num     = [1 1];
ecg2hb_amri_min_relative_amplitude.val     = {0.4};
ecg2hb_amri_min_relative_amplitude.help    = pspm_cfg_help_format('pspm_convert_ecg2hb_amri', 'options.min_relative_amplitude');

ecg2hb_amri_opt      = cfg_branch;
ecg2hb_amri_opt.name = 'Options';
ecg2hb_amri_opt.tag  = 'opt';
ecg2hb_amri_opt.val  = {ecg2hb_amri_signal_to_use, ecg2hb_amri_hrrange, ...
    ecg2hb_amri_ecg_bandpass, ecg2hb_amri_teo_bandpass, ecg2hb_amri_teo_order,...
    ecg2hb_amri_min_cross_corr, ecg2hb_amri_min_relative_amplitude};
ecg2hb_amri_opt.help = {};

ecg2hb_amri         = cfg_exbranch;
ecg2hb_amri.name    = 'Convert ECG to heart beat (AMRI)';
ecg2hb_amri.tag     = 'ecg2hb_amri';
ecg2hb_amri.help    = pspm_cfg_help_format('pspm_convert_ecg2hb_amri');
ecg2hb_amri.val     = {ecg_chan, ecg2hb_amri_opt};

hb2hp_sr            = cfg_entry;
hb2hp_sr.name       = 'Sample rate';
hb2hp_sr.tag        = 'sr';
hb2hp_sr.help       = pspm_cfg_help_format('pspm_convert_hb2hp', 'sr');
hb2hp_sr.num        = [1 1];
hb2hp_sr.val        = {10};
hb2hp_sr.strtype    = 'r';

limit_upper         = cfg_entry;
limit_upper.name    = 'Upper limit';
limit_upper.tag     = 'upper';
limit_upper.strtype = 'r';
limit_upper.num     = [1 1];
limit_upper.val     = {2};
limit_upper.help    = pspm_cfg_help_format('pspm_convert_hb2hp', 'options.upper');

limit_lower         = cfg_entry;
limit_lower.name    = 'Lower limit';
limit_lower.tag     = 'lower';
limit_lower.strtype = 'r';
limit_lower.num     = [1 1];
limit_lower.val     = {.2};
limit_lower.help    = pspm_cfg_help_format('pspm_convert_hb2hp', 'options.lower');

limit               = cfg_branch;
limit.name          = 'Limit';
limit.tag           = 'limit';
limit.val           = {limit_upper, limit_lower};
limit.help          = pspm_cfg_help_format('pspm_convert_hb2hp', 'options.limit');

hb2hp               = cfg_exbranch;
hb2hp.name          = 'Convert heart beat to heart period';
hb2hp.tag           = 'hb2hp';
hb2hp.val           = {hb2hp_sr, hb_chan, limit};
hb2hp.help          = pspm_cfg_help_format('pspm_convert_hb2hp');

%% ppg2hb
ppg2hb_heartpy      = pspm_cfg_selector_python('HeartPy', '1.2.7');

ppg2hb_classic      = cfg_const;
ppg2hb_classic.name = 'Classic';
ppg2hb_classic.tag  = 'classic';
ppg2hb_classic.val  = {0};
ppg2hb_classic.help = {};

ppg2hb_method       = cfg_choice;
ppg2hb_method.name  = 'Select the method of converting the data';
ppg2hb_method.tag   = 'method';
ppg2hb_method.val   = {ppg2hb_classic};
ppg2hb_method.values    = {ppg2hb_classic, ppg2hb_heartpy};
ppg2hb_method.help  = pspm_cfg_help_format('pspm_convert_ppg2hb', 'options.method');

ppg2hb              = cfg_exbranch;
ppg2hb.name         = 'Convert peripheral pulse oximetry to heart beat';
ppg2hb.tag          = 'ppg2hb';
ppg2hb.val          = {ppg_chan, ppg2hb_method};
ppg2hb.help         = pspm_cfg_help_format('pspm_convert_ppg2hb');

pp_type             = cfg_choice;
pp_type.name        = 'Type of preprocessing';
pp_type.tag         = 'pp_type';
pp_type.values      = {ecg2hb, ecg2hb_amri, hb2hp, ppg2hb};
pp_type.help        = {};

pp                  = cfg_repeat;
pp.name             = 'Preprocessing';
pp.tag              = 'pp';
pp.values           = {pp_type};
pp.num              = [1 Inf];
pp.help             = {};

% Executable Branch
pp_heart_data      = cfg_exbranch;
pp_heart_data.name = 'Cardiac data conversion';
pp_heart_data.tag  = 'pp_heart_data';
pp_heart_data.val  = {datafile, pp, channel_action};
pp_heart_data.prog = @pspm_cfg_run_convert_cardiac;
pp_heart_data.vout = @pspm_cfg_vout_outchannel;
pp_heart_data.help = {'See individual preprocessing options for help.'};


