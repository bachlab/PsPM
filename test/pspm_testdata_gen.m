function outfile = pspm_testdata_gen(channels, duration, filename)
%SCR_TESTDATA_GEN generates simple testdata
%
% The function generates testdata for multiple channels. For continuous
% channels it generates a simple sine waveform with amplitude 1 and
% arbitrary frequency. For event based channels, it generates a column
% vector with those time points at which events take place (starting with 0),
% using constant and arbitrary intervals.
%
% FORMAT:
% OUTFILE=SCR_TESTDATA_GEN(channels, duration, filename)
%
% duration: duration of the testsignal in s (default value is 10s)
% channels: a cell array of struct with mandatory fields for each channel:
%           - .chantype: 'scr', 'hr', 'hb', 'resp', 'trigger', 'scanner'
%           and optional fields:
%           if .chantype is 'scr' or 'hr' (continuous channels):
%           - .units: units to write to channel, defaults to 'unknown' for continuous and 'events' for event data
%           - .sr: sampling rate for waveform (default value is 100Hz)
%           - .freq: frequencey of the waveform (default value is 1Hz)
%           - .noise: (default: 0) if 1 will add random normally
%                      distributed noise
%           if .chantype is 'hb', 'resp', 'trigger' or 'scanner' (eventbased channels):
%           - .sessions: split event trains in to multiple sessions
%                       (pspm_split_sessions). default: 1
%           - .session_distance: if sessions is > 1 the distance between
%                                two sessions. default: 0
%           - .variance: define if there should be normally distributed
%                        variance in the event distance. default: 0
%           - .eventrt: event rate (default value is 1Hz);
%           - .eventdist: define how to distribute events (default: even)
%                           - 'even' create an event at each .eventrt
%                           - 'max' create an event at each maximum of an
%                             imaginary sinusoid curve as it is generated
%                             in continuous channels
%                           - 'min' create an event at each minimum of an
%                             imaginary sinusoid curve as it is generated
%                             in continuous channels
%                           -> 'min' and 'max' could be used as a
%                           counterpart for a continuous wave form channel
% filename: filname of the .mat file, where the generated data will be
%           saved (optional).
%
% outfile:  a struct with the two following fields:
%           - .infos: a struct with the fields '.duration' and '.durationinfo'
%           - .data:  a cell array of struct with the following fields for
%                    each channel:
%                    - .data:   the genarated data as a column vector
%                    - .header: a struct with the fields '.chantype',
%                               '.units', '.sr' and '.eventrt' for eventbased
%                               channels or '.freq' and  for continuous channels
%__________________________________________________________________________
% PsPM
% (C) 2013 Linus Rüettimann & Dominik R Bach (University of Zurich)

% $Id: pspm_testdata_gen.m 458 2017-08-09 09:32:12Z tmoser $
% $Rev: 458 $

% v002 lr  22.04.2013
% v001 drb 15.03.2013


% Check input
% -------------------------------------------------------------------------
if nargin < 1
  warning('No channels are given'); return;
elseif ~iscell(channels)
  if isstruct(channels) && numel(channels) == 1
    foo{1} = channels; channels = foo; clear foo;
  else
    warning('channels needs to be a cell array of struct, or a single struct'); return;
  end
elseif nargin < 2
  %Default value
  duration = 10;
end

% check options
try options.noise; catch, options.noise = 0; end

save_flag = 0;
if nargin==3 && ischar(filename), save_flag=1; end


% prepare output
% -------------------------------------------------------------------------

% Continuous Channels
cont_channels{1} = 'scr';
cont_channels{2} = 'hr';
cont_channels{3} = 'resp';
cont_channels{4} = 'snd';

% regex expression for scr OR hr OR resp OR snd OR gaze with x/y and r/l
cont_channels_regex = '^(scr|hr|resp|snd|gaze_[x|y]_[r|l])$';

