function [varargout] = pspm_convert_area2diameter(varargin)
% ● Description
%   pspm_convert_area2diameter converts area values into diameter values
%   It can work on PsPM files or on numeric vectors.
% ● Format
%   [sts, d]    = pspm_convert_area2diameter(area)
%   [sts, channel] = pspm_convert_area2diameter(fn, channel, options)
% ● Arguments
%                 fn: a numeric vector of milimeter values
%               channel: Channels which should be converted from area to diameter.
%                     This can be a channel number, any channel type including 
%                     'pupil' (which will select a channel according to the 
%                     precedence order specified in pspm_load_channel), or 'both',
%                     which will work on 'pupil_r' and 'pupil_l'. 
%                     Default is 'both'. 
%               area: a numeric vector of area values (the unit is not
%                     important)
%   ┌────────options:
%   └.channel_action: ['add'/'replace', default as 'add']
%                     Defines whether the new channel should be added or the
%                     previous outputs of this function should be replaced.
% ● History
%   Introduced in PsPM 3.1
%   Written in 2016 by Tobias Moser (University of Zurich)

%% Initialise
global settings
if isempty(settings)
  pspm_init;
end
sts = -1;

narginchk(1, 3);

if numel(varargin) == 1
  area = varargin{1};

  if ~isnumeric(area)
    warning('ID:invalid_input', 'area is not numeric'); return;
  end
  mode = 'vector';
else
  fn = varargin{1};
  channel = varargin{2};
  if strcmpi(channel, 'both')
      channel = {'pupil_r', 'pupil_l'};
  else
      channel = {channel};
  end
  options = pspm_options(options, 'convert_area2diameter');
  if options.invalid
    return
  end

  mode = 'file';

end

if strcmpi(mode, 'vector')
    varargout{2} = 2.*sqrt(area./pi);
    sts = 1;
elseif strcmpi(mode, 'file')
    % load the data once to avoid multiple i/o operations in case 'both' is
    % specified
    [sts, alldata.infos, alldata.data] = pspm_load_data(fn);
    if sts < 1, return; end
    diam = cell(numel(channel), 1);
    for i = 1:numel(channel)
        [sts, channeldata] = pspm_load_channel(alldata, channel{i}, 'pupil');
        if sts < 1, return; end
        % recursive call to avoid the formula being stated twice in the same function
        [sts, diam{i}.data] = pspm_covert_area2diameter(channeldata.data);
        if sts < 1, return; end
        diam{i}.header = channeldata.header;
        % replace metric values
        diam{i}.header.units = ...
            regexprep(channeldata{1}.header.units, ...
            '(square)?(centi|milli|deci|c|m|d)?(m(et(er|re))?)(s?\^?2?)', ...
            '$2$3');
        % if not metric, replace area with diameter
        if strcmpi(diam{i}.header.units, 'area units')
            diam{i}.header.units = 'diameter units';
        end
    end
    [sts, infos] = pspm_write_channel(fn, diam, options.channel_action);
    varargout{2} = infos.channel;
end
varargout{1} = sts;
return
