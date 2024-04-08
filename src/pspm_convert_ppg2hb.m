function [ sts, outinfo ] = pspm_convert_ppg2hb( fn , options )
% ● Description
%   pspm_convert_ppg2hb Converts a pulse oxymeter channel to heartbeats and
%   adds it as a new channel.
%   First a template is generated from non ambiguous heartbeats. The ppu
%   signal is then cross correlated with the template and maximas are
%   identified as heartbeat maximas and a heartbeat channel is then
%   generated from these.
% ● Format
%   [ sts, outinfo ] = pspm_convert_ppg2hb( fn, options )
% ● Arguments
%                 fn: file name with path
%            channel: ppg channel number, default: last ppg channel
%   ┌────────options: struct with following possible fields
%   ├────────.method: 'classic' (default) or 'heartpy'.
%   ├───────.channel: [optional, numeric/string, default: 'ppg', i.e. last 
%   │                 PPG channel in the file]
%   │                 Channel type or channel ID to be preprocessed.
%   │                 Channel can be specified by its index (numeric) in the 
%   │                 file, or by channel type (string).
%   │                 If there are multiple channels with this type, only
%   │                 the last one will be processed. If you want to
%   │                 process several PPG channels in a PsPM file,
%   │                 call this function multiple times with the index of
%   │                 each channel.  In this case, set the option 
%   │                 'channel_action' to 'add',  to store each
%   │                 resulting 'hb' channel separately.
%   ├───.diagnostics: [true/FALSE]
%   │                 displays some debugging information
%   ├.channel_action: ['add'/'replace', 'replace']
%   │                 Defines whether the interpolated
%   │                 data should be added or the corresponding channel
%   │                 should be replaced.
%   ├───────.missing: allows to specify missing (e. g. artefact) epochs in the
%   │                 data file. See pspm_get_timing for epoch definition. This
%   │                 must always be specified in SECONDS. These epochs will be
%   │                 set to 0 for the detection.
%   │                 Default: no missing values
%   ├───────────.lsm: [integer] for method 'classic'
%   │                 large spikes mode compensates for large spikes
%   │                 while generating template by removing the [integer]
%   │                 largest percentile of spikes from consideration.
%   └───.python_path: [char] for method 'heartpy'
%                     The path where python can be found. Mandatory if
%                     python environment is not yet set up
% ● History
%   Introduced in PsPM 3.1
%   Written in 2016 by Samuel Gerster (University of Zurich)
%                      Tobias Moser (University of Zurich)
%   Updated in 2024 by Dominik Bach/Uzay Gokay (Uni Bonn)

%% Initialise
global settings
if isempty(settings)
  pspm_init;
end
sts = -1;
outinfo = struct();

%% check input
% -------------------------------------------------------------------------
if nargin < 1
  warning('ID:invalid_input', 'No input. Don''t know what to do.'); return;
elseif nargin < 2 
    options = struct();
end
options = pspm_options(options, 'convert_ppg2hb');
if options.invalid
  return
end

%% user output
% -------------------------------------------------------------------------
fprintf('Heartbeat detection for %s ... \n', fn);

% get data
% -------------------------------------------------------------------------
[nsts, data] = pspm_load_channel(fn, options.channel, 'ppg');
if nsts == -1, return; end

%% Large spikes mode
%--------------------------------------------------------------------------
ppg = data.data;
% large spike mode
if options.lsm
  fprintf('Entering large spikes mode. This might take some time.');
  % Look for all peaks lower than 200 bpm (multiple of two in heart rate
  %  to compensate for absolute value and therefore twice as mani maxima)
  [pks,pis] = findpeaks(abs(ppg),...
    'MinPeakDistance',30/200*data.header.sr);
  % Ensure at least one spike is removed by adapting quantil to realistic
  % values, given number of detected spikes
  q = floor(length(pks)*(1-options.lsm/100))/length(pks);
  % define large spikes index as last lsm percentile (or as adapted above)
  lsi = pks>quantile(pks,q);
  %define a minimum peak prominence 2/3 of non large spikes range (more
  %or less)
  minProm = max(pks(~lsi))*2/3;
  % save indexes of large spikes for later removal while generating
  % template
  lsi = pis(lsi);
  fprintf('   done.\n');
