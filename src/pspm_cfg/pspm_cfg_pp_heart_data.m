function pp_heart_data = pspm_cfg_pp_heart_data
% Updated on 26-Mar-2024 by Teddy
%% Initialise
global settings
if isempty(settings), pspm_init; end
%% Preprocess ECG data
% [Fil] Data File ---
datafile                = cfg_files;
datafile.name           = 'Data File';
datafile.tag            = 'datafile';
datafile.num            = [1 1];
datafile.filter         = '.*\.(mat|MAT)$';
datafile.help           = {'Specify data file.',' ',settings.datafilehelp};
% [Con] ECG2HB channel definition ---
ecg2hbChanDef           = cfg_const;
ecg2hbChanDef.name      = 'Default';
ecg2hbChanDef.tag       = 'chan_def';
ecg2hbChanDef.val       = {0};
ecg2hbChanDef.help      = {'Last ECG channel.'};
% [Ent] ECG2HB channel number --- 
ecg2hbChanNum           = cfg_entry;
ecg2hbChanNum.name      = 'Number';
ecg2hbChanNum.tag       = 'chan_nr';
ecg2hbChanNum.strtype   = 'i';
ecg2hbChanNum.num       = [1 1];
ecg2hbChanNum.help      = {''};
% [Cho] ECG2HB channel ---
ecg2hbChan              = cfg_choice;
ecg2hbChan.name         = 'Channel';
ecg2hbChan.tag          = 'chan';
ecg2hbChan.val          = {ecg2hbChanDef};
ecg2hbChan.values       = {ecg2hbChanDef, ecg2hbChanNum};
ecg2hbChan.help         = {'Number of ECG channel (default: last ECG channel).'};
% [Ent] ECG2HB minimum heart rate ---
ecg2hbMinHR             = cfg_entry;
ecg2hbMinHR.name        = 'Minimum Heart Rate';
ecg2hbMinHR.tag         = 'minhr';
ecg2hbMinHR.strtype     = 'r';
ecg2hbMinHR.num         = [1 1];
ecg2hbMinHR.val         = {30};
ecg2hbMinHR.help        = {''};
ecg2hbMinHR.hidden      = true;
% [Ent] ECG2HB maximum heart rate ---
ecg2hbMaxHR             = cfg_entry;
ecg2hbMaxHR.name        = 'Max Heart Rate';
ecg2hbMaxHR.tag         = 'maxhr';
ecg2hbMaxHR.strtype     = 'r';
ecg2hbMaxHR.num         = [1 1];
ecg2hbMaxHR.val         = {200};
ecg2hbMaxHR.help        = {''};
ecg2hbMaxHR.hidden      = true;
% [Men] ECG2HB semi-automatic mode switch ---
ecg2hbSemi              = cfg_menu;
ecg2hbSemi.name         = 'Semi automatic mode';
ecg2hbSemi.tag          = 'semi';
ecg2hbSemi.val          = {0};
ecg2hbSemi.values       = {0,1};
ecg2hbSemi.labels       = {'Off', 'On'};
ecg2hbSemi.help         = {'Switch for allowing manual correction of all potential beat intervals.'};
% [Ent] ECG2HB T wave threshold ---
ecg2hbTWaveThr          = cfg_entry;
ecg2hbTWaveThr.name     = 'T wave threshold';
ecg2hbTWaveThr.tag      = 'twthresh';
ecg2hbTWaveThr.strtype  = 'r';
ecg2hbTWaveThr.num      = [1 1];
ecg2hbTWaveThr.val      = {0.36};
ecg2hbTWaveThr.hidden   = true;
ecg2hbTWaveThr.help     = {'Threshold to perform the T wave check.'};
% [Bra] ECG2HB options ---
ecg2hbOpt               = cfg_branch;
ecg2hbOpt.name          = 'Options';
ecg2hbOpt.tag           = 'opt';
ecg2hbOpt.val           = {ecg2hbMinHR, ecg2hbMaxHR, ecg2hbSemi, ecg2hbTWaveThr};
ecg2hbOpt.help          = {''};
% [ExB] ECG2HB execute branch ---
ecg2hb                  = cfg_exbranch;
ecg2hb.name             = 'Convert ECG to Heart Beat (Pan & Tompkins)';
ecg2hb.tag              = 'ecg2hb';
ecg2hb.help             = {['Convert ECG data into Heart beat time ',...
                          'stamps using Pan & Tompkins algorithm']};
ecg2hb.val              = {ecg2hbChan, ecg2hbOpt};
% [Con] ECG2HB amri channel definition ---
ecg2hbAmriChanDef       = cfg_const;
ecg2hbAmriChanDef.name  = 'Default';
ecg2hbAmriChanDef.tag   = 'chan_def';
ecg2hbAmriChanDef.val   = {'ecg'};
ecg2hbAmriChanDef.help  = {'Last ECG channel.'};

