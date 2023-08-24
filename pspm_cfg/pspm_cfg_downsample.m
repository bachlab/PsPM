function downsample = pspm_cfg_downsample
% Downsample

% $Id$
% $Rev$

% Initialise
global settings
if isempty(settings), pspm_init; end

% Data File
datafile         = cfg_files;
datafile.name    = 'Data File(s)';
datafile.tag     = 'datafile';
datafile.num     = [1 Inf];
datafile.filter  = '.*\.(mat|MAT)$';
datafile.help    = {'Name of the data files to be downsampled.',' ',settings.datafilehelp};

% Channels to downsample
all_chan         = cfg_const;
all_chan.name    = 'All Channels';
all_chan.tag     = 'all_chan';
all_chan.val     = {0};
all_chan.help    = {'Downsample all channels.'};

chan_vec         = cfg_entry;
chan_vec.name    = 'Enter Channel Numbers';
chan_vec.tag     = 'chan_vec';
chan_vec.strtype = 'i';
chan_vec.num     = [1 Inf];
chan_vec.help    = {'Vector with channel numbers to downsample.'};

chan         = cfg_choice;
chan.name    = 'Channels To Downsample';
chan.tag     = 'chan';
chan.val     = {all_chan};
chan.values  = {all_chan, chan_vec};
chan.help    = {'Channels to downsample.'};


% New frequency
newfreq         = cfg_entry;
newfreq.name    = 'New Frequency';
newfreq.tag     = 'newfreq';
newfreq.strtype = 'r';
newfreq.num     = [1 1];
newfreq.check   = @pspm_cfg_checkdownsample_newfreq;
newfreq.help    = {'Required sampling frequency.'};

% Overwrite File
overwrite         = cfg_menu;
overwrite.name    = 'Overwrite Existing File';
overwrite.tag     = 'overwrite';
overwrite.val     = {false};
overwrite.labels  = {'No', 'Yes'};
overwrite.values  = {false, true};
overwrite.help    = {'Specify whether you want to overwrite existing mat files.'};


%% Executable Branch
downsample      = cfg_exbranch;
downsample.name = 'Downsample Data';
downsample.tag  = 'downsample';
downsample.val  = {datafile,newfreq,chan,overwrite};
downsample.prog = @pspm_cfg_run_downsample;
downsample.vout = @pspm_cfg_vout_downsample;
downsample.help = {['This function downsamples individual channels in a PsPM file to a required sampling ' ...
    'rate, applying an anti-aliasing filter at the Nyquist frequency. The resulting data will be written to a ' ...
    'new .mat file, prependend with ''d'', and will contain all channels � also the ones that were not downsampled.']};

function [sts, val] =  pspm_cfg_checkdownsample_newfreq(val)
sts = [];
if val < 10
    sts = 'New Frequency hast to be at least 10Hz';
end
if ~isempty(sts) uiwait(msgbox(sts)); end

function vout = pspm_cfg_vout_downsample(job)

vout = cfg_dep;
vout.sname      = 'Output File';
vout.tgt_spec = cfg_findspec({{'class','cfg_files'}});
vout.src_output = substruct('()',{':'});
