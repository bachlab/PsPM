function markerinfo = pspm_cfg_get_markerinfo

%% Standard items
datafile               = pspm_cfg_selector_datafile;
marker_chan            = pspm_cfg_selector_channel('many');
[file_name, file_path] = pspm_cfg_selector_outputfile('marker info');
overwrite              = pspm_cfg_selector_overwrite;

%% file
file             = cfg_branch;
file.name        = 'File';
file.tag         = 'file';
file.val         = {file_name, file_path};
file.help        = {'Specify the output file to which the marker info should be written to.'};

%% Output
output           = cfg_branch;
output.name      = 'Output';
output.tag       = 'output';
output.val       = {file, overwrite};
output.help      = {''};

%% Executable branch
markerinfo      = cfg_exbranch;
markerinfo.name = 'Extract event marker info';
markerinfo.tag  = 'extract_markerinfo';
markerinfo.val  = {datafile, marker_chan, output};
markerinfo.prog = @pspm_cfg_run_get_markerinfo;
markerinfo.vout = @pspm_cfg_vout_outfile;
markerinfo.help = {['Allows to extract additional marker information for ', ...
    'further processing. The information can be used to distinguish ', ...
    'between different types of events or for other purposes. This is ', ...
    'usually used to extract marker information from EEG-style data files ', ...
    'such as BrainVision or NeuroScan.']};