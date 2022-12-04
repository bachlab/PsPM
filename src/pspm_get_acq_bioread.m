function [sts, import, sourceinfo] = pspm_get_acq_bioread(datafile, import)
% ● Description
%   pspm_get_acq_bioread is the main function for import of converted
%   BIOPAC/AcqKnowledge files (any version). It requires the files to be
%   converted to .mat files using the bioread[1] tool acq2mat.exe.
%   This function is based on sample files, not on proper documentation of the
%   file format. Always check your imported data before using it.
% ● Format
%   [sts, import, sourceinfo] = pspm_get_acq_bioread(datafile, import);
% ● Arguments
%   datafile: the path of the BIOPAC/AcqKnowledge file to be imported
%     import:
%        .sr:
%      .data:
%     .units:
%    .marker:
% ● Reference
%   [1] https://github.com/njvack/bioread
% ● History
%   Introduced in PsPM 3.1
%   Written in 2016 by Tobias Moser (University of Zurich)
%   Maintained in 2022 by Teddy Chao (UCL)

%% Initialise
global settings
if isempty(settings)
  pspm_init;
end
sts = -1;
sourceinfo = [];
%% load data
inputdata = load(datafile);
%% extract individual channels
for k = 1:numel(import)
  channel_labels = transpose(cellfun(@(x) x.name, inputdata.channels, 'UniformOutput', 0));
  % define channel number ---
  if import{k}.channel > 0
    channel = import{k}.channel;
  else
    channel = pspm_find_channel(channel_labels, import{k}.type);
    if channel < 1, return; end;
  end;
  if channel > size(channel_labels, 1)
    warning('ID:channel_not_contained_in_file', ...
    'Channel %02.0f not contained in file %s.\n', channel, datafile);
    return
  end
  sourceinfo.channel{k, 1} = sprintf('Channel %02.0f: %s', channel, channel_labels{channel});
  % define sample rate ---

  import{k}.sr = inputdata.channels{channel}.samples_per_second;
  % get data & data units
  import{k}.data = double(inputdata.channels{channel}.data);
  import{k}.units = inputdata.channels{channel}.units;
  if strcmpi(settings.channeltypes(import{k}.typeno).data, 'events')
    import{k}.marker = 'continuous';
  end;
end;
sts = 1;
return