% Eventbased Channels
event_channels{1} = 'hb';
event_channels{2} = 'rs';
event_channels{3} = 'marker';
% Generate testdata for each channel:
% -------------------------------------------------------------------------
% Initalize outfile:
outfile.data = cell(0);
outfile.infos.duration = duration;
outfile.infos.durationinfo = 'Duration in seconds';
for k = 1:numel(channels)
  % needed for both channel types
  if ~isfield(channels{k}, 'sr')
    channels{k}.sr = 100;
  end
  if ~isfield(channels{k}, 'chantype')
    warning('No type given for channels job %2.0f', k); outfile = cell(0); return;
  elseif regexp(channels{k}.chantype, cont_channels_regex)
    %default values
    if ~isfield(channels{k}, 'freq')
      channels{k}.freq = 1;
    end
    if ~isfield(channels{k}, 'noise')
      channels{k}.noise = 0;
    end
    outfile.data{k,1}.header = channels{k};
    if isfield(channels{k}, 'units')
      outfile.data{k,1}.header.units = channels{k}.units;
    else
      outfile.data{k,1}.header.units = 'unknown';
    end
    outfile.data{k,1}.header.chantype = channels{k}.chantype;
    %Generate sinewaveform
    t = ((channels{k}.sr^-1):(channels{k}.sr^-1):duration)';
    % generate data
    d = sin(2*pi*t*channels{k}.freq);
    % add noise to data
    if channels{k}.noise
      d = d + randn(size(d))*0.3*max(d);
    end
    outfile.data{k,1}.data = d;
  elseif any(strcmp(channels{k}.chantype, event_channels))
    %default values
    if ~isfield(channels{k}, 'eventrt')
      channels{k}.eventrt = 1;
    end
    if ~isfield(channels{k}, 'eventdist')
      channels{k}.eventdist = 'even';
    end
    if ~isfield(channels{k}, 'sessions')
      channels{k}.sessions = 1;
    end
    if ~isfield(channels{k}, 'session_distance')
      channels{k}.session_distance = 0;
    end
    if ~isfield(channels{k}, 'variance')
      channels{k}.variance = 0;
    end
    newdur = ...
      floor((duration-(channels{k}.sessions-1)*channels{k}.session_distance)/channels{k}.sessions);
    % how many events fit into one session:
    nevent = newdur*channels{k}.eventrt;
    ev_data = zeros(nevent*channels{k}.sessions,1);
    for j = 1:channels{k}.sessions
      % generate normally distributed
      % 'diff()' and then 'integrate' with cumsum()
      deriv = normrnd(channels{k}.eventrt^-1, channels{k}.variance, nevent,1);
      % the mean is not exactly, so correct it
      deriv = deriv/mean(deriv);
      sess_ev = cumsum(deriv);
      % just in case. ensure that last value is not too big
      sess_ev(end) = floor(sess_ev(end));
      % add session distance
      sess_ev = (newdur+channels{k}.session_distance)*(j-1) + sess_ev;
      %offset according to eventdist
      % -> distribute events around maximum or minimum
      if strcmpi(channels{k}.eventdist, 'max')
        % maximum at pi/2 (-> 1/4*2*pi) and 2*pi periodic
        % 1-3/4 = 1/4
        sess_ev = sess_ev - (3/4)*channels{k}.eventrt^-1;
      elseif strcmpi(channels{k}.eventdist, 'min')
        % minimum at 3*pi/2 (-> 3/4*2*pi)
        % 1-1/4 = 3/4
        sess_ev = sess_ev - (1/4)*channels{k}.eventrt^-1;
      end
      ev_data(((j-1)*nevent+1):(j*nevent)) = sess_ev;
    end
    outfile.data{k,1}.header = channels{k};
    if isfield(channels{k}, 'units')
      outfile.data{k,1}.header.units = channels{k}.units;
    else
      outfile.data{k,1}.header.units = 'events';
    end
    outfile.data{k,1}.header.chantype = channels{k}.chantype;
    outfile.data{k,1}.data = ev_data;
  else
    warning('Type %s is not supported', channels{k}.chantype); outfile = cell(0); return;
  end
end
% Save the struct fields in a .mat file
if save_flag
save(filename,'-struct','outfile');
end
end