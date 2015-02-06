function sts = scr_resp2rr(fn, sr, chan, options)
% scr_resp2rr transforms continuous respiration data into an interpolated 
% respiration rate signal and adds this as an additional channel to the 
% data file (based on scr_resp2rp). Output is in cycle/min.
% 
% sts = scr_resp2rr(fn, sr, chan, options)
%       fn: data file name
%       sr: sample rate for respiration rate channel
%       chan: number of heart beat channel (optional, default: first heart
%             beat channel)
%       options: options.plot creates a diagnostic plot
%__________________________________________________________________________
% PsPM 3.0
% (C) 2008-2015 Dominik R Bach (Wellcome Trust Centre for Neuroimaging)

% $Id: scr_resp2rr.m 701 2015-01-22 14:36:13Z tmoser $
% $Rev: 701 $


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
newresp = medfilt1(newresp, 11);



% detect breathing cycles and interpolate
% 1) zero crossing
% 2) minimum IBI of 1 s
% -------------------------------------------------------------------------
respstamp = find(diff(sign(newresp)) == -2)/data{1}.header.sr;
ibi = diff(respstamp);
indx = find(ibi < 1);
ibi(indx) = [];
respstamp(indx + 1) = [];
newt = (1/sr):(1/sr):infos.duration;
newrr = interp1(respstamp(2:end), 60./ibi, newt, 'linear' ,'extrap'); % assign rp to following zero crossing


% save data
% -------------------------------------------------------------------------
msg = sprintf('Respiration converted to respiration rate in cycles/min and added to data on %s', date);

newdata.data = newrr(:);
newdata.header.sr = sr;
newdata.header.units = 'cpm';
newdata.header.chantype = 'rr';

nsts = scr_add_channel(fn, newdata, msg);
if nsts == -1, return; end;

% create diagnostic plot
% -------------------------------------------------------------------------
if options.plot
    figure('Position', [50, 50, 1000, 500]);
    axes; hold on;
    % normal breathing is 12-20 per minute, i. e. 3 - 5 s per breath. prd.
    % according to Schmidt/Thews, 10-18 per minute, i. e. 3-6 s per period
    % here we flag values outside 1-10 s breathing period
    stem(newt, 2 * (newrr > 60 | newrr < 6), 'Marker', 'none', 'Color', 'r', 'LineWidth', 4);
    plot(newt, resp(1:numel(newt)), 'k');
    plot(newt, newresp(1:numel(newt)), 'b');
    stem(respstamp, ones(size(respstamp)), 'Marker', 'o', 'Color', 'b');
end;



sts = 1;