ecg2hbAmriChanNum       = cfg_entry;
ecg2hbAmriChanNum.name  = 'Number';
ecg2hbAmriChanNum.tag   = 'chan_nr';
ecg2hbAmriChanNum.strtype = 'i';
ecg2hbAmriChanNum.num   = [1 1];
ecg2hbAmriChanNum.help  = {'Channel ID of the ECG channel in the given PsPM file'};

ecg2hbAmriChan          = cfg_choice;
ecg2hbAmriChan.name     = 'Channel';
ecg2hbAmriChan.tag      = 'chan';
ecg2hbAmriChan.val      = {ecg2hbAmriChanDef};
ecg2hbAmriChan.values   = {ecg2hbAmriChanDef, ecg2hbAmriChanNum};
ecg2hbAmriChan.help     = {'ID of ECG channel in the PsPM file (default: last ECG channel).'};
% [Men] ECG2HB AMRI signal to use ---
ecg2hbAmriSig           = cfg_menu;
ecg2hbAmriSig.name      = 'Signal to use';
ecg2hbAmriSig.tag       = 'signal_to_use';
ecg2hbAmriSig.val       = {'auto'};
ecg2hbAmriSig.values    = {'ecg', 'teo', 'auto'};
ecg2hbAmriSig.labels    = {'Filtered ECG signal', 'Filtered and TEO applied ECG signal',...
                          'Choose automatically based on autocorrelation'};
ecg2hbAmriSig.help      = {['Which signal to feed to the core ',...
                          'heartbeat detection procedure. ''ecg'' corresponds to filtered ECG signal. ''teo'' corresponds to the signal obtained by filtering ',...
                          'the ECG signal even more and applying the Teager Enery Operator. ''auto'' option picks the one of ',...
                          'these two options that results in higher autocorrelation']};
% [Ent] ECG2HB AMRI heart rate range ---
ecg2hbAmriHRRg          = cfg_entry;
ecg2hbAmriHRRg.name     = 'Feasible heartrate range';
ecg2hbAmriHRRg.tag      = 'hrrange';
ecg2hbAmriHRRg.strtype  = 'r';
ecg2hbAmriHRRg.num      = [1 2];
ecg2hbAmriHRRg.val      = {[20 200]};
ecg2hbAmriHRRg.help     = {'Define the minimum and maximum possible heartrates for your data'};

ecg2hbAmriECGBP         = cfg_entry;
ecg2hbAmriECGBP.name    = 'ECG bandpass filter';
ecg2hbAmriECGBP.tag     = 'ecg_bandpass';
ecg2hbAmriECGBP.strtype = 'r';
ecg2hbAmriECGBP.num     = [1 2];
ecg2hbAmriECGBP.val     = {[0.5 40]};
ecg2hbAmriECGBP.help    = {'Define the cutoff frequencies (Hz) for bandpass filter applied to raw ECG signal'};

ecg2hbAmriTeoBP         = cfg_entry;
ecg2hbAmriTeoBP.name    = 'TEO bandpass filter';
ecg2hbAmriTeoBP.tag     = 'teo_bandpass';
ecg2hbAmriTeoBP.strtype = 'r';
ecg2hbAmriTeoBP.num     = [1 2];
ecg2hbAmriTeoBP.val     = {[8 40]};
ecg2hbAmriTeoBP.help    = {['Define the cutoff frequencies (Hz) for bandpass filter applied to filtered ECG',...
    ' signal before applying TEO']};

ecg2hb_amri_teo_order         = cfg_entry;
ecg2hb_amri_teo_order.name    = 'TEO order';
ecg2hb_amri_teo_order.tag     = 'teo_order';
ecg2hb_amri_teo_order.strtype = 'r';
ecg2hb_amri_teo_order.num     = [1 1];
ecg2hb_amri_teo_order.val     = {1};
ecg2hb_amri_teo_order.help    = {['Define the order k of TEO. Note that for signal x(t),'],...
    ['TEO[x(t); k] = x(t)x(t) - x(t-k)x(t+k)']};

ecg2hbAmriMinCorr         = cfg_entry;
ecg2hbAmriMinCorr.name    = 'Minimum cross correlation';
ecg2hbAmriMinCorr.tag     = 'min_cross_corr';
ecg2hbAmriMinCorr.strtype = 'r';
ecg2hbAmriMinCorr.num     = [1 1];
ecg2hbAmriMinCorr.val     = {0.5};
ecg2hbAmriMinCorr.help    = {['Define the minimum cross correlation between a candidate R-peak',...
    ' and the found template such that the candidate is classified as an R-peak']};

