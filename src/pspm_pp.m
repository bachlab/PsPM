function newdatafile = pspm_pp(varargin)
% ● Description
%   pspm_pp contains various preprocessing utilities for reducing noise in the
%   data.
% ● Format
%   pspm_pp('median', datafile, n, channelnumber, options)
%   pspm_pp('butter', datafile, freq, channelnumber, options)
% ● Arguments
%   [Currently implemented]
%   'median': medianfilter for SCR
%          n: number of timepoints for median filter
%   'butter': 1st order butterworth low pass filter for SCR
%       freq: cut off frequency (min 20 Hz)
%	channelnumber:
%	┌──options:	[struct] optional
% └.overwrite:[logical] (0 or 1)
%             Define whether to overwrite existing output files or not.
%             Default value: determined by pspm_overwrite.
% ● History
%   Introduced In PsPM 3.0
%   Written in 2009-2015 by Dominik R Bach (Wellcome Trust Centre for Neuroimaging)
%   Maintained in 2022 by Teddy Chao (UCL)

%% Initialise
global settings
if isempty(settings)
  pspm_init;
end
newdatafile = [];
%% Check input arguments
if nargin < 1
  warning('ID:invalid_input', 'No input arguments. Don''t know what to do.');
elseif nargin < 2
  warning('ID:invalid_input', 'No datafile.'); return;
end
method = varargin{1};
supported_methods = {'median', 'butter', 'simple_qa'};
if ~any(strcmp(method, supported_methods))
  methods_str = sprintf('%s ', supported_methods{:});
  warning('ID:invalid_input', sprintf('Preprocessing method must be one of %s', methods_str)); return;
end
if nargin < 3
  if strcmp(method, 'median') || strcmp(method, 'butter')
    warning('ID:invalid_input', 'Missing filter specs.'); return;
  end
end
fn = varargin{2};
if nargin >=5 && isstruct(varargin{5}) && isfield(varargin{5}, 'overwrite')
  options = varargin{5};
else
  options = struct(); % build an empty struct if nothing is available
end
options = pspm_options(options, 'pp');% update options
if options.invalid
  return
end
%% Load data
[sts, infos, data] = pspm_load_data(fn, 0);
if sts ~= 1
  warning('ID:invalid_input', 'call of pspm_load_data failed');
  return;
end
%% Determine channel number
if nargin >= 4 && ~isempty(varargin{4}) && ...
    (~isequal(size(varargin{4}), [1,1]) || varargin{4} ~= 0)
  channum = varargin{4};
else
  for k = 1:numel(data)
    if strcmp(data{k}.header.channeltype, 'scr')
      channum(k) = 1;
    end
  end
  channum = find(channum == 1);
end
%% Do the job
switch method
  case 'median'
    n = varargin{3};
    % user output
    fprintf('\n\xBB Preprocess: median filtering datafile %s, ', fn);
    for k = 1:numel(channum)
      curr_chan = channum(k);
      data{curr_chan}.data = medfilt1(data{curr_chan}.data, n);
    end
    infos.pp = sprintf('median filter over %1.0f timepoints', n);
  case 'butter'
    freq = varargin{3};
    if freq < 20, warning('ID:invalid_freq', 'Cut off frequency must be at least 20 Hz'); return; end
    % user output
    fprintf('\n\xBB Preprocess: butterworth filtering datafile %s, ', fn);
    for k = 1:numel(channum)
      curr_chan = channum(k);
      filt.sr = data{curr_chan}.header.sr;
      filt.lpfreq = freq;
      filt.lporder = 1;
      filt.hpfreq = 'none';
      filt.hporder = 0;
      filt.down = 'none';
      filt.direction = 'bi';
      [sts, data{curr_chan}.data, data{curr_chan}.header.sr] = pspm_prepdata(data{curr_chan}.data, filt);
      if sts == -1
        warning('ID:invalid_input', 'call of pspm_prepdata failed');
        return;
      end
    end
    infos.pp = sprintf('butterworth 1st order low pass filter at cutoff frequency %2.2f Hz', freq);
  otherwise
    warning('ID:invalid_input', 'Unknown filter option ...');
    return;
end
[pth, fn, ext] = fileparts(fn);
newdatafile = fullfile(pth, ['m', fn, ext]);
infos.ppdate = date;
infos.ppfile = newdatafile;
clear savedata
savedata.data = data;
savedata.infos = infos;
options.overwrite = pspm_overwrite(newdatafile, options);
savedata.options = options;
pspm_load_data(newdatafile, savedata);
fprintf('done.');
return
