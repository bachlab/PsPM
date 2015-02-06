function hb2hr = scr_cfg_hb2hp
% Heart beat to heart period

% $Id: scr_cfg_hb2hp.m 701 2015-01-22 14:36:13Z tmoser $
% $Rev: 701 $

% Data File
datafile         = cfg_files;
datafile.name    = 'Data File';
datafile.tag     = 'datafile';
datafile.num     = [1 1];
%datafile.filter  = '.*\.(mat|MAT)$';
datafile.help    = {'Specify data file. The interpolated heart period data will be written to a new channel in this file.'};

% Sample rate
sr         = cfg_entry;
sr.name    = 'Sample Rate';
sr.tag     = 'sr';
sr.strtype = 'i';
sr.num     = [1 1];
sr.val     = {10};
sr.help    = {'Sample rate for heart period channel. Default: 10 Hz'};

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

% Executable Branch
hb2hr      = cfg_exbranch;
hb2hr.name = 'Convert Heart Beat to Heart Period';
hb2hr.tag  = 'dcg2hp';
hb2hr.val  = {datafile,sr,chan};
hb2hr.prog = @scr_cfg_run_hb2hp;
hb2hr.vout = @scr_cfg_vout_hb2hp;
hb2hr.help = {['Interpolate heart beat time stamps into continuous heart period data and write into ' ...
    'new channel. This function uses heart period rather than heart rate because heart period varies ' ...
    'linearly with ANS input into the heart.']};

function vout = scr_cfg_vout_hb2hp(job)
vout = cfg_dep;
vout.sname      = 'Output File';
vout.tgt_spec = cfg_findspec({{'class','cfg_files'}});
vout.src_output = substruct('()',{':'});