ecg2hbAmriMinRelaAmp         = cfg_entry;
ecg2hbAmriMinRelaAmp.name    = 'Minimum relative amplitude';
ecg2hbAmriMinRelaAmp.tag     = 'min_relative_amplitude';
ecg2hbAmriMinRelaAmp.strtype = 'r';
ecg2hbAmriMinRelaAmp.num     = [1 1];
ecg2hbAmriMinRelaAmp.val     = {0.4};
ecg2hbAmriMinRelaAmp.help    = {['Define the minimum relative amplitude of a candidate R-peak',...
    ' such that it is classified as an R-peak']};

ecg2hb_amri_opt      = cfg_branch;
ecg2hb_amri_opt.name = 'Options';
ecg2hb_amri_opt.tag  = 'opt';
ecg2hb_amri_opt.val  = {ecg2hbAmriSig, ecg2hbAmriHRRg, ...
    ecg2hbAmriECGBP, ecg2hbAmriTeoBP, ecg2hb_amri_teo_order,...
    ecg2hbAmriMinCorr, ecg2hbAmriMinRelaAmp};
ecg2hb_amri_opt.help = {'Define various options that change the procedure''s behaviour'};

ecg2hb_amri         = cfg_exbranch;
ecg2hb_amri.name    = 'Convert ECG to Heart Beat (AMRI)';
ecg2hb_amri.tag     = 'ecg2hb_amri';
ecg2hb_amri.help    = {['Convert ECG data into heart beat time stamps using the algorithm by AMRI. The algorithm',...
    ' performs template matching to classify candidate R-peaks after filtering the',...
    ' data and applying Teager Energy Operator (TEO)'],...
    ['Reference: Liu, Zhongming, et al. "Statistical feature extraction for artifact removal ',...
    'from concurrent fMRI-EEG recordings." Neuroimage 59.3 (2012): 2073-2087.']};
ecg2hb_amri.val     = {ecg2hbAmriChan, ecg2hb_amri_opt};

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
hb2hp_chan_def.help = {'Last Heart Beat channel.'};


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
hb2hp_chan.help     = {'Number of Heart Beat channel (default: last Heart Beat channel).'};
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

ppg2hbChanDef     = cfg_const;
ppg2hbChanDef.name = 'Default';
ppg2hbChanDef.tag = 'chan_def';
ppg2hbChanDef.val = {0};
ppg2hbChanDef.help = {['Last peripheral pulse oximetry channel.']};

ppg2hbChanNum      = cfg_entry;
ppg2hbChanNum.name = 'Number';
ppg2hbChanNum.tag  = 'chan_nr';
ppg2hbChanNum.strtype = 'i';
ppg2hbChanNum.num  = [1 1];
ppg2hbChanNum.help = {''};

ppg2hbChan         = cfg_choice;
ppg2hbChan.name    = 'Channel';
ppg2hbChan.tag     = 'chan';
ppg2hbChan.val     = {ppg2hbChanDef};
ppg2hbChan.values  = {ppg2hbChanDef, ppg2hbChanNum};
ppg2hbChan.help    = {['Number of peripheral pulse oximetry channel ', ...
    '(default: last peripheral puls oximetry channel)']};

ppg2hbMethod       = cfg_menu;
ppg2hbMethod.name  = 'Select the method of converting the data';
ppg2hbMethod.tag   = 'ppg2hb_convert';
ppg2hbMethod.values= {'classic', 'heartpy'};
ppg2hbMethod.labels= {'Classic', 'Heartpy'};
ppg2hbMethod.val   = {'classic'};
ppg2hbMethod.help  = {['Convert the PPG data into heart rate by using the selected method.']};

ppg2hb              = cfg_exbranch;
ppg2hb.name         = 'Convert peripheral pulse oximetry to Heart Beat';
ppg2hb.tag          = 'ppg2hb';
ppg2hb.val          = {ppg2hbChan, ppg2hbMethod};
ppg2hb.help          = {['Convert Peripheral pulse oximetry (PPG) to ', ...
    'Heart Beat events.']};
    
PyDetectMode                = cfg_menu;
PyDetectMode.name           = 'Select the method of detecting python code';
PyDetectMode.tag            = 'py_mode';
PyDetectMode.values= {'py_auto', 'py_manual'};
PyDetectMode.labels= {'Automatic', 'Manual'};
PyDetectMode.help           = {'1'};

ecg2hp              = cfg_exbranch;
ecg2hp.name         = 'Convert ECG to Heart Period';
ecg2hp.tag          = 'ecg2hp';
% re-use already defined variables
ecg2hp.val          = {ecg2hbChan,ecg2hbOpt,hb2hp_sr, limit};
ecg2hp.help         = {'Convert ECG data into Heart period time series.'};

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

function vout = pspm_cfg_vout_pp_heart_data(~)
vout = cfg_dep;
vout.sname      = 'Output File';
vout.tgt_spec = cfg_findspec({{'class','cfg_files'}});
vout.src_output = substruct('()',{':'});
