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

% Initialise
global settings

%% Standard items
[modelfile, outdir]      = pspm_cfg_selector_outputfile('model');
overwrite                = pspm_cfg_selector_overwrite;
session_rep              = pspm_cfg_selector_data_design('glm', vars);
timeunits                = pspm_cfg_selector_timeunits;
chan                     = pspm_cfg_selector_channel(vars.modality);
modelspec                = strcmpi({settings.glm.modelspec}, vars.modspec);
filter                   = pspm_cfg_selector_filter(settings.glm(modelspec).filter);
norm                     = pspm_cfg_selector_norm;


%% Specific items

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
