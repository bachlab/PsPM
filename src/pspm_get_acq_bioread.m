function [sts, import, sourceinfo] = pspm_get_acq_bioread(datafile, import)
% pspm_get_acq_bioread is the main function for import of converted
% biopac/acknowledge files (any version). It requires the files to be
% converted to .mat files using the bioread[1] tool acq2mat.exe.
%
% FORMAT: [sts, import, sourceinfo] = pspm_get_acq_bioread(datafile, import);
%
% This function is based on sample files, not on proper documentation of the
% file format. Always check your imported data before using it.
%
% [1] https://github.com/njvack/bioread
%__________________________________________________________________________
% PsPM 3.1
% (C) 2016 Tobias Moser (University of Zurich)

%% Initialise
global settings
if isempty(settings)
  pspm_init;
end
sts = -1;
sourceinfo = [];

% load data
% -------------------------------------------------------------------------
inputdata = load(datafile);
if isfield(inputdata, 'channels') && ~isfield(inputdata, 'chans')
  inputdata.chans = inputdata.channels;
  inputdata = rmfield(inputdata, 'channels');
end

% extract individual channels
% -------------------------------------------------------------------------
for k = 1:numel(import)
  channel_labels = cellfun(@(x) x.name, inputdata.chans, 'UniformOutput', 0)';
  % define channel number ---
  if import{k}.chan > 0
    chan = import{k}.chan;
  else
    chan = pspm_find_channel(channel_labels, import{k}.type);
    if chan < 1, return; end;
  end;

  if chan > size(channel_labels, 1), warning('ID:channel_not_contained_in_file', 'Channel %02.0f not contained in file %s.\n', chan, datafile); return; end;

  sourceinfo.chan{k, 1} = sprintf('Channel %02.0f: %s', chan, channel_labels{chan});

  % define sample rate ---
  import{k}.sr = inputdata.chans{chan}.samples_per_second;

  % get data & data units
  import{k}.data = double(inputdata.chans{chan}.data);
  import{k}.units = inputdata.chans{chan}.units;

  if strcmpi(settings.chantypes(import{k}.typeno).data, 'events')
    import{k}.marker = 'continuous';
  end;
end;

sts = 1;
return