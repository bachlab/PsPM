function overwrite = pspm_cfg_selector_overwrite

% Overwrite File
overwrite         = cfg_menu;
overwrite.name    = 'Overwrite Existing File';
overwrite.tag     = 'overwrite';
overwrite.val     = {0};
overwrite.labels  = {'No', 'Yes'};
overwrite.values  = {0, 1};
overwrite.help    = {'Specify whether you want to overwrite an existing file with the same name.'};
