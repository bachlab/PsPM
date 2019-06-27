function [sts, import, sourceinfo] = pspm_get_eyelink(datafile, import)
% pspm_get_eyelink is the main function for import of SR Research Eyelink 1000
% files. 
%
% FORMAT: [sts, import, sourceinfo] = pspm_get_eyelink(datafile, import);
%          import: import job structure with 
%                   - mandatory fields:
%                       .sr
%
%                       .data
%                       except for custom channels, the field .channel will 
%                       be ignored. The id will be determined according to 
%                       the channel type. 
%
%                   - optional fields:
%                       .eyelink_trackdist: 
%                           A numeric value representing the distance between
%                           camera and recorded eye. Disabled if 0 or negative.
%                           If it is a positive numeric value, causes the
%                           conversion from arbitrary units to distance unit
%                           according to the set distance.
%
%                       .distance_unit:
%                           the unit to which the data should be converted and
%                           in which eyelink_trackdist is given
%
%                       .blink_saccade_edge_discard_factor:
%                           Factor used to determine the number of
%                           samples right before and right after a blink/saccade
%                           period to discard. This value is multiplied by the
%                           sampling rate of the recording to determine the
%                           number of samples to discard from one end. Therefore,
%                           for each blink/saccade period, 2*this_value*SR many
%                           samples are discarded in total, and effectively
%                           blink/saccade period is extended.
%
%                           This value also corresponds to the duration of
%                           samples to discard on one end in seconds. For example,
%                           when it is 0.01, we discard 10 ms worth of data on
%                           each end of every blink/saccade period.
%                           (Default: 0.05)
%                           
% 
% In this function, channels related to eyes will not produce an error, if 
% they do not exist. Instead they will produce an empty channel (a channel 
% with NaN values only).
%
%__________________________________________________________________________
% PsPM 3.0
% (C) 2008-2017 Tobias Moser (University of Zurich)

% $Id$
% $Rev$

% initialise
% -------------------------------------------------------------------------
global settings;
if isempty(settings), pspm_init; end
sourceinfo = []; sts = -1;
% add specific import path for specific import function
addpath([settings.path, 'Import', filesep, 'eyelink']);

if ~isfield(options, 'blink_saccade_edge_discard_factor')
    options.blink_saccade_edge_discard_factor = 0.05;
end

if ~isnumeric(options.blink_saccade_edge_discard_factor) || ...
        options.blink_saccade_edge_discard_factor < 0
    warning('ID:invalid_input', 'Edge discard factor must be a positive number');
    return;
end

% transfer options
% -------------------------------------------------------------------------
reference_distance = 700;
reference_unit = 'mm';
diameter_multiplicator = 0.00087743;
area_multiplicator = 0.119;

% load data with specific function
% -------------------------------------------------------------------------
data = import_eyelink(datafile, options.blink_saccade_edge_discard_factor);

% iterate through data and fill up channel list as long as there is no
% marker channel. if there is any marker channel, the settings accordingly
% markerinfos, markers and marker type.
% -------------------------------------------------------------------------

% ensure sessions have the same samplerate
%separate marker_data from real data
all_markers = data{numel(data)};
data = data(1:numel(data)-1);
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

        % time stamps are in miliseconds. if sampling rate different
        % then we have to correct for that otherwise break is too small/large
        n_diff = round((start_time - last_time)*sr/1000);
        if n_diff > 0
            
            % channels and markers
            channels(counter:(counter+n_diff-1),1:n_cols) = NaN(n_diff, n_cols);
            markers(counter:(counter+n_diff-1), 1) = zeros(n_diff,1);
            
            % markerinfos
            mi_value(end + 1 : end + n_diff, 1) = zeros(n_diff,1);
            mi_name( end + 1 : end + n_diff, 1) = {'0'};
            
            % find if there are markers in the breaks
            break_markers_idx = all_markers.times>=last_time & all_markers.times<=start_time;
            tmp_times = all_markers.times(break_markers_idx);
            tmp_vals  = all_markers.vals(break_markers_idx);
            tmp_names = all_markers.names(break_markers_idx);
            
            % calculate, weher to insert missing markers
            tmp_marker_idx = round((tmp_times- last_time)*sr/1000)-1 + counter;
            markers(tmp_marker_idx,1) = 1;
            mi_value(tmp_marker_idx,1) = tmp_vals;
            mi_name(tmp_marker_idx,1) = tmp_names;
            counter = counter + n_diff;
        end
        
        n_data = size(data{c}.channels, 1);
        
        % channels and markers
        channels(counter:(counter+n_data-1),1:n_cols) = data{c}.channels;
        markers(counter:(counter+n_data-1),1) = data{c}.markers;
        
        % markerinfos
        n_markers = numel(data{c}.markerinfos.value);
        mi_value(end + 1 : end + n_markers, 1) = data{c}.markerinfos.value;
        mi_name( end + 1 : end + n_markers, 1) = data{c}.markerinfos.name;
        
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
blink_idx = find(strcmpi(units, 'blink'));
saccade_idx = find(strcmpi(units, 'saccade'));

%assumption that whenever blink_idx has more than one entry saccade will
%... have also more than one entry

