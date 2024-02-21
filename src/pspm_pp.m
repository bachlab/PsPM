function [sts, fn] = pspm_pp(varargin)
% ● Description
%   pspm_pp contains various preprocessing utilities for reducing noise in the
%   data. The 'butter' option allows downsampling after application of an
%   anti-alias filter.
% ● Format
%   [sts, datafile] = pspm_pp('median', datafile, channel, n, options)
%   [sts, datafile] = pspm_pp('butter', datafile, channel, filterstruct, options)
% ● Arguments
%   [Currently implemented]
%   'median': medianfilter
%          n: number of timepoints for median filter
%   'butter': Butterworth band pass filter potentially including
%             downsampling
%   ┌──────filt:  a struct with fields:
%   ├───.lpfreq:  low pass filt frequency or 'none' (default)
%   ├──.lporder:  low pass filt order (default: 1)
%   ├───.hpfreq:  high pass filt frequency or 'none' (default)
%   ├──.hporder:  high pass filt order (default: 1)
%   ├.direction:  filt direction ('uni' or 'bi', default 'uni')
%   └─────.down:  sample rate in Hz after downsampling or 'none' (default)
%  channel: A channel definition accepted by pspm_load_channel
%   ┌──options: [struct]
%   └─.channel_action:
%              [optional][string][Accepts: 'add'/'replace'][Default: 'add']
%              Defines whether corrected data should be added or the
%              corresponding preprocessed channel should be replaced. 
% ● History
%   Introduced In PsPM 3.0
%   Written in 2009-2015 by Dominik R Bach (Wellcome Trust Centre for Neuroimaging)
%   Refactored in 2024 by Dominik R Bach

%% Initialise
global settings
if isempty(settings)
  pspm_init;
end
sts = -1;
newdatafile = [];
%% Check input arguments
if nargin < 1
  warning('ID:invalid_input', 'No input arguments. Don''t know what to do.');
elseif nargin < 2
  warning('ID:invalid_input', 'No datafile.'); return;
elseif nargin < 3
    warning('ID:invalid_input', 'No channel given.'); return;
elseif nargin < 4
      warning('ID:invalid_input', 'Missing filter specs.'); return;
elseif nargin < 5
    options = struct(); % build an empty struct if nothing is available
else
    options = varargin{5};
end

method = varargin{1};
fn = varargin{2};
channel = varargin{3};
  
%% Load data
[sts, data, ~, pos_of_channel] = pspm_load_channel(fn, channel);
if sts ~= 1, return; end

%% Do the job
switch method
  case 'median'
    n = varargin{4};
    % user output
    fprintf('\n\xBB Preprocess: median filtering datafile %s ... ', fn);
    data.data = medfilt1(data.data, n);
    msg = sprintf('median filter over %1.0f timepoints', n);
  case 'butter'
    filt = varargin{4};    
    if ~isstruct(filt)
        warning('ID:invalid_input', 'Filter must be a struct.'); return;
    end
    % set defaults
    if ~isfield(filt, 'down')
        filt.down = 'none';
    end
    if ~isfield(filt, 'lpfreq')
        filt.lpfreq = 'none';
    end
    if ~isfield(filt, 'hpfreq')
        filt.hpfreq = 'none';
    end
    if ~isfield(filt, 'lporder')
        filt.lporder = 1;
    end
    if ~isfield(filt, 'hporder')
        filt.hporder = 1;
    end
    if ~isfield(filt, 'direction')
        filt.direction = 'uni';
    end
    filt.sr = data.header.sr;
    fprintf('\n\xBB Preprocess: butterworth filtering datafile %s ... ', fn);
    [sts, data.data, data.header.sr] = pspm_prepdata(data.data, filt);
    if sts == -1, return; end
    msg = sprintf('butterworth filter');
  otherwise
    warning('ID:invalid_input', 'Unknown filter option ...');
    return;
end
fprintf('done.\n');
sts = pspm_write_channel(fn, data, options.channel_action, struct('prefix', msg, 'channel', pos_of_channel));
return
