function [extract_segments] = pspm_cfg_extract_segments
% function [extract_segments] = pspm_cfg_extract_segments
%
% Matlabbatch function for pspm_extract_segments
%__________________________________________________________________________
% PsPM 3.1
% (C) 2016 Tobias Moser (University of Zurich)


%% General items
modelfile                = pspm_cfg_selector_datafile('model');
channel                  = pspm_cfg_selector_channel('any');
design                   = pspm_cfg_selector_data_design('extract');
timeunits                = pspm_cfg_selector_timeunits;
nan_outputfile           = pspm_cfg_selector_outputfile('NaN output');
nan_outputfile.val(3)    = []; % remove second overwrite selector
outputfile               = pspm_cfg_selector_outputfile('Output');


%% Manual mode
mode_manual             = cfg_branch;
mode_manual.name        = 'Read from data file';
mode_manual.tag         = 'mode_manual';

mode_manual.val         = {channel, timeunits, design};
mode_manual.help        = {};


%% Automatic mode
mode_automatic          = cfg_branch;
mode_automatic.name     = 'Automatically read from model file (GLM, or non-linear SCR model)';
mode_automatic.tag      = 'mode_automatic';
mode_automatic.val      = {modelfile};
mode_automatic.help     = {};

%% Mode
extract_mode            = cfg_choice;
extract_mode.name       = 'Mode';
extract_mode.tag        = 'mode';
extract_mode.val        = {mode_automatic};
extract_mode.values     = {mode_automatic, mode_manual};
extract_mode.help       = {['Extract from model, or define onsets explicitly.']};


%% Segment length
segment_length          = cfg_entry;
segment_length.name     = 'Segment length';
segment_length.tag      = 'segment_length';
segment_length.strtype  = 'r';
segment_length.num      = [1 1];
segment_length.val      = {10};
segment_length.help     = pspm_cfg_help_format('pspm_extract_segments', 'options.length');

%% Outputfile for nan-percentage
nan_none                = cfg_const;
nan_none.name           = 'none';
nan_none.tag            = 'nan_none';
nan_none.val            = {'none'};
nan_none.help           = {'No output.'};

nan_screen              = cfg_const;
nan_screen.name         = 'Screen';
nan_screen.tag          = 'nan_screen';
nan_screen.val          = {'screen'};
nan_screen.help         = {};

%% NaN output
nan_output              = cfg_choice;
nan_output.name         = 'NaN output';
nan_output.tag          = 'nan_output';
nan_output.val          = {nan_none};
nan_output.values       = {nan_none, nan_screen, nan_outputfile};
nan_output.help         = pspm_cfg_help_format('pspm_extract_segments', 'options.nan_output');

%% Options
options                 = cfg_branch;
options.name            = 'Options';
options.tag             = 'options';
options.val             = {segment_length, nan_output};
options.help            = {};

%% Plot
plot                    = cfg_menu;
plot.name               = 'Plot';
plot.tag                = 'plot';
plot.val                = {false};
plot.labels             = {'No', 'Yes'};
plot.values             = {false, true};
plot.help               = pspm_cfg_help_format('pspm_extract_segments', 'options.plot');
%% Output
output                 = cfg_branch;
output.name            = 'Output';
output.tag             = 'output';
output.val             = {outputfile, plot};
output.help            = {};

%% Executable branch
extract_segments      = cfg_exbranch;
extract_segments.name = 'Extract segments';
extract_segments.tag  = 'extract_segments';
extract_segments.val  = {extract_mode, options, output};
extract_segments.prog = @pspm_cfg_run_extract_segments;
extract_segments.vout = @pspm_cfg_vout_outfile;
extract_segments.help = pspm_cfg_help_format('pspm_extract_segments');


