function pp_heart_data = scr_cfg_pp_heart_data
% Preprocess ECG data
% Data File
datafile         = cfg_files;
datafile.name    = 'Data File';
datafile.tag     = 'datafile';
datafile.num     = [1 1];
%datafile.filter  = '.*\.(mat|MAT)$';
datafile.help    = {'Specify data file.'};

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
ecg2hb_maxhr.val     = {300};
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
ecg2hb.name         = 'Convert ECG to Heart Beat';
ecg2hb.tag          = 'ecg2hb';
ecg2hb.help         = {'Convert ECG data into Heart beat time stamps.'};
ecg2hb.val          = {ecg2hb_chan, ecg2hb_opt};

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

hb2hp               = cfg_exbranch;
hb2hp.name          = 'Convert Heart Beat to Heart Period';
hb2hp.tag           = 'hb2hp';
hb2hp.val           = {hb2hp_sr, hb2hp_chan};
hb2hp.help          = {['Convert heart beat time stamps into interpolated ', ... 
    'heart period time series. You can use the output of the ECG to ', ... 
    'Heart beat conversion, or directly work on heart beat time stamps, ', ...
    'for example obtained by a pulse oxymeter.']};

ppu2hb_chan_def     = cfg_const;
ppu2hb_chan_def.name = 'Default';
ppu2hb_chan_def.tag = 'chan_def';
ppu2hb_chan_def.val = {0};
ppu2hb_chan_def.help = {['First PPU channel.']};

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
ppu2hb_chan.help    = {['Number of PPU channel (default: first PPU channel)']};

ppu2hb              = cfg_exbranch;
ppu2hb.name         = 'Convert PPU to Heart Beat';
ppu2hb.tag          = 'ppu2hb';
ppu2hb.val          = {ppu2hb_chan};
hb2hp.help          = {['Convert Peripheral Pulse Units (PPU) to a ', ...
    'Heart Beat events.']};

ecg2hp              = cfg_exbranch;
ecg2hp.name         = 'Convert ECG to Heart Period';
ecg2hp.tag          = 'ecg2hp';
% re-use already defined variables
ecg2hp.val          = {ecg2hb_chan,ecg2hb_opt,hb2hp_sr};
ecg2hp.help         = {['Convert ECG data into Heart period time series.']};

pp_type             = cfg_choice;
pp_type.name        = 'Type of preprocessing';
pp_type.tag         = 'pp_type';
pp_type.values      = {ecg2hb, hb2hp, ppu2hb, ecg2hp};
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
pp_heart_data.prog = @scr_cfg_run_pp_heart_data;
pp_heart_data.vout = @scr_cfg_vout_pp_heart_data;
pp_heart_data.help = {['Convert ECG to heart beat detects QRS complexes in ', ...
    'ECG data and write timestamps of detected R spikes into a new ', ...
    'heart beat channel. This function uses an algorithm adapted from ', ...
    'Pan & Tompkins (1985). Hidden options for minimum and maximum heart ', ...
    'rate become visible when the job is saved as a script and ', ...
    'should only be used if the algorithm fails.'], ['Convert Heart Beat ', ...
    'to heart period interpolates heart beat time stamps into ', ...
    'continuous heart period data and writes to a new channel. ', ...
    'This function uses heart period rather than heart rate because heart ',...
    'period varies linearly with ANS input into the heart.']};

function vout = scr_cfg_vout_pp_heart_data(job)
vout = cfg_dep;
vout.sname      = 'Output File';
vout.tgt_spec = cfg_findspec({{'class','cfg_files'}});
vout.src_output = substruct('()',{':'});