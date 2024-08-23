function markerinfo = pspm_cfg_get_markerinfo

%% Standard items
datafile               = pspm_cfg_selector_datafile;
marker_chan            = pspm_cfg_selector_channel('marker');
output                 = pspm_cfg_selector_outputfile('Marker info');

%% Executable branch
markerinfo      = cfg_exbranch;
markerinfo.name = 'Extract event marker info';
markerinfo.tag  = 'extract_markerinfo';
markerinfo.val  = {datafile, marker_chan, output};
markerinfo.prog = @pspm_cfg_run_get_markerinfo;
markerinfo.vout = @pspm_cfg_vout_outfile;
markerinfo.help = pspm_cfg_help_format('pspm_get_markerinfo');