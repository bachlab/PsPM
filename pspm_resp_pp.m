function sts = pspm_resp_pp(fn, sr, chan, options)
% ● Description
% pspm_resp_pp preprocesses raw respiration traces. The function detects
% respiration cycles for bellows and cushion systems, computes respiration
% period, amplitude and RFR, assigns these measures to the start of each
% cycle and linearly interpolates these (expect rs = respiration time
% stamps). Results are written to new channels in the same file
% ● Format
% sts = pspm_resp_pp(fn, sr, chan, options)
% ● Arguments
% fn                  data file name
% sr                  sample rate for new interpolated channel
% chan                number of respiration channel (optional, default: first
%                     respiration channel)
% options
% ┣━.systemtype       ['bellows'(default) /'cushion']
% ┣━.datatype         a cell array with any of 'rp', 'ra', 'rfr',
% ┃                   'rs', 'all' (default)
% ┣━.plot             1 creates a respiratory cycle detection plot
% ┗━.channel_action   ['add'(default) /'replace']
%                     Defines whether the new channels should be added or 
%                     the corresponding channel should be replaced.
% PsPM 3.0
% (C) 2015 Dominik R Bach (Wellcome Trust Centre for Neuroimaging)

%% Initialise
global settings
if isempty(settings)
  pspm_init;
end
sts = -1;
%% check input
if nargin < 1
  warning('ID:invalid_input', 'No input. Don''t know what to do.'); return;
elseif ~ischar(fn)
  warning('ID:invalid_input', 'Need file name string as first input.'); return;
elseif nargin < 2
  warning('ID:invalid_input', 'No sample rate given.'); return;
elseif ~isnumeric(sr)
  warning('ID:invalid_input', 'Sample rate needs to be numeric.'); return;
elseif nargin < 3 || isempty(chan) || (chan == 0)
  chan = 'resp';
elseif ~isnumeric(chan)
  warning('ID:invalid_input', 'Channel number must be numeric'); return;
end
try options.systemtype; catch, options.systemtype = 'bellows'; end
try options.datatype; catch, options.datatype = {'rp', 'ra', 'rfr', 'rs'}; end
try options.plot; catch, options.plot = 0; end
try options.diagnostics; catch, options.diagnostics = 0; end
try options.channel_action; catch, options.channel_action = 'add'; end
if ~ischar(options.systemtype) || sum(strcmpi(options.systemtype, {'bellows', 'cushion'})) == 0
  warning('ID:invalid_input', 'Unknown system type.'); return;
elseif ~iscell(options.datatype)
  warning('ID:invalid_input', 'Unknown data type.'); return;
else
  datatypes = {'rp', 'ra', 'rfr', 'rs', 'all'};
  datatype = zeros(5, 1);
  for k = 1:numel(options.datatype)
    datatype(strcmpi(options.datatype{k}, datatypes)) = 1;
  end
  if datatype(end), datatype(1:end) = 1; end
end
%% get data
[nsts, infos, data] = pspm_load_data(fn, chan);
old_chantype = data{1}.header.chantype;
if nsts == -1
  warning('ID:invalid_input', 'Could not load data properly.');
  return;
end
if numel(data) > 1
  fprintf(['There is more than one respiration channel in the data file. ',...
    'Only the first of these will be analysed.']);
  data = data(1);
end
resp = data{1}.data;
%% filter mean-centred data
% Butterworth filter
filt.sr        = data{1}.header.sr;
filt.lpfreq    = 0.6;
filt.lporder   = 1;
filt.hpfreq    = .01;
filt.hporder   = 1;
filt.direction = 'bi';
filt.down      = 10;
[sts, newresp, newsr] = pspm_prepdata(resp - mean(resp), filt);
% Median filter
newresp = medfilt1(newresp, ceil(newsr) + 1);
%% detect breathing cycles
if strcmpi(options.systemtype, 'bellows')
  % find pos/neg zero crossings
  respstamp = find(diff(sign(newresp)) == -2)/newsr;
