function [prod_illu] = pspm_cfg_process_illuminance(~)
% * Description
%   GUI script for "prepare illuminance GLM".
% * History
%   Introduced in PsPM 3.1
%   Written in 2016 by Tobias Moser (University of Zurich)
%   Updated in 2024 by Teddy

%% Standard items
[file_name, file_path] = pspm_cfg_selector_outputfile('nuisance regressors');
overwrite              = pspm_cfg_selector_overwrite;

%% Select file
lum_file        = cfg_files;
lum_file.name   = 'Illuminance file';
lum_file.tag    = 'lum_file';
lum_file.num    = [1 1];
lum_file.help   = {['Select a file that contains illuminance data. ', ...
                    'The file should contain a variable ''Lx'' ', ...
                    'which should be an n x 1 numeric ', ...
                    'vector containing the illuminance values. ']};
%% Sample rate
sr              = cfg_entry;
sr.name         = 'Sample rate';
sr.tag          = 'sr';
sr.strtype      = 'i';
sr.num          = [1 1];
sr.help         = {'Specify the sample rate of the illuminance data.'};
%% Duration
duration        = cfg_entry;
duration.name   = 'Duration';
duration.tag    = 'duration';
duration.strtype= 'r';
duration.val    = {20};
duration.num    = [1 1];
duration.help   = {['Specify the duration of the basis function ', ...
                    'in seconds (default: 20s).']};
%% Offset
offset          = cfg_entry;
offset.name     = 'Offset';
offset.tag      = 'offset';
offset.strtype  = 'r';
offset.val      = {0.2};
offset.num      = [1 1];
offset.help     = {['Specify an offset of the basis function in ', ...
                    'seconds (default: 0.2s).']};
%% LDRF_GM
ldrf_gm         = cfg_const;
ldrf_gm.name    = 'LDRF_GM';
ldrf_gm.tag     = 'ldrf_gm';
ldrf_gm.val     = {true};
ldrf_gm.help    = {['Use gamma probability density function to ', ...
                    'model the dilation response (default).']};
%% LDRF_GU
ldrf_gu         = cfg_const;
ldrf_gu.name    = 'LDRF_GU';
ldrf_gu.tag     = 'ldrf_gu';
ldrf_gu.val     = {true};
ldrf_gu.help    = {['Use a smoothed gaussian function to model ', ...
                    'the dilation response.']};
%% Dilation
dilation        = cfg_choice;
dilation.name   = 'Dilation';
dilation.tag    = 'dilation';
dilation.values = {ldrf_gm, ldrf_gu};
dilation.val    = {ldrf_gm};
dilation.help   = {['Specify the basis function to model the ', ...
                    'dilation response.']};
%% LCRF_GM
lcrf_gm         = cfg_const;
lcrf_gm.name    = 'LCRF_GM';
lcrf_gm.tag     = 'lcrf_gm';
lcrf_gm.val     = {true};
lcrf_gm.help    = {['Use gamma probability density function to model ', ...
                    'the constriction response (default).']};
%% Constriction
constrict       = cfg_choice;
constrict.name  = 'Constriction';
constrict.tag   = 'constriction';
constrict.val   = {lcrf_gm};
constrict.values= {lcrf_gm};
constrict.help  = {['Specify the basis function to model the ', ...
                    'constriction response.']};
%% Basis function options
bf              = cfg_branch;
bf.name         = 'Basis function options';
bf.tag          = 'bf';
bf.val          = {duration, offset, dilation, constrict};
bf.help         = {'Specify options for the basis functions.'};

%% Executable branch
prod_illu       = cfg_exbranch;
prod_illu.name  = 'Prepare illuminance GLM';
prod_illu.tag   = 'process_illuminance';
prod_illu.val   = {lum_file, sr, bf, file_name, file_path, overwrite};
prod_illu.prog  = @pspm_cfg_run_proc_illuminance;
prod_illu.vout  = @pspm_cfg_vout_outfile;
prod_illu.help  = {['Transform an illuminance time series into ', ...
                    'a convolved pupil response time series to ', ...
                    'be used as nuisance file in a GLM. This ', ...
                    'allows you to partial out illuminance ', ...
                    'contributions to pupil responses evoked by ', ...
                    'cognitive inputs. ', ...
                    'Alternatively you can analyse the illuminance ', ...
                    'responses themselves, by extracting parameter ', ...
                    'estimates relating to the regressors from the ', ...
                    'GLM.'], ...
                  ['The illuminance file should be a .mat file with ', ...
                    'a vector variable called Lx. In order to ', ...
                    'fulfill the requirements of a later nuisance ', ...
                    'file there must be as many values as there ', ...
                    'are data values in the data file. The data ', ...
                    'must be given in lux (lm/m2) to account for ', ...
                    'the non-linear mapping from illuminance to ', ...
                    'steady-state pupil size.', ...
                    'A function to transform luminace (cd/m2) to ', ...
                    'illuminace values is provided under PsPM ', ...
                    '> Data processing > Pupil & Eyetracking.'], ...
                    'References', ...
                    'Korn & Bach (2016) Journal of Vision'};
