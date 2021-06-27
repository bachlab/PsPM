function [newdatafile, newepochfile] = pspm_split_sessions(datafile, markerchannel, options)
% pspm_split_sessions splits experimental sessions/blocks, based on
% regularly incoming markers, for example volume or slice markers from an
% MRI scanner (equivalent to the 'scanner' option during import in previous
% versions of PsPM and SCRalyze), or based on a vector of split points in
% terms of markers. The first and the last marker will define the start of
% the first session and the end of the last session.
%
% FORMAT:
% newdatafile = pspm_split_sessions(datafile, markerchannel, options)
%
% INPUT:
% datafile:                 a file name, or cell array of file names
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
%
%       REMARK for suffix and prefix:
%           Markers in the prefix and suffix intervals are ignored. Only markers
%           between the splitpoints are considered for each session to
%           avoid duplication of markers.
%
%
% OUTPUT:
% newdatafile: cell array of filenames for the individual sessions (char
%              input), or cell array of cell arrays of filenames (cell
%              input)
%__________________________________________________________________________
% PsPM 5.1.1


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
if ischar(datafile) || isstruct(datafile)
    D = {datafile};
elseif iscell(datafile)
    D = datafile;
else
    warning('ID:invalid_input', 'Data file must be a char, cell, or struct.');
    return;
end
% 1.3.2 clear datafile
if options.missing
    if ~ischar(options.missing)
        warning('ID:invalid_input', 'Missing epochs file needs to be a char or cell.\n');
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
for d = 1:numel(D)
    % 2.1 Obtain data
    datafile = D{d};
    if options.verbose
        fprintf('Splitting %s ... \n', datafile);
    end
    [sts, ininfos, indata, filestruct] = pspm_load_data(datafile); % check and get datafile ---
    if sts == -1
        warning('ID:invalid_input', 'Could not load data');
        return;
    end
    
    % 2.2 Handle missing epochs
    if options.missing
        % makes sure the epochs are in seconds and not empty
        [~, missing] = pspm_get_timing('epochs', options.missing, 'seconds');
        missingsr = indata{1,1}.header.sr; % dummy sample rate, should be consistent with files
        if any(missing > ininfos.duration)
            warning('ID:invalid_input', 'Some missing epochs are outside data file.');
            return
        else
            missing = round(missing*missingsr); % convert epochs in sec to datapoints
        end
        indx = zeros(1,round(missingsr * ininfos.duration)); % indx should be a one-dimensional array?
        indx(missing(:, 1)+1) = 1;
        indx(missing(:, 2)) = -1;
        dp_epochs = (cumsum(indx(:)) == 1);
    end
    
    % 2.3 Handle markers
    
    % 2.3.1 Define marker channel
    if markerchannel == 0
        markerchannel = filestruct.posofmarker;
    end
    mrk = indata{markerchannel}.data;
    newdatafile{d} = [];
    newepochfile{d} = [];
    
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
            
            % 2.4.1 Determine filename
            [p, f, ex] = fileparts(datafile);
            newdatafile{d}{sn} = fullfile(p, sprintf('%s_sn%02.0f%s', f, sn, ex));
            
            if ~isempty(options.missing) && ~isempty(missing)
                [p_epochs, f_epochs, ex_epochs] = fileparts(options.missing);
                newepochfile{d}{sn} = fullfile(p_epochs, sprintf('%s_sn%02.0f%s', f_epochs, sn, ex_epochs));
            end
            trimoptions = struct('drop_offset_markers', 1);
            newdata = pspm_trim(struct('data', {indata}, 'infos', ininfos), ...
                options.prefix, suffix(sn), trimpoint(sn, 1:2), trimoptions);
            newdata.options = struct('overwrite', options.overwrite);
            pspm_load_data(newdatafile{d}{sn}, newdata);
            
            
            % 2.4.5 Split Epochs - to be updated
            if ~isempty(options.missing) && ~isempty(missing)
                dummydata{1,1}.header = struct('chantype', 'marker', ...
                                                'sr', missingsr, ...
                                                'units', 'unknown');
                dummydata{1,1}.data   = dp_epochs;
                
                % Not sure what does this line mean
                % I think this piece of code is dealing with epochs
                % Why is it recommended to add annother channel for
                % markerchennel?
                % dummydata{1,1}.markerinfo = indata{markerchannel};
                % dummyinfos          = ininfos;
                
                newmissing = pspm_trim(struct('data', {dummydata}, 'infos', ininfos), ...
                    options.prefix, suffix(sn), trimpoint(sn, 1:2), trimoptions);
                
                epochs = newmissing.data{1}.data;
                
                epoch_on = strfind(epochs.', [0 1]); % Return the start points of the excluded interval
                epoch_off = strfind(epochs.', [1 0]); % Return the end points of the excluded interval
                if numel(epoch_off) < numel(epoch_on) % if the epochs is in the middle of 2 blocks
                    epoch_off(end+1) = numel(epochs);
                elseif numel(epoch_on) < numel(epoch_off)
                    epoch_on = [1, epoch_on];
                end
                epochs = [epoch_on.', epoch_off.']/missingsr; % convert back to seconds
                save(newepochfile{d}{sn}, 'epochs');
            end
            
        end
    end
end

% convert newdatafile if necessary
if d == 1
    newdatafile = newdatafile{1};
    if options.missing
        newepochfile = newepochfile{1};
    end
end

end