elseif strcmpi(options.systemtype, 'cushion')
  % find neg/pos zero crossings of first derivative
  diffresp = diff(newresp);
  foo = diff(sign(diffresp));
  % find direct zero crossings
  zero1 = find(foo == 2);
  % find zero crossings that stay at zero for a while
  indx = find(foo ~= 0);
  neighbour_sums = conv(foo(indx), [1 1], 'valid');
  pairs = find(neighbour_sums == 2);
  zero2 = ceil(mean([indx(pairs + 1), indx(pairs)], 2));
  % combine while accouting for differentiating twice
  respstamp = sort([zero1;zero2] + 1)/newsr;
end
%% exclude < 1 s IBIs
ibi = diff(respstamp);
indx = find(ibi < 1);
respstamp(indx + 1) = [];
if strcmp(options.channel_action, 'replace') && numel(find(datatype == 1)) > 1
  % replace makes no sense
  warning('ID:invalid_input', ...
    ['More than one datatype defined. Replacing data makes no sense. '...
    'Resetting ''options.channel_action'' to ''add''.']);
  options.channel_action = 'add';
end
%% compute data values, interpolate and write
for iType = 1:(numel(datatypes) - 1)
  respdata = [];
  if datatype(iType)
    clear newdata
    % compute new data values
    switch iType
      case 1
        %rp
        respdata = diff(respstamp);
        newdata.header.chantype = 'rp';
        action_msg = 'Respiration converted to respiration period';
        newdata.header.units = 's';
      case 2
        %ra
        for k = 1:(numel(respstamp) - 1)
          win = ceil(respstamp(k) * data{1}.header.sr):ceil(respstamp(k + 1) * data{1}.header.sr);
          respdata(k) = range(resp(win));
        end
        newdata.header.chantype = 'ra';
        action_msg = 'Respiration converted to respiration amplitude';
        newdata.header.units = 'unknown';
      case 3
        %rfr
        ibi = diff(respstamp);
        for k = 1:(numel(respstamp) - 1)
          win = ceil(respstamp(k) * data{1}.header.sr):ceil(respstamp(k + 1) * data{1}.header.sr);
          respdata(k) = range(resp(win))/ibi(k);
        end
        newdata.header.chantype = 'rfr';
        action_msg = 'Respiration converted to rfr';
        newdata.header.units = 'unknown';
      case 4
        %rs
        newdata.header.chantype = 'rs';
        action_msg = 'Respiration converted to respiration time stamps';
        newdata.header.units = 'events';
    end
    channel_str = num2str(chan);
    o.msg.prefix = sprintf(...
      'Respiration preprocessing :: Input channel: %s -- Input chantype: %s -- Output channel: %s -- Action: %s --', ...
      channel_str, ...
      old_chantype, ...
      newdata.header.chantype, ...
      action_msg);
    % interpolate
    switch iType
      case {1, 2, 3}
        newt = (1/sr):(1/sr):infos.duration;
        if ~isempty(respdata)
          % assign rp/ra/RFR to following zero crossing
          writedata = interp1(respstamp(2:end), respdata, newt, 'linear' ,'extrap'); 
          % 'extrap' option may introduce falsely negative values
          writedata(writedata < 0) = 0;
        else
          writedata = NaN(length(newt), 1);
        end
        newdata.header.sr = sr;
      case {4}
        writedata = respstamp;
        newdata.header.sr = 1;
    end
    % write
    newdata.data = writedata(:);
    nsts = pspm_write_channel(fn, newdata, options.channel_action, o);
    if nsts == -1, return; end
  end
end
%% create diagnostic plot for detection/interpolation
if options.plot
  figure('Position', [50, 50, 1000, 500]);
  axes; hold on;
  oldsr = data{1}.header.sr;
  oldt = (1/oldsr):(1/oldsr):infos.duration;
  newt = (1/newsr):(1/newsr):infos.duration;
  % normal breathing is 12-20 per minute, i. e. 3 - 5 s per breath. prd.
  % according to Schmidt/Thews, 10-18 per minute, i. e. 3-6 s per period
  % here we flag values outside 1-10 s breathing period
  plot(oldt, resp(1:numel(oldt)), 'k');
  plot(newt, newresp(1:numel(newt)), 'b');
  indx = (diff(respstamp)<1)|(diff(respstamp)>10);
  stem(respstamp(indx), 2*ones(size(respstamp(indx))), 'Marker', 'none', 'Color', 'r', 'LineWidth', 4);
  stem(respstamp, ones(size(respstamp)), 'Marker', 'o', 'Color', 'b');
end
sts = 1;