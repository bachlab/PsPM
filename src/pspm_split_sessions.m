function [newdatafile, newepochfile] = pspm_split_sessions(datafile, markerchannel, options)
% pspm_split_sessions splits experimental sessions/blocks, based on
% regularly incoming markers, for example volume or slice markers from an
% MRI scanner, or based on a vector of split points that is defined in
% terms of markers. The first and the last marker will define the start of
% the first session and the end of the last session.
%
% FORMAT:
% newdatafile = pspm_split_sessions(datafile, markerchannel, options)
%
% INPUT:
% datafile:                 a file name
% markerchannel (optional): number of the channel that contains the
%                           relevant markers
% options
% options.overwrite:        overwrite existing files by default
% options.max_sn:           Define the maximum of sessions to look for.
%                           Default is 10 (defined by
%                           settings.split.max_sn)
% options.min_break_ratio:  Minimum for ratio
%                           [(session distance)/(maximum marker distance)]
%                           Default is 3 (defined by
%                           settings.split.min_break_ratio)
% options.splitpoints       Alternatively, directly specify session start
%                           in terms of markers (vector of integer)
% options.prefix            In seconds, how long data before start trim point
%                           should also be included. First marker will be
%                           at t = options.prefix
%                           Default = 0
% options.suffix            In seconds, how long data after the end trim
%                           point should be included. Last marker will be
%                           at t = duration (of session) - options.suffix
%                           Default = 0
% options.randomITI         Tell the function to use all the markers to
%                           evaluate the mean distance between them.
%                           Usefull for random ITI since it reduces the
%                           variance. Default = 0
% options.missing           Optional name of an epoch file, e.g. containing
%                           a missing epochs definition in s. This is then split accordingly.
%                           epochs have a fixed sampling rate of 10000
%
%       REMARK for suffix and prefix:
%           Markers in the prefix and suffix intervals are ignored. Only markers
%           between the splitpoints are considered for each session, to
%           avoid duplication of markers.
%
%
% OUTPUT:
% newdatafile: cell array of filenames for the individual sessions
% newepochfile: cell array of missing epoch filenames for the individual
% sessions (empty if no options.missing not specified)
%__________________________________________________________________________
% PsPM 5.1.1
% 2021 PsPM Team


%% 1 Initialise
global settings;
if isempty(settings)
    pspm_init;
end
newdatafile = [];

% 1.1 Check input arguments
if nargin<1
    warning('ID:invalid_input', 'No data.\n');
    return;
end

% 1.2 Set options
if ~exist('options','var') || isempty(options) || ~isstruct(options)
    options = struct();
end
if ~isfield(options, 'overwrite')
    options.overwrite = 0;
elseif options.overwrite ~= 1
    options.overwrite = 0;
end
try options.prefix; catch
    options.prefix = 0;
end
try options.suffix; catch
    options.suffix = 0;
end
try options.verbose; catch
    options.verbose = 0;
end
try options.splitpoints; catch
    options.splitpoints = [];
end
try options.missing; catch
    options.missing = 0;
end
try options.randomITI; catch
    options.randomITI = 0;
end
try options.max_sn; catch
    options.max_sn = settings.split.max_sn; % maximum number of sessions (default 10)
end
try options.min_break_ratio; catch
    options.min_break_ratio = settings.split.min_break_ratio; % minimum ratio of session break to normal inter marker interval (default 3)
end

% 1.3 Handle data files
% 1.3.1 check data file argument
if ~ischar(datafile)
    warning('ID:invalid_input', 'Data file must be a char.');
    return;
end
% 1.3.2 clear datafile
if options.missing
    if ~ischar(options.missing)
        warning('ID:invalid_input', 'Missing epochs file needs to be a char.\n');
    end
end

% 1.4 Check if prefix is positiv and suffix is negative
if options.prefix > 0
    warning('ID:invalid_input', 'Prefix must be negative.');
    return;
elseif options.suffix < 0
    warning('ID:invalid_input', 'Suffix must be positive.');
    return;
end
if nargin < 2
    markerchannel = 0;
elseif isempty(markerchannel)
    markerchannel = 0;
elseif ~isnumeric(markerchannel)
    warning('ID:invalid_input', 'Marker channel needs to be a number.\n');
    return;
end
if ~isnumeric(options.splitpoints)
    warning('ID:invalid_input', 'options.splitpoints has to be numeric.');
    return;
end
if ~isnumeric(options.randomITI) || ~ismember(options.randomITI, [0, 1])
    warning('ID:invalid_input', 'options.randomITI should be 0 or 1.');
    return;
end

%% 2 Work on all data files

% 2.1 Obtain data
if options.verbose
    fprintf('Splitting %s ... \n', datafile);
end
[sts, ininfos, indata, filestruct] = pspm_load_data(datafile); % check and get datafile ---
if sts == -1
    warning('ID:invalid_input', 'Could not load data.');
    return;
end

