function [sts, outdata] = pspm_interpolate(indata, options)
% pspm_interpolate
% 
% FORMAT: 
% [sts, outdata] = pspm_interpolate(indata, options)
%
% DESCRIPTION: 
% This function interpolates NaN values passed with the indata parameter.
% The behaviour of the function can furthermore be adjusted with the
% combination of different options.
%
% The function works either on single data sets such as a filename, a
% numeric array or a pspm data struct. Alternatively it is possible to pass
% a cell containing all these possible datatypes. The function then iterates
% through the whole data set and replaces the passed data with the interpolated
% data. For filenames the interpolated data will, depending on option.newfile, 
% be written to the existing file or can also be added to a new file 
% with filename 'i'+<old filename>. The corresponding cell (in outdata)
% will then contain the filename of the new file (if newfile = 1) or will
% contain the channel id where the interpolated data can be found in the
% existing file (because it has been added or replaced). The edited data set 
% will then be returned as parameter outdata.
%
% INPUT:
%   indata: [struct/char/numeric] or [cell array of struct/char/numeric]
%           contains the data to be interpolated
%  
%   options: 
%       .overwrite:     Defines if existing datafiles should be
%                       overwritten (Default is 0)
%       .method:        Defines the interpolation method, see interp1() for
%                       possible interpolation methods (Default is linear)
%       .extrapolate    1 if should extrapolate for data out of the data
%                       range (not recommended; Default is 0)
%       .channels       If passed, should have the same size as indata and
%                       contains for each entry in indata the channel(s) to 
%                       be interpolated. If options.channels is empty or a 
%                       certain cell is empty the function then tries to 
%                       interpolate all continuous data channels. This
%                       works only on files or structs.
%                       (Default is empty).
%       .channel_action ['add'/'replace'] Defines whether the interpolated
%                       data should be added or the corresponding channel
%                       should be replaced.
%                       (Default: 'add')
%       .newfile:       This is only possible if data is loaded from a file.
%                       If 0 the data will be added to the file where
%                       the data was loaded from. If 1 the data will be
%                       written to a new file called 'i'+<old filename>.
%                       (Default is 0)
% OUTPUT:
%       sts:            Returns the status of the function
%                       -1: function did not work properly
%                       1: the function went through properly
%       
%       outdata:        Has the same format as indata but contains the
%                       interpolated data (or the filename(s) where the 
%                       interpolated data can be found). 
%       
%__________________________________________________________________________
% PsPM 3.0
% (C) 2015 Tobias Moser (University of Zurich)

% $Id: pspm_interpolate.m 592 2018-09-14 09:01:41Z lciernik $
% $Rev: 592 $

%% Initialise
global settings
if isempty(settings)
	pspm_init;
end
sts = -1;
% will return a cell of the same size as the indata
outdata = {};
sts = -1;

% check input arguments
% -------------------------------------------------------------------------
if nargin<1
    warning('ID:missing_data', 'No data.\n'); 
    return;
end;

if isempty(indata)
    warning('ID:missing_data', 'Input data is empty, nothing to do.');
    return;
end;

% set options ---
try options.overwrite; catch, options.overwrite = 0; end;
try options.method; catch, options.method = 'linear'; end;
try options.channels; catch, options.channels = []; end;
try options.newfile; catch, options.newfile = 0; end;
try options.channel_action; catch, options.channel_action = 'add'; end;
try options.extrapolate; catch, options.extrapolate = 0; end;
try options.dont_ask_overwrite; catch, options.dont_ask_overwrite = 0; end;

% check channel size
if numel(options.channels) > 0
    if numel(options.channels) ~= numel(indata)
        warning('ID:invalid_size', 'options.channels must have same size as indata');
        return;
    elseif (numel(options.channels) == 1) && ~iscell(options.channels)
        options.channels = {options.channels};
    end;
end;