else
  minProm = range(ppg)/3;
end

%% Create template
%--------------------------------------------------------------------------
fprintf('Creating template. This might take some time.');
% Find prominent peaks for a max heart rate of 200 bpm
[~,pis] = findpeaks(data.data,...
  'MinPeakDistance',60/200*data.header.sr,...
  'MinPeakProminence',minProm);

if options.lsm
  % Remove large spikes from
  [~,lsi_in_pis,~] = intersect(pis,lsi);
  pis(lsi_in_pis) = [];
end

% handle possible errors
if isempty(pis),warning('ID:NoPulse', 'No pulse found, nothing done.');return;end
if length(pis)==1,warning('ID:OnePulse', 'Only one pulse found, unable to calculate min_pulse_period.');return;end

% get pulse period lower limit (assumed onset) as 30% of smalest period
% before detected peaks
min_pulse_period = min(diff(pis));
period_index_lower_bound = floor(pis(2:end-1)-.3*min_pulse_period);
fprintf('...');

% Create template from mean of peak time-locked ppg pulse periods
pulses = cell2mat(arrayfun(@(x) data.data(x:x+min_pulse_period),period_index_lower_bound','un',0));
template = mean(pulses,2);
fprintf('done.\n');

% handle diagnostic plots relevant to template building
if options.diagnostics
  t_template = (0:length(template)-1)'/data.header.sr;
  t_pulses = repmat(t_template,1,length(pis)-2);
  figure
  plot(t_pulses,pulses,'--')
  set(gca,'NextPlot','add')
  plot(t_template,template,'k','lineWidth',3)
  xlabel('time [s]')
  ylabel('Amplitude')
  title('Generated ppg template (bk) and pulses used (colored)')
end

%% Cross correlate the signal with the template and find peaks
%--------------------------------------------------------------------------
fprintf('Applying template.');
ppg_corr = xcorr(data.data,template)/sum(template);
% Truncate ppg_xcorr and realigne it so the max correlation corresponds to
% templates peak and not beginning of template.
ppg_corr = ppg_corr(length(data.data)-floor(.3*min_pulse_period):end-floor(.3*min_pulse_period));
if options.diagnostics
  t_ppg = (0:length(data.data)-1)'/data.header.sr;
  figure
  if length(t_ppg) ~= length(ppg_corr)
    length(t_ppg)
  end
  plot(t_ppg,ppg_corr,t_ppg,data.data)
  xlabel('time [s]')
  ylabel('Amplitude')
  title('ppg cross-corelated with template and ppg')
  legend('ppg (X) template','ppg')
end
% Get peaks that are at least one template width appart. These are the best
% correlation points.
[~,hb] = findpeaks(ppg_corr/max(ppg_corr),...
  data.header.sr,...
  'MinPeakdistance',min_pulse_period/data.header.sr);
fprintf('   done.\n');

%% Prepare output and save
%--------------------------------------------------------------------------
% save data
fprintf('Saving data.');
msg = sprintf('Heart beat detection from ppg with cross correlation HB-timeseries added to data on %s', date);

newdata.data = hb(:);
newdata.header.sr = 1;
newdata.header.units = 'events';
newdata.header.chantype = 'hb';

write_options = struct();
write_options.msg = msg;

% Replace last existing channel or save as new channel
[nsts, nout] = pspm_write_channel(fn, newdata, options.channel_action, write_options);
if ~nsts
  return
end
% user output
fprintf('  done.\n');
sts = 1;
outinfo.channel = nout.channel;
return
