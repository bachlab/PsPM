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
first_file.name    = 'First file';
first_file.tag      = 'first_file';
first_file.help     = {['Specify the first of the two files to be ', ...
    'merged. The output file ', ...
    'will have the name of the first file prepended with an ''m''.']};

%% Second file
second_file         = datafile;
second_file.name    = 'Second file';
second_file.tag     = 'second_file';
second_file.help    = {['Specify the second of the two files to be merged. ']};

%% Data files
datafiles           = cfg_branch;
datafiles.name      = 'Datafiles';
datafiles.tag       = 'datafiles';
datafiles.val       =  {first_file, second_file};
datafiles.help      = {['Specify the PsPM datafiles to be merged.']};

%% Marker channel
marker_chan.val     = {[0 0]};
marker_chan.help    = {['Specify for both files a numerical ', ...
    'channel index, which should be used as marker reference. A 1x2 vector is ', ...
    'expected. If equal to 0, the first marker channel is used. ', ...
    'Default: [0 0]']};

%% Reference
file            = cfg_const;
file.name       = 'File';
file.tag        = 'file';
file.val        = {'file'};
file.help       = {''};

markers         = cfg_branch;
markers.name    = 'Markers';
markers.tag     = 'markers';
markers.val     = {marker_chan};
markers.help    = {''};

reference           = cfg_choice;
reference.name      = 'Reference';
reference.tag       = 'reference';
reference.values    = {markers, file};
reference.val       = {file};
reference.help      = {['Specify whether to align the files with respect ', ...
    'to the first marker or with respect to the file start.']};



%% Executable branch
merge      = cfg_exbranch;
merge.name = 'Merge files';
merge.tag  = 'merge';
merge.val  = {datafiles, reference, overwrite};
merge.prog = @pspm_cfg_run_merge;
merge.vout = @pspm_cfg_vout_outfile;
merge.help = {['Allows to merge (i.e. stack) two files that were acquired ', ...
    'simultaneously but contain different channels. The files are ', ...
    'aligned according to the first event of a given marker channel or ', ...
    'to the start of the file. The output file name consists of an ''m'' ', ...
    'prepended to the name of the first file. ']};