% check if valid data in options
if ~ismember(options.method, {'linear', 'nearest', 'next', 'previous', 'spline', 'pchip', 'cubic'})
    warning('ID:invalid_input', 'Invalid interpolation method.');
    return;
elseif ~(isnumeric(options.channels) || isempty(options.channels) || ... 
        (iscell(options.channels) && sum(cellfun(@(f) (isnumeric(f) || isempty(f)), options.channels)) == numel(options.channels)))
    warning('ID:invalid_input', 'options.channels must be numeric or a cell of numerics');
    return;
elseif ~islogical(options.newfile) && ~isnumeric(options.newfile)
    warning('ID:invalid_input', 'options.newfile must be numeric or logical');
    return;
elseif ~islogical(options.dont_ask_overwrite) && ~isnumeric(options.dont_ask_overwrite)
    warning('ID:invalid_input', 'options.dont_ask_overwrite must be numeric or logical');
    return;
elseif ~islogical(options.extrapolate) && ~isnumeric(options.extrapolate)
    warning('ID:invalid_input', 'options.extrapolate must be numeric or logical');
    return;
elseif ~any(strcmpi(options.channel_action, {'add', 'replace'}))
    warning('ID:invalid_input', 'options.channel_action can only be ''add'' or ''replace''');
    return;
elseif ~islogical(options.overwrite) && ~isnumeric(options.overwrite)
    warning('ID:invalid_input', 'options.overwrite must be numeric or logical');
    return;
end;

% check data file argument --
if ischar(indata) || isstruct(indata) || isnumeric(indata)
    D = {indata};
elseif iscell(indata) ... 
        && sum(cellfun(@(f) isstruct(f), indata) | ... 
            cellfun(@(f) isnumeric(f), indata) | ...
            cellfun(@(f) ischar(f), indata)) == numel(indata)
    D = indata;
else
    warning('ID:invalid_input', 'Data must be either char, numeric, struct or cell array of char, numeric or struct.');
    return;
end;

if iscell(indata)
    outdata = cell(size(D));
end;

