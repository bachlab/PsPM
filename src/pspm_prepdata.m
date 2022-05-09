function [sts, outdata, newsr] = pspm_prepdata(data, filt)
% pspm_prepdata is a shared PsPM function for twofold butterworth filting and
% downsampling raw data "on the fly". This data is usually stored in
% results files rather than data files.
%
% FORMAT [sts, data, newsr] = pspm_prepdata(data, filt)
%
% data is a column vector of data
% filt is a struct with fields:
%       .sr        - current sample rate in Hz
%       .lpfreq    - low pass filt frequency or 'none'
%       .lporder   - low pass filt order
%       .hporder   - high pass filt order
%       .hpfreq    - high pass filt frequency or 'none'
%       .direction - filt direction
%       .down      - sample rate in Hz after downsampling or 'none'
%
% Note that the order for bandpass and bandstop filters is equal to
% order = lporder + hporder
%
% the new sample rate is returned as newsr because downsampling might
% fail for some required sampling rates; a fallback is used then
%
% used by pspm_glm, pspm_sf, pspm_pulse_convert, pspm_dcm, pspm_pp
%
%__________________________________________________________________________
% PsPM 3.0
% (C) 2008-2015 Dominik R Bach (Wellcome Trust Centre for Neuroimaging)
% $Id$
% $Rev$


%% Initialise
global settings
if isempty(settings)
  pspm_init;
end
sts = -1;
newsr = 0;
outdata = data;

% check input for NaN values
% -------------------------------------------------------------------------
if any(isnan(data))
  warning('ID:invalid_input', 'Data contains NaN values.'); return;
end

% check input
% -------------------------------------------------------------------------
if nargin < 2
  warning('ID:invalid_input', 'Nothing to do.'); return;
elseif ~isnumeric(data)
  warning('ID:invalid_input', 'Data must be numeric.'); return;
elseif (~isfield(filt, 'lpfreq') || ~isfield(filt, 'lporder') || ...
    ~isfield(filt, 'hpfreq') || ~isfield(filt, 'hporder') || ...
    ~isfield(filt, 'down')   || ~isfield(filt, 'direction') || ...
    ~isfield(filt, 'sr'))
  warning('ID:invalid_input', 'filt structure has missing fields.'); return;
elseif ((~isnumeric(filt.lpfreq) && (~ischar(filt.lpfreq) || ~strcmpi(filt.lpfreq, 'none'))) || ...
    ~isnumeric(filt.lporder) || ...
    (~isnumeric(filt.hpfreq) && (~ischar(filt.hpfreq) || ~strcmpi(filt.hpfreq, 'none'))) || ...
    ~isnumeric(filt.hporder) || ...
    (~isnumeric(filt.down)   && (~ischar(filt.down  ) || ~strcmpi(filt.down, 'none'))) || ...
    ~ischar(filt.direction)   || ~isnumeric(filt.sr) || ...
    ~any(strcmpi(filt.direction, {'uni', 'bi'})))
  warning('ID:invalid_input', 'filt structure has misspecified fields.');
  return;
end
uni = strcmpi(filt.direction, 'uni');

% prepare data
% -------------------------------------------------------------------------

% determine nyquist frequency --
nyq = filt.sr/2;
% transform data into column --
data = data(:);
% if unidirectional, append data to avoid filter ringing --
if uni
  data = [data(1) * ones(floor(50 * filt.sr), 1); data];
end

lowpass_filt = false;

% lowpass filt
% -------------------------------------------------------------------------
if ~ischar(filt.lpfreq) && ~isnan(filt.lpfreq)
  lowpass_filt = true;
elseif isnumeric(filt.down) && ~isnan(filt.down) && filt.down < filt.sr
  % if lowpass filtering is disabled and downsampling is enabled
  % enable lpfiltering with down/2 in order to avoid creating artifacts
  lowpass_filt = true;
  filt.lpfreq = filt.down/2;
  filt.lporder = 1;
end

if lowpass_filt
  if filt.lpfreq >= nyq
    warning('ID:no_low_pass_filtering', 'The low pass filter cutoff frequency is higher (or equal) than the nyquist frequency. The data won''t be low pass filtered!');
  else
    [lsts, filt.b, filt.a]=pspm_butter(filt.lporder, filt.lpfreq/nyq, 'low');
    if lsts == -1
      warning('ID:invalid_input', 'call of pspm_butter failed');
      return;
    end
    if uni
      data = filter(filt.b, filt.a, data);
      data = filter(filt.b, filt.a, data);
    else
      data = pspm_filtfilt(filt.b, filt.a, data);
    end
  end
end

% highpass filt
% -------------------------------------------------------------------------
if ~ischar(filt.hpfreq) && ~isnan(filt.hpfreq)
  [lsts, filt.b, filt.a]=pspm_butter(filt.hporder, filt.hpfreq/nyq, 'high');
  if lsts == -1
    warning('ID:invalid_input', 'call of pspm_butter failed');
    return;
  end
  if uni
    data = filter(filt.b, filt.a, data);
    data = filter(filt.b, filt.a, data);
  else
    data = pspm_filtfilt(filt.b, filt.a, data);
  end
end

% if uni, remove dummy data
if uni
  data = data((floor(50 * filt.sr) + 1):end);
end

% downsample
% -------------------------------------------------------------------------
if ~ischar(filt.down) && filt.sr > filt.down
  if strcmpi(filt.lpfreq, 'none') || isnan(filt.lpfreq)
    warning('No low pass filter applied - aliasing is possible. Use a low pass filter to prevent.');
  elseif filt.down < 2 * filt.lpfreq
    filt.down = 2 * filt.lpfreq;
    warning('ID:freq_change', 'Sampling rate was changed to %01.2f Hz to prevent aliasing', filt.down)
  end
  freqratio = filt.sr/filt.down;
  if freqratio == ceil(freqratio) % NB isinteger might not work for some values
    % to avoid toolbox use, but only works for integer sr ratios
    [lsts, data] = pspm_downsample(data, freqratio);
    if lsts == -1, errmsg = 'for an unknown reason in pspm_downsample.'; end
    newsr = filt.down;
  elseif settings.signal
    % this filts the data on the way, which does not really matter
    % for us anyway, but allows real sr ratios
    if filt.sr == floor(filt.sr) && filt.down == floor(filt.down)
      data = resample(data, filt.down, filt.sr);
      newsr = filt.down;
    else
      % use a crude but very general way of getting to integer
      % numbers
      altsr = floor(filt.sr);
      altdownsr = floor(filt.down);
      data = resample(data, altdownsr, altsr);
      newsr = filt.sr * altdownsr/altsr;
      warning('ID:nonint_sr', 'Note that the new sampling rate is a non-integer number.');
    end
  else
    lsts = -1; errmsg = 'because signal processing toolbox is not installed and downsampling ratio is non-integer.';
  end
  if lsts == -1
    warning('ID:downsampling_failed', sprintf('\nDownsampling failed %s', errmsg)); return;
  end
else
  newsr = filt.sr;
end

outdata = data;
sts = 1;
return;


