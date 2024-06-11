function markerinfo = pspm_cfg_get_markerinfo

%% Standard items
datafile               = pspm_cfg_selector_datafile;
marker_chan            = pspm_cfg_selector_channel('many');
output                 = pspm_cfg_selector_outputfile('Marker info');

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