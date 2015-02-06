function contrast = scr_cfg_contrast2
% Contrast (first level)

% $Id: scr_cfg_contrast2.m 701 2015-01-22 14:36:13Z tmoser $
% $Rev: 701 $


% Select File
modelfile         = cfg_files;
modelfile.name    = 'Model File(s)';
modelfile.tag     = 'modelfile';
modelfile.num     = [2 Inf];
modelfile.filter  = '.*\.(mat|MAT)$';
modelfile.help    = {''};

modelfile1         = cfg_files;
modelfile1.name    = 'Model File(s) 1';
modelfile1.tag     = 'modelfile1';
modelfile1.num     = [2 Inf];
modelfile1.filter  = '.*\.(mat|MAT)$';
modelfile1.help    = {'Model files for group 1.'};

modelfile2         = cfg_files;
modelfile2.name    = 'Model File(s) 2';
modelfile2.tag     = 'modelfile2';
modelfile2.num     = [2 Inf];
modelfile2.filter  = '.*\.(mat|MAT)$';
modelfile2.help    = {'Model files for group 2.'};

% One sample
one_sample         = cfg_branch;
one_sample.name    = 'One Sample T-Test';
one_sample.tag     = 'one_sample';
one_sample.val     = {modelfile};
one_sample.help    = {''};

% Two sample
two_sample         = cfg_branch;
two_sample.name    = 'Two Sample T-Test';
two_sample.tag     = 'two_sample';
two_sample.val     = {modelfile1, modelfile2};
two_sample.help    = {''};

% Test tpe
testtype        = cfg_choice;
testtype.name   = 'Test Type';
testtype.tag    = 'testtype';
testtype.values = {one_sample, two_sample};
testtype.help   = {'Specify the test type.'};

% Output directory
outdir         = cfg_files;
outdir.name    = 'Output Directory';
outdir.tag     = 'outdir';
outdir.filter  = 'dir';
outdir.num     = [1 1];
outdir.help    = {'Specify directory where the mat file with the resulting model will be written.'};

% All Contrasts
con_all         = cfg_const;
con_all.name    = 'All Contrasts';
con_all.tag     = 'con_all';
con_all.val     = {'all'};
con_all.help    = {''};

% Filename for model output
filename         = cfg_entry;
filename.name    = 'Filename for Output Model';
filename.tag     = 'filename';
filename.strtype = 's';
filename.help    = {'Specify name for the resulting model.'};

% Contrast value
convec         = cfg_entry;
convec.name    = 'Contrast Vector';
convec.tag     = 'convec';
convec.strtype = 'r';
convec.num     = [1 Inf];
convec.help    = {''};

% Read from first modelfile
file         = cfg_choice;
file.name    = 'Read Contrast Names from First Model File';
file.tag     = 'file';
file.values  = {con_all, convec};
file.help    = {''};

% Number contrats
number         = cfg_choice;
number.name    = 'Number Contrasts';
number.tag     = 'number';
number.values  = {con_all, convec};
number.help    = {''};

% Define contrast names
def_con_name         = cfg_choice;
def_con_name.name    = 'Define Contrasts';
def_con_name.tag     = 'def_con_name';
def_con_name.values  = {file, number};
def_con_name.help    = {'Define contrasts and names: these can be read from the first model file, entered manually, or just be numbered.'};


% Overwrite File
overwrite         = cfg_menu;
overwrite.name    = 'Overwrite Existing File';
overwrite.tag     = 'overwrite';
overwrite.val     = {false};
overwrite.labels  = {'No', 'Yes'};
overwrite.values  = {false, true};
overwrite.help    = {'Specify whether you want to overwrite existing mat files.'};


% Executable Branch
contrast      = cfg_exbranch;
contrast.name = 'Define Second-Level Model';
contrast.tag  = 'contrast';
contrast.val  = {testtype, outdir, filename, def_con_name, overwrite};
contrast.prog = @scr_cfg_run_contrast2;
contrast.vout = @scr_cfg_vout_contrast;
contrast.help = {['Define one-sample and two-sample t-tests on the between-subject (second) level. ' ...
    'A one-sample t-test is normally used to test within-subject contrasts and is equivalent to t-contrasts ' ...
    'in an ANOVA model A two-sample t-test is required for between-subjects contrasts or interactions. This ' ...
    'module sets up the model but does not report results.']};

function vout = scr_cfg_vout_contrast(job)
vout = cfg_dep;
vout.sname      = 'Output File';
% this can be entered into any file selector
vout.tgt_spec   = cfg_findspec({{'class','cfg_files'}});
vout.src_output = substruct('()',{':'});