function [sts, import, sourceinfo] = pspm_get_obs(datafile, import)
% pspm_get_obs is the main function for import of text-exported Noldus
% Observer XT compatible files. At the current state the function is only
% assured to work with the output files of Vsrrp98.
%
% FORMAT: [sts, import, sourceinfo] = pspm_get_obs(datafile, import);
%__________________________________________________________________________
% PsPM 3.0
% (C) 2013-2015 Linus R¸ttimann (University of Zurich)

%% Initialise
global settings
if isempty(settings)
  pspm_init;
end
sts = -1;
sourceinfo = [];

% get external file
% -------------------------------------------------------------------------
% read sample rate ---
fid = fopen(datafile);
obs.sr = textscan(fid, '%s%s%f', 1);
if ~strcmp(obs.sr{1}{1}, 'Sample') || ~strcmp(obs.sr{2}{1}, 'Rate:') || numel(obs.sr{3}) == 0 || isnan(obs.sr{3})
  warning('Wrong data format'); return
end
obs.sr = obs.sr{3};
fclose(fid);

% read channel names ---
fid = fopen(datafile);
fgetl(fid); %ignore first line
channel_names = textscan(fgetl(fid), '%s', 'Delimiter', '\t'); %read second line
fclose(fid);

if numel(channel_names{1}) == 0 || strcmp(channel_names{1}{1}, 'Time (s)') == 0
  warning('Wrong data format'); return
elseif numel(channel_names{1}) == 1
  warning('No channels were found in the datafile.'); return
end
obs.channel_names = channel_names{1};

% read data ---
formatSpec = '';
for i=1:numel(obs.channel_names)
  formatSpec = [formatSpec '%f'];
end
fid = fopen(datafile);
obs.data = textscan(fid, formatSpec, 'HeaderLines', 2);
fclose(fid);

% check sample rate
fid = fopen(datafile);
str = textscan(fid, '%s', 1, 'HeaderLines', 2);
fclose(fid);
str = str{1}{1};
pos = strfind(str, '.'); %position of the the decimal point

if isempty(pos)
  threshold = obs.sr;
elseif numel(pos) > 1
  warning('Wrong data format.'); return
else
  threshold = obs.sr * 10^-(length(str) - pos); %length(str) - pos = no. of decimal places
end

% diff(timestamps) < sr^-1 + abs(error)
% --> abs(1-diff(timestamps)) < threshold, with threshold = sr * abs(error)
if any(abs(1-obs.sr*diff(obs.data{1}))>threshold)
  warning('Samplerate and time stamps do not match.'); return;
end

% extract individual jobs
% -------------------------------------------------------------------------
for k = 1:numel(import)
  if import{k}.channel > 0
    chan = import{k}.channel;
  elseif strcmpi(import{k}.type, 'marker')
    chan = pspm_find_channel(obs.channel_names, {'sync'});
    if chan < 1, warning('Marker channel for import job %02.0f could not be identified (it''s name needs to be SYNC). Please specify as field .channel', k);  return; end;
  else
    chan = pspm_find_channel(obs.channel_names, import{k}.type);
    if chan < 1, return; end;
  end;

  if chan > numel(obs.data), warning('ID:channel_not_contained_in_file', 'Channel %02.0f not contained in file %s.\n', chan, datafile); return; end;

  sourceinfo.chan{k, 1} = sprintf('Channel %02.0f: %s', chan, obs.channel_names{chan});

  import{k}.sr = obs.sr;
  if strcmpi(import{k}.type, 'marker')
    import{k}.marker = 'continuous';
  end;
  import{k}.data = obs.data{chan};

end;

sts = 1;
return;

