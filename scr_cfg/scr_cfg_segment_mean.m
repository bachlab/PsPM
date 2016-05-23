function [segment_mean] = scr_cfg_segment_mean(job)
% function [segment_mean] = scr_cfg_segment_mean(job)
%
% Matlabbatch function for scr_segment_mean
%__________________________________________________________________________
% PsPM 3.1
% (C) 2016 Tobias Moser (University of Zurich)

% $Id$
% $Rev$

% Initialise
global settings
if isempty(settings), scr_init; end;


%% Segment files
segment_files                   = cfg_files;
segment_files.name              = 'Segment files';
segment_files.tag               = 'segment_files';
segment_files.num               = [1 Inf];
segment_files.help              = {['Specify the segment files which have been ', ...
    'created with the ''extact segment'' function.']};

%% File path
file_path                       = cfg_files;
file_path.name                  = 'File path';
file_path.tag                   = 'file_path';
file_path.filter            	= 'dir';
file_path.help                  = {['Path to file.']};

%% File name
file_name                       = cfg_entry;
file_name.name                  = 'File name';
file_name.tag                   = 'file_name';
file_name.strtype               = 's';
file_name.num                   = [1 Inf];
file_name.help                  = {['Name of file.']};

%% Output file
output_file                     = cfg_branch;
output_file.name                = 'Ouptut file';
output_file.tag                 = 'output_file';
output_file.val                 = {file_path, file_name};
output_file.help                = {['Where to store the segment mean ', ...
    'across the specified files.']};

%% Adjust method
adjust_method           = cfg_menu;
adjust_method.name      = 'Adjust method';
adjust_method.tag       = 'adjust_method';
adjust_method.val       = {'none'};
adjust_method.labels    = {'None', 'Interpolate', 'Downsample'};
adjust_method.values    = {'none', 'interpolate', 'downsample'};
adjust_method.help      = {['How to deal with different sample rates ', ...
    'across segment files. ''interpolate'' data segments to highest or ', ...
    '''downsample'' data segments to lowest sampling rate.']};

%% Overwrite
overwrite               = cfg_menu;
overwrite.name          = 'Overwrite existing file';
overwrite.tag           = 'overwrite';
overwrite.val           = {false};
overwrite.labels        = {'No', 'Yes'};
overwrite.values        = {false, true};
overwrite.help          = {['Overwrite existing segment files.']};

%% Overwrite
plot               = cfg_menu;
plot.name          = 'Plot';
plot.tag           = 'plot';
plot.val           = {false};
plot.labels        = {'No', 'Yes'};
plot.values        = {false, true};
plot.help          = {['Overwrite existing segment files.']};

%% Executable branch
segment_mean      = cfg_exbranch;
segment_mean.name = 'Segment mean';
segment_mean.tag  = 'segment_mean';
segment_mean.val  = {segment_files, output_file, adjust_method, overwrite, plot};
segment_mean.prog = @scr_cfg_run_segment_mean;
segment_mean.vout = @scr_cfg_vout_segment_mean;
segment_mean.help = {['This function creates means over extracted data segments ', ...
    '(as extracted in ''Extract segments'').']};

function vout = scr_cfg_vout_segment_mean(job)
vout = cfg_dep;
vout.sname      = 'Output File';
% only cfg_files
vout.tgt_spec   = cfg_findspec({{'class','cfg_files'}});
vout.src_output = substruct('()',{':'});