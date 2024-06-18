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
mode_manual.help        = {['Specify all the settings manually.']};


%% Automatic mode
mode_automatic          = cfg_branch;
mode_automatic.name     = 'Automatically read from model file (GLM, or non-linear SCR model)';
mode_automatic.tag      = 'mode_automatic';
mode_automatic.val      = {modelfile};
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
nan_output.values       = {nan_none, nan_screen, nan_outputfile};
nan_output.help         = {'Option to output the percentages of NaN values of each trial and over all trials per condition'};

%% Options
options                 = cfg_branch;
options.name            = 'Options';
options.tag             = 'options';
options.val             = {segment_length, nan_output};
options.help            = {['Change values of optional settings.']};

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
output.val             = {outputfile, plot};
output.help            = {['Output settings.']};

%% Executable branch
extract_segments      = cfg_exbranch;
extract_segments.name = 'Extract segments';
extract_segments.tag  = 'extract_segments';
extract_segments.val  = {extract_mode, options, output};
extract_segments.prog = @pspm_cfg_run_extract_segments;
extract_segments.vout = @pspm_cfg_vout_outfile;
extract_segments.help = {['This function extracts data segments ', ...
    '(e.g., for visual inspection of mean responses per condition).']};


