function [sts, infos] = pspm_find_sounds(varargin)
% ● Description
%   pspm_find_sounds finds and if required analyzes sound events in a pspm file.
%   A sound is accepted as event if it is longer than 10 ms and events are
%   recognized as different if they are at least 50 ms appart.
% ● Format
%   [sts, infos] = pspm_find_sounds(file,options)
% ● Arguments
%             file: path and filename of the pspm file holding the sound
% ┌────────options: struct with following possible values
% ├.channel_action: ['none'/'add'/'replace'] if not set to 'none'
% │                 sound events are written as marker channel to the
% │                 specified pspm file. Onset times then correspond to marker
% │                 events and duration is written to markerinfo. The
% │                 values 'add' or 'replace' state whether existing marker
% │                 channels should be replaced (last found marker channel will
% │                 be overwritten) or whether the new channel should be added
% │                 at the end of the data file. Default is 'none'.
% │                 Be careful: May overwrite reference marker channel
% │                 when working with 'replace'!!!
% ├.channel_output: ['all'/'corrected'] (default: 'all') defines
% │                 whether all sound markers or only sound markers which have
% │                 been assigned to a marker from the trigger channel should
% │                 be added as channel to the original file. 'corrected'
% │                 requires enabled diagnostics, but does not force it (the
% │                 option will otherwise not work).
% ├───.diagnostics: [TRUE/false] computes the delay between trigger and
% │                 displays the mean delay and standard deviation and
% │                 removes triggers which could not be assigned to a trigger
% │                 from existing trigger channel.
% ├──────.maxdelay: [number] Upper limit (in seconds) of the window in
% │                 which pspm_find_sounds will accept sounds to belong to a
% │                 marker. default is 3s.
% ├──────.mindelay: [number] Lower limit (in seconds) of the window in
% │                 which pspm_find_sounds will accept sounds to belong to a
% │                 marker. default is 0s.
% ├──────────.plot: [true/FALSE] displays a histogramm of the delays found and
% │                 a plot with the detected sound, the trigger and the onset
% │                 of the sound events. These are color coded for delay, from
% │                 green (smallest delay) to red (longest). Forces the
% │                 'diagnostics' option to true.
% ├──────.resample: [integer] spline interpolates the sound by the factor
% │                 specified. (1 for no interpolation, by default).
% │                 Caution must be used when using this option. It should only
% │                 be used when following conditions are met :
% │                 1. all frequencies are well below the Nyquist frequency
% │                 2. the signal is sinusoidal or composed of multiple sin
% │                 waves all respecting condition 1
% │                 Resampling will restore more or less the original signal
% │                 and lead to more accurate timings.
% ├───────────.roi: [vector of 2 floats] Region of interest for discovering
% │                 sounds. Especially usefull if pairing events with triggers.
% │                 Only sounds included inbetween the 2 timestamps will be
% │                 considered.
% ├────.sndchannel: [integer] number of the channel holding the sound.
% │                 By default the last 'snd' channel.
% ├─────.threshold: [0...1] percent of the max of the power in the signal that
% │                 will be accepted as a sound event. Default is 0.1.
% ├───.trigchannel: [integer] number of the channel holding the triggers.
% │                 By default first 'marker' channel.
% │   EXPERIMENTAL, use with caution!
% └.expectedSoundCount: [integer] Checks for correct number of detected sounds.
%                   If too few are found, lowers threshhold until at least
%                   specified count is reached. Thresh is lowered by .01 until
%                   0.05 is reached for a max of 95 iterations.
% ● Outputs
%             sts: 1 on successfull completion, -1 otherwise
% ┌──────────info: struct()
% ├──.snd_markers: vector of begining of sound sound events
% ├───────.delays: vector of delays between markers and detected sounds.
% │                Only available with option 'diagnostics' turned on.
% └──────.channel: number of added channel, when options.channel_action ~= 'none'
% ● History
%   Introduced in PsPM 3.0
%   Written in 2015 by Samuel Gerster (University of Zurich)

%% Initialise
global settings
if isempty(settings)
  pspm_init;
end
sts = -1;

switch length(varargin)
  case 1
    file = varargin{1};
    options = struct;
  case 2
    file = varargin{1};
    options = varargin{2};
  case 3
    warning('Up to two variables are accepted by pspm_find_sounds.');
    return
end

fprintf('Processing sound in file %s\n',file);

options = pspm_options(options, 'find_sounds');
if options.invalid
  return
end

% call it outinfos not to get confused
outinfos = struct();


% Load Data
[lsts, snd] = pspm_load_channel(file, options.sndchannel, 'snd');
if lsts == -1 
  return;
end

%% Sound

% Process Sound
snd.data = snd.data-mean(snd.data);
snd.data = snd.data/(max(snd.data));
tsnd = (0:length(snd.data)-1)'/snd.header.sr;

