function varargout = pspm_trim(datafile, from, to, reference, options)
% ● Description
%   pspm_trim cuts an PsPM dataset to the limits set with the parameters 'from'
%   and 'to' and writes it to a file with a prepended 't'
% ● Format
%   newdatafile = pspm_trim (datafile, from, to, reference, options)
% ● Arguments
%            datafile:  string/struct/cell_array
%                       [string] the name of the file to be trimmed.
%                       [struct] fields .data and .infos
%                       [cell_array] a cell array of filenames or structs
%                from:  either numbers, or 'none'
%                       the start of trimming period
%                  to:  a numeric value or 'none'
%                       the end of trimming period
%           reference:  string/vector/cell_array
%                       [string]
%                       'marker' from and to are set in seconds with respect
%                                to the first and last scanner/marker pulse
%                       'file'   from and to are set in seconds with respect
%                                to start of datafile
%                       [vector] a 2-element vector:
%                       from and to are set in seconds with respect to the two
%                       markers defined here
%                       [cell_array] a 2-element cell-array
%                       from and to are set in seconds with respect to the first
%                       two markers having the value held in the cell array
%   ┌─────────options:
%   ├──────.overwrite:  [logical] (0 or 1)
%   │                   Define whether to overwrite existing output files or not.
%   │                   Default value: determined by pspm_overwrite.
%   ├.marker_chan_num:  marker channel number.
%   │                   if undefined or 0, first marker channel is used.
%   └.drop_offset_markers:
%                       if offsets are set in the reference, you might be
%                       interested in only the data, but not in the additional
%                       markers which are within the offset. therefore set this
%                       option to 1 to drop markers which lie in the offset.
%                       this is for event channels only. default is 0.
% ● Outputs
%                  sts: status variable indicating whether function run successfully.
%          newdatafile: a filename for the updated file, a cell array of
%                       filenames, a struct with fields .data and .infos or a
%                       cell array of structs
% ● Version
%   Introduced in PsPM 3.0
%   Written in 2008-2015 by Dominik R Bach (Wellcome Trust Centre for Neuroimaging)
%   Maintained in 2022 by Teddy Chao (UCL)

%% 1 Pre-settings
% 1.1 Initialise
global settings
if isempty(settings)
    pspm_init;
end
sts = -1;
newdatafile = [];
switch nargout
    case 1
        varargout{1} = newdatafile;
    case 2
        varargout{1} = sts;
        varargout{2} = newdatafile;
end
% 1.2 Verify the number of input arguments
switch nargin
    case 0
        warning('ID:invalid_input', 'No data.\n');
        return
    case 1
        warning('ID:invalid_input', 'No start or end point given.\n');
        return
    case 2
        warning('ID:invalid_input', 'No end point given.\n');
        return
    case 3
        warning('ID:invalid_input', 'No reference given.\n');
        return
end
% 1.3 Verify the data file
if ischar(datafile) || isstruct(datafile)
    D = {datafile};
    Dout = D; % the output cell
elseif iscell(datafile)
    D = datafile;
    Dout = D; % the output cell
else
    warning('Data file must be a char, cell, or struct.');
end
clear datafile
% 1.4 Verify the start and end points
if ~( ...
        (ischar(from) && strcmpi(from, 'none')) || ...
        (isnumeric(from) && numel(from) == 1) || ...
        (isnumeric(from) && numel(from) == numel(D)) ...
        )
    warning('ID:invalid_input', 'No valid start point given.\n');
    return
end
if ~( ...
        (ischar(to) && strcmpi(to, 'none')) || ...
        (isnumeric(to) && numel(to) == 1) || ...
        (isnumeric(to) && numel(to) == numel(D)) ...
        )
    warning('ID:invalid_input', 'No end point given');
    return
end
if numel(from) == 1
    from = ones(1,numel(D)) * from;
end
if numel(to) == 1
    to = ones(1,numel(D)) * to;
end
% 1.5 Verify reference
calculate_idx = false;
switch(class(reference))
    case 'char'
        switch reference
            case 'marker'
                getmarker = 1;
                startmarker = 1;
                g_endmarker = [];
            case 'file'
                getmarker = 0;
            otherwise
                warning('ID:invalid_input', ...
                    ['Invalid reference option ''%s'', ',...
                    'should be marker or file.'], reference);
                return
        end
    case 'double'
        if numel(reference) == 2
            getmarker = 1;
            startmarker = reference(1);
            g_endmarker = reference(2);
            % check if reference markers are valid ---
            if startmarker < 1 || g_endmarker < startmarker
                warning('ID:invalid_input', 'No valid reference markers.\n');
                return
            end
        else
            warning('ID:invalid_input', 'Invalid reference option ''%s'', should contain only two elements', reference);
            return
        end
    case 'cell'
        if numel(reference) == 2
            getmarker = 1;
            marker_sta_vals = reference{1};
            marker_end_vals = reference{2};
            calculate_idx = true;
        else
            warning('ID:invalid_input', ...
                'Invalid reference option ''%s'', should contain only two elements',...
                reference);
            return
        end
    otherwise
        warning('ID:invalid_input', ...
            'Invalid reference option ''%s'', should be a character, a number, or a cell', reference);
        return
end
% 1.6 Set options
if ~exist('options','var') || isempty(options) || ~isstruct(options)
    options = struct();
end
options = pspm_options(options, 'trim');
if options.invalid
    return
