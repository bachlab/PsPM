function sts = pspm_combine_markerchannels(datafile, options)
% ● Description
%   pspm_combine_markerchannels combines several marker channels into one.
%   Index of original marker channel is converted into marker name and marker 
%   value of the new channel. 
%   This allows for example creating GLM timing definitions based on
%   markers distributed across multiple channels.
% ● Format
%   sts = pspm_combine_markerchannels(datafile, options)
% ● Arguments
%    datafile:          data file name(s) (char, or cell array for multiple
%                       files)
%   ┌─────────options:
%   ├.channel_action:
%   │             Accepted values: 'add'/'replace'
%   │             Defines whether the new channel should be added on top of
%   │             existing marker channels ('add), or all existing marker
%   │             channels should be deleted and replaced with the one
%   │             new channel ('replace')
%   └.marker_chan_num:  any number of marker channel numbers - if undefined
%                       or 0, all marker channels of each file are used
% ● History
%   Introduced In PsPM 6.2
%   Written in 2023 by Dominik R Bach (Uni Bonn)

%% Initialise
global settings
if isempty(settings)
  pspm_init;
end
sts = -1;

% check faulty input --
if nargin < 1; errmsg = 'Nothing to do.'; warning('ID:invalid_input', errmsg); return
elseif nargin < 2; options = struct(); end

if ischar(datafile)
  datafile = {datafile};
elseif ~iscell(datafile)
  warning('ID:invalid_input', 'Data file name must be string or cell array'); return;
end

options = pspm_options(options, 'combine_markerchannels');
if options.invalid
  return
end

for iFile = 1:numel(datafile)
    % combine all markers
    [sts, infos, data, filestruct] = pspm_load_data(datafile{iFile}, options.marker_chan_num);
    if sts < 1, return; end
    for iChannel = 1:numel(data)
        if ~strcmpi(data{iChannel}.header.chantype, 'marker')
            warning('ID:invalid_input', sprintf('Channel %1.0f is not of type marker', ...
                filestruct.posofchannels(iChannel))); return; 
        end
    end
    newdata{1}.data = sort(reshape(cell2mat(cellfun(@(x) x.data(:), data, ...
        'UniformOutput', false)), [], 1));
    newdata{1}.header = data{1}.header;
    newdata{1}.markerinfo.value = reshape(cumsum(cell2mat(cellfun(@(x) ones(length(x.data), 1), ...
        data, 'UniformOutput', false)), 2), [], 1);
    newdata{1}.markerinfo.name = num2str(newdata{1}.markerinfo.value);
    % decide which channels to drop
    if strcmpi(options.channel_action, 'replace')
        dropchannels = filestruct.posofchannels;
    else
        dropchannels = [];
    end
    % load entire file, add new channel, drop channels and save
     [sts, infos, data] = pspm_load_data(datafile{iFile});
     data(dropchannels) = [];
     data(end + 1) = newdata;
     sts = pspm_load_data(datafile{iFile}, struct('data', {data}, ...
         'infos', infos, 'options', struct('overwrite', 1)));
  
     if sts < 1, return; end
end