% 2.2 Handle missing epochs
if options.missing
    % makes sure the epochs are in seconds and not empty
    [sts, missing] = pspm_get_timing('epochs', options.missing, 'seconds');
    if sts < 0
        warning('ID:invalid_input', 'Could not load missing epochs.');
    end
    missingsr = 10000; % dummy sample rate, should be higher than data sampling rates (but no need to make it dynamic)
    if any(missing > ininfos.duration)
        warning('ID:invalid_input', 'Some missing epochs are outside data file.');
        return
    else
        missing = round(missing*missingsr); % convert epochs in sec to datapoints
    end
    indx = zeros(1,round(missingsr * ininfos.duration)); % indx should be a one-dimensional array?
    % allow splitting empty missing epochs
    if ~isempty(missing)
        indx(missing(:, 1)) = 1;
        indx(missing(:, 2)+1) = -1;
    end
    dp_epochs = (cumsum(indx(:)) == 1);
    % extract fileparts for later
    [p_epochs, f_epochs, ex_epochs] = fileparts(options.missing);
end

% 2.3 Handle markers

% 2.3.1 Define marker channel
if markerchannel == 0
    markerchannel = filestruct.posofmarker;
end
mrk = indata{markerchannel}.data;
newdatafile = cell(0);
newepochfile = cell(0);

% 2.3.2 Find split points
if isempty(options.splitpoints)
    imi = sort(diff(mrk), 'descend');
    if min(imi)*options.min_break_ratio > max(imi)
        fprintf('  The file won''t be split. No possible split points found in marker channel %i.\n', markerchannel);
    elseif numel(mrk) <=  options.max_sn
        fprintf('  The file won''t be split. Not enough markers in marker channel %i.\n', markerchannel);
    end
    imi(1:(options.max_sn-1)) = [];
    cutoff = options.min_break_ratio * max(imi);
    splitpoint = find(diff(mrk) > cutoff)+1;
else
    splitpoint = options.splitpoints;
end

% 2.3.3 Define trim points and adjust suffix
if isempty(splitpoint)
    return;
else
    % initialise
    suffix = zeros(1,(numel(splitpoint)+1));
    for sn = 1:(numel(splitpoint)+1)
        if sn == 1
            trimpoint(sn, :) = [1, max(splitpoint(sn) - 1, 1)];
        elseif sn > numel(splitpoint)
            trimpoint(sn, :) = [max(splitpoint(sn - 1), 1), numel(mrk)];
        else
            trimpoint(sn, :) = [splitpoint(sn - 1), max(splitpoint(sn) - 1, 1)];
        end
        
        if sn > numel(splitpoint)
            trimpoint(sn, 2) = numel(mrk);
        else
            trimpoint(sn, 2) = max(1, splitpoint(sn) - 1);
        end
        
        if options.suffix == 0
            if trimpoint(sn, 1) == trimpoint(sn, 2) || options.randomITI
                suffix(sn) = mean(diff(mrk));
            else
                suffix(sn) = mean(diff(mrk(trimpoint(sn, 1):trimpoint(sn, 2))));
            end
        else
            suffix(sn) = options.suffix;
        end
    end
    
    % 2.4 Split files
    for sn = 1:size(trimpoint,1)
        
        % 2.4.1 Determine filenames
        [p, f, ex] = fileparts(datafile);
        newdatafile{sn} = fullfile(p, sprintf('%s_sn%02.0f%s', f, sn, ex));
        
        if ischar(options.missing)
            newepochfile{sn} = fullfile(p_epochs, sprintf('%s_sn%02.0f%s', f_epochs, sn, ex_epochs));
        end
        
        % 2.4.2 Split data
        trimoptions = struct('drop_offset_markers', 1);
        newdata = pspm_trim(struct('data', {indata}, 'infos', ininfos), ...
            options.prefix, suffix(sn), trimpoint(sn, 1:2), trimoptions);
        newdata.options = struct('overwrite', options.overwrite);
        pspm_load_data(newdatafile{sn}, newdata);
        
        
        % 2.4.5 Split Epochs
        if options.missing
                dummydata{1,1}.header = struct('chantype', 'custom', ...
                'sr', missingsr, ...
                'units', 'unknown');
            dummydata{1,1}.data   = dp_epochs;

            % add marker channel to that pspm_trim has a reference
            dummydata{2,1}      = indata{markerchannel};
            dummyinfos          = ininfos;

            newmissing = pspm_trim(struct('data', {dummydata}, 'infos', dummyinfos), ...
                options.prefix, suffix(sn), trimpoint(sn, 1:2), trimoptions);

            epochs = newmissing.data{1}.data;
            
            epoch_on = 1 + strfind(epochs.', [0 1]); % Return the start points of the excluded interval
            epoch_off = strfind(epochs.', [1 0]); % Return the end points of the excluded interval
            if numel(epoch_off) < numel(epoch_on) % if the epochs is in the middle of 2 blocks
                epoch_off(end+1) = numel(epochs);
            elseif numel(epoch_on) < numel(epoch_off)
                epoch_on = [0, epoch_on];
            end
            epochs = [epoch_on.', epoch_off.']/missingsr; % convert back to seconds
            save(newepochfile{sn}, 'epochs');
        end
        
    end
end