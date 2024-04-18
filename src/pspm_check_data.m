function [sts, data] = pspm_check_data(data, infos)
% ● Description
%   pspm_checks_data checks a PsPM data (and, optional, infos) structure
%   This function is used throughout PsPM (and in particular in
%   pspm_load_data). It returns a data cell array with legacy and format
%   conversions.
% ● Format
%   [sts, data] = pspm_check_data(data, infos)

% this code is taken from pspm_load_data; it could be improved using
% cellfun

global settings
if isempty(settings)
    pspm_init;
end
sts = -1;

if nargin < 1
    warning('ID:invalid_input', 'No input - don''t know what to do');
    return
end

% check infos
if nargin > 1
    flag_infos = 0;
    if isempty(fieldnames(infos))
        flag_infos = 1;
    else
        if ~isfield(infos, 'duration')
            flag_infos = 1;
        end
    end
    if flag_infos
        warning('ID:invalid_data_structure', 'Input data does not have sufficient infos');
        return
    end
else
    flag_infos = 1;
end

% 7.1 initialise error flags --
vflag = zeros(numel(data), 1); % records data structure, valid if 0
wflag = zeros(numel(data), 1); % records whether data is out of range, valid if 0
nflag = zeros(numel(data), 1);

% loop through channels
for k = 1:numel(data)
    % 7.2 Check header --
    if ~isfield(data{k}, 'header')
        vflag(k) = 1;
    else
        % 7.2.1 Convert header channeltype into chantype if there are --
        if isfield(data{k}.header, 'channeltype')
            data{k}.header.chantype = data{k}.header.channeltype;
            data{k}.header = rmfield(data{k}.header, 'channeltype');
        end
        if ~isfield(data{k}.header, 'chantype') || ...
                ~isfield(data{k}.header, 'sr') || ...
                ~isfield(data{k}.header, 'units')
            vflag(k) = 1;
        else
            if ~ismember(lower(data{k}.header.chantype), {settings.channeltypes.type})
                nflag(k) = 1;
            end
        end
    end
    % 7.3 Check data --
    if vflag(k)==0 && nflag(k)==0
        % required information is available and valid in header and infos
        if ~isfield(data{k}, 'data')
            vflag(k) = 1;
        else
            if isempty(data{k}.data)
                warning('ID:missing_data', 'Channel %01.0f is empty.', k);
                % convert empty data to a generalised 1-by-0 matrix
                data{k}.data = zeros(1,0);
            elseif ~isvector(data{k}.data)
                vflag(k) = 1;
            elseif size(data{k}.data, 1) < size(data{k}.data, 2) 
                data{k}.data = data{k}.data(:);
                warning('ID:invalid_data_structure', ...
                    'Channel %i seems to have the wrong orientation. Trying to transpose...', k);
            end
            if ~flag_infos && ~vflag(k)
                if strcmpi(data{k}.header.units, 'events')
                    if (any(data{k}.data > infos.duration) || any(data{k}.data < 0))
                        wflag(k) = 1;
                    end
                else
                    if (length(data{k}.data) < infos.duration * data{k}.header.sr - 3 ||...
                            length(data{k}.data) > infos.duration * data{k}.header.sr + 3)
                        wflag(k) = 1;
                    end
                end
            end
        end
    end
end

if any(vflag)
    errmsg = [sprintf('Invalid data structure for channel %01.0f.', find(vflag,1))];
    warning('ID:invalid_data_structure', '%s', errmsg);
    return
end
if any(wflag)
    errmsg = [sprintf(['The data in channel %01.0f is out of ',...
        'the range [0, infos.duration]'], find(wflag,1))];
    warning('ID:invalid_data_structure', '%s', errmsg);
    return
end
if any(nflag)
    errmsg = [sprintf('Unknown channel type %s in channel %01.0f', data{find(nflag,1)}.header.chantype, find(nflag,1))];
    warning('ID:invalid_data_structure', '%s', errmsg);
    return
end

sts = 1;

