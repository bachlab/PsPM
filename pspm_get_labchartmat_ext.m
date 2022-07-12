function [sts, import, sourceinfo] = pspm_get_labchartmat_ext(datafile, import)
% pspm_get_labchartmat_ext is the main function for import of LabChart
% (ADInstruments) files, exported into matlab using the online LabChart
% extension. See pspm_labchartmat_in for import of matlab files that were
% exported using the built-in export feature available in more recent
% LabChart versions (from version 7.2 onwards)
%
% this function only supports data files containing one data block
%
% FORMAT: [data sourceinfo sts] = pspm_get_labchartmat_ext(datafile, import);
%
%__________________________________________________________________________
% PsPM 3.0
% (C) 2011-2015 Dominik R Bach (Wellcome Trust Centre for Neuroimaging)

% ------------------------------------------------------------------------
% Tue Jun 08, 2010 12:25 am from
% http://www.adinstruments.com/forum/viewtopic.php?f=7&t=35&p=79#p79
% Export MATLAB writes the comment timestamps using the overall "tick rate".
% The tick rate corresponds to the highest sample rate. If all channels are
% at the same sample rate then that's the tick rate. However if you had
% three channels recorded at 1kHz, 2kHz and 500Hz, then the tick rate would
% be 2kHz and the comment positions would be at 2kHz ticks.
% John Enlow, Windows Development Manager, ADInstruments, New Zealand
% -------------------------------------------------------------------------

%% Initialise
global settings
if isempty(settings)
  pspm_init;
end
sts = -1;
sourceinfo = [];

% load & check data
% -------------------------------------------------------------------------
labchart = load(datafile);

% check whether one or multiple blocks ---
if isfield(labchart, 'data_block2')
  warning('LabChart files must contain one block only - concatenate on export if necessary.');
  return;
elseif ~isfield(labchart, 'data_block1')
  warning('This version of the export extension is not supported. Please contact PsPM developers.');
  return;
end;

% retrieve sampling rate(s) ---
for chan = 1:size(labchart.ticktimes_block1, 1)
  samples = ~isnan(labchart.ticktimes_block1(chan, :));
  timestamps = unique(diff(labchart.ticktimes_block1(chan, samples)));
  if any(timestamps > 1.05 * mean(timestamps)) || any(timestamps < 0.95 * mean(timestamps))
    warning('Recording timestamps imprecise (> 5% deviation)'); return;
  else
    sr(chan) = mean(timestamps);
  end;
end;

% loop through import jobs
% -------------------------------------------------------------------------
for k = 1:numel(import)

  if strcmpi(import{k}.type, 'marker')
    import{k}.data   = labchart.comtick_block1;
    import{k}.sr     = min(sr);
    import{k}.marker = 'timestamps';

    sourceinfo.chan{k, 1} = sprintf('Channel %02.0f: %s', k, 'Events');
  else
    % define channel number ---
    if import{k}.channel > 0
      chan = import{k}.channel;
    else
      chan = pspm_find_channel(cellstr(labchart.titles_block1), import{k}.type);
      if chan < 1, return; end;
    end;

    if chan > numel(cellstr(labchart.titles_block1)), warning('ID:channel_not_contained_in_file', 'Channel %02.0f not contained in file %s.\n', chan, datafile); return; end;

    sourceinfo.chan{k, 1} = sprintf('Channel %02.0f: %s', chan, labchart.titles_block1(chan, :));

    % use ticktimes from channel 1 if ticktimes contains only one row
    if size(labchart.ticktimes_block1,1) > 1
      % get time range ---
      samples = ~isnan(labchart.ticktimes_block1(chan, :));
      % get sample rate ---
      import{k}.sr = 1/sr(chan);
    else
      % get time range ---
      samples = ~isnan(labchart.ticktimes_block1(1, :));
      % get sample rate ---
      import{k}.sr = 1/sr;
    end;
    % get data
    import{k}.data = labchart.data_block1(chan, samples);
    % get units ---
    import{k}.units = labchart.units_block1(chan, :);
  end;
end;

sts = 1;
return;