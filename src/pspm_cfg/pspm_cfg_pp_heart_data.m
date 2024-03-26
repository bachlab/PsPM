function PPHR = pspm_cfg_pp_heart_data
% Updated on 26-Mar-2024 by Teddy
%% Initialise
global settings
if isempty(settings), pspm_init; end
%% Files
% [Fil] Data File --
datafile                = cfg_files;
datafile.name           = 'Data File';
datafile.tag            = 'datafile';
datafile.num            = [1 1];
datafile.filter         = '.*\.(mat|MAT)$';
datafile.help           = {'Specify data file.',' ',settings.datafilehelp};
% [Fil] Python path --
PyPath                  = cfg_files;
PyPath.name             = 'Manual';
PyPath.tag              = 'py_path';
PyPath.num              = [1 1];
PyPath.help             = {'Please specify python executable file on the computer.'};
% [Con] PPG2HB python path --
ppg2hbPy                = cfg_const;
ppg2hbPy.name           = 'Automatic';
ppg2hbPy.tag            = 'ppg2hbPy';
ppg2hbPy.val            = {0};
ppg2hbPy.help           = {''};
%% Constants
% [Con] ECG2HB channel definition --
ecg2hbChanDef           = cfg_const;
ecg2hbChanDef.name      = 'Default';
ecg2hbChanDef.tag       = 'chan_def';
ecg2hbChanDef.val       = {0};
ecg2hbChanDef.help      = {'Last ECG channel.'};
% [Con] ECG2HB amri channel definition --
ecg2hbAmriChanDef       = cfg_const;
ecg2hbAmriChanDef.name  = 'Default';
ecg2hbAmriChanDef.tag   = 'chan_def';
ecg2hbAmriChanDef.val   = {'ecg'};
ecg2hbAmriChanDef.help  = {'Last ECG channel.'};
% [Con] Default channel of heart beat channels --
hb2hpChanDef            = cfg_const;
hb2hpChanDef.name       = 'Default';
hb2hpChanDef.tag        = 'chan_def';
hb2hpChanDef.val        = {0};
hb2hpChanDef.help       = {'Last Heart Beat channel.'};
% [Con] PPG2HB --
ppg2hbChanDef           = cfg_const;
ppg2hbChanDef.name      = 'Default';
ppg2hbChanDef.tag       = 'chan_def';
ppg2hbChanDef.val       = {0};
ppg2hbChanDef.help      = {'Last peripheral pulse oximetry channel.'};
% [Con] PPG2HB mode --
ppg2hbClassic           = cfg_const;
ppg2hbClassic.name      = 'Classic';
ppg2hbClassic.tag       = 'classic';
ppg2hbClassic.val       = {0};
ppg2hbClassic.help      = {'Mode.'};
%% Entry
% [Ent] ECG2HB channel number -- 
ecg2hbChanNum           = cfg_entry;
ecg2hbChanNum.name      = 'Number';
ecg2hbChanNum.tag       = 'chan_nr';
ecg2hbChanNum.strtype   = 'i';
ecg2hbChanNum.num       = [1 1];
ecg2hbChanNum.help      = {''};
% [Ent] ECG2HB minimum heart rate --
ecg2hbMinHR             = cfg_entry;
ecg2hbMinHR.name        = 'Minimum Heart Rate';
ecg2hbMinHR.tag         = 'minhr';
ecg2hbMinHR.strtype     = 'r';
ecg2hbMinHR.num         = [1 1];
ecg2hbMinHR.val         = {30};
ecg2hbMinHR.help        = {''};
ecg2hbMinHR.hidden      = true;
% [Ent] ECG2HB maximum heart rate --
ecg2hbMaxHR             = cfg_entry;
ecg2hbMaxHR.name        = 'Max Heart Rate';
ecg2hbMaxHR.tag         = 'maxhr';
ecg2hbMaxHR.strtype     = 'r';
ecg2hbMaxHR.num         = [1 1];
ecg2hbMaxHR.val         = {200};
ecg2hbMaxHR.help        = {''};
ecg2hbMaxHR.hidden      = true;
% [Ent] ECG2HB T wave threshold --
ecg2hbTWaveThr          = cfg_entry;
ecg2hbTWaveThr.name     = 'T wave threshold';
ecg2hbTWaveThr.tag      = 'twthresh';
ecg2hbTWaveThr.strtype  = 'r';
ecg2hbTWaveThr.num      = [1 1];
ecg2hbTWaveThr.val      = {0.36};
ecg2hbTWaveThr.hidden   = true;
ecg2hbTWaveThr.help     = {'Threshold to perform the T wave check.'};
% [Ent] ECG2HB amri channel number --
ecg2hbAmriChanNum       = cfg_entry;
ecg2hbAmriChanNum.name  = 'Number';
ecg2hbAmriChanNum.tag   = 'chan_nr';
ecg2hbAmriChanNum.strtype = 'i';
ecg2hbAmriChanNum.num   = [1 1];
ecg2hbAmriChanNum.help  = {'Channel ID of the ECG channel in the given PsPM file'};
% [Ent] ECG2HB AMRI heart rate range --
ecg2hbAmriHRRg          = cfg_entry;
ecg2hbAmriHRRg.name     = 'Feasible heartrate range';
ecg2hbAmriHRRg.tag      = 'hrrange';
ecg2hbAmriHRRg.strtype  = 'r';
ecg2hbAmriHRRg.num      = [1 2];
ecg2hbAmriHRRg.val      = {[20 200]};
ecg2hbAmriHRRg.help     = {'Define the minimum and maximum possible heartrates for ',...
                          'your data'};
