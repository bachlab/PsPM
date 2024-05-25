function datafile = pspm_cfg_selector_datafile(varargin)

if nargin < 1 || strcmpi(varargin{1}, 'PsPM')
    ext = 'mat';
    helptext = 'Specify a PsPM file with the data to be used.';
else
    ext = varargin{1};
    helptext = 'Specify the data file to be imported.';
end

datafile         = cfg_files;
datafile.name    = 'Data File';
datafile.tag     = 'datafile';
datafile.num     = [1 1];
datafile.filter  = ['.*\.(' ext '|' upper(ext) ')$'];
datafile.help    = {helptext};