% work on all data files
% -------------------------------------------------------------------------
for d=1:numel(D)
    % determine file names ---
    fn=D{d};
        
    % flag to decide what kind of data should be handled
    inline_flag = 0;
    
    % user output ---
    if ischar(fn)
        fprintf('Interpolating %s ... \n', fn);
    elseif isnumeric(fn)
            inline_flag = 1;
    end;
    
    % not inline data must be loaded first; check and get datafile ---
    if ~inline_flag
        
        if ischar(fn) && ~exist(fn, 'file')
            warning('ID:nonexistent_file', 'The file ''%s'' does not exist.', [fn]);
            outdata = {};
            return;
        end;
        
        % struct get checked if structure is okay; files get loaded
        [lsts, infos, data] = pspm_load_data(fn, 0);
        if any(lsts == -1)
            warning('ID:invalid_data_structure', 'Cannot load data from data');
            outdata = {};
            break;
        end;

        if numel(options.channels) > 0 && numel(options.channels{d}) > 0
            % channels passed; try to get appropriate channels
            work_chans = options.channels{d};
            chans = data(work_chans);
        else
            % no channels passed; try to search appropriate channels
            work_chans = find(cellfun(@(f) ~strcmpi(f.header.units, 'events'), data))';
            chans = data(work_chans);
        end;
        
        % sanity check chans should be a cell
        if ~iscell(chans) && numel(chans) == 1
            chans = {chans};
        end;
        
        % look for event channels
        ev = cellfun(@(f) strcmpi(f.header.units, 'events'), chans);
        if any(ev)
            warning('ID:invalid_channeltype', 'Cannot interpolate event channels.');
            return;
        end;
    else
        chans = {fn};
    end
        
    interp_frac = ones(numel(chans), 1);
    for k = 1:numel(chans)
        if inline_flag
            dat = chans{k};
        else
            dat = chans{k}.data;
        end;
        
        if numel(find(~isnan(dat))) < 2
            warning('ID:invalid_input','Need at least two sample points to run interpolation (Channel %i). Skipping.', k);
        else
            x = 1:length(dat);
            v = dat;
            
            % add some other checks here if you want to filter out other data
            % features (e. g. out-of-range values)
            filt = isnan(v);
            xq = find(filt);
            
            % remember how many data is being interpolated
            interp_frac(k) = numel(xq)/numel(v);
            
            % throw away data matching 'filt'
            x(xq) = [];
            v(xq) = [];
            
            % check for overlaps
            if numel(xq) < 1
                e_overlap = 0;
                s_overlap = 0;
            else
                e_overlap = max(xq) > max(x);
                s_overlap = min(xq) < min(x);
            end;
            
            if s_overlap || e_overlap
                if ~options.extrapolate
                    %warning('ID:option_disabled', ['Cannot interpolate without extrapolating,', ...
                    %    ' because out-of-range data overlaps at the beginning or at the end.', ...
                    %    ' Either turn on extrapolation or use pspm_trim to cut away ', ...
                    %    'out-of-range values at the beginning or end of the data.']);
                    %return;
					warning('ID:option_disabled', ['Extrapolating was forced because interpolate without extrapolating cannot be done']);
					vq = interp1(x, v, xq, options.method, 'extrap');
					
                elseif s_overlap && strcmpi(options.method, 'previous')
                    warning('ID:out_of_range', ['Cannot extrapolate with ', ...
                        'method ''previous'' and overlap at the beginning.']);
                    return;
                elseif e_overlap && strcmpi(options.method, 'next')
                    warning('ID:out_of_range', ['Cannot extrapolate with ', ...
                        'method ''next'' and overlap at the end.']);
                    return;
                else
                    % extrapolate because of overlaps
                    vq = interp1(x, v, xq, options.method, 'extrap');
                end;
            else
                % no overlap
                vq = interp1(x, v, xq, options.method);
            end;
            
            dat(xq) = vq;
            
            if inline_flag
                chans{k} = dat;
            else
                chans{k}.data = dat;
            end;
        end;
    end;
    
    if ~inline_flag 
        clear savedata
        savedata.data = data;
        savedata.data(work_chans) = chans(:);
        savedata.infos = infos;
        
        if isfield(savedata.infos, 'history')
            nhist = numel(savedata.infos.history);
        else
            nhist = 0;
        end;
        
        savedata.infos.history{nhist + 1} = ['Performed interpolation: ', ...
            sprintf('Channel %i: %.3f interpolated\n', [work_chans; interp_frac']), ...
            ' on ', datestr(now, 'dd-mmm-yyyy HH:MM:SS')];
        
        if isstruct(fn)
            % check datastructure
            sts = pspm_load_data(savedata, 'none');
            outdata{d} = savedata;
        else
            if options.newfile
                % save as a new file preprended with 'i'
                [pth, fn, ext] = fileparts(fn);
                newdatafile    = fullfile(pth, ['i', fn, ext]);
                savedata.infos.interpolatefile = newdatafile;
                
                % pass options
                o.overwrite = options.overwrite;
                o.dont_ask_overwrite = options.dont_ask_overwrite;
                
                savedata.options = o;
                
                sts = pspm_load_data(newdatafile, savedata);
                
                if sts == 1
                    outdata{d} = newdatafile;
                end;
            else
                o = struct();
                
                % add to existing file 
                if strcmp(options.channel_action, 'replace')
                    o.channel = work_chans;
                end;
                    
                o.msg.prefix = 'Interpolated channel';
                [sts, infos] = pspm_write_channel(fn, savedata.data(work_chans), options.channel_action, o);
                
                % added channel ids are in infos.channel
                outdata{d} = infos.channel;
            end;
        end;
    else
        outdata{d} = chans{1};
    end;
   
end;

% format output same as input
if (numel(outdata) == 1) && ~iscell(indata)
    outdata = outdata{1};
end;

sts = 1;


    