% [Ent] ECG2HB AMRI ECG bandpass filter --
ecg2hbAmriECGBP         = cfg_entry;
ecg2hbAmriECGBP.name    = 'ECG bandpass filter';
ecg2hbAmriECGBP.tag     = 'ecg_bandpass';
ecg2hbAmriECGBP.strtype = 'r';
ecg2hbAmriECGBP.num     = [1 2];
ecg2hbAmriECGBP.val     = {[0.5 40]};
ecg2hbAmriECGBP.help    = {'Define the cutoff frequencies (Hz) for bandpass filter ',...
                          'applied to raw ECG signal'};
% [Ent] ECG2HB AMRI TEO Bandpass --
ecg2hbAmriTeoBP         = cfg_entry;
ecg2hbAmriTeoBP.name    = 'TEO bandpass filter';
ecg2hbAmriTeoBP.tag     = 'teo_bandpass';
ecg2hbAmriTeoBP.strtype = 'r';
ecg2hbAmriTeoBP.num     = [1 2];
ecg2hbAmriTeoBP.val     = {[8 40]};
ecg2hbAmriTeoBP.help    = {['Define the cutoff frequencies (Hz) for bandpass filter ',...
                          'applied to filtered ECG signal before applying TEO']};
% [Ent] ECG2HB AMRI TEO Order --
ecg2hbAmriTeoOrder      = cfg_entry;
ecg2hbAmriTeoOrder.name = 'TEO order';
ecg2hbAmriTeoOrder.tag  = 'teo_order';
ecg2hbAmriTeoOrder.strtype = 'r';
ecg2hbAmriTeoOrder.num  = [1 1];
ecg2hbAmriTeoOrder.val  = {1};
ecg2hbAmriTeoOrder.help = {['Define the order k of TEO. Note that for signal x(t),',...
                           'TEO[x(t); k] = x(t)x(t) - x(t-k)x(t+k)']};
% [Ent] ECG2HB AMRI Minimum Cross Correlation --
ecg2hbAmriMinCorr       = cfg_entry;
ecg2hbAmriMinCorr.name  = 'Minimum cross correlation';
ecg2hbAmriMinCorr.tag   = 'min_cross_corr';
ecg2hbAmriMinCorr.strtype = 'r';
ecg2hbAmriMinCorr.num   = [1 1];
ecg2hbAmriMinCorr.val   = {0.5};
ecg2hbAmriMinCorr.help  = {['Define the minimum cross correlation between a ',...
                           'candidate R-peak and the found template such that the ',...
                           'candidate is classified as an R-peak']};
% [Ent] ECG2HB AMRI Minium Relative Amplitude --
ecg2hbAmriMinRelaAmp    = cfg_entry;
ecg2hbAmriMinRelaAmp.name = 'Minimum relative amplitude';
ecg2hbAmriMinRelaAmp.tag  = 'min_relative_amplitude';
ecg2hbAmriMinRelaAmp.strtype = 'r';
ecg2hbAmriMinRelaAmp.num  = [1 1];
ecg2hbAmriMinRelaAmp.val  = {0.4};
ecg2hbAmriMinRelaAmp.help = {['Define the minimum relative amplitude of a ',...
                           'candidate R-peak such that it is classified as an R-peak']};
% [Ent] HB2HP --
hb2hpChanNum            = cfg_entry;
hb2hpChanNum.name       = 'Number';
hb2hpChanNum.tag        = 'chan_nr';
hb2hpChanNum.strtype    = 'i';
hb2hpChanNum.num        = [1 1];
hb2hpChanNum.help       = {''};

