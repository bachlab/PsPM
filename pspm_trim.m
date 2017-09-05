function newdatafile = pspm_trim(datafile, from, to, reference, options)
% SCR_TRIM cuts an SCR dataset to the limits set with the parameters 'from'
% and 'to' and writes it to a file with a prepended 't'
%
% FORMAT:
% NEWDATAFILE = SCR_TRIM (DATAFILE, FROM, TO, REFERENCE, options)
%
% datafile: a file name, a cell array of filenames, a struct with
%           fields .data and .infos or a cell array of structs
% from and to: either numbers, or 'none'
% reference: 'marker': from and to are set in seconds with 
%                         respect to the first and last scanner/marker pulse
%            'file':    from and to are set in seconds with respect to start
%                         of datafile 
%            a 2-element vector: from and to are set in seconds with
%                         respect to the two markers defined here
%
% options:  options.overwrite:       overwrite existing files by default
%           options.marker_chan_num: marker channel number - if undefined 
%                                     or 0, first marker channel is used
%
% RETURNS a filename for the updated file, a cell array of filenames, a
% struct with fields .data and .infos or a cell array of structs
%
%__________________________________________________________________________
% PsPM 3.0
% (C) 2008-2015 Dominik R Bach (Wellcome Trust Centre for Neuroimaging)

% $Id$
% $Rev$

% initialise
% -------------------------------------------------------------------------
global settings;
if isempty(settings), pspm_init; end
newdatafile = [];

% check input arguments
% -------------------------------------------------------------------------
if nargin<1
    warning('ID:invalid_input', 'No data.\n'); return;
elseif nargin<2
    warning('ID:invalid_input', 'No start or end point given.\n'); return;
elseif nargin<3
    warning('ID:invalid_input', 'No end point given.\n'); return;
elseif nargin<4
    warning('ID:invalid_input', 'No reference given.\n'); return;
end

if ~((ischar(from) && strcmpi(from, 'none')) ...
        || (isnumeric(from) && numel(from) == 1)) 
    warning('ID:invalid_input', 'No valid start point given.\n'); return;
elseif ~((ischar(to) && strcmpi(to, 'none')) ...
        || (isnumeric(to) && numel(to) == 1))
    warning('ID:invalid_input', 'No end point given'); return;
end

if strcmpi(reference, 'marker')
    getmarker = 1;
    startmarker = 1;
    g_endmarker = [];
elseif isnumeric(reference) && numel(reference) == 2
    getmarker = 1;
    startmarker = reference(1);
    g_endmarker = reference(2);    
    % check if reference markers are valid ---
    if startmarker < 1 || g_endmarker < startmarker
        warning('ID:invalid_input', 'No valid reference markers.\n'); return;
    end
elseif strcmpi(reference, 'file')
    getmarker = 0;
else
    warning('ID:invalid_input', 'Invalid reference option ''%s''', reference); 
    return;
end

% set options ---
try
    options.overwrite; 
catch
    options.overwrite = 0;
end

if ~isfield(options,'marker_chan_num') || ...
        ~isnumeric(options.marker_chan_num) || ...
        numel(options.marker_chan_num) > 1
    options.marker_chan_num = 0;
end

% check data file argument --
if ischar(datafile) || isstruct(datafile)
    D = {datafile};
elseif iscell(datafile) 
    D = datafile;
else
    warning('Data file must be a char, cell, or struct.');
end
clear datafile

