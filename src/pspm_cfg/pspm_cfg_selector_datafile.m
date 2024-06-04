function datafile = pspm_cfg_selector_datafile(varargin)

if nargin < 1 || strcmpi(varargin{1}, 'PsPM')
    ext = 'mat';
    helptext = 'Specify a PsPM file with the data to be used.';
elseif strcmpi(varargin{1}, 'epochs')
    ext = 'mat';
    helptext = ['Specify an epoch *.mat file containing the start and ', ...
    'end points of missing epochs. This mat file has to contain a ', ...
    'variable ''epochs'', which is an m x 2 matrix, where m is the number of' ...
    ' missing epochs. The first column marks the start points', ...
    'of the epochs that are excluded from the ' ...
    'analysis and the second column the end points. All time points must ...' ...
    'be specified in seconds from file start.'];
else
    ext = varargin{1};
    helptext = 'Specify the data file to be imported.';
end

datafile         = cfg_files;
datafile.name    = 'Data file';
datafile.tag     = 'datafile';
datafile.num     = [1 1];
datafile.filter  = ['.*\.(' ext '|' upper(ext) ')$'];
datafile.help    = {helptext};