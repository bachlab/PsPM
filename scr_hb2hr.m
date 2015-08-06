efunction sts = scr_hb2hr(fn, sr, chan, options)
% scr_hb2hr transforms heart beat data into an interpolated heart rate
% signal and adds this as an additional channel to the data file
% 
% sts = scr_hb2hr(fn, sr, chan)
%       fn: data file name
%       sr: sample rate for heart rate channel
%       chan: number of heart beat channel (optional, default: first heart
%             beat channel)
%       options: optional arguments [struct]
%           .replace - if specified and 1 when existing data should be
%                      overwritten
%__________________________________________________________________________
% PsPM 3.0
% (C) 2008-2015 Dominik R Bach (Wellcome Trust Centre for Neuroimaging)

% $Id: scr_hb2hr.m 701 2015-01-22 14:36:13Z tmoser $
% $Rev: 701 $


% initialise & user output
% -------------------------------------------------------------------------
sts = -1;
global settings;
if isempty(settings), scr_init; end;

try options.replace; catch options.replace = 0; end;

% check input
% -------------------------------------------------------------------------
if nargin < 1
    warning('No input. Don''t know what to do.'); return;
elseif ~ischar(fn)
    warning('Need file name string as first input.'); return;
elseif nargin < 2
    warning('No sample rate given.'); return; 
elseif ~isnumeric(sr)
    warning('Sample rate needs to be numeric.'); return;
elseif nargin < 3
    chan = 'hb';
elseif ~isnumeric(chan)
    warning('Channel number must be numeric'); return;
end;

% get data
% -------------------------------------------------------------------------
[nsts, infos, data] = scr_load_data(fn, chan);
if nsts == -1, return; end;
if numel(data) > 1
    fprintf('There is more than one heart beat channel in the data file. Only the first of these will be analysed.');
    data = data(1);
end;

% interpolate
% -------------------------------------------------------------------------
hb  = data{1}.data;
ibi = diff(hb);
hr = 1./ibi; % in Hz
newt = (1/sr):(1/sr):infos.duration;
newhr = interp1(hb(2:end), hr, newt, 'linear' ,'extrap'); % assign hr to following heart beat 


% save data
% -------------------------------------------------------------------------
newdata.data = newhr(:) * 60;
newdata.header.sr = sr;
newdata.header.units = 'bpm';
newdata.header.chantype = 'hr';

if options.replace == 1
    msg = sprintf('Heart beat converted to heart rate and replaced data on %s', date);
    nsts = scr_rewrite_channel(fn, chan, newdata, msg);
else
    msg = sprintf('Heart beat converted to heart rate and added to data on %s', date);
    nsts = scr_add_channel(fn, newdata, msg);
end;
if nsts == -1, return; end;

sts = 1;