bns_chans = [blink_idx saccade_idx];
for i_bns = 1:numel(bns_chans)
    channels(isnan(channels(:, bns_chans(i_bns))), bns_chans(i_bns)) = 0;
end

n_blink = sum (channels(:,blink_idx));
n_saccade= sum (channels(:,saccade_idx));


for k = 1:numel(import)

    if ~any(strcmpi(import{k}.type, ...
            settings.import.datatypes(strcmpi('eyelink', ...
            {settings.import.datatypes.short})).chantypes))
        warning('ID:channel_not_contained_in_file', ...
            'Channel type ''%s'' is not supported.\n', ...
            import{k}.type);
        return;
    end

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
        % determine chan id from chantype - eyelink specific
        % thats why channel ids will be ignored!
        if strcmpi(data{1}.eyesObserved, 'LR') 
            chan_struct = {'pupil_l', 'pupil_r', 'gaze_x_l', 'gaze_y_l', ...
                'gaze_x_r', 'gaze_y_r','blink_l','blink_r','saccade_l','saccade_r'};
        else
            eye_obs = lower(data{1}.eyesObserved);
            chan_struct = {['pupil_' eye_obs], ['gaze_x_' eye_obs], ...
                ['gaze_y_' eye_obs], ['blink_' eye_obs],['saccade_' eye_obs]};
        end

        if strcmpi(import{k}.type, 'custom')
            chan = import{k}.channel;
        else
            chan = find(strcmpi(chan_struct, import{k}.type), 1, 'first');
        end

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
        if ~isempty(regexpi(import{k}.type, 'pupil'))
            if isfield(import{k}, 'eyelink_trackdist') && ...
                    isnumeric(import{k}.eyelink_trackdist) && ...
                    import{k}.eyelink_trackdist > 0 && ...
                    ~isempty(import{k}.units)
                parts = split(import{k}.units);
                record_method = lower(parts{2});
                % transfer pupil data according to transfer settings
                if strcmpi(record_method, 'diameter')
                    [~, import{k}.data] = pspm_convert_au2unit(...
                        import{k}.data, import{k}.distance_unit, ...
                        import{k}.eyelink_trackdist, record_method, ...
                        diameter_multiplicator, ...
                        reference_distance, ...
                        reference_unit);
                elseif strcmpi(record_method, 'area')
                    [~, import{k}.data] = pspm_convert_au2unit(...
                        import{k}.data, import{k}.distance_unit, ...
                        import{k}.eyelink_trackdist, record_method, ...
                        area_multiplicator, ...
                        reference_distance, ...
                        reference_unit);
                else
                    warning('ID:invalid_data_structure', 'Calculated record method must be ''area'' or ''diameter''');
                    return;
                end
                % set new unit to mm
                import{k}.units = import{k}.distance_unit;
            else
                warning('ID:invalid_input', ['Importing pupil in arbitrary units.'...
                    ' You must pass a positive ''eyelink_trackdist'' so that pupil' ...
                    ' in arbitrary units is converted to milimeters or ''distance_unit''']);
            end
        % store data range in header for gaze channels
        elseif ~isempty(regexpi(import{k}.type, 'gaze_x_'))
            import{k}.range = [data{1}.gaze_coords.xmin ...
                data{1}.gaze_coords.xmax];
        elseif ~isempty(regexpi(import{k}.type, 'gaze_y_'))
            import{k}.range = [data{1}.gaze_coords.ymin ...
                data{1}.gaze_coords.ymax];
        end
        
        % create statistics for eye specific channels
        if ~isempty(regexpi(import{k}.type, '_[lr]', 'once'))
            if size(n_blink, 2) > 1
                eye_t = regexp(import{k}.type, '.*_([lr])', 'tokens');
                n_eye_blink = n_blink(strcmpi(eye_t{1}, {'l','r'}));
            else
                n_eye_blink = n_blink;
            end
            sourceinfo.chan_stats{k}.blink_ratio = n_eye_blink / n_data;
            
            if size(n_saccade, 2) > 1
                eye_t = regexp(import{k}.type, '.*_([lr])', 'tokens');
                n_eye_saccade = n_saccade(strcmpi(eye_t{1}, {'l','r'}));
            else
                n_eye_saccade = n_saccade;
            end
            sourceinfo.chan_stats{k}.saccade_ratio = n_eye_saccade / n_data;
        end 
    end
end

% extract record time and date / should be in all sessions the same
sourceinfo.date = data{1}.record_date;
sourceinfo.time = data{1}.record_time;
% other record settings
sourceinfo.gaze_coords = data{1}.gaze_coords;
sourceinfo.elcl_proc = data{1}.elcl_proc;

% only imported eyes should be stated in eyesObserved 
left_occurance = any(cell2mat(cellfun(@(x) ~isempty(regexpi(x.type, '_l', 'once')), import,'UniformOutput',0)));
right_occurance = any(cell2mat(cellfun(@(x) ~isempty(regexpi(x.type, '_r', 'once')), import,'UniformOutput',0)));
if left_occurance && right_occurance
    sourceinfo.eyesObserved = 'lr';
elseif left_occurance && ~right_occurance
    sourceinfo.eyesObserved = 'l';
else
    sourceinfo.eyesObserved = 'r';
end

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

