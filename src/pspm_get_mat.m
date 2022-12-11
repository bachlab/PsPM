function [sts, import, sourceinfo] = pspm_get_mat(datafile, import)
% ● Description
%   pspm_get_mat is the main function for import of matlab files
% ● Format
%   [sts, import, sourceinfo] = pspm_get_mat(datafile, import);
% ● Arguments
%   datafile: a .mat file that contains a variable 'data' that is either
%             [1] a cell array of channel data vectors
%             [2] a datapoints x channel matrix
% ● History
%   Introduced in PsPM 3.0
%   Written in 2008-2015 by Dominik R Bach (Wellcome Trust Centre for Neuroimaging)

%% Initialise
global settings
if isempty(settings)
  pspm_init;
end
sts = -1;
sourceinfo = [];

% load data and check contents
% -------------------------------------------------------------------------
data = load (datafile);
if ~isfield(data, 'data')
  warning('ID:invalid_data_structure', 'No variable ''data'' in file %s.\n', datafile); data = []; return
elseif isnumeric(data.data)
  for k = 1:size(data.data, 2)
    foo{k} = data.data(:, k);
  end;
  data = foo;
  channeltype = 'column';
elseif iscell(data.data)
  for k = 1:numel(data.data)
    if ~(isnumeric(data.data{k}) && isvector(data.data{k}))
      warning('ID:invalid_data_structure', 'All ellements of the cellarray ''data'' in file %s must be numeric vectors.\n', datafile); return;
    end
  end
  data = data.data;
  channeltype = 'cell';
else
  warning('ID:invalid_data_structure', 'Variable ''data'' in file %s must be a cell or numeric.\n', datafile); return;
end;

% select desired channels
% -------------------------------------------------------------------------
for k = 1:numel(import)
  channel = import{k}.channel;

  if channel > numel(data), warning('ID:channel_not_contained_in_file', 'Channel %02.0f not contained in file %s.\n', channel, datafile); return; end;

  import{k}.data = data{channel};
  if strcmpi(settings.channeltypes(import{k}.typeno).data, 'events') && ~isfield(import{k}, 'marker')
    if strcmpi(channeltype, 'cell') && import{k}.sr <= settings.import.mat.sr_threshold
      import{k}.marker = 'timestamps';
    else
      import{k}.marker = 'continuous';
    end
  end
  sourceinfo.channel{k} = sprintf('Data %s %02.0', channeltype, channel);
end;

sts = 1;
end
