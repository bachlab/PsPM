function [sts, import, sourceinfo] = pspm_get_eyelink(datafile, import)
% pspm_get_eyelink is the main function for import of SR Research Eyelink 1000
% files. 
%
% FORMAT: [sts, import, sourceinfo] = pspm_get_eyelink(datafile, import);
%__________________________________________________________________________
% PsPM 3.0
% (C) 2008-2015 Tobias Moser (University of Zurich)

% $Id$
% $Rev$

% initialise
% -------------------------------------------------------------------------
global settings;
if isempty(settings), pspm_init; end;
sourceinfo = []; sts = -1;
% add specific import path for specific import function
addpath([settings.path, 'Import', filesep, 'eyelink']);

% load data with specific function
% -------------------------------------------------------------------------
data = import_eyelink(datafile);

% iterate through data and fill up channel list as long as there is no
% marker channel. if there is any marker channel, the settings accordingly
% markerinfos, markers and marker type.
% -------------------------------------------------------------------------

% ensure sessions have the same samplerate
sr = cell2mat(cellfun(@(d) d.sampleRate, data, 'UniformOutput', false));
eyesObs = cellfun(@(d) d.eyesObserved, data, 'UniformOutput', false);
if numel(data) > 1 && (any(diff(sr)) || any(~strcmp(eyesObs,eyesObs{1})))
    warning('ID:invalid_data_structure', ['Cannot concatenate multiple sessions with different ', ... 
        'sample rate or different eye observation.']);
    % channels
    channels = data{1}.channels;
    % samplerate
    sampleRate = data{1}.sampleRate;
    % markers
    markers = data{1}.markers;
    % markerinfos
    markerinfos = data{1}.markerinfos;
    % units
    units = data{1}.units;
else
    % try to concatenate sessions
    
    % channels
    channels = cellfun(@(d) d.channels, data, 'UniformOutput', false);
    channels = vertcat(channels{:});
    % markers
    markers = cellfun(@(d) d.markers, data, 'UniformOutput', false);
    markers = vertcat(markers{:});
    % markerinfos
    markerinfos = cellfun(@(d) d.markerinfos, data, 'UniformOutput', false);
    markerinfos = vertcat(markerinfos{:});
    % units (they should be for all channels the same
    units = data{1}.units;
    % samplerate
    sampleRate = data{1}.sampleRate;
end

for k = 1:numel(import)
    if strcmpi(import{k}.type, 'marker')
        import{k}.marker = 'continuous';
        import{k}.sr     = sampleRate;
        import{k}.data   = markers;
        % marker info is read and set (in this instance) but
        % imported data cannot be read at the moment (in later instances)
        import{k}.markerinfo = markerinfos;
        
        % use ascending flank for translation from continuous to events
        import{k}.flank = 'ascending';
    else
        chan = import{k}.channel;
        if chan > size(channels, 2), warning('ID:channel_not_contained_in_file', 'Column %02.0f not contained in file %s.\n', chan, datafile); return; end;
        import{k}.sr = sampleRate;
        import{k}.data = channels(:, chan);
        import{k}.units = units{import{k}.channel};
        sourceinfo.chan{k, 1} = sprintf('Column %02.0f', chan);
    end
end

% extract record time and date / should be in all sessions the same
sourceinfo.date = data{1}.record_date;
sourceinfo.time = data{1}.record_time;
% other record settings
sourceinfo.gaze_coords = data{1}.gaze_coords;
sourceinfo.elcl_proc = data{1}.elcl_proc;
sourceinfo.eyesObserved = data{1}.eyesObserved;

% remove specific import path
rmpath([settings.path, 'Import', filesep, 'eyelink']);

sts = 1;
return;

