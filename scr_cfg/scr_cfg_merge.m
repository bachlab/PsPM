function merge = scr_cfg_merge
% function [proc_illuminance] = scr_cfg_process_illuminance(job)
%
% Matlabbatch function specifies the scr_cfg_process_illuminance.
% 
%__________________________________________________________________________
% PsPM 3.1
% (C) 2016 Tobias Moser (University of Zurich)

% $Id$
% $Rev$

% Initialise
global settings
if isempty(settings), scr_init; end;

%% First file
first_file          = cfg_files;
first_file.name     = 'First file';
first_file.tag      = 'first_file';
first_file.num      = [1 Inf];
first_file.help     = {['Specify the first of the two files to be ', ...
    'merged. The output file will have the name of the first file prepended ', ...
    'with an ‘m’.']};

%% Second file
second_file         = cfg_files;
second_file.name    = 'Second file';
second_file.tag     = 'second_file';
second_file.num     = [1 Inf];
second_file.help    = {['Specify the second of the two files to be ', ...
    'merged. If multiple files are selected, second file must have the ', ...
    'same length as first file.']};

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

%% Overwrite file
overwrite           = cfg_menu;
overwrite.name      = 'Overwrite existing file(s)';
overwrite.tag       = 'overwrite';
overwrite.val       = {false};
overwrite.labels    = {'No', 'Yes'};
overwrite.values    = {false, true};
overwrite.help      = {'Specify whether existing files should be overwritten (Yes) or not (No). Default: No'};

%% Marker channel
marker_chan         = cfg_entry;
marker_chan.name    = 'Marker channel';
marker_chan.tag     = 'marker_chan';
marker_chan.val     = {[0 0]};
marker_chan.num     = [1 2];
marker_chan.strtype = 'i';
marker_chan.help    = {['Specify for each file (first and second) a ', ...
    'channel which should be used as marker reference. A 1x2 vector is ', ...
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
merge.prog = @scr_cfg_run_merge;
merge.vout = @scr_cfg_vout_merge;
merge.help = {['Allows to merge a second into a first file. ', ...
    'Multiple files are allowed and are processed in a sequential ', ...
    'manner. Which means the first element of second file is merged into ', ...
    'the first element of first file and so on. Therefore first file ', ...
    'and second file must have the same number of elements. The files are ', ...
    'aligned according to the first event of a given marker channel or ', ...
    'to the start of the file. The output file consists of an ‘m’ at the ', ...
    'beginning and the name of the first file appended. ']};

function vout = scr_cfg_vout_merge(job)
vout = cfg_dep;
vout.sname      = 'Output File';
% this can be entered into any file selector
vout.tgt_spec   = cfg_findspec({{'class','cfg_files'}});
vout.src_output = substruct('()',{':'});