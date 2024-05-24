function datafile = pspm_cfg_selector_datafile()

datafile         = cfg_files;
datafile.name    = 'Data File';
datafile.tag     = 'datafile';
datafile.num     = [1 1];
datafile.filter  = '.*\.(mat|MAT)$';
datafile.help    = {'Add a PsPM data file containing the data to be used.'};