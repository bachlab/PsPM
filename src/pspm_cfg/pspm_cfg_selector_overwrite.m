function overwrite = pspm_cfg_selector_overwrite

% Overwrite File
overwrite         = cfg_menu;
overwrite.name    = 'Overwrite Existing File';
overwrite.tag     = 'overwrite';
overwrite.val     = {2};
overwrite.labels  = {'Discard data if file exists', 'Always overwrite', 'Ask user every time a file exists'};
overwrite.values  = {0, 1, 2};
overwrite.help    = {'Specify whether you want to overwrite an existing file with the same name.'};
