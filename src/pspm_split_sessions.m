function newdatafile = pspm_split_sessions(datafile, markerchannel, options)
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
%                           at t = -options.prefix
%                           Default = 0
% options.suffix            In seconds, how long data after the end trim
%                           point should be included. Last marker will be
%                           at t = duration (of session) - options.suffix
%                           Default = 0
% options.randomITI         Tell the function to use all the markers to
%                           evaluate the mean distance between them.
%                           Usefull for random ITI since it reduce the
%                           variance. Default = 0
% options.verbose:          Tell the function to display information about the state of processing.
%                           Default: 0.
%
%       REMARK for suffix and prefix:
%           The prefix and  suffix intervals will only be applied to data -
%           channels. Markers in those intervals are ignored.Only markers
%           within the splitpoints will be considered for each session to
%           avoid dupplication of markers.
%
%
% OUTPUT:
% newdatafile: cell array of filenames for the individual sessions (char
%              input), or cell array of cell arrays of filenames (cell
%              input)
%__________________________________________________________________________
% PsPM 3.1
% (C) 2008-2015 Linus Ruttimann & Tobias Moser (University of Zurich)
%
% PsPM 5.1
% Revised and modified in 2021: Dadi Zhao (UCL)

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

%% Initialise
global settings;
if isempty(settings), pspm_init; end
newdatafile = [];

%% Check input arguments
if nargin<1
    warning('ID:invalid_input', 'No data.\n'); return;
end

%% Set options
if ~exist('options','var') || isempty(options) || ~isstruct(options)
    options = struct();
end
try
    if options.overwrite ~= 1, options.overwrite = 0; end
catch
    options.overwrite = 0;
end

try options.prefix;     catch,  options.prefix = 0;         end
try options.suffix;     catch,  options.suffix = 0;         end
try options.splitpoints;catch,  options.splitpoints = [];   end
try options.verbose;    catch,  options.verbose = 0;        end

% maximum number of sessions (default 10)
try options.max_sn; catch, options.max_sn = settings.split.max_sn; end
% minimum ratio of session break to normal inter marker interval (default 3)
try
    options.min_break_ratio;
catch
    options.min_break_ratio = settings.split.min_break_ratio;
end

try options.randomITI; catch, options.randomITI = 0; end

% check data file argument
if ischar(datafile) || isstruct(datafile)
    D = {datafile};
elseif iscell(datafile)
    D = datafile;
else
    warning('ID:invalid_input', 'Data file must be a char, cell, or struct.');
end
%clear datafile

% check if prefix is positiv and suffix is negative
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
    warning('ID:invalid_input', 'Marker channel needs to be a number.\n'); return;
end

if ~isnumeric(options.splitpoints)
    warning('ID:invalid_input', 'options.splitpoints has to be numeric.'); return;
end

if ~isnumeric(options.randomITI) || ~ismember(options.randomITI, [0, 1])
    warning('ID:invalid_input', 'options.randomITI has to be numeric and equal to 0 or 1.'); return;
end