end
%% 2 Work on all data
for i_D = 1:numel(D)
    % 2.1 Obtain essential file info
    datafile = D{i_D}; % Obtain file name
    if isstruct(datafile)
        fprintf('Trimming ... ');
    else
        fprintf('Trimming %s ... ', datafile);
    end
    [sts_load_data, infos, data] = pspm_load_data(datafile, 0);
    if ~sts_load_data
        warning('ID:invalid_option', 'Failed to load datafile');
    end
    % 2.2 Calculate markers if needed
    if getmarker == 1
        % 2.2.1 Verify the markers
        [nsts, ~, ndata] = pspm_load_data(datafile, options.marker_chan_num);
        if ~strcmp(ndata{1}.header.chantype, 'marker')
            warning('ID:invalid_option', ['Channel %i is no marker ', ...
                ' channel. The first marker channel in the file is ', ...
                'used instead'], options.marker_chan_num);
            [nsts, ~, ndata] = pspm_load_data(datafile, 'marker');
        end
        if nsts > 0
            events = ndata{1}.data;
        else
            return
        end
        if isempty(events)
            warning('ID:marker_out_of_range', 'Marker channel (%i) is empty. Cannot use as a reference.', options.marker_chan_num);
            return
        end
        % 2.2.2 Caluculate marker idx if specified by marker values or markernames
        if calculate_idx
            % get idx of starting marker
            try_num_start = str2double(marker_sta_vals);
            if ~isempty(try_num_start)
                startmarker = find(ndata{1}.markerinfo.value == try_num_start,1);
            elseif ischar(marker_sta_vals)
                startmarker = find(strcmpi(ndata{1}.markerinfo.name,marker_sta_vals),1);
            else
                warning('ID:invalid_input', 'The value or name of the starting marker must be numeric or a string');
                return
            end
            % get idx of ending marker
            try_num_end = str2double(marker_end_vals);
            if ~isempty(try_num_end)
                g_endmarker = find(ndata{1}.markerinfo.value == try_num_end,1);
            elseif ischar(marker_end_vals)
                g_endmarker = find(strcmpi(ndata{1}.markerinfo.name,marker_end_vals),1);
            else
                warning('ID:invalid_input', 'The value or name of the ending marker must be numeric or a string');
                return
            end
            % check if the markers are valid
            if startmarker < 1 || g_endmarker < startmarker
                warning('ID:invalid_input', 'No valid reference markers.\n'); return
            end
        end
        % 2.2.3 set local endmarker depending on global endmarker
        if isempty(g_endmarker)
            l_endmarker = numel(events);
        else
            l_endmarker = g_endmarker;
        end
        clear nsts ninfos ndata
    end

    % 2.3 Convert from and to from time points into seconds
    if ischar(from) % 'none'
        sta_p = 0;
        sta_offset = 0;
    else
        if getmarker % 'marker'
            sta_p = events(startmarker);
            sta_offset = from(i_D);
        else         % 'file'
            sta_p = from(i_D);
            sta_offset = 0;
        end
    end
    if ischar(to) % 'none'
        sto_p = infos.duration;
        sto_offset = 0;
    else
        if getmarker  % 'marker'
            if l_endmarker > numel(events)
                warning('ID:marker_out_of_range', ...
                    ['\nEnd marker (%03.0f) out of file - no ', ...
                    'trimming at end.\n'], g_endmarker);
                sto_p = infos.duration;
                sto_offset = 0;
            else
                sto_p = events(l_endmarker);
                sto_offset = to(i_D);
            end
        else          % 'file'
            sto_p = to(i_D);
            sto_offset = 0;
        end
    end
    % 2.4 Check start and end points
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
    % 2.5 Trim file
    for k = 1:numel(data)
        if ~strcmpi(data{k}.header.units, 'events') % waveform channels
            % set start point (`ceil` for protect against having duration < data*sr,
            % the `+1` is here because of matlabs convention to start indices from 1)
            newstartpoint = ceil((sta_p + sta_offset) * data{k}.header.sr)+1;
            if newstartpoint == 0
                newstartpoint = 1;
            end
            % set end point
            newendpoint = floor((sto_p + sto_offset) * data{k}.header.sr);
            if newendpoint > numel(data{k}.data), ...
                    newendpoint = numel(data{k}.data);
            end
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
    % 2.6 Save data
    savedata.data = data;
    savedata.infos = infos;
    if isstruct(datafile)
        sts_load_data = pspm_load_data(savedata, 'none');
        if ~sts_load_data
            warning('ID:unable_to_save', 'Cannot save data to the expected file.')
            return
        end
        newdatafile = savedata;
    else
        [pth, fn, ext] = fileparts(datafile);
        newdatafile    = fullfile(pth, ['t', fn, ext]);
        savedata.infos.trimfile = newdatafile;
        options.overwrite = pspm_overwrite(newdatafile, options);
        savedata.options = options;
        sts_load_data = pspm_load_data(newdatafile, savedata);
        if ~sts_load_data
            warning('ID:unable_to_save', 'Cannot save data to the expected file.')
            return
        end
    end
    Dout{i_D} = newdatafile;
    fprintf('  done.\n');
end
% 3 Return value
% if cell array of datafiles is being processed,
% return cell array of filenames
if i_D > 1
    clear newdatafile
    newdatafile = Dout;
end
sts = 1;
switch nargout
    case 1
        varargout{1} = newdatafile;
    case 2
        varargout{1} = sts;
        varargout{2} = newdatafile;
end
return
