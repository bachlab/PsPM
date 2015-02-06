function resp2rp = scr_cfg_resp2rp
% Coversion of continuous respiration data to interpolated 
% respiration rate

% $Id: scr_cfg_resp2rp.m 701 2015-01-22 14:36:13Z tmoser $
% $Rev: 701 $

% Data File
datafile         = cfg_files;
datafile.name    = 'Data File';
datafile.tag     = 'datafile';
datafile.num     = [1 1];
%datafile.filter  = '.*\.(mat|MAT)$';
datafile.help    = {['Specify data file. Specify data file. The interpolated' ...
    'respiration period data will be written to a new channel in this file.']};

% Sample rate
sr         = cfg_entry;
sr.name    = 'Sample Rate';
sr.tag     = 'sr';
sr.strtype = 'r';
sr.num     = [1 1];
sr.val     = {10};
sr.help    = {'Sample rate for respiration period channel. Default: 10 Hz'};

% Channel
chan_def         = cfg_const;
chan_def.name    = 'Default';
chan_def.tag     = 'chan_def';
chan_def.val     = {0};
chan_def.help    = {'First respiration channel.'};

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
chan.help    = {'Number of respiration channel (default: first heart beat channel).'};

plot         = cfg_menu;
plot.name    = 'Diagnostic Plot';
plot.tag     = 'plot';
plot.val     = {0};
plot.labels  = {'No', 'Yes'};
plot.values  = {0, 1};
plot.help    = {'Creates a diagnostic plot.'};
plot.hidden  = true;

% Executable Branch
resp2rp      = cfg_exbranch;
resp2rp.name = 'Convert Respiration to Respiration Period';
resp2rp.tag  = 'resp2rp';
resp2rp.val  = {datafile,sr,chan,plot};
resp2rp.prog = @scr_cfg_run_resp2rp;
resp2rp.vout = @scr_cfg_vout_resp2rp;
resp2rp.help = {''};

function vout = scr_cfg_vout_resp2rp(job)
vout = cfg_dep;
vout.sname      = 'Output File';
vout.tgt_spec = cfg_findspec({{'class','cfg_files'}});
vout.src_output = substruct('()',{':'});