%% Work on all data files
for d = 1:numel(D)
    
    % determine file names ---
    datafile=D{d};
    
    % check and get datafile ---
    [sts, ininfos, indata, filestruct] = pspm_load_data(datafile);
    if sts == -1
        warning('ID:invalid_input', 'Could not load data');
        return;
    end;
    
    % define marker channel --
    if markerchannel == 0, markerchannel = filestruct.posofmarker; end
    mrk = indata{markerchannel}.data;
    
    newdatafile{d} = [];
    if isempty(options.splitpoints)
        % get markers and define cut off ---
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
            
            % include last space (estimated by mean space)
            % do not cut immedeately after stop because there might be some
            % relevant data within the mean space
            
            % add global mean space
            if sta == sto || options.randomITI
                mean_space = mean(diff(mrk));
            else
                mean_space = mean(diff(mrk(sta:sto)));
            end
            start_time = mrk(sta);
            stop_time = mrk(sto)+mean_space;
            
            % correct starttime (we cannot go into -) ---
            if start_time <= 0, start_time = 0; end
            % correct stop_time if it exceeds duration of file
            if stop_time > ininfos.duration, stop_time = ininfos.duration; end
            spp(s,:) = [start_time, stop_time];
        end
        
        splitpoint = spp;
        
        % split file ---
        for sn = 1:size(splitpoint,1)
            % determine filename ---
            [p, f, ex] = fileparts(datafile);
            newdatafile{d}{sn} = fullfile(p, sprintf('%s_sn%02.0f%s', f, sn, ex));
            
            % adjust split points according to prefix and suffix ---
            if (splitpoint(sn,1) + options.prefix) < 0
                sta_p = 0;
                sta_prefix = sta_p - splitpoint(sn,1);
            else
                sta_p = splitpoint(sn,1) + options.prefix;
                sta_prefix = options.prefix;
            end
            
            if (splitpoint(sn,2) + options.suffix) > ininfos.duration
                sto_p = ininfos.duration;
                sto_suffix = ininfos.duration - splitpoint(sn,2);
            else
                sto_p = splitpoint(sn,2) + options.suffix;
                sto_suffix = options.suffix;
            end
            
            % update infos ---
            infos = ininfos;
            infos.duration = sto_p - sta_p;
            infos.splitdate = date;
            infos.splitsn = sprintf('Session %02.0f', sn);
            infos.splitfile = newdatafile{d}{sn};
            
            % split data ---
            data = cell(numel(indata),1);
            for k = 1:numel(indata)
                % assign header
                data{k}.header = indata{k}.header;
                % assign data
                if strcmp(data{k}.header.units, 'events')
                    if k == markerchannel
                        startpoint = sta_p - sta_prefix;
                        stoppoint = sto_p - sto_suffix;
                        foo = indata{k}.data;
                        foo_idx = find(foo<=stoppoint & foo>=startpoint);
                        foo(foo > stoppoint) = [];
                        foo = foo - startpoint;
                        foo(foo < 0) = [];
                        foo = foo - sta_prefix;
                        data{k}.data = foo;
                        if isfield(indata{k},'markerinfo')
                            if isfield(indata{k}.markerinfo, 'value')
                                foo_markervalues = indata{k}.markerinfo.value;
                                foo_markervalues = foo_markervalues(foo_idx);
                                data{k}.markerinfo.value = foo_markervalues;
                            end
                            if isfield(indata{k}.markerinfo, 'name')
                                foo_markernames = indata{k}.markerinfo.name;
                                foo_markernames = foo_markernames(foo_idx);
                                data{k}.markerinfo.name = foo_markernames;
                            end
                        end
                        clear foo;
                    else
                        startpoint = sta_p;
                        stoppoint  = sto_p;
                        foo = indata{k}.data;
                        foo(foo > stoppoint) = [];
                        foo = foo - startpoint;
                        foo(foo < 0) = [];
                        data{k}.data = foo;
                        clear foo;
                    end
                else
                    % convert from s into datapoints
                    startpoint = max(1, ceil(sta_p * data{k}.header.sr));
                    stoppoint  = min(floor(sto_p * data{k}.header.sr), ...
                        numel(indata{k}.data));
                    data{k}.data = indata{k}.data(startpoint:stoppoint);
                    
                    
%                     % Testing trim
%                     options.overwrite = 1;
%                     options.verbose = 1;
%                     options.drop_offset_markers = 1;
%                     reference = [sta_p, sto_p];
%                     options.marker_chan_num = d;
%                     newdatafile{d}{sn} = pspm_trim(datafile, startpoint, stoppoint, reference, options);
                end
            end
            
            % save data ---
            if exist(newdatafile{d}{sn}, 'file') && ~options.overwrite
                if feature('ShowFigureWindows')
                    msg = ['Split file already exists. Overwrite?', newline, 'Existing file: ',newdatafile{d}{sn}];
                    overwrite = questdlg(msg, 'File already exists', 'Yes', 'No', 'Yes');
                else
                    overwrite = 'Yes';
                end
                if strcmp(overwrite, 'No'), continue; end
            end
            save(newdatafile{d}{sn}, 'infos', 'data');
        end
    end
    
end

% convert newdatafile if necessary
if d == 1
    newdatafile = newdatafile{1};
end

return;

% Testing MATLAB licence

