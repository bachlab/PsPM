function [sts] = pspm_remove_epochs(datafile, channel, epochfile, options)
% ● Description
%   pspm_remove_epochs sets epochs of data to NaN
% ● Format
%   [sts] = pspm_remove_epochs(datafile, channel, epochfile, options)
% ● Arguments
%    datafile:  a filename or a cell of filenames
%     channel:  defines which channels should be affected by epoch removal. This
%               argument is passed to pspm_load_data(). Therefore, valid values
%               are defined therein.
%   epochfile:  a filename which defines the epoch to be set to NaN. The epochs
%               must be in seconds. This parameter is passed to pspm_get_timing().
%   timeunits:  timeunit of the epochfile.
%   ┌─options:  [struct]
%   └.channel_action:
%               ['add'/'replace'] Defines whether the new channels should be
%               added or the corresponding channel should be replaced.
%               (Default: 'add')
% ● History
%   Introduced in PsPM 4.0
%   Written in 2016 by Tobias Moser (University of Zurich)

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
options = pspm_options(options, 'remove_epochs');
if options.invalid
  return
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
  channeltype = chan.header.channeltype;
  for i_ep = 1:n_ep
    epoch = ep(i_ep, :);
    if strcmpi(settings.channeltypes(strcmpi({settings.channeltypes.type}, ...
        channeltype)).data, 'events')
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
if ~lsts
  warning('ID:invalid_input', 'Could not write channel to file.');
  return;
end
sts = 1;
end
