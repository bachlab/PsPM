function datafile = pspm_cfg_selector_datafile(varargin)
% pspm_cfg_selector_datafile is the standard item to select one or several
% input datafiles.
% Format: datafile = pspm_cfg_selector_datafile(datatype, filenumber)
% datatype: 'PsPM' (default), 'epochs', 'model', or a file extension for pspm_import
% number of files: integer (default: 1)

% Initialise
ext            = 'mat';
filedescriptor = 'Data file';
filetag        = 'datafile';

% parse file number
if nargin > 1
    fileno = varargin{2};
else
    fileno = 1;
end

% parse data type
if nargin < 1 || strcmpi(varargin{1}, 'PsPM')
    helptext = 'Specify a PsPM file with the data to be used.';
elseif strcmpi(varargin{1}, 'epochs')
    helptext = ['Specify a *.mat file containing the start and ', ...
    'end points of the epochs. This mat file has to contain a ', ...
    'variable ''epochs'', which is an m x 2 matrix, where m is the number of' ...
    ' epochs. The first column marks the start points', ...
    ' and the second column the end points of the epochs. Start and end points must ...' ...
    'be specified in units of seconds with reference to start of the corresponding data file.'];
    filetag = 'epochfile';
    filedescriptor = 'Epoch file';
elseif strcmpi(varargin{1}, 'model')
    if fileno == 1
        helptext = 'Specify a PsPM model file.';
        filedescriptor = 'Model file';
    elseif isinf(fileno)
        helptext = 'Specify any number of PsPM model files.';
        filedescriptor = 'Model file(s)';
    end
else
    ext = varargin{1};
    helptext = 'Specify the data file to be imported.';
end


datafile         = cfg_files;
datafile.name    = filedescriptor;
datafile.tag     = filetag;
datafile.num     = [1 fileno];
datafile.filter  = ['.*\.(' ext '|' upper(ext) ')$'];
datafile.help    = {helptext};