if options.resample>1
  % Interpolate data to restore sin like wave for more precision
  t = (0:1/options.resample:length(snd.data)-1)'/snd.header.sr;
  snd_pow = interp1(tsnd,snd.data,t,'spline').^2;
else
  t = tsnd;
  snd_pow = snd.data.^2;
end
% Apply simple bidirectional square filter
snd_pow = snd_pow-min(snd_pow);
mask = ones(round(.01*snd.header.sr),1)/round(.01*snd.header.sr);
snd_pow = conv(snd_pow,mask);
snd_pow = sqrt(snd_pow(1:end-length(mask)+1).*snd_pow(length(mask):end));

%% Process roi option
if isempty(options.roi)
  ll = 1;
  ul = length(snd.data);
else
  ll = dsearchn(t,options.roi(1));
  ul = dsearchn(t,options.roi(2));
end
roi_mask = false(size(snd.data));
roi_mask(ll:ul) = true;
loc_snd_pow = snd_pow;
loc_snd_pow(~roi_mask) = 0;


%% Find sound events
searchForMoreSounds = true;
while searchForMoreSounds == true
  clear snd_pres
  thresh_l = max(loc_snd_pow)*options.threshold;
  snd_pres(loc_snd_pow>thresh_l) = 1;
  snd_pres(loc_snd_pow<=thresh_l) = 0;
  % Convert detected sounds into events. If pulses are separated by less than
  % 50ms, combine into one event.
  mask = ones(round(0.05*snd.header.sr*options.resample),1);
  n_pad = length(mask)-1;
  c = conv(snd_pres,mask)>0;
  snd_pres = (c(1:end-n_pad) & c(n_pad+1:end));

  % Find rising and falling edges
  snd_re = t(conv([1,-1],snd_pres(1:end-1)+0)>0);
  % Find falling edges
  snd_fe = t(conv([1,-1],snd_pres(1:end-1)+0)<0);
  if numel(snd_re) ~= 0 && numel(snd_fe) ~= 0
    % Start with a rising and end with a falling edge
    if snd_re(1)>snd_fe(1)
      snd_re = snd_re(2:end);
    end
    if snd_fe(end) < snd_re(end)
      snd_fe = snd_fe(1:end-1);
    end
  end
  % Discard sounds shorter than 10ms
  noevent_i = find((snd_fe-snd_re)<0.01);
  snd_re(noevent_i)=[];
  snd_fe(noevent_i)=[];

  % find sound in sound
  if isstruct(options.snd_in_snd)
    % look for sound bursts of specific length option.snd_in_snd.width
    % within previously found sounds

    % go through all detected events
    clear snd_re_l snd_fe_l;
    for i_re = 1:length(snd_re)
      % if the detected sound is too small to be a possible snd in
      % snd ignore and continue for loop
      if (snd_fe(i_re) - snd_re(i_re)) < options.snd_in_snd.max_width
        continue
      end

      % get event's sound power, remoce DC component and normalize
      loc_snd_pow_l = loc_snd_pow(t>snd_re(i_re) & t<snd_fe(i_re));
      loc_snd_pow_l = loc_snd_pow_l-mean(loc_snd_pow_l);
      loc_snd_pow_l = loc_snd_pow_l/range(loc_snd_pow_l);
      % create time vector
      t_l = t(t>snd_re(i_re) & t<snd_fe(i_re));

      thresh_l = options.snd_in_snd.threshold;
      snd_pres_l = [];
      snd_pres_l(loc_snd_pow_l>thresh_l) = 1;
      snd_pres_l(loc_snd_pow_l<=thresh_l) = 0;
      % Convert detected sounds into events. If pulses are separated by less than
      % 10ms, combine into one event.
      mask_l = ones(round(0.01*snd.header.sr*options.resample),1);
      n_pad_l = length(mask_l)-1;
      c_l = conv(snd_pres_l,mask_l)>0;
      snd_pres_l = (c_l(1:end-n_pad_l) & c_l(n_pad_l+1:end));

      % Find rising and falling edges
      if sum(snd_pres_l)>0
        snd_re_l(i_re) = t_l(conv([1,-1],snd_pres_l(1:end-1)+0)>0); %#ok<*AGROW>
        % Find falling edges
        snd_fe_l(i_re) = t_l(conv([1,-1],snd_pres_l(1:end-1)+0)<0);
      else
        snd_re_l(i_re)=NaN;
        snd_fe_l(i_re)=NaN;
      end
    end
    snd_re_l(isnan(snd_re_l))=[];
    snd_fe_l(isnan(snd_fe_l))=[];
    if numel(snd_re_l) ~= 0 && numel(snd_fe_l) ~= 0
      % Start with a rising and end with a falling edge
      if snd_re_l(1)>snd_fe_l(1)
        snd_re_l = snd_re_l(2:end);
      end
      if snd_fe_l(end) < snd_re_l(end)
        snd_fe_l = snd_fe_l(1:end-1);
      end
    end
    % discard empty fields
    snd_re_l(snd_re_l==0)=[];
    snd_fe_l(snd_fe_l==0)=[];

    % assigne new values
    snd_re = snd_re_l';
    snd_fe = snd_fe_l';
  end

  % keep current snd_re for channel_output 'all'
  snd_re_all = snd_re;
  snd_fe_all = snd_fe;

  %% Triggers
  if options.diagnostics
    [lsts, mkr] = pspm_load_channel(file, options.trigchannel, 'marker');
    if lsts == -1
      return;
    end

    %% Estimate delays from trigger to sound
    delays = nan(length(mkr.data),1);
    snd_markers = nan(length(mkr.data),1);
    for i=1:length(mkr.data)
      % Find sound onset in region of interest
      t_re = snd_re(find(snd_re>mkr.data(i)+options.mindelay,1));
      delay = t_re-mkr.data(i);
      if delay<options.maxdelay
        delays(i) = delay;
        snd_markers(i)=t_re;
      end
    end
    delays(isnan(delays)) = [];
    %if isempty(delays)
    %    warning('ID:out_of_range', 'Too strict max delay was set, no results would be generated.');
    %end
    snd_markers(isnan(snd_markers)) = [];
    % Discard any sound event not related to a trigger
    if ~isempty(snd_fe)
      snd_fe = snd_fe(dsearchn(snd_re,snd_markers));
    end
    if ~isempty(snd_re)
      snd_re = snd_re(dsearchn(snd_re,snd_markers));
    end
    %% Display some diagnostics
    fprintf(['%4d sound events associated with a marker found\n', ...
      'Mean Delay : %5.1f ms\nStd dev    : %5.1f ms\n'],...
      length(snd_markers),mean(delays)*1000,std(delays)*1000);

    outinfos.delays = delays;
    outinfos.snd_markers = snd_markers;
  end
  if length(snd_re)>=options.expectedSoundCount
    searchForMoreSounds = false;
  elseif options.threshold < .05
    searchForMoreSounds = false;
    warning('ID:max_iteration','Not enough sounds could be detected to match expectedSoundCount option, result is incomplete');sts=2;
  else
    options.threshold = options.threshold - 0.01;
    warning('ID:bad_data',sprintf('Only %d sounds detected but %d expected. threshold lowered to %3.2f',...
      length(snd_re),options.expectedSoundCount,options.threshold));sts=2;
  end
