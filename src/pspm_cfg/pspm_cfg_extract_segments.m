function [extract_segments] = pspm_cfg_extract_segments(job)
% function [extract_segments] = pspm_cfg_extract_segments(job)
%
% Matlabbatch function for pspm_extract_segments
%__________________________________________________________________________
% PsPM 3.1
% (C) 2016 Tobias Moser (University of Zurich)

% $Id$
% $Rev$

% Initialise
global settings
if isempty(settings), pspm_init; end;

% call the common data & design selector to be used later
[session_rep, timeunits] = pspm_cfg_data_design_selector('extract');


%% Channel
channel                 = pspm_cfg_channel_selector('any');

%% Manual mode
mode_manual             = cfg_branch;
mode_manual.name        = 'Manual';
mode_manual.tag         = 'mode_manual';
mode_manual.val         = {channel, timeunits, session_rep};
mode_manual.help        = {['Specify all the settings manually.']};

%% GLM file
glm_file                = cfg_files;
glm_file.name           = 'Model file';
glm_file.tag            = 'glm_file';
glm_file.num            = [1 1];
glm_file.help           = {['Choose model file to extract the required information.'],...
                            ' ',settings.datafilehelp};

%% Automatic mode
mode_automatic          = cfg_branch;
mode_automatic.name     = 'Automatically read from model file (GLM, or non-linear SCR model)';
mode_automatic.tag      = 'mode_automatic';
mode_automatic.val      = {glm_file};
mode_automatic.help     = {['Extracts all relevant information from a GLM or']...
                           ['non-linear SCR model file. To distinguish between conditions in a']...
                           ['non-linear model, trialnames must be specified in the model definition ']...
                           ['(before running it)']};

%% Mode
extract_mode            = cfg_choice;
extract_mode.name       = 'Mode';
extract_mode.tag        = 'mode';
extract_mode.val        = {mode_automatic};
extract_mode.values     = {mode_automatic, mode_manual};
extract_mode.help       = {['Either extract all information from a ', ...
    'model file or define the relevant information manually. ']};


%% Segment length
segment_length          = cfg_entry;
segment_length.name     = 'Segment length';
segment_length.tag      = 'segment_length';
segment_length.strtype  = 'r';
segment_length.num      = [1 1];
segment_length.val      = {10};
segment_length.help     = {['Length of segments in seconds. Default: 10 s.']};

%% Outputfile for nan-percentage
nan_file                = cfg_entry;
nan_file.name           = 'File name';
nan_file.tag            = 'nan_file';
nan_file.strtype        = 's';
nan_file.num            = [1 Inf];
nan_file.help           = {['The name of the file to which the ', ...
    'NaN output should be written']};

nan_path                = cfg_files;
nan_path.name           = 'Path to File';
nan_path.tag            = 'nan_path';
nan_path.filter         = 'dir';
nan_path.help           = {['Path where the NaN output file should ', ...
    'be written.']};

nan_output_file         = cfg_branch;
nan_output_file.name    = 'File output';
nan_output_file.tag     = 'nan_output_file';
nan_output_file.val     = {nan_file, nan_path};
nan_output_file.help    = {['Write NaN output to file.']};

nan_none                = cfg_const;
nan_none.name           = 'none';
nan_none.tag            = 'nan_none';
nan_none.val            = {'none'};
nan_none.help           = {'No output.'};

nan_screen              = cfg_const;
nan_screen.name         = 'Screen';
nan_screen.tag          = 'nan_screen';
nan_screen.val          = {'screen'};
nan_screen.help         = {'Output to screen.'};

%% NaN output
nan_output              = cfg_choice;
nan_output.name         = 'NaN-output';
nan_output.tag          = 'nan_output';
nan_output.val          = {nan_none};
nan_output.values       = {nan_none, nan_screen, nan_output_file};
nan_output.help         = {'Option to output the percentages of NaN values of each trial and over all trials per condition'};
%% Options
options                 = cfg_branch;
options.name            = 'Options';
options.tag             = 'options';
options.val             = {segment_length, nan_output};
options.help            = {['Change values of optional settings.']};

%% File path
file_path               = cfg_files;
file_path.name          = 'File path';
file_path.tag           = 'file_path';
file_path.filter        = 'dir';
file_path.help          = {['Path to file.']};

%% File name
file_name               = cfg_entry;
file_name.name          = 'File name';
file_name.tag           = 'file_name';
file_name.strtype       = 's';
file_name.num           = [1 Inf];
file_name.help          = {['Name of file.']};

%% Output file
output_file             = cfg_branch;
output_file.name        = 'Output file';
output_file.tag         = 'output_file';
output_file.val         = {file_path, file_name};
output_file.help        = {['Where to store the extracted segments.']};

%% Overwrite
overwrite               = cfg_menu;
overwrite.name          = 'Overwrite existing file';
overwrite.tag           = 'overwrite';
overwrite.val           = {false};
overwrite.labels        = {'No', 'Yes'};
overwrite.values        = {false, true};
overwrite.help          = {['Overwrite existing segment files.']};

%% Plot
plot                    = cfg_menu;
plot.name               = 'Plot';
plot.tag                = 'plot';
plot.val                = {false};
plot.labels             = {'No', 'Yes'};
plot.values             = {false, true};
plot.help               = {['Plot means over conditions with standard error of the mean.']};

%% Output
output                 = cfg_branch;
output.name            = 'Output';
output.tag             = 'output';
output.val             = {output_file, overwrite, plot};
output.help            = {['Output settings.']};

%% Executable branch
extract_segments      = cfg_exbranch;
extract_segments.name = 'Extract segments';
extract_segments.tag  = 'extract_segments';
extract_segments.val  = {extract_mode, options, output};
extract_segments.prog = @pspm_cfg_run_extract_segments;
extract_segments.vout = @pspm_cfg_vout_extract_segments;
extract_segments.help = {['This function extracts data segments ', ...
    '(e.g., for visual inspection of mean responses per condition).']};

function vout = pspm_cfg_vout_extract_segments(job)
vout = cfg_dep;
vout.sname      = 'Output File';
% only cfg_files
vout.tgt_spec   = cfg_findspec({{'class','cfg_files'}});
vout.src_output = substruct('()',{':'});
