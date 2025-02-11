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
second_file.help    = {'Specify the second of the two files to be merged.'};

%% Data files
datafiles           = cfg_branch;
datafiles.name      = 'Datafiles';
datafiles.tag       = 'datafiles';
datafiles.val       =  {first_file, second_file};
datafiles.help      = {'Specify the PsPM datafiles to be merged.'};

%% Marker channel
marker_chan.val     = {[0 0]};
marker_chan.help    = pspm_cfg_help_format('pspm_merge', 'options.marker_chan_num');

%% Reference
file            = cfg_const;
file.name       = 'File';
file.tag        = 'file';
file.val        = {'file'};
file.help       = {''};

marker         = cfg_branch;
marker.name    = 'Marker';
marker.tag     = 'marker';
marker.val     = {marker_chan};
marker.help    = {''};

reference           = cfg_choice;
reference.name      = 'Reference';
reference.tag       = 'reference';
reference.values    = {marker, file};
reference.val       = {file};
reference.help      = pspm_cfg_help_format('pspm_merge', 'reference');



%% Executable branch
merge      = cfg_exbranch;
merge.name = 'Merge files';
merge.tag  = 'merge';
merge.val  = {datafiles, reference, overwrite};
merge.prog = @pspm_cfg_run_merge;
merge.vout = @pspm_cfg_vout_outfile;
merge.help = pspm_cfg_help_format('pspm_merge');