% [Ent] Sample rate -- 
hb2hpSR                 = cfg_entry;
hb2hpSR.name            = 'Sample rate';
hb2hpSR.tag             = 'sr';
hb2hpSR.help            = {'Sample rate for the interpolated time series. Default: 10 Hz.'};
hb2hpSR.num             = [1 1];
hb2hpSR.val             = {10};
hb2hpSR.strtype         = 'r';


% [Ent] HB2HP processing channel --
hb2hp_proc_chan         = cfg_entry;
hb2hp_proc_chan.name    = 'Processed channel';
hb2hp_proc_chan.tag     = 'proc_chan';
hb2hp_proc_chan.strtype = 'i';
hb2hp_proc_chan.num     = [1 1];
hb2hp_proc_chan.help    = {['Convert a channel already preprocessed with ECG to ', ...
                           'Heart beat. Specify the preprocessed channel with a ', ...
                           'number corresponding to the position in the list of ',...
                           'preprocessings.']};
% [Ent] Upper limit --
LimUpper                = cfg_entry;
LimUpper.name           = 'Upper limit';
LimUpper.tag            = 'upper';
LimUpper.strtype        = 'r';
LimUpper.num            = [1 1];
LimUpper.val            = {2};
LimUpper.help           = {'Values bigger this value (in seconds) will be ignored ',...
                           'and interpolated.'};
% [Ent] Lower limit --
LimLower                = cfg_entry;
LimLower.name           = 'Lower limit';
LimLower.tag            = 'lower';
LimLower.strtype        = 'r';
LimLower.num            = [1 1];
LimLower.val            = {.2};
LimLower.help           = {'Values bigger than this value (in seconds) will ',...
                           'be ignored and interpolated.'};
% [Ent] PPG2HB channel number --
ppg2hbChanNum           = cfg_entry;
ppg2hbChanNum.name      = 'Number';
ppg2hbChanNum.tag       = 'chan_nr';
ppg2hbChanNum.strtype   = 'i';
ppg2hbChanNum.num       = [1 1];
ppg2hbChanNum.help      = {''};
%% Menu
% [Men] ECG2HB semi-automatic mode switch --
ecg2hbSemi              = cfg_menu;
ecg2hbSemi.name         = 'Semi automatic mode';
ecg2hbSemi.tag          = 'semi';
ecg2hbSemi.val          = {0};
ecg2hbSemi.values       = {0,1};
ecg2hbSemi.labels       = {'Off', 'On'};
ecg2hbSemi.help         = {['Switch for allowing manual correction of all potential ',...
                          'beat intervals.']};
% [Men] ECG2HB AMRI signal to use --
ecg2hbAmriSig           = cfg_menu;
ecg2hbAmriSig.name      = 'Signal to use';
ecg2hbAmriSig.tag       = 'signal_to_use';
ecg2hbAmriSig.val       = {'auto'};
ecg2hbAmriSig.values    = {'ecg', 'teo', 'auto'};
ecg2hbAmriSig.labels    = {'Filtered ECG signal', 'Filtered and TEO applied ECG ',...
                          'signal. Choose automatically based on autocorrelation'};
