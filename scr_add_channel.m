function sts = scr_add_channel(fn, newdata, msg)
% scr_add_channel adds a channel to an existing data file and updates the
% infos
% 
% sts = scr_add_channel(fn, data, msg)
%       fn: data file name
%       data: data structure for the new channel, must contain
%           data.data (data vector)
%           data.header.sr (sample rate)
%           data.header.chantype (as defined in settings)
%           data.header.units (data units, or 'events')
%       msg: message for updating infos
%__________________________________________________________________________
% PsPM 3.0
% (C) 2008-2015 Dominik R Bach (Wellcome Trust Centre for Neuroimaging)

% $Id: scr_add_channel.m 701 2015-01-22 14:36:13Z tmoser $
% $Rev: 701 $


% initialise & user output
% -------------------------------------------------------------------------
sts = -1;
global settings;
if isempty(settings), scr_init; end;

% check input
% -------------------------------------------------------------------------
if nargin < 1
    warning('ID:invalid_input', 'No input. Don''t know what to do.'); return;
elseif ~ischar(fn)
    warning('ID:invalid_input', 'Need file name string as first input.'); return;
elseif nargin < 2
    warning('ID:invalid_input', 'No data to add.'); return; 
elseif ~isstruct(newdata)
    warning('ID:invalid_input', 'Need data structure to add to file.'); return;
elseif nargin < 3
    msg = sprintf('Unknown channel added on %s', date);
end;

% get data
% -------------------------------------------------------------------------
[nsts, infos, data] = scr_load_data(fn);
if nsts == -1, return; end;

% add data
% -------------------------------------------------------------------------
nchan = numel(data);
data{nchan + 1} = newdata;
if isfield(infos, 'history')
    nhist = numel(infos.history);
else
    nhist = 0;
end;
infos.history{nhist + 1} = msg;


% save data
% -------------------------------------------------------------------------
outdata.infos = infos;
outdata.data  = data;
outdata.options.overwrite = 1;

nsts = scr_load_data(fn, outdata);
if nsts == -1, return; end;

sts = 1;