% work on all data files
% -------------------------------------------------------------------------
for d=1:numel(D)
    % determine file names ---
    datafile=D{d};
        
    % user output ---
    if isstruct(datafile)
        fprintf('Trimming ... ');
    else
        fprintf('Trimming %s ... ', datafile);
    end
    
    % check and get datafile ---
    [sts, infos, data] = pspm_load_data(datafile, 0);
    if getmarker
        if options.marker_chan_num
            [nsts, ~, ndata] = pspm_load_data(datafile, options.marker_chan_num);
            if ~strcmp(ndata{1}.header.chantype, 'marker')
                warning('ID:invalid_option', ['Channel %i is no marker ', ...
                    ' channel. The first marker channel in the file is ', ...
                    'used instead'], options.marker_chan_num);
                [nsts, ~, ndata] = pspm_load_data(datafile, 'marker');
            end
        else
            [nsts, ~, ndata] = pspm_load_data(datafile, 'marker');
        end
        sts = [sts; nsts];
        events = ndata{1}.data;

        % set local endmarker depending on global endmarker
        if isempty(g_endmarker)
            l_endmarker = numel(events); 
        else
            l_endmarker = g_endmarker;
        end

        clear nsts ninfos ndata
        
        if isempty(events)
           warning('ID:marker_out_of_range', ...
               'Marker channel (%i) is empty. Cannot use as a reference.', ...
               options.marker_chan_num);
           return;
        end
    end
    if any(sts == -1), newdatafile = []; break; end
    
    % convert from and to into time in seconds ---
    if ischar(from) % 'none'
        startpoint = 0;
    else
        if getmarker % 'marker'
            startpoint = events(startmarker) + from;
        else         % 'file'
            startpoint = from;
        end
    end
    if ischar(to) % 'none'
        endpoint = infos.duration;
    else
        if getmarker  % 'marker'
            if l_endmarker > numel(events)
                warning('ID:marker_out_of_range', ...
                    ['\nEnd marker (%03.0f) out of file - no ', ...
                   'trimming end end.\n'], g_endmarker);
                endpoint = infos.duration;
            else
                endpoint = events(l_endmarker) + to;
            end
        else          % 'file'
            endpoint = to;
        end
    end
    
    % check start and end points ---
    if (startpoint < 0)
        warning('ID:marker_out_of_range', ['\nStart point (%.2f s) outside', ...
            ' file, no trimming at start.'], startpoint);
        startpoint = 0;
    end
    if endpoint > infos.duration
        warning('ID:marker_out_of_range', ['\nEnd point (%.2f s) outside ', ...
            'file, no trimming at end.'], endpoint);
        endpoint = infos.duration;
    end
    
    % trim file ---
    for k = 1:numel(data)
        if ~strcmpi(data{k}.header.units, 'events') % waveform channels
            % set start and endpoint
            newstartpoint = floor(startpoint * data{k}.header.sr);
            if newstartpoint == 0, newstartpoint = 1; end
            newendpoint = floor(endpoint * data{k}.header.sr);
            if newendpoint > numel(data{k}.data), ...
                newendpoint = numel(data{k}.data); end
            % trim data
            data{k}.data=data{k}.data(newstartpoint:newendpoint);
        else                                        % event channels
            remove_late = data{k}.data > endpoint;
            data{k}.data(remove_late) = [];
            data{k}.data = data{k}.data - startpoint;
            remove_early = data{k}.data < 0;
            data{k}.data(remove_early) = [];
            if isfield(data{k}, 'markerinfo')
                % also trim marker info if available
                data{k}.markerinfo.value(remove_late) = [];
                data{k}.markerinfo.name(remove_late) = [];
                
                data{k}.markerinfo.value(remove_early) = [];
                data{k}.markerinfo.name(remove_early) = [];
            end
        end
        % save new file
        infos.duration = endpoint - startpoint;
        infos.trimdate = date;
        infos.trimpoints = [startpoint endpoint];
    end
    clear savedata
    savedata.data = data; savedata.infos = infos; 
    if isstruct(datafile)
        sts = pspm_load_data(savedata, 'none');
        newdatafile = savedata;
    else
        [pth, fn, ext] = fileparts(datafile);
        newdatafile    = fullfile(pth, ['t', fn, ext]);
        savedata.infos.trimfile = newdatafile;
        savedata.options = options;
        sts = pspm_load_data(newdatafile, savedata);
    end
    if sts ~= 1
        warning('Trimming unsuccessful for file %s.\n', newdatafile); 
    else
        Dout{d} = newdatafile;
        % user output
        fprintf('  done.\n');
    end
end

% if cell array of datafiles is being processed, return cell array of
% filenames
if d > 1
    clear newdatafile
    newdatafile = Dout;
end

return;
