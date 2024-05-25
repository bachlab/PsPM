function merge = pspm_cfg_merge
% function [proc_illuminance] = pspm_cfg_process_illuminance(job)
%
% Matlabbatch function specifies the pspm_cfg_process_illuminance.
%
%__________________________________________________________________________
% PsPM 3.1
% (C) 2016 Tobias Moser (University of Zurich)

%% Standard items
datafile          = pspm_cfg_selector_datafile;
overwrite         = pspm_cfg_selector_overwrite;
marker_chan       = pspm_cfg_selector_channel(2);

%% Specific items
first_file = datafile;
first_file.name    = 'First file(s)';
first_file.tag      = 'first_file';
first_file.help     = {['Specify the first of the two files to be ', ...
    'merged. The output file ', ...
    'will have the name of the first file prepended with an ''m''.']};

%% Second file
second_file         = datafile;
second_file.name    = 'Second file(s)';
second_file.tag     = 'second_file';
second_file.help    = {['Specify the second of the two files to be merged. ']};

%% Data files
datafiles           = cfg_branch;
datafiles.name      = 'Datafiles';
datafiles.tag       = 'datafiles';
datafiles.val       =  {first_file, second_file};
datafiles.help      = {['Specify the PsPM datafiles to be merged.']};

%% Reference
reference           = cfg_menu;
reference.name      = 'Reference';
reference.tag       = 'reference';
reference.values    = {'marker', 'file'};
reference.labels    = {'Marker', 'File'};
reference.val       = {'file'};
reference.help      = {['Specify whether to align the files with respect ', ...
    'to the first marker or with respect to the file start.']};


%% Marker channel
marker_chan.val     = {[0 0]};
marker_chan.help    = {['Specify for both files a numerical ', ...
    'channel index, which should be used as marker reference. A 1x2 vector is ', ...
    'expected. If equal to 0, the first marker channel is used. ', ...
    'Default: [0 0]']};

%% Options
options             = cfg_branch;
options.name        = 'Options';
options.tag         = 'options';
options.val         = {marker_chan, overwrite};
options.help        = {['']};

%% Executable branch
merge      = cfg_exbranch;
merge.name = 'Merge files';
merge.tag  = 'merge';
merge.val  = {datafiles, reference, options};
merge.prog = @pspm_cfg_run_merge;
merge.vout = @pspm_cfg_vout_merge;
merge.help = {['Allows to merge (i.e. stack) two files that were acquired ', ...
    'simultaneously but contain different channels. The files are ', ...
    'aligned according to the first event of a given marker channel or ', ...
    'to the start of the file. The output file name consists of an ''m'' ', ...
    'prepended to the name of the first file. ']};

function vout = pspm_cfg_vout_merge(job)
vout = cfg_dep;
vout.sname      = 'Output File';
% this can be entered into any file selector
vout.tgt_spec   = cfg_findspec({{'class','cfg_files'}});
vout.src_output = substruct('()',{':'});
