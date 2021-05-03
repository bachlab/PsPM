function newdatafile = pspm_trim(datafile, pt_start, pt_end, reference, options)
% pspm_trim cuts an PsPM dataset to the limits set with the parameters 'from'
% and 'to' and writes it to a file with a prepended 't'
%
% FORMAT:
% NEWDATAFILE = pspm_trim (datafile, from, to, reference, options)
%
% datafile:     a file name, a cell array of filenames, a struct with
%               fields .data and .infos or a cell array of structs
% from and to:  either numbers, or 'none'
% reference:    'marker': from and to are set in seconds with
%                         respect to the first and last scanner/marker pulse
%               'file':   from and to are set in seconds with respect to start
%                         of datafile
%               a 2-element vector: from and to are set in seconds with
%                         respect to the two markers defined here
%               a 2-elemtn cell-array: from and to are set in seconds with
%                         respect to the first two markers having the value
%                         held in the cell array
%
% options:  options.overwrite:       overwrite existing files by default
%           options.marker_chan_num: marker channel number - if undefined
%                                     or 0, first marker channel is used
%           options.drop_offset_markers:
%                                    if offsets are set in the reference, you
%                                    might be interested in only the data, but
%                                    not in the additional markers which are
%                                    within the offset. therefore set this
%                                    option to 1 to drop markers which lie in
%                                    the offset. this is for event channels
%                                    only. default is 0.
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

if ~((ischar(pt_start) && strcmpi(pt_start, 'none')) ...
        || (isnumeric(pt_start) && numel(pt_start) == 1))
    warning('ID:invalid_input', 'No valid start point given.\n'); return;
elseif ~((ischar(pt_end) && strcmpi(pt_end, 'none')) ...
        || (isnumeric(pt_end) && numel(pt_end) == 1))
    warning('ID:invalid_input', 'No end point given'); return;
end

calculate_idx = false;
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
elseif iscell(reference) && numel(reference) == 2
    getmarker = 1;
    startmarker_vals = reference{1};
    g_endmarker_vals = reference{2};
    calculate_idx =true;
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

if ~isfield(options, 'drop_offset_markers') || ...
        ~isnumeric(options.drop_offset_markers)
    options.drop_offset_markers = 0;
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
        
        if isempty(events)
            warning('ID:marker_out_of_range', ...
                'Marker channel (%i) is empty. Cannot use as a reference.', ...
                options.marker_chan_num);
            return;
        end
        
        % caluculate marker idx if specified by marker values or markernames
        if calculate_idx
            % get idx of starting marker
            try_num_start = str2num(startmarker_vals);
            if ~isempty(try_num_start)
                startmarker = find(ndata{1}.markerinfo.value == try_num_start,1);
                
            elseif ischar(startmarker_vals)
                startmarker = find(strcmpi(ndata{1}.markerinfo.name,startmarker_vals),1);
            else
                warning('ID:invalid_input', ...
                    'The value or name of the starting marker must be numeric or a string');
                return;
            end
            %get idx of ending marker
            try_num_end = str2num(g_endmarker_vals);
            if ~isempty(try_num_end)
                g_endmarker = find(ndata{1}.markerinfo.value == try_num_end,1);
            elseif ischar(g_endmarker_vals)
                g_endmarker = find(strcmpi(ndata{1}.markerinfo.name,g_endmarker_vals),1);
            else
                warning('ID:invalid_input', ...
                    'The value or name of the ending marker must be numeric or a string');
                return;
            end
            
            % check if the markers are valid
            if startmarker < 1 || g_endmarker < startmarker
                warning('ID:invalid_input', 'No valid reference markers.\n'); return;
            end
        end
        
        % set local endmarker depending on global endmarker
        if isempty(g_endmarker)
            l_endmarker = numel(events);
        else
            l_endmarker = g_endmarker;
        end
        
        clear nsts ninfos ndata
        
        
    end
    if any(sts == -1), newdatafile = []; break; end
    
    % convert from and to into time in seconds ---
    if ischar(pt_start) % 'none'
        sta_p = 0;
        sta_offset = 0;
    else
        if getmarker % 'marker'
            sta_p = events(startmarker);
            sta_offset = pt_start;
        else         % 'file'
            sta_p = pt_start;
            sta_offset = 0;
        end
    end
    if ischar(pt_end) % 'none'
        sto_p = infos.duration;
        sto_offset = 0;
    else
        if getmarker  % 'marker'
            if l_endmarker > numel(events)
                warning('ID:marker_out_of_range', ...
                    ['\nEnd marker (%03.0f) out of file - no ', ...
                    'trimming end end.\n'], g_endmarker);
                sto_p = infos.duration;
                sto_offset = 0;
            else
                sto_p = events(l_endmarker);
                sto_offset = pt_end;
            end
        else          % 'file'
            sto_p = pt_end;
            sto_offset = 0;
        end
    end
    
    % check start and end points ---
    if ((sta_p + sta_offset) < 0)
        warning('ID:marker_out_of_range', ['\nStart point (%.2f s) outside', ...
            ' file, no trimming at start.'], (sta_p + sta_offset));
        
        if (sta_p > 0)
            sta_offset = -sta_p;
        else
            sta_p = 0;
            sta_offset = 0;
        end
    end
    if (sto_p + sto_offset) > infos.duration
        warning('ID:marker_out_of_range', ['\nEnd point (%.2f s) outside ', ...
            'file, no trimming at end.'], (sto_p + sto_offset));
        
        if (sto_p > infos.duration)
            sto_p = infos.duration;
            sto_offset = 0;
        else
            sto_offset = infos.duration - sto_p;
        end
    end
    
    % trim file ---
    for k = 1:numel(data)
        if ~strcmpi(data{k}.header.units, 'events') % waveform channels
            % set start point (`ceil` for protect against having duration < data*sr,  
            % the "+1" is here because of matlabs convention to start indices from 1)
            newstartpoint = ceil((sta_p + sta_offset) * data{k}.header.sr)+1;
            if newstartpoint == 0, newstartpoint = 1; end
            
            % set end point
            newendpoint = floor((sto_p + sto_offset) * data{k}.header.sr);
            if newendpoint > numel(data{k}.data), ...
                    newendpoint = numel(data{k}.data); end
            
            % trim data
            data{k}.data=data{k}.data(newstartpoint:newendpoint);
        else % event channels
            if options.drop_offset_markers
                newendpoint = sto_p;
                newstartpoint = sta_p;
            else
                newendpoint = sto_p + sto_offset;
                newstartpoint = sta_p + sta_offset;
            end
            remove_late = data{k}.data > newendpoint;
            data{k}.data(remove_late) = [];
            data{k}.data = data{k}.data - newstartpoint;
            remove_early = data{k}.data < 0;
            data{k}.data(remove_early) = [];
            
            % move to match data if offset markers should be dropped
            if options.drop_offset_markers
                data{k}.data = data{k}.data - sta_offset;
            end
            if isfield(data{k}, 'markerinfo')
                % also trim marker info if available
                data{k}.markerinfo.value(remove_late) = [];
                data{k}.markerinfo.name(remove_late) = [];
                
                data{k}.markerinfo.value(remove_early) = [];
                data{k}.markerinfo.name(remove_early) = [];
            end
        end
        % save new file
        infos.duration = (sto_p + sto_offset) - (sta_p + sta_offset);
        infos.trimdate = date;
        infos.trimpoints = [(sta_p + sta_offset) (sto_p + sto_offset)];
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
