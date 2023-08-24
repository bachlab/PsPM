function [sts, newfile] = pspm_down(datafile, newsr, channel, options)
% ● Description
%   pspm_down downsamples a PsPm dataset to the desired new sample rate
%   this function applies anti-aliasing filtering at 1/2 of the new sample
%   rate. The data will be written to a new file, the original name will be
%   prepended with 'd'.
% ● Format
%   [sts, newfile] = pspm_down(datafile, newsr, channel, options)
% ● Arguments
%   datafile:  can be a name, or for convenience, a cell array of filenames
%    newfreq:  new frequency (must be >= 10 Hz)
%    channel:  channels to downsample (default: all channels)
%    options:  defines whether to overwrite the file.
%              Default value: overwrite, and also determined by pspm_overwrite.
% ● Output
%        sts:  1 if the function runs successfully
%    newfile:  the filename for the updated file, or cell array of filenames
% ● History
%   Introduced in PsPM 3.0
%   Written in 2010-2015 by Dominik R Bach (Wellcome Trust Centre for Neuroimaging)

%% Initialise
global settings
if isempty(settings)
  pspm_init;
end
sts = -1;

%% check input arguments
if nargin<1
  errmsg='No data file'; warning('ID:invalid_input', errmsg); return;
elseif nargin<2
  errmsg='No frequency given'; warning('ID:invalid_input', errmsg); return;
elseif newsr < 10
  errmsg='This function does not support downsampling to frequencies below 10 Hz.';
  warning('ID:rate_below_minimum', errmsg);
  return;
end

if nargin < 3 || isempty(channel)
  channel = 0;
elseif isnumeric(channel) && isvector(channel)
  if numel(channel) == 1 && channel < 0
    warning('ID:invalid_input', 'channel must be nonnegative'); return;
  elseif any(channel < 0)
    warning('ID:invalid_input', 'All elements of channel must be positive'); return;
  end
elseif ischar(channel)
  if strcmpi(channel, 'all')
    channel = 0;
  else
    warning('ID:invalid_input', 'Channel argument must be a number, or ''all''.'); return;
  end
end

if nargin == 4
if ~isstruct(options)
  warning('ID:invalid_input','options has to be a struct');
  return;
end
options = pspm_options(options, 'down');
if options.invalid
  return
end

%% convert datafile to cell for convenience
if iscell(datafile)
  D = datafile;
else
  D = {datafile};
end
clear datafile

%% work on all data files
for d = 1:numel(D)
  % determine file names
  datafile = D{d};

  % check and get datafile
  [lsts, ~, ~] = pspm_load_data(datafile, 0);
  if lsts == -1, continue; end

  if any(channel > numel(data))
    warning(['Datafile %s contains only %i channels. ', ...
      'At least one selected channel is inexistent'], ...
      datafile, numel(data));
    return;
  end

  % set channels
  if channel == 0
    channel = 1:numel(data);
  end

  % make outputfile
  [p, f, ex]=fileparts(datafile);
  newfile=fullfile(p, ['d', f, ex]);

  % if not to overwrite files, end the function
  if ~pspm_overwrite(newfile, options); return; end

  % user output
  fprintf('Downsampling %s ... ', datafile);

  % downsample channel after channel
  for k = channel
    % leave event channels alone
    if strcmpi(data{k}.header.units, 'events')
      fprintf(['\nNo downsampling for event channel %2.0f in ', ...
        'datafile %s ...'], k, datafile);
    else
      filt.sr = data{k}.header.sr;
      filt.lpfreq = newsr/2;
      filt.lporder = 1;
      filt.hpfreq = 'none';
      filt.hporder = 0;
      filt.direction = 'bi';
      filt.down = newsr;
      [lsts, foo, sr] = pspm_prepdata(data{k}.data, filt);
      data{k}.data = foo;
      data{k}.header.sr = sr;
    end
  end

  [pth, nfn, ext] = fileparts(newfile);
  infos.downsampledfile = [nfn ext];
  save(newfile, 'infos', 'data');
  Dout{d}=newfile;

end

% user output
fprintf('  done.\n');

% if cell array of datafiles is being processed, return cell array of
% filenames
if d>1
  clear newdatafile
  newfile=Dout;
end

sts = 1;
return
