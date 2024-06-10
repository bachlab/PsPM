function [glm] = pspm_cfg_glm(vars)
% function [glm] = pspm_cfg_glm(vars)
%
% Matlabbatch function specifies the basic glm_module.
% Its called by pspm_cfg_glm_<modalities> where modality specific settings
% are set. Then the struct is passed on to the next higher level of the
% matlabbatch configuration set.
%
% vars is a struct with char fields:
%   - modality
%   - modspec
%   - glmref
%   - glmhelp
%__________________________________________________________________________
% PsPM 3.0
% (C) 2015 Tobias Moser (University of Zurich)

% $Id: pspm_cfg_glm.m 626 2019-02-20 16:14:40Z lciernik $
% $Rev: 626 $

% Initialise
global settings
if isempty(settings), pspm_init; end

%% Modality independent items

% call the common data & design selector to be used later
[session_rep, timeunits] = pspm_cfg_data_design_selector('glm', vars);

% Modelfile name
modelfile         = cfg_entry;
modelfile.name    = 'Model Filename';
modelfile.tag     = 'modelfile';
modelfile.strtype = 's';
modelfile.help    = {'Specify file name for the resulting model.'};

% Output directory
outdir         = cfg_files;
outdir.name    = 'Output Directory';
outdir.tag     = 'outdir';
outdir.filter  = 'dir';
outdir.num     = [1 1];
outdir.help    = {'Specify directory where the mat file with the resulting model will be written.'};


% Normalize
norm              = cfg_menu;
norm.name         = 'Normalize';
norm.tag          = 'norm';
norm.val          = {false};
norm.labels       = {'No', 'Yes'};
norm.values       = {false, true};
norm.help         = {['Specify if you want to z-normalize the ', vars.modality, ' data for each subject. For within-subjects ' ...
    'designs, this is highly recommended, but for between-subjects designs it needs to be set to "no". ']};

% Channel
chan              = pspm_cfg_channel_selector(vars.modality);

%settings if Create Stats Exclude = yes
excl_segment_length         = cfg_entry;
excl_segment_length.name    = 'Segment length';
excl_segment_length.tag     = 'segment_length';
excl_segment_length.strtype = 'i';
excl_segment_length.num     = [1 1];
excl_segment_length.help    = {['Length of segments after each event onset over',...
                                ' which the NaN-ratio is computed.']};

excl_cutoff         = cfg_entry;
excl_cutoff.name    = 'Cutoff';
excl_cutoff.tag     = 'cutoff';
excl_cutoff.strtype = 'r';
excl_cutoff.num     = [1 1];
excl_cutoff.help    = {'Maximum NaN ratio for a condition to be accepted for further analysis.'};

exclude_missing_yes      = cfg_branch;
exclude_missing_yes.name = 'Settings for stats exclude';
exclude_missing_yes.tag  = 'exclude_missing_yes';
exclude_missing_yes.val  = {excl_segment_length,excl_cutoff};
exclude_missing_yes.help = {'Need to define the segment length and a cutoff value to do the statistics.'};

%settings if Create Stats Exclude = no
excl_no                  = cfg_const;
excl_no.name             = 'No';
excl_no.tag              = 'excl_no';
excl_no.val              = {'No'};
excl_no.help             = {'No statistics created.'};

%Create Stats Exclude
exclude_missing          = cfg_choice;
exclude_missing.name     = 'Create information on missing data values';
exclude_missing.tag      = 'exclude_missing';
exclude_missing.val      = {excl_no};
exclude_missing.values   = {excl_no, exclude_missing_yes};
exclude_missing.help   = {'Option to extract information over missing values in each',...
                          ' condition of the GLM. This option extractes the ratio of NaN-values',...
                          ' over all trials for each condition, and whether this ratio exceeds',...
                          ' a cutoff value. The information is stored in the GLM structure and',...
                          ' will be used in future releases for excluding vales during extraction and first-level contrasts'};

% Overwrite File
overwrite         = cfg_menu;
overwrite.name    = 'Overwrite Existing File';
overwrite.tag     = 'overwrite';
overwrite.val     = {false};
overwrite.labels  = {'No', 'Yes'};
overwrite.values  = {false, true};
overwrite.help    = {'Specify whether you want to overwrite existing mat files.'};


