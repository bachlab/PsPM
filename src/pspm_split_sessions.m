function [newdatafile, newepochfile] = pspm_split_sessions(datafile, markerchannel, options)
% pspm_split_sessions splits experimental sessions/blocks, based on
% regularly incoming markers, for example volume or slice markers from an
% MRI scanner (equivalent to the 'scanner' option during import in previous
% versions of PsPM and SCRalyze)
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
%                           Default is settings.split.max_sn = 10
% options.min_break_ratio:  Minimum for ratio
%                           [(session distance)/(mean marker distance)]
%                           Default is settings.split.min_break_ratio = 3
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
%                           Usefull for random ITI since it reduce the
%                           variance. Default = 0
% options.missing           Split the missing epochs file for SCR data. The
%                           input must be a filename containing missing
%                           epochs in seconds
%
%       REMARK for suffix and prefix:
%           The prefix and  suffix intervals will only be applied to data -
%           channels. Markers in those intervals are ignored.Only markers
%           within the splitpoints will be considered for each session to
%           avoid duplication of markers.
%
%
% OUTPUT:
% newdatafile: cell array of filenames for the individual sessions (char
%              input), or cell array of cell arrays of filenames (cell
%              input)
%__________________________________________________________________________
% PsPM 3.1
% (C) 2008-2015 Linus Ruttimann & Tobias Moser (University of Zurich)
% Updated 2021 Teddy Chao (WCHN)

% $Id$
% $Rev$

% -------------------------------------------------------------------------
% DEVELOPERS NOTES: this function was completely rewritten for SCRalyze 3.0
% and does not take into account slice numbers any more. It is a very
% simple algorithm now that simply defines a cut off in inter-marker
% intervals
%
% Was rewritten in PsPM 3.1 also in order to either have the first marker
% at t=0 or at a defined time point.
% -------------------------------------------------------------------------

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
elseif ~isfield(options, 'overwrite')
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
    warning('ID:invalid_input', 'options.randomITI has to be numeric and equal to 0 or 1.');
    return;
end

%% 2 Work on all data files
for d = 1:numel(D)
    % 2.1 Obtain data
    datafile = D{d};
    if options.verbose
        fprintf('Splitting %s ... ', datafile);
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
        
        if ~isempty(missing)
            [sts, ~, datascr] = pspm_load_data(datafile, 'scr');
            if sts == -1
                warning('ID:invalid_input', 'Could not load SCR data');
                return;
            end
            srscr = datascr{1}.header.sr;
            if any(missing > ininfos.duration) % convert epochs in sec to datapoints
                warning('ID:invalid_input', 'Some missing epochs are outside data file.');
            else
                missing = round(missing*srscr);
            end
            indx = zeros(size(datascr{1}.data));
            indx(missing(:, 1)+1) = 1;
            indx(missing(:, 2)) = -1;
            dp_epochs = (cumsum(indx(:)) == 1);
        end
    end
    
    % 2.3 Handle markers
    
    % 2.3.1 Define marker channel
    if markerchannel == 0
        markerchannel = filestruct.posofmarker;
    end
    mrk = indata{markerchannel}.data;
    newdatafile{d} = [];
    newepochfile{d} = [];
    
    % 2.3.2 Get markers and define cut off
    if isempty(options.splitpoints)
        imi = sort(diff(mrk), 'descend');
        if min(imi)*options.min_break_ratio > max(imi)
            fprintf('  The file won''t be split. No possible timepoints for split in channel %i.\n', markerchannel);
        elseif numel(mrk) <=  options.max_sn
            fprintf('  The file won''t be split. Not enough markers in channel %i.\n', markerchannel);
        end
        imi(1:(options.max_sn-1)) = [];
        cutoff = options.min_break_ratio * max(imi);
        splitpoint = find(diff(mrk) > cutoff)+1;
    else
        splitpoint = options.splitpoints;
    end
    if ~isempty(splitpoint)
        suffix = zeros(1,(numel(splitpoint)+1));% initialise
        for s = 1:(numel(splitpoint)+1)
            if s == 1
                sta = 1;
            else
                sta = splitpoint(s-1);
            end

            if s > numel(splitpoint)
                sto = numel(mrk);
            else
                sto = max(1,splitpoint(s) - 1);
            end
           
            if options.suffix == 0
                if sta == sto || options.randomITI
                    suffix(s) = mean(diff(mrk));
                else
                    suffix(s) = mean(diff(mrk(sta:sto)));
                end
            else
                suffix(s) = options.suffix;
            end
            spp(s,:) = [sta, sto];
        end
        splitpoint = spp;
        
        % 2.4 Split files
        for sn = 1:size(splitpoint,1)
            
            % 2.4.1 Determine filename
            [p, f, ex] = fileparts(datafile);
            newdatafile{d}{sn} = fullfile(p, sprintf('%s_sn%02.0f%s', f, sn, ex));

            if options.missing && ~isempty(missing)
                [p_epochs, f_epochs, ex_epochs] = fileparts(options.missing);
                newepochfile{d}{sn} = fullfile(p_epochs, sprintf('%s_sn%02.0f%s', f_epochs, sn, ex_epochs));
            end
            
            trimoptions = struct('overwrite', options.overwrite, 'drop_offset_markers', 1);
            newfn = pspm_trim(datafile, options.prefix, options.suffix, splitpoint(sn, 1:2), trimoptions);
            pspm_ren(newfn, newdatafile{d}{sn});

           
            % 2.4.5 Split Epochs - to be updated
            if options.missing && ~isempty(missing)
                startpoint = max(1, ceil((mrk(splitploint(:, 1)) - options.prefix) * srscr)); % convert from seconds into datapoints
                stoppoint  = min(floor((mrk(splitploint(:, 2)) + options.suffix) * srscr), numel(datascr{1}.data));
                epochs = dp_epochs(startpoint:stoppoint);
                epoch_on = strfind(epochs.', [0 1]); % Return the start points of the excluded interval
                epoch_off = strfind(epochs.', [1 0]); % Return the end points of the excluded interval
                if numel(epoch_off) < numel(epoch_on) % if the epochs is in the middle of 2 blocks
                    epoch_off(end+1) = stoppoint;
                elseif numel(epoch_on) < numel(epoch_off)
                    epoch_on = [1, epoch_on];
                end
                epochs = [epoch_on.', epoch_off.']/srscr; % convert back to seconds
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
return
end