ecg2hbAmriSig.help      = {['Which signal to feed to the core heartbeat detection ',...
                          'procedure. ''ecg'' corresponds to filtered ECG signal. ',...
                          '''teo'' corresponds to the signal obtained by filtering ',...
                          'the ECG signal even more and applying the Teager Enery ',...
                          'Operator. ''auto'' option picks the one of these two ',...
                          'options that results in higher autocorrelation']};

% [Men] Define channel action --
ChanAction              = cfg_menu;
ChanAction.name         = 'Channel action';
ChanAction.tag          = 'channel_action';
ChanAction.values       = {'add', 'replace'};
ChanAction.labels       = {'Add', 'Replace'};
ChanAction.val          = {'replace'};
ChanAction.help         = {'Choose whether to add the new channels or ', ...
                           'replace a channel previously added by this method.'};
%% Branch
% [Bra] Limit --
limit                   = cfg_branch;
limit.name              = 'Limit';
limit.tag               = 'limit';
limit.val               = {LimUpper, LimLower};
limit.help              = {'Define unrealistic values which should be ignored ',...
                           'and interpolated.'};
% [Bra] ECG2HB options --
ecg2hbOpt               = cfg_branch;
ecg2hbOpt.name          = 'Options';
ecg2hbOpt.tag           = 'opt';
ecg2hbOpt.val           = {ecg2hbMinHR, ecg2hbMaxHR, ecg2hbSemi, ecg2hbTWaveThr};
ecg2hbOpt.help          = {''};
% [Bra] ECG2HB AMRI Options --
ecg2hbAmriOpt           = cfg_branch;
ecg2hbAmriOpt.name      = 'Options';
ecg2hbAmriOpt.tag       = 'opt';
ecg2hbAmriOpt.val       = {ecg2hbAmriSig, ecg2hbAmriHRRg, ecg2hbAmriECGBP, ...
                           ecg2hbAmriTeoBP, ecg2hbAmriTeoOrder, ecg2hbAmriMinCorr, ...
                           ecg2hbAmriMinRelaAmp};
ecg2hbAmriOpt.help      = {'Define various options that change the procedure''s behaviour'};
%% Choice, Execute Branch and Repeat
% [Cho] ECG2HB channel --
ecg2hbChan              = cfg_choice;
ecg2hbChan.name         = 'Channel';
ecg2hbChan.tag          = 'chan';
ecg2hbChan.val          = {ecg2hbChanDef};
ecg2hbChan.values       = {ecg2hbChanDef, ecg2hbChanNum};
ecg2hbChan.help         = {'Number of ECG channel (default: last ECG channel).'};

% [ExB] ECG2HB --
ecg2hb                  = cfg_exbranch;
ecg2hb.name             = 'Convert ECG to Heart Beat (Pan & Tompkins)';
ecg2hb.tag              = 'ecg2hb';
ecg2hb.val              = {ecg2hbChan, ecg2hbOpt};
ecg2hb.help             = {['Convert ECG data into Heart beat time stamps using ',...
                          'Pan & Tompkins algorithm']};
% [Cho] ECG2HB amri channel definition --
ecg2hbAmriChan          = cfg_choice;
ecg2hbAmriChan.name     = 'Channel';
ecg2hbAmriChan.tag      = 'chan';
ecg2hbAmriChan.val      = {ecg2hbAmriChanDef};
ecg2hbAmriChan.values   = {ecg2hbAmriChanDef, ecg2hbAmriChanNum};
ecg2hbAmriChan.help     = {'ID of ECG channel in the PsPM file (default: last ECG channel).'};
% [ExB] ECG2HB AMRI --
ecg2hbAmri              = cfg_exbranch;
ecg2hbAmri.name         = 'Convert ECG to Heart Beat (AMRI)';
ecg2hbAmri.tag          = 'ecg2hb_amri';
ecg2hbAmri.help         = {['Convert ECG data into heart beat time stamps using the',...
                           'algorithm by AMRI. The algorithm performs template ',...
                           'matching to classify candidate R-peaks after filtering ',...
                           'the data and applying Teager Energy Operator (TEO)'],...
                           ['Reference: Liu, Zhongming, et al. "Statistical feature',...
                           'extraction for artifact removal from concurrent fMRI-EEG ',...
                           'recordings." Neuroimage 59.3 (2012): 2073-2087.']};
ecg2hbAmri.val          = {ecg2hbAmriChan, ecg2hbAmriOpt};
% [Cho] Python detection mode --
ppg2hbPyDetectMode      = cfg_choice;
ppg2hbPyDetectMode.name = 'HeartPy';
ppg2hbPyDetectMode.tag  = 'HeartPy';
ppg2hbPyDetectMode.val  = {ppg2hbPy};
ppg2hbPyDetectMode.values = {ppg2hbPy, PyPath};
ppg2hbPyDetectMode.help = {'Mode of detecting python path in the operating system.'};
% [Men] PPG2HB method
ppg2hbMethod            = cfg_choice;
ppg2hbMethod.name       = 'Select the method of converting the data';
ppg2hbMethod.tag        = 'ppg2hb_convert';
ppg2hbMethod.val        = {ppg2hbClassic};
ppg2hbMethod.values     = {ppg2hbClassic, ppg2hbPyDetectMode};
ppg2hbMethod.help       = {['Convert the PPG data into heart rate by using the ', ...
                           'selected method.']};
% [Cho] PPG2HB channel choice --
ppg2hbChan              = cfg_choice;
ppg2hbChan.name         = 'Channel';
ppg2hbChan.tag          = 'chan';
ppg2hbChan.val          = {ppg2hbChanDef};
ppg2hbChan.values       = {ppg2hbChanDef, ppg2hbChanNum};
ppg2hbChan.help         = {['Number of peripheral pulse oximetry channel ', ...
                           '(default: last peripheral puls oximetry channel)']};
% [ExB] PPG2HB --
ppg2hb                  = cfg_exbranch;
ppg2hb.name             = 'Convert peripheral pulse oximetry (PPG) to Heart Beat';
ppg2hb.tag              = 'ppg2hb';
ppg2hb.val              = {ppg2hbChan, ppg2hbMethod};
ppg2hb.help             = {['Convert Peripheral pulse oximetry (PPG) to ', ...
                           'Heart Beat events.']};
% [Cho] HB2HP channel --
hb2hp_chan              = cfg_choice;
hb2hp_chan.name         = 'Channel';
hb2hp_chan.tag          = 'chan';
hb2hp_chan.help         = {'Number of Heart Beat channel (default: last Heart ',...
                           'Beat channel).'};
hb2hp_chan.val          = {hb2hpChanDef};
hb2hp_chan.values       = {hb2hpChanDef, hb2hpChanNum, hb2hp_proc_chan};
% [ExB] HB2HP --
hb2hp                   = cfg_exbranch;
hb2hp.name              = 'Convert Heart Beat to Heart Period';
hb2hp.tag               = 'hb2hp';
hb2hp.val               = {hb2hpSR, hb2hp_chan, limit};
hb2hp.help              = {['Convert heart beat time stamps into interpolated ', ...
                           'heart period time series. You can use the output of the ', ...
                           'ECG to Heart beat conversion, or directly work on heart ', ...
                           'beat time stamps, for example obtained by a pulse oxymeter.']};
% [ExB] ECG2HP --
ecg2hp                  = cfg_exbranch;
ecg2hp.name             = 'Convert ECG to Heart Period';
ecg2hp.tag              = 'ecg2hp';
ecg2hp.val              = {ecg2hbChan,ecg2hbOpt,hb2hpSR,limit};
ecg2hp.help             = {'Convert ECG data into Heart period time series.'};

% [Cho] Preprocessing type --
PPType                  = cfg_choice;
PPType.name             = 'Type of preprocessing';
PPType.tag              = 'pp_type';
PPType.values           = {ecg2hb, ecg2hbAmri, ecg2hp, hb2hp, ppg2hb};
PPType.help             = {'Specify the type of preprocessing.'};
% [Rep] Preprocessing --
PP                      = cfg_repeat;
PP.name                 = 'Preprocessing';
PP.tag                  = 'pp';
PP.values               = {PPType};
PP.num                  = [1 Inf];
PP.help                 = {['Add different preprocessing steps here. ', ...
                           'The converted data will be written into a new channel ', ...
                           'in the same file.']};
% [ExB] Preprocessing heart rate --
PPHR                    = cfg_exbranch;
PPHR.name               = 'Preprocess heart data';
PPHR.tag                = 'pp_heart_data';
PPHR.val                = {datafile, PP, ChanAction};
PPHR.prog               = @pspm_cfg_run_pp_heart_data;
PPHR.vout               = @pspm_cfg_vout_pp_heart_data;
PPHR.help               = {['Convert ECG to heart beat using Pan & Tompkins detects ', ...
                           'QRS complexes in ECG data and write timestamps of ', ...
                           'detected R spikes into a new heart beat channel. ', ...
                           'This function uses an algorithm adapted from Pan & ', ...
                           'Tompkins (1985). Hidden options for minimum and maximum ', ...
                           'heart rate become visible when the job is saved as a ', ...
                           'script and should only be used if the algorithm fails.'],...
                           ['Convert ECG to heart beat using ',...
                           'AMRI algorithm similarly detects QRS complexes in ECG ',...
                           'data. This function uses the algorithm described in ',...
                           'Liu, Zhongming, et al. "Statistical feature extraction ',...
                           'for artifact removal from concurrent fMRI-EEG ',...
                           'recordings." Neuroimage 59.3 (2012): 2073-2087.'], ...
                           ['Convert Heart Beat to heart period interpolates heart ',...
                           'beat time stamps into continuous heart period data and ',...
                           'writes to a new channel.'], ...
                           ['This function uses heart period rather than heart rate ',...
                           'because heart period varies linearly with ANS input into ',...
                           'the heart.'], ...
                           ['Convert Peripheral pulse oximetry to heart beat first ', ...
                           'creates a template from non-ambiguous heart beats.'],...
                           ['The signal is then cross correlated with the template ', ...
                           'and maxima are identified as heart beats.'], ...
                           ['Convert ECG to heart period allows to directly convert ',...
                           'continuous ECG data into continuous heart period data.'],...
                           ['This function is a combination of the two functions ', ...
                           '"Convert ECG to heart beat" and "Convert Heart Beat to ', ...
                           'heart period".']};

%% Execute the GUI
function vout = pspm_cfg_vout_pp_heart_data(~)
vout            = cfg_dep;
vout.sname      = 'Output File';
vout.tgt_spec   = cfg_findspec({{'class','cfg_files'}});
vout.src_output = substruct('()',{':'});
