function norm = pspm_cfg_selector_norm

norm         = cfg_menu;
norm.name    = 'Normalization';
norm.tag     = 'norm';
norm.labels  = {'No', 'Yes'};
norm.val     = {0};
norm.values  = {0,1};
norm.help    = {['Specify if you want to normalize the data. For ', ...
    'within-subjects designs, this usually makes the output less variable between persons.']};