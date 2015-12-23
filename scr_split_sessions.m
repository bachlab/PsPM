function newdatafile = scr_split_sessions(datafile, markerchannel, options)
% SCR_SPLIT_SESSIONS splits experimental sessions/blocks, based on
% regularly incoming markers, for example volume or slice markers from an
% MRI scanner (equivalent to the 'scanner' option during import in previous
% versions of PsPM and SCRalyze)
% 
% FORMAT: 
% newdatafile = scr_split_sessions(datafile, markerchannel, options)
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
% options.prefix            In seconds, how long data before start trim point 
%                           should also be included. First marker will be
%                           at t = options.prefix 
%                           Default = 0
% options.suffix            In seconds, how long data after the end trim
%                           point should be included. Last marker will be
%                           at t = duration (of session) - options.suffix
%                           Default = 0
% 
%       REMARK for suffix and prefix: 
%           If the session of markerchannel (and markerchannel only)
%           overlaps with other sessions (after prefix time and suffix time 
%           have been added) the markers of the overlapping session will 
%           not be in the current session. But then the markers will start 
%           at t=prefix and not at t=0. This only applies for the 
%           markerchannel and in other channels the overlap data will be 
%           included.
%
% OUTPUT:
% newdatafile: cell array of filenames for the individual sessions (char 
%              input), or cell array of cell arrays of filenames (cell
%              input)
%__________________________________________________________________________
% PsPM 3.1
% (C) 2008-2015 Linus Rüttimann & Tobias Moser (University of Zurich)

% $Id: scr_split_sessions.m 701 2015-01-22 14:36:13Z tmoser $
% $Rev: 701 $

% -------------------------------------------------------------------------
% DEVELOPERS NOTES: this function was completely rewritten for SCRalyze 3.0
% and does not take into account slice numbers any more. It is a very
% simple algorithm now that simply defines a cut off in inter-marker
% intervals 
%
% Was rewritten in PsPM 3.1 also in order to either have the first marker
% at t=0 or at a defined time point.
% -------------------------------------------------------------------------

% initialise
% -------------------------------------------------------------------------
global settings;
if isempty(settings), scr_init; end;
newdatafile = [];

% options
% -------------------------------------------------------------------------
if ~exist('options','var') || isempty(options) || ~isstruct(options)
    options = struct(); 
end;
try
    if options.overwrite ~= 1, options.overwrite = 0; end;
catch
    options.overwrite = 0;
end;

try options.prefix; catch, options.prefix = 0; end;
try options.suffix; catch, options.suffix = 0; end;

% maximum number of sessions (default 10)
try options.max_sn; catch, options.max_sn = settings.split.max_sn; end;
% minimum ratio of session break to normal inter marker interval (default 3)
try 
    options.min_break_ratio; 
catch
    options.min_break_ratio = settings.split.min_break_ratio;
end;

% check input arguments
% -------------------------------------------------------------------------
if nargin < 1
    warning('ID:invalid_input', 'No data file(s).\n'); return;
elseif ischar(datafile)
    D = {datafile};
elseif iscell(datafile)
    D = datafile;
else
    warning('ID:invalid_input', 'Datafile needs to be a char or cell.\n'); return;
end;

if nargin < 2
    markerchannel = 0;
elseif isempty(markerchannel)
    markerchannel = 0;
elseif ~isnumeric(markerchannel)
    warning('ID:invalid_input', 'Marker channel needs to be a number.\n'); return;
end;

% work on all data files
% -------------------------------------------------------------------------
for d = 1:numel(D)
    
    % determine file names ---
    datafile=D{d};
    
    % user output ---
    fprintf('Trimming %s ... ', datafile);

    % check and get datafile ---
    [sts, ininfos, indata, filestruct] = scr_load_data(datafile);
    if sts < 0, break, end;
    
    % define marker channel --
    if markerchannel == 0, markerchannel = filestruct.posofmarker; end;
    mrk = indata{markerchannel}.data;
       
    % get markers and define cut off ---
    imi = sort(diff(mrk), 'descend');
    
    newdatafile{d} = [];
    if min(imi)*options.min_break_ratio > max(imi)
        fprintf('  The file won''t be trimmed. No possible timepoints for split in channel %i.\n', markerchannel);        
    elseif numel(mrk) <=  options.max_sn
        fprintf('  The file won''t be trimmed. Not enough markers in channel %i.\n', markerchannel);
    else
        imi(1:(options.max_sn-1)) = [];
        cutoff = options.min_break_ratio * max(imi);
            
        % get split points ---
        splitpoint = find(diff(mrk) > cutoff)+1;
        
        for s = 1:(numel(splitpoint)+1)
            if s == 1
                sta = 1;
            else
                sta = splitpoint(s-1);
            end;
            
            if s > numel(splitpoint)
                sto = numel(mrk);
            else
                sto = splitpoint(s) - 1;
            end;
            
            % include last space (estimated by mean space)
            mean_space = mean(diff(mrk(sta:sto)));
            start_time = mrk(sta);
            stop_time = mrk(sto)+mean_space;
            
            % correct starttime (we cannot go into -) ---
            if start_time <= 0, start_time = 0; end;
            % correct stop_time if it exceeds duration of file
            if stop_time > ininfos.duration, stop_time = ininfos.duration; end;
            spp(s,:) = [start_time, stop_time];
        end;
        
        splitpoint = spp;
        
        % split file ---
        for sn = 1:size(splitpoint,1)
            % determine filename ---
            [p, f, ex] = fileparts(datafile);
            newdatafile{d}{sn} = fullfile(p, sprintf('%s_sn%02.0f%s', f, sn, ex));
            
            % adjust split points according to prefix and suffix ---
            if (splitpoint(sn,1) - options.prefix) < 0
                sta_p = 0.001;
                sta_prefix = splitpoint(sn,1);
            else
                sta_p = splitpoint(sn,1) - options.prefix;
                sta_prefix = options.prefix;
            end;
            
            if (splitpoint(sn,2) + options.suffix) > ininfos.duration
                sto_p = ininfos.duration;
                sto_suffix = ininfos.duration - splitpoint(sn,2);
            else
                sto_p = splitpoint(sn,2) + options.suffix;
                sto_suffix = options.suffix;
            end;
            
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
                        startpoint = sta_p + sta_prefix;
                        stoppoint = sto_p - sto_suffix;
                        foo = indata{k}.data;
                        foo(foo > stoppoint) = [];
                        foo = foo - startpoint;
                        foo(foo < 0) = [];
                        foo = foo + sta_prefix;
                        data{k}.data = foo;
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
                    end;
                else
                    % convert from s into datapoints
                    startpoint = ceil(sta_p * data{k}.header.sr);
                    stoppoint  = floor(sto_p * data{k}.header.sr);
                    data{k}.data = indata{k}.data(startpoint:stoppoint);
                end;
            end;
            
            % save data ---
            if exist(newdatafile{d}{sn}, 'file') && ~options.overwrite
                overwrite=menu(sprintf('Trimmed file (%s) already exists. Overwrite?', newdatafile{d}{sn}), 'yes', 'no');
                %close gcf;
                if overwrite == 2, continue; end;
            end;
            save(newdatafile{d}{sn}, 'infos', 'data');
        end;
        % User output
        fprintf('  done.\n');
    end;
    
end;

% convert newdatafile if necessary
if d == 1
    newdatafile = newdatafile{1};
end;

return;
    
    
    