%% Modality dependent items
% Basis function
% SCRF
for i=1:3
    scrf{i}        = cfg_const;
    scrf{i}.name   = ['SCRF ' num2str(i-1)];
    scrf{i}.tag    = ['scrf' num2str(i-1)];
    scrf{i}.val    = {i-1};
end
scrf{1}.help   = {'SCRF without derivatives.'};
scrf{2}.help   = {'SCRF with time derivative (default).'};
scrf{3}.help   = {'SCRF with time and dispersion derivative.'};

%FIR
n         = cfg_entry;
n.name    = 'N: Number of Time Bins';
n.tag     = 'n';
n.strtype = 'i';
n.num     = [1 1];
n.help    = {'Number of time bins.'};

d         = cfg_entry;
d.name    = 'D: Duration of Time Bins';
d.tag     = 'd';
d.strtype = 'r';
d.num     = [1 1];
d.help    = {'Duration of time bins (in seconds).'};

arg        = cfg_branch;
arg.name   = 'Arguments';
arg.tag    = 'arg';
arg.val    = {n, d};
arg.help   = {''};

fir        = cfg_branch;
fir.name   = 'FIR';
fir.tag    = 'fir';
fir.val    = {arg};
fir.help   = {'Uninformed finite impulse response (FIR) model: specify the number and duration of time bins to be estimated.'};

bf        = cfg_choice;
bf.name   = 'Basis Function';
bf.tag    = 'bf';
bf.val    = {scrf{2}};
bf.values = {scrf{:}, fir};
bf.help   = {['Basis functions. Standard is to use a canonical skin conductance response function ' ...
    '(SCRF) with time derivative for later reconstruction of the response peak.']};

%% Latency
time_window          = cfg_entry;
time_window.name     = 'Time window';
time_window.tag      = 'time_window';
time_window.strtype  = 'r';
time_window.num      = [1 2];
time_window.help     = {['A 2-element vector in seconds, specifies over which time window ', ...
    'latencies should be evaluated. Positive values mean that the ', ...
    'response function is shifted to later time points, negative values ', ...
    'that it is shifted to earlier time points.']};

fixed_latency   = cfg_const;
fixed_latency.name = 'Fixed latency';
fixed_latency.tag = 'fixed';
fixed_latency.val = {'fixed'};
fixed_latency.help = {['']};

free_latency    = cfg_branch;
free_latency.name = 'Free latency';
free_latency.tag = 'free';
free_latency.val = {time_window};
free_latency.help = {['']};

latency         = cfg_choice;
latency.name    = 'Latency';
latency.tag     = 'latency';
latency.val     = {fixed_latency};
latency.values  = {fixed_latency, free_latency};
% is hidden per default
latency.hidden  = true;
latency.help    = {['Latency is either ''fixed'' or ''free''. If latency is ''free''', ...
    ', the model estimates the best latency within the given time window ', ...
    'for each regressor (using a dictionary matching algorithm) and ', ...
    'then inverts the GLM with these latencies. See Khemka et al. 2016 ', ...
    'in the context of SEBR.']};

%% Filter settings
% try to get default settings for filter
f = strcmpi({settings.glm.modelspec}, vars.modspec);
def_filt = settings.glm(f).filter;

% Filter
disable        = cfg_const;
disable.name   = 'Disable';
disable.tag    = 'disable';
disable.val    = {0};
disable.help   = {''};

% Low pass
lpfreq         = cfg_entry;
lpfreq.name    = 'Cutoff Frequency';
lpfreq.tag     = 'freq';
lpfreq.strtype = 'r';
if isfield(def_filt,'lpfreq')
    lpfreq.val = {def_filt.lpfreq};
end
lpfreq.num     = [1 1];
lpfreq.help    = {'Specify the low-pass filter cutoff in Hz.'};

lporder         = cfg_entry;
lporder.name    = 'Filter Order';
lporder.tag     = 'order';
lporder.strtype = 'i';
if isfield(def_filt,'lporder')
    lporder.val = {def_filt.lporder};
end
lporder.num     = [1 1];
lporder.help    = {'Specify the low-pass filter order.'};

enable_lp        = cfg_branch;
enable_lp.name   = 'Enable';
enable_lp.tag    = 'enable';
enable_lp.val    = {lpfreq, lporder};
enable_lp.help   = {''};