end

%% Save as new channel
if ~strcmpi(options.channel_action, 'none')
  % Save the new channel
  if strcmpi(options.channel_output, 'all')
    snd_events.data = snd_re_all;
    vals = snd_fe_all-snd_re_all;
    snd_events.markerinfo.value = vals;
    vals_cell =num2cell(vals);
    snd_events.markerinfo.name = cellfun(@(x) num2str(x),vals_cell,'UniformOutput',0);
  else
    snd_events.data = snd_re;
    vals =snd_fe-snd_re;
    snd_events.markerinfo.value = vals;
    vals_cell =num2cell(vals);
    snd_events.markerinfo.name = cellfun(@(x) num2str(x),vals_cell,'UniformOutput',0);
  end

  % marker channels have sr = 1 (because marker events are specified in
  % seconds)
  snd_events.header.sr = 1;
  snd_events.header.chantype = 'marker';
  snd_events.header.units ='events';
  [~, ininfos] = pspm_write_channel(file, snd_events, options.channel_action);
  outinfos.channel = ininfos.channel;
end

%% Plot Option
if options.plot
  % Histogramm
  fh = findobj('Tag','delays_hist');
  if isempty(fh)
    fh=figure('Tag','delays_hist');
  else
    figure(fh)
  end
  % use version dependent histogram function
  if verLessThan('matlab', '8.4')
    hist(delays*1000,10)
  else
    histogram(delays*1000, 10)
  end
  title('Trigger to sound delays')
  xlabel('t [ms]')
  if options.resample
    % downsample for plot
    t = t(1:options.resample:end);
    snd_pres = snd_pres(1:options.resample:end);
  end
  % Time series
  fh = findobj('Tag','delays_time_series');
  if isempty(fh)
    fh=figure('Tag','delays_time_series');
  else
    figure(fh)
  end

  plot(t,snd_pres)
  hold on
  scatter(mkr.data,ones(size(mkr.data))*.1,'k')
  for i = 1:length(delays)
    scatter(snd_re(i),.2,500,[(delays(i)-min(delays))/range(delays),1-(delays(i)-min(delays))/range(delays),0],'.')
  end
  xlabel('t [s]')
  legend('Detected sound','Trigger','Sound onset')
  hold off
end

%% Return values
sts =1;
infos = outinfos;
return
