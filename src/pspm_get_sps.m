function [sts, data] = pspm_get_sps(import, eye)
% pspm_get_sps is a comon function for importing eyelink data (distances
% between following data points)
%
% FORMAT:
%   [sts, data]=pspm_get_sps(import)
%   with import.data: column vector of waveform data
%        import.sr: sample rate
%

global settings;
if isempty(settings), pspm_init; end;



% initialise status
sts = -1;

chantype_suffix = '';
if nargin == 2;

  if (ischar(eye) && (strcmp(eye, 'l') || strcmp(eye, 'r')));
    chantype_suffix = strcat('_', eye);
  else;
    warning('ID:invalid_input', 'eye parameter must be "r" or "l"');
    return;
  end;
end;

% assign respiratory data
data.data = import.data(:);

% add header
data.header.chantype = strcat('sps', chantype_suffix);
data.header.units = import.units;
data.header.sr = import.sr;
data.header.range = import.range;

% check status
sts = 1;

end

