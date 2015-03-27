function sts = scr_resp2rp(fn, sr, chan, options)
% scr_resp2rp transforms continuous respiration data into an interpolated 
% respiration period signal and adds this as an additional channel to the 
% data file
% 
% sts = scr_resp2rp(fn, sr, chan, options)
%       fn: data file name
%       sr: sample rate for respiration rate channel
%       chan: number of heart beat channel (optional, default: first heart
%             beat channel)
%       options: options.plot creates a respiratory cycle detection plot
%                options.diagnostics creates an interpolation diagnostics
%                plot
%__________________________________________________________________________
% PsPM 3.0
% (C) 2008-2015 Dominik R Bach (Wellcome Trust Centre for Neuroimaging)

% $Id: scr_resp2rp.m 711 2015-02-04 11:01:18Z dominik_bach $
% $Rev: 711 $


% initialise & user output
% -------------------------------------------------------------------------
sts = -1;
global settings;
if isempty(settings), scr_init; end;

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
elseif nargin < 3 || isempty(chan)
    chan = 'resp';
elseif ~isnumeric(chan)
    warning('Channel number must be numeric'); return;
end;

try options.plot; catch, options.plot = 0; end;
try options.diagnostics; catch, options.diagnostics = 0; end;

% get data
% -------------------------------------------------------------------------
[nsts, infos, data] = scr_load_data(fn, chan);
if nsts == -1, return; end;
if numel(data) > 1
    fprintf('There is more than one respiration channel in the data file. Only the first of these will be analysed.');
    data = data(1);
end;
resp = data{1}.data;

% filter mean-centred data
% -------------------------------------------------------------------------
filt.sr        = data{1}.header.sr;
filt.lpfreq    = 0.6;
filt.lporder   = 1;
filt.hpfreq    = .01;
filt.hporder   = 1;
filt.direction = 'bi';
filt.down      = 'none';
[sts, newresp] = scr_prepdata(resp - mean(resp), filt);

% median filter
newresp = medfilt1(newresp, ceil(filt.sr) + 1);



% detect breathing cycles and interpolate
% 1) zero crossing
% 2) minimum IBI of 1 s
% -------------------------------------------------------------------------
respstamp = find(diff(sign(newresp)) == -2)/data{1}.header.sr;
ibi = diff(respstamp);
indx = find(ibi < 1);
respstamp(indx + 1) = [];
ibi = diff(respstamp);
newt = (1/sr):(1/sr):infos.duration;
newrp = interp1(respstamp(2:end), ibi, newt, 'linear' ,'extrap'); % assign rp to following zero crossing


% save data
% -------------------------------------------------------------------------
msg = sprintf('Respiration converted to respiration period and added to data on %s', date);

newdata.data = newrp(:);
newdata.header.sr = sr;
newdata.header.units = 's';
newdata.header.chantype = 'rp';

nsts = scr_add_channel(fn, newdata, msg);
if nsts == -1, return; end;

% create diagnostic plot for detection/interpolation
% -------------------------------------------------------------------------
if options.plot
    figure('Position', [50, 50, 1000, 500]);
    axes; hold on;
    % normal breathing is 12-20 per minute, i. e. 3 - 5 s per breath. prd.
    % according to Schmidt/Thews, 10-18 per minute, i. e. 3-6 s per period
    % here we flag values outside 1-10 s breathing period
    stem(newt, 2 * (newrp < 1 | newrp > 9), 'Marker', 'none', 'Color', 'r', 'LineWidth', 4);
    plot(newt, resp(1:numel(newt)), 'k');
    plot(newt, newresp(1:numel(newt)), 'b');
    stem(respstamp, ones(size(respstamp)), 'Marker', 'o', 'Color', 'b');
elseif options.diagnostics
    figure('Position', [50, 50, 1000, 500]);
    axes; hold on;
    plot(newt, newrp, 'b');
    stem(respstamp, ones(size(respstamp)), 'Marker', 'o', 'Color', 'b');
end;



sts = 1;
