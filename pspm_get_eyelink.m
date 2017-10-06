function [sts, import, sourceinfo] = pspm_get_eyelink(datafile, import)
% pspm_get_eyelink is the main function for import of SR Research Eyelink 1000
% files. 
%
% FORMAT: [sts, import, sourceinfo] = pspm_get_eyelink(datafile, import);
%          import: import job structure with 
%                   - mandatory fields:
%                       .sr
%                       .data
%                   - optional fields:
%                       .eyelink_trackdist: 
%                           the distance between camera and 
%                           recorded eye in mm. Disabled if 'none'. If
%                           is a numeric value, causes the conversion
%                           from arbitrary units to mm according to the
%                           set distance.
%
%__________________________________________________________________________
% PsPM 3.0
% (C) 2008-2015 Tobias Moser (University of Zurich)

% $Id$
% $Rev$

% initialise
% -------------------------------------------------------------------------
global settings;
if isempty(settings), pspm_init; end
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
    % try to concatenate sessions according to timing
    sr = data{1}.sampleRate;
    last_time = data{1}.raw(1,1);
    
    channels = [];
    markers = [];
    
    mi_value = [];
    mi_name = {};
    
    n_cols = size(data{1}.channels, 2);
    counter = 1;
    
    for c = 1:numel(data)
        if sr ~= data{c}.sampleRate
            warning('ID:invalid_input', ['File consists of multiple ', ...
                'sessions with different sample rates: Unable to concatenate sessions.']);
            return;
        end
        
        start_time = data{c}.raw(1,1);
        end_time = data{c}.raw(end,1);
            
        n_diff = start_time - last_time;
        if n_diff > 0
            % channels and markers
            channels(counter:(counter+n_diff-1),1:n_cols) = NaN(n_diff, n_cols);
            markers(counter:(counter+n_diff-1), 1) = NaN(n_diff, 1);
            
            % markerinfos
            mi_value(counter:(counter+n_diff-1),1) = NaN(n_diff, 1);
            mi_name(counter:(counter+n_diff-1), 1) = {NaN};
            
            counter = counter + n_diff;
        end
        
        n_data = size(data{c}.channels, 1);
        
        % channels and markers
        channels(counter:(counter+n_data-1),1:n_cols) = data{c}.channels;
        markers(counter:(counter+n_data-1),1) = data{c}.markers;
        
        % markerinfos
        mi_value(counter:(counter+n_data-1),1) = data{c}.markerinfos.value;
        mi_name(counter:(counter+n_data-1),1) = data{c}.markerinfos.name;
        
        counter = counter + n_data;
        last_time = end_time;
    end
    
    markerinfos.name = mi_name;
    markerinfos.value = mi_value;
    
    % units (they should be for all channels the same)
    units = data{1}.units;
    
    % samplerate
    sampleRate = sr;
end

% create invalid data stats
n_data = size(channels,1);

% count blink and saccades (combined in blink channel at the moment)
n_bns = sum(channels(:,strcmpi(units, 'blink')) == 1);

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
        if ~isempty(regexpi(import{k}.type, '_[lr]', 'once')) && ...
                isempty(regexpi(import{k}.type, ['_([' data{1}.eyesObserved '])'], 'once'))
            warning('ID:channel_not_contained_in_file', ...
                ['Cannot import channel type %s, as data for this eye', ...
                ' does not seem to be present in the datafile. ', ...
                'Will create artificial channel with NaN values.'], import{k}.type);
            
            % create NaN values for this channel
            import{k}.data = NaN(size(channels, 1),1);
            chan = -1;
            import{k}.units = '';
        else
            if chan > size(channels, 2)
                warning('ID:channel_not_contained_in_file', ...
                    'Column %02.0f (%s) not contained in file %s.\n', ...
                    chan, import{k}.type, datafile);
                return;
            end
            import{k}.data = channels(:, chan);
            import{k}.units = units{chan};
        end
        
        
        import{k}.sr = sampleRate;
        sourceinfo.chan{k, 1} = sprintf('Column %02.0f', chan);
        
        % chan specific stats
        sourceinfo.chan_stats{k,1} = struct();
        n_inv = sum(isnan(import{k}.data));
        sourceinfo.chan_stats{k}.nan_ratio = n_inv/n_data;

        % check for transfer if import type is a pupil
        if ~isempty(regexpi(import{k}.type, 'pupil')) && ...
            isfield(import{k}, 'eyelink_trackdist') && ...
            ~strcmpi(import{k}.eyelink_trackdist, 'none')

                % transfer pupil data according to transfer settings
                [~, import{k}.data] = pspm_convert_au2mm(import{k}.data, ...
                    import{k}.eyelink_trackdist, import{k}.units);

                % set new unit to mm
                import{k}.units = 'mm';
        end
        
        % create statistics for eye specific channels
        if ~isempty(regexpi(import{k}.type, '_[lr]', 'once'))
            if size(n_bns, 2) > 1
                eye_t = regexp(import{k}.type, '.*_([lr])', 'tokens');
                n_eye_bns = n_bns(strcmpi(eye_t{1}, {'l','r'}));
            else
                n_eye_bns = n_bns;
            end
            
            sourceinfo.chan_stats{k}.blink_ratio = n_eye_bns / n_data;
            sourceinfo.chan_stats{k}.other_ratio = (n_inv - n_eye_bns) / n_data;
        end 
    end
end

% extract record time and date / should be in all sessions the same
sourceinfo.date = data{1}.record_date;
sourceinfo.time = data{1}.record_time;
% other record settings
sourceinfo.gaze_coords = data{1}.gaze_coords;
sourceinfo.elcl_proc = data{1}.elcl_proc;
sourceinfo.eyesObserved = lower(data{1}.eyesObserved);

% determine best eye
eye_stat = Inf(1,numel(sourceinfo.eyesObserved));
for i = 1:numel(sourceinfo.eyesObserved)
    e = lower(sourceinfo.eyesObserved(i));
    e_stat = vertcat(sourceinfo.chan_stats{...
        cellfun(@(x) ~isempty(regexpi(x.type, ['_' e], 'once')), import)});
    if ~isempty(e_stat)
        eye_stat(i) = max([e_stat.nan_ratio]);
    end
end

[~, min_idx] = min(eye_stat);
sourceinfo.best_eye = lower(sourceinfo.eyesObserved(min_idx));

% remove specific import path
rmpath([settings.path, 'Import', filesep, 'eyelink']);

sts = 1;
return;