lowpass        = cfg_choice;
lowpass.name   = 'Low-Pass Filter';
lowpass.tag    = 'lowpass';
lowpass.val    = {enable_lp};
lowpass.values = {enable_lp, disable};
lowpass.help   = {''};

% High pass
hpfreq         = cfg_entry;
hpfreq.name    = 'Cutoff Frequency';
hpfreq.tag     = 'freq';
hpfreq.strtype = 'r';
if isfield(def_filt,'hpfreq')
    hpfreq.val = {def_filt.hpfreq};
end
hpfreq.num     = [1 1];
hpfreq.help    = {'Specify the high-pass filter cutoff in Hz.'};

hporder         = cfg_entry;
hporder.name    = 'Filter Order';
hporder.tag     = 'order';
hporder.strtype = 'i';
if isfield(def_filt,'hporder')
    hporder.val = {def_filt.hporder};
end
hporder.num     = [1 1];
hporder.help    = {'Specify the high-pass filter order.'};

enable_hp        = cfg_branch;
enable_hp.name   = 'Enable';
enable_hp.tag    = 'enable';
enable_hp.val    = {hpfreq, hporder};
enable_hp.help   = {''};

highpass        = cfg_choice;
highpass.name   = 'High-Pass Filter';
highpass.tag    = 'highpass';
highpass.val    = {enable_hp};
highpass.values = {enable_hp, disable};
highpass.help   = {''};

% Sampling rate
down         = cfg_entry;
down.name    = 'New Sampling Rate';
down.tag     = 'down';
down.strtype = 'r';
if isfield(def_filt,'down')
    down.val = {def_filt.down};
end
down.num     = [1 1];
down.help    = {['Specify the sampling rate in Hz to down sample ', vars.modality, ' data.', ...
    ' Enter NaN to leave the sampling rate unchanged.']};

% Filter direction
direction         = cfg_menu;
direction.name    = 'Filter Direction';
direction.tag     = 'direction';
if isfield(def_filt, 'direction')
    direction.val = {def_filt.direction};
else
    direction.val     = {'uni'};
end;
direction.labels  = {'Unidirectional', 'Bidirectional'};
direction.values  = {'uni', 'bi'};
direction.help    = {['A unidirectional filter is applied twice in the forward direction. ' ...
    'A �bidirectional� filter is applied once in the forward direction and once in the ' ...
    'backward direction to correct the temporal shift due to filtering in forward direction.']};

filter_edit        = cfg_branch;
filter_edit.name   = 'Edit Settings';
filter_edit.tag    = 'edit';
filter_edit.val    = {lowpass, highpass, down, direction};
filter_edit.help   = {'Create your own filter settings (discouraged).'};

filter_def        = cfg_const;
filter_def.name   = 'Default';
filter_def.tag    = 'def';
filter_def.val    = {0};
filter_def.help   = {['Standard settings for the Butterworth bandpass filter. These are the optimal ' ...
    'settings for ', vars.modality, ' data.']};

filter        = cfg_choice;
filter.name   = 'Filter Settings';
filter.tag    = 'filter';
filter.val    = {filter_def};
filter.values = {filter_def, filter_edit};
filter.help   = {['Specify how you want filter the ',vars.modality,' data.']};


%% Executable Branch
glm       = cfg_exbranch;
glm.name  = 'GLM';
glm.tag   = 'glm';
glm.val   = {modelfile, outdir, chan, timeunits, session_rep, latency, ...
    bf, norm, filter, exclude_missing, overwrite};
%glm_scr.prog  = ;
glm.vout  = @pspm_cfg_vout_glm;
glm.help  = {...

    ['General linear convolution models (GLM) are powerful for analysing evoked responses that ' ...
    'follow an event with (approximately) fixed latency. This is similar to standard analysis of fMRI data. ' ...
    'The user specifies events for different conditions. These are used to estimate the mean response amplitude ' ...
    'per condition. These mean amplitudes can later be compared, using the contrast manager.'], '', ...
    vars.glmhelp, '', ...
    'References: ', '', ...
    vars.glmref{:} ...
    };

function vout = pspm_cfg_vout_glm(job)
vout = cfg_dep;
vout.sname      = 'Output File';
% this can be entered into any file selector
vout.tgt_spec   = cfg_findspec({{'class','cfg_files'}});
vout.src_output = substruct('.','modelfile');
