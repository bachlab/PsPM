function [proc_illuminance] = pspm_cfg_process_illuminance(job)
% function [proc_illuminance] = pspm_cfg_process_illuminance(job)
%
% Matlabbatch function specifies the pspm_cfg_process_illuminance.
% 
%__________________________________________________________________________
% PsPM 3.1
% (C) 2016 Tobias Moser (University of Zurich)

% $Id$
% $Rev$

% Initialise
global settings
if isempty(settings), pspm_init; end;

%% Select file
lum_file         = cfg_files;
lum_file.name    = 'Illuminance file';
lum_file.tag     = 'lum_file';
lum_file.num     = [1 Inf];
lum_file.help    = {['Select a file that contains illuminance data. ', ...
    'The file should contain a variable ''Lx'' which should be an n x 1 numeric ', ...
    'vector containing the illuminance values.'],' ',settings.datafilehelp};

%% Sample rate
sr         = cfg_entry;
sr.name    = 'Sample rate';
sr.tag     = 'sr';
sr.strtype = 'i';
sr.num     = [1 1];
sr.help    = {'Specify the sample rate of the illuminance data.'};

%% Duration
duration         = cfg_entry;
duration.name    = 'Duration';
duration.tag     = 'duration';
duration.strtype = 'r';
duration.val     = {20};
duration.num     = [1 1];
duration.help    = {'Specify the duration of the basis function in seconds (default: 20s).'};

%% Offset
offset         = cfg_entry;
offset.name    = 'Offset';
offset.tag     = 'offset';
offset.strtype = 'r';
offset.val     = {0.2};
offset.num     = [1 1];
offset.help    = {'Specify an offset of the basis function in seconds (default: 0.2s).'};

%% LDRF_GM
ldrf_gm         = cfg_const;
ldrf_gm.name    = 'LDRF_GM';
ldrf_gm.tag     = 'ldrf_gm';
ldrf_gm.val     = {true};
ldrf_gm.help    = {'Use gamma probability density function to model the dilation response (default).'};

%% LDRF_GU
ldrf_gu         = cfg_const;
ldrf_gu.name    = 'LDRF_GU';
ldrf_gu.tag     = 'ldrf_gu';
ldrf_gu.val     = {true};
ldrf_gu.help    = {'Use a smoothed gaussian function to model the dilation response.'};

%% Dilation
dilation        = cfg_choice;
dilation.name   = 'Dilation';
dilation.tag    = 'dilation';
dilation.values = {ldrf_gm, ldrf_gu};
dilation.val    = {ldrf_gm};
dilation.help   = {'Specify the basis function to model the dilation response.'};

%% LCRF_GM
lcrf_gm         = cfg_const;
lcrf_gm.name    = 'LCRF_GM';
lcrf_gm.tag     = 'lcrf_gm';
lcrf_gm.val     = {true};
lcrf_gm.help    = {'Use gamma probability density function to model the constriction response (default).'};

%% Constriction
constriction        = cfg_choice;
constriction.name   = 'Constriction';
constriction.tag    = 'constriction';
constriction.val    = {lcrf_gm};
constriction.values = {lcrf_gm};
constriction.help   = {'Specify the basis function to model the constriction response.'};

%% Basis function options
bf         = cfg_branch;
bf.name    = 'Basis function options';
bf.tag     = 'bf';
bf.val     = {duration, offset, dilation, constriction};
bf.help    = {'Specify options for the basis functions.'};

%% Outdir
outdir          = cfg_files;
outdir.name     = 'Output directory';
outdir.tag      = 'outdir';
outdir.help     = {'Specify the directory where the .mat file with the resulting nuisance data will be written.'};
outdir.filter   = 'dir';
outdir.num      = [1 1];

%% Filename
filename        = cfg_entry;
filename.name   = 'Filename for output';
filename.tag    = 'filename';
filename.help   = {'Specify the name for the resulting nuisance file.'};
filename.num    = [1 Inf];
filename.strtype = 's';

%% Overwrite file
overwrite         = cfg_menu;
overwrite.name    = 'Overwrite existing file';
overwrite.tag     = 'overwrite';
overwrite.val     = {false};
overwrite.labels  = {'No', 'Yes'};
overwrite.values  = {false, true};
overwrite.help    = {'Choose “yes” if you want to overwrite existing file(s) with the same name.'};

%% Executable branch
proc_illuminance      = cfg_exbranch;
proc_illuminance.name = 'Prepare illuminance GLM';
proc_illuminance.tag  = 'process_illuminance';
proc_illuminance.val  = {lum_file, sr, bf, outdir, filename, overwrite};
proc_illuminance.prog = @pspm_cfg_run_proc_illuminance;
proc_illuminance.vout = @pspm_cfg_vout_proc_illuminance;
proc_illuminance.help = {['Transform an illuminance time series into ', ... 
    'a convolved pupil response time series to be used as nuisance ', ...
    'file in a GLM. This allows you to partial out illuminance ', ...
    'contributions to pupil responses evoked by cognitive inputs. ', ...
    'Alternatively you can analyse the illuminance responses ', ...
    'themselves, by extracting parameter estimates relating to ', ...
    'the regressors from the GLM.'], ...
    ['The illuminance file should be a .mat file with a vector ', ...
    'variable called Lx. In order to fulfill the requirements of ', ...
    'a later nuisance file there must be as many values as ', ...
    'there are data values in the data file. The data must be given ', ...
    'in lux (lm/m2) to account for the non-linear mapping from ', ...
    'illuminance to steady-state pupil size.', ...
    'A function to transform luminace (cd/m2) to illuminace values is ', ...
    'provided under PsPM > Data processing > Pupil & Eyetracking.'], 'References', ...
    'Korn & Bach (2016) Journal of Vision'};

function vout = pspm_cfg_vout_proc_illuminance(job)
vout = cfg_dep;
vout.sname      = 'Output File';
% this can be entered into any entry
vout.tgt_spec   = cfg_findspec({{'class','cfg_files'}});
vout.src_output = substruct('()',{':'});
