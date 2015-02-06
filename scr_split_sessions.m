function newdatafile = scr_split_sessions(datafile, markerchannel, options)
% SCR_SPLIT_SESSIONS splits experimental sessions/blocks, based on
% regularly incoming markers, for example volume or slice markers from an
% MRI scanner (equivalent to the 'scanner' option during import in previous
% versions of SCRalyze)
% 
% FORMAT: 
% newdatafile = scr_split_sessions(datafile, markerchannel, options)
% 
% datafile: a file name, or cell array of file names
% markerchannel (optional): number of the channel that contains the
%                           relevant markers
% options  
% options.overwrite:       overwrite existing files by default
% 
% newdatafile: cell array of filenames for the individual sessions (char 
%              input), or cell array of cell arrays of filenames (cell
%              input)
%__________________________________________________________________________
% PsPM 3.0
% (C) 2008-2015 Linus Rüttimann (University of Zurich)

% $Id: scr_split_sessions.m 701 2015-01-22 14:36:13Z tmoser $
% $Rev: 701 $

% -------------------------------------------------------------------------
% DEVELOPERS NOTES: this function was completely rewritten for SCRalyze 3.0
% and does not take into account slice numbers any more. It is a very
% simple algorithm now that simply defines a cut off in inter-marker
% intervals 
% -------------------------------------------------------------------------

% initialise
% -------------------------------------------------------------------------
global settings;
if isempty(settings), scr_init; end;
newdatafile = [];

% constants
% -------------------------------------------------------------------------
MAXSN    = settings.split.maxsn; % maximum number of sessions (default 10)
BRK2NORM = settings.split.brk2norm; % minimum ratio of session break to normal inter marker interval (default 3)

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

% set options ---
try
    if options.overwrite ~= 1, options.overwrite = 0; end;
catch
    options.overwrite = 0;
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
    
    if numel(mrk) <=  MAXSN
        fprintf('  The file won''t be trimmed. Not enough markers in channel %i.\n', markerchannel);
        newdatafile{d} = [];
        continue;
    end;
    
    % get markers and define cut off ---
    imi = sort(diff(mrk), 'descend');
    imi(1:MAXSN) = [];
    cutoff = BRK2NORM * max(imi);
    
    % get split points ---
    splitpoint = find(diff(mrk) > cutoff);
    startsn = mrk([1; splitpoint(:)]);
    stopsn  = [mrk(splitpoint(:)); mrk(end)];
    splitpoint = [startsn, stopsn];
    
    % split file ---
    for sn = 1:numel(startsn)
        % determine filename ---
        [p, f, ex] = fileparts(datafile);
        newdatafile{d}{sn} = fullfile(p, sprintf('%s_sn%02.0f%s', f, sn, ex));
        
        % update infos ---
        infos = ininfos;
        infos.duration = splitpoint(sn,2) - splitpoint(sn,1);
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
                startpoint = splitpoint(sn, 1);
                stoppoint  = splitpoint(sn, 2);
                foo = indata{k}.data;
                foo(foo > stoppoint) = [];
                foo = foo - startpoint;
                foo(foo < 0) = [];
                data{k}.data = foo;
                clear foo;
            else
                % convert from s into datapoints
                startpoint = floor(splitpoint(sn, 1) * data{k}.header.sr) + 1;
                stoppoint  = floor(splitpoint(sn, 2) * data{k}.header.sr) + 1;
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

% convert newdatafile if necessary
if d == 1
    newdatafile = newdatafile{1};
end;

return;
    
    
    
