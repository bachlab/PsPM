function ecg2hb = scr_cfg_ecg2hb
% ECG to heart beat

% $Id: scr_cfg_ecg2hb.m 701 2015-01-22 14:36:13Z tmoser $
% $Rev: 701 $

% Data File
datafile         = cfg_files;
datafile.name    = 'Data File';
datafile.tag     = 'datafile';
datafile.num     = [1 1];
%datafile.filter  = '.*\.(mat|MAT)$';
datafile.help    = {'Specify data file. The detected heart beat data will be written to a new channel in this file.'};

% Channel
chan_def         = cfg_const;
chan_def.name    = 'Default';
chan_def.tag     = 'chan_def';
chan_def.val     = {0};
chan_def.help    = {'First heart beat channel.'};

chan_nr         = cfg_entry;
chan_nr.name    = 'Number';
chan_nr.tag     = 'chan_nr';
chan_nr.strtype = 'i';
chan_nr.num     = [1 1];
chan_nr.help    = {''};

chan         = cfg_choice;
chan.name    = 'Channel';
chan.tag     = 'chan';
chan.val     = {chan_def};
chan.values  = {chan_def,chan_nr};
chan.help    = {'Number of heart beat channel (default: first heart beat channel).'};

minhr         = cfg_entry;
minhr.name    = 'Min Heart Rate';
minhr.tag     = 'minhr';
minhr.strtype = 'r';
minhr.num     = [1 1];
minhr.val     = {30};
minhr.help    = {''};

maxhr         = cfg_entry;
maxhr.name    = 'Max Heart Rate';
maxhr.tag     = 'maxhr';
maxhr.strtype = 'r';
maxhr.num     = [1 1];
maxhr.val     = {300};
maxhr.help    = {''};

peakmaxhr         = cfg_entry;
peakmaxhr.name    = 'Peak Max Heart Rate';
peakmaxhr.tag     = 'peakmaxhr';
peakmaxhr.strtype = 'r';
peakmaxhr.num     = [1 1];
peakmaxhr.val     = {250};
peakmaxhr.help    = {''};

options         = cfg_branch;
options.name    = 'Options';
options.tag     = 'options';
options.val     = {minhr,maxhr,peakmaxhr};
options.hidden  = true;
options.help    = {''};

% Executable Branch
ecg2hb      = cfg_exbranch;
ecg2hb.name = 'Convert ECG to Heart Beat';
ecg2hb.tag  = 'ecg2hb';
ecg2hb.val  = {datafile, chan, options};
ecg2hb.prog = @scr_cfg_run_ecg2hb;
ecg2hb.vout = @scr_cfg_vout_ecg2hb;
ecg2hb.help = {['Detect QRS complexes in ECG data and write timestamps of detected R spikes into a ' ...
    'new heart beat channel. This function uses an algorithm adapted from Pan & Tompkins (1985). ' ...
    'Hidden options for minimum and maximum heart rate become visible when the job is saved as a script ' ...
    'and should only be used if the algorithm fails.']};

function vout = scr_cfg_vout_ecg2hb(job)
vout = cfg_dep;
vout.sname      = 'Output File';
vout.tgt_spec = cfg_findspec({{'class','cfg_files'}});
vout.src_output = substruct('()',{':'});