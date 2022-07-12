function [sts] = pspm_remove_epochs(datafile, channel, epochfile, options)
% pspm_remove_epochs sets epochs of data to NaN
%
%
% FORMAT:
%   [sts] = pspm_remove_epochs(datafile, channel, epochfile, options)
%
% ARGUMENTS:
%   datafile:                   a filename or a cell of filenames
%   channel:                    defines which channels should be affected by
%                               epoch removal. this argument is passed to
%                               pspm_load_data(). therefore valid values are
%                               defined therein.
%   epochfile:                  a filename which defines the epoch to be set to
%                               NaN. The epochs must be in seconds.
%                               this parameter is passed to pspm_get_timing().
%   timeunits:                  timeunit of the epochfile.
%   options:
%       .channel_action ['add'/'replace'] Defines whether the new channels
%                       should be added or the corresponding channel
%                       should be replaced.
%                       (Default: 'add')
%
% OUTPUT:
%__________________________________________________________________________
% PsPM 4.0
% (C) 2016 Tobias Moser (University of Zurich)

% $Id: pspm_find_data_epochs.m 410 2017-01-30 11:14:06Z tmoser $
% $Rev: 410 $

%% Initialise
global settings
if isempty(settings)
  pspm_init;
end
sts = -1;

% input checks for options only as these are not directly passed to
% other functions.

if nargin < 3
  warning('ID:invalid_input', 'Not enough input arguments');
  return;
end

if ~exist('options', 'var')
  options = struct();
end

if ~isfield(options, 'channel_action')
  options.channel_action = 'add';
end

[lsts, ~, data] = pspm_load_data(datafile, channel);
if lsts == -1
  warning('ID:invalid_input', 'Could not load data properly.');
  return;
end

[lsts, ep] = pspm_get_timing('epochs', epochfile, 'seconds');
if lsts == -1
  warning('ID:invalid_input', 'Could not load epochs properly.');
  return;
end

n_ep = size(ep, 1);
n_data = numel(data);
for i_data = 1:n_data

  chan = data{i_data};
  sr = chan.header.sr;
  chantype = chan.header.chantype;

  for i_ep = 1:n_ep
    epoch = ep(i_ep, :);

    if strcmpi(settings.chantypes(strcmpi({settings.chantypes.type}, ...
        chantype)).data, 'events')

      % remove markers within the period
      chan.data(chan.data >= epoch(1) & chan.data <= epoch(2)) = [];

    else
      % find start and stop sample and ensure they're not
      % going over the edges
      smp_start = max(1, round(sr*epoch(1)));
      smp_stop = min(numel(chan.data), round(sr*epoch(2)));

      % set period to NaN
      chan.data(smp_start:smp_stop) = NaN;
    end

    % write back to data struct
    data{i_data}.data = chan.data;
  end

end

% save data to file
[lsts] = pspm_write_channel(datafile, data, options.channel_action);

if lsts == -1
  warning('ID:invalid_input', 'Could not write channel to file.');
  return;
end

sts = 1;
