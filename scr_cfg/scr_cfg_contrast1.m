function contrast = scr_cfg_contrast1
% Contrast (first level)

% $Id$
% $Rev$


% Select File
modelfile         = cfg_files;
modelfile.name    = 'Model File(s)';
modelfile.tag     = 'modelfile';
modelfile.num     = [1 Inf];
modelfile.filter  = '.*\.(mat|MAT)$';
modelfile.help    = {'Specify the model file for which to compute contrasts.'};

% Contrast name
conname         = cfg_entry;
conname.name    = 'Contrast Name';
conname.tag     = 'conname';
conname.strtype = 's';
conname.help    = {'This name identifies the contrast in tables and displays.'};

% Contrast vector
convec         = cfg_entry;
convec.name    = 'Contrast Vector';
convec.tag     = 'convec';
convec.strtype = 'r';
convec.num     = [1 Inf];
convec.help    = {['This is a vector on all included conditions (GLM), trials (DCM for event-related responses), ' ...
    'or epochs (DCM for SF). Shorter vectors will be appended with zeros.'], ['To specify a condition or trial ' ...
    'difference, the contrast weights must add up to zero (e. g. was sympathetic arousal in condition A larger ' ...
    'than in condition B: c = [1 -1]).'], ['To specify a summary of conditions or trials, the contrast weights ' ...
    'should add up to 1 to retain proper scaling (e. g. was non-zero sympathetic arousal elicited in combined ' ...
    'conditions A and B: c = [0.5 0.5])']};

% Contrasts
con         = cfg_branch;
con.name    = 'Contrast';
con.tag     = 'con';
con.val     = {conname, convec};
con.help    = {''};

con_rep         = cfg_repeat;
con_rep.name    = 'Contrast(s)';
con_rep.tag     = 'con_rep';
con_rep.values  = {con};
con_rep.num     = [1 Inf];
con_rep.help    = {''};


% Delete existing contrasts
deletecon         = cfg_menu;
deletecon.name    = 'Delete Existing Contrasts';
deletecon.tag     = 'deletecon';
deletecon.val     = {false};
deletecon.labels  = {'No', 'Yes'};
deletecon.values  = {false, true};
deletecon.help    = {'Deletes existing contrasts from the model file.'};

% Zscore data
zscored         = cfg_menu;
zscored.name    = 'Z-scoring';
zscored.tag     = 'zscored';
zscored.val     = {false};
zscored.labels  = {'No', 'Yes'};
zscored.values  = {false, true};
zscored.help    = {['Use parameter estimates across all conditions for each ', ...
    'parameter/eventtype, subtract the mean and divide by the standard ',...
    'deviation, before computing the contrast. This option is only available ',...
    'for models with trial-wise parameter estimates.']};

% Datatype
datatype        = cfg_menu;
datatype.name   = 'Stats type';
datatype.tag    = 'datatype';
datatype.val    = {'param'};
datatype.labels = {'param','cond','recon'};
datatype.values = {'param','cond','recon'};
datatype.help   = {['Contrasts are usually specified on parameter estimates. For GLM, you can ' ...
    'also choose to specify them on conditions or reconstructed responses per condition. In this ' ...
    'case, your contrast vector needs to take into account only the first basis function. ' ...
    'For DCM, you can specify contrasts based on conditions as well. This will average within conditions. ', ...
    'Use the review manager to extract condition names and their order.', ...
    'This argument cannot be used for other first-level models.'], ...
    '', ...
    '- Parameter: Use all parameter estimates.', '', ...
    ['- Condition: Contrasts formulated in terms of conditions in a GLM, automatically detects number ' ...
    'of basis functions and uses only the first one (i.e. without derivatives), ', ...
    'or based on assignment of trials to conditions in DCM.'], '', ...
    ['- Reconstructed: Contrasts formulated in terms of conditions in a GLM, reconstructs estimated response ' ...
    'from all basis functions and uses the peak of the estimated response.'], ''};


% Executable Branch
contrast      = cfg_exbranch;
contrast.name = 'First-Level Contrasts';
contrast.tag  = 'contrast';
contrast.val  = {modelfile, datatype, con_rep, deletecon, zscored};
contrast.prog = @scr_cfg_run_contrast1;
contrast.vout = @scr_cfg_vout_contrast;
contrast.help = {['Define within-subject contrasts here for testing on the second level. Contrasts can be between ' ...
    'conditions (GLM), epochs (SF) or trials (Non-linear SCR models). Contrast weight should add up to 0 ' ...
    '(for testing differences between conditions/epochs/trials) or to 1 (for testing global/intercept effects ' ...
    'across conditions/epochs/trials).'], '', ['Example: an experiment realises a 2 (Factor 1: a, A) x 2 ' ...
    '(Factor 2: b, B) factorial design and consists of 4 conditions: aa, aB, Ab, AB. Testing the following ' ...
    'contrasts is equivalent to a full ANOVA model:'], '', ...
    'Main effect factor 1: [1 1 -1 -1]', '', ...
    'Main effect factor 2: [1 -1 1 -1]', '', ...
    'Interaction factor 1 x factor 2: [1 -1 -1 1]', '', ...
    ['To test condition effects in non-linear models, assign the same contrast weight to all trials from ' ...
    'the same condition.']};

function vout = scr_cfg_vout_contrast(job)
vout = cfg_dep;
vout.sname      = 'Output File';
% this can be entered into any file selector
vout.tgt_spec   = cfg_findspec({{'class','cfg_files'}});
vout.src_output = substruct('()',{':'});