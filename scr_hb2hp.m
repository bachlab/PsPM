function [sts, infos] = scr_hb2hp(fn, sr, chan, options)
% scr_hb2hp transforms heart beat data into an interpolated heart rate
% signal and adds this as an additional channel to the data file
% 
% sts = scr_hb2hp(fn, sr, chan, options)
%       fn: data file name
%       sr: sample rate for heart rate channel
%       chan: number of heart beat channel (optional, default: first heart
%             beat channel); if empty (= 0 / []) will be set to default
%             value
%       options: optional arguments [struct]
%           .replace - if specified and 1 when existing data should be
%                      overwritten
%           .cutoff  - maximum heart period which will be replaced by the
%                      average of the surrounding values
%__________________________________________________________________________
% PsPM 3.0
% (C) 2008-2015 Dominik R Bach (Wellcome Trust Centre for Neuroimaging)

% $Id: scr_hb2hp.m 701 2015-01-22 14:36:13Z tmoser $
% $Rev: 701 $


% initialise & user output
% -------------------------------------------------------------------------
sts = -1;
global settings;
if isempty(settings), scr_init; end;

try options.replace; catch options.replace = 0; end;
try options.cutoff; catch options.cutoff = 3; end;

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
elseif nargin < 3 || isempty(chan) || (chan == 0)
    chan = 'hb';
elseif ~isnumeric(chan)
    warning('Channel number must be numeric'); return;
end;

% get data
% -------------------------------------------------------------------------
[nsts, dinfos, data] = scr_load_data(fn, chan);
if nsts == -1, return; end;
if numel(data) > 1
    fprintf('There is more than one heart beat channel in the data file. Only the first of these will be analysed.');
    data = data(1);
end;

% interpolate
% -------------------------------------------------------------------------
hb  = data{1}.data;
ibi = diff(hb);
% replace periods if they are longer than options.cutoff
c = find(ibi > options.cutoff);
for i = 1:numel(c)
    if c(i) == 1
        ibi(c(i)) = ibi(c(i)+1);
    elseif c(i) == numel(ibi)
        ibi(c(i)) = ibi(c(i)-1);
    else
        ibi(c(i)) = mean([ibi(c(i)-1),ibi(c(i)+1)]);
    end;
end;
hp = 1000 * ibi; % in ms
newt = (1/sr):(1/sr):dinfos.duration;
newhp = interp1(hb(2:end), hp, newt, 'linear' ,'extrap'); % assign hr to following heart beat 


% save data
% -------------------------------------------------------------------------
newdata.data = newhp(:);
newdata.header.sr = sr;
newdata.header.units = 'ms';
newdata.header.chantype = 'hp';

if options.replace == 1
    action = 'replace';
else
    action = 'add';
end;
o.msg.prefix = 'Heart beat converted to heart period and';
[sts, winfos] = scr_write_channel(fn, newdata, action, o);
if nsts == -1, return; end;
infos.channel = winfos.channel;

sts = 1;
