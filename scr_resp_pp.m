function sts = scr_resp_pp(fn, sr, chan, options)
% scr_resp_pp preprocesses raw respiration traces. The function detects 
% respiration cycles for bellows and cushion systems, computes respiration
% period, amplitude and RLL, assigns these measures to the start of each
% cycle and linearly interpolates these (expect rs = respiration time 
% stamps). Results are written to new channels in the same file
% 
% sts = scr_resp_pp(fn, sr, chan, options)
%       fn: data file name
%       sr: sample rate for new interpolated channel
%       chan: number of respiration channel (optional, default: first
%       respiration channel)
%       options: .systemtype - 'bellows' (default) or 'cushion'
%                .datatype - a cell array with any of 'rp', 'ra', 'RLL',
%                'rs', 'all' (default)
%                .plot - 1 creates a respiratory cycle detection plot
%                .diagnostics - 1 creates an interpolation diagnostics
%                plot
%__________________________________________________________________________
% PsPM 3.0
% (C) 2015 Dominik R Bach (Wellcome Trust Centre for Neuroimaging)

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

try options.systemtype; catch, options.systemtype = 'bellows'; end;
try options.datatype; catch, options.datatype = {'rp', 'amp', 'RLL'}; end;
try options.plot; catch, options.plot = 0; end;
try options.diagnostics; catch, options.diagnostics = 0; end;

if ~ischar(options.systemtype) || sum(strcmpi(options.systemtype, {'bellows', 'cushion'})) == 0
    warning('Unknown system type.'); return;
elseif ~iscell(options.datatype) 
    warning('Unknown data type.'); return;
else 
    datatypes = {'rp', 'ra', 'RLL', 'rs', 'all'};
    datatype = zeros(4, 1);
    for k = 1:numel(options.datatype)
        datatype(strcmpi(options.datatype{k}, datatypes)) = 1;
    end;
    if datatype(end), datatype(1:end) = 1; end;
end;

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

% Butterworth filter
filt.sr        = data{1}.header.sr;
filt.lpfreq    = 0.6;
filt.lporder   = 1;
filt.hpfreq    = .01;
filt.hporder   = 1;
filt.direction = 'bi';
filt.down      = 'none';
[sts, newresp] = scr_prepdata(resp - mean(resp), filt);

% Median filter
newresp = medfilt1(newresp, ceil(filt.sr) + 1);

% detect breathing cycles 
% -------------------------------------------------------------------------
if strcmpi(options.systemtype, 'bellows')
    % find pos/neg zero crossings
    respstamp = find(diff(sign(newresp)) == -2)/data{1}.header.sr;
elseif strcmpi(options.systemtype, 'cushion')
    % find neg/pos zero crossings of first derivative
    diffresp = diff(newresp);
    foo = diff(sign(diffresp));
    % find direct zero crossings
    zero1 = find(foo == 2);   
    % find zero crossings that stay at zero for a while
    indx = find(foo ~= 0);
    pairs = find(conv(foo(indx), [1 1]) == 2);
    zero2 = ceil(mean([indx(pairs - 1), indx(pairs)], 2));
    % combine while accouting for differentiating twice
    respstamp = sort([zero1;zero2] + 1)/data{1}.header.sr;
end;

% exclude < 1 s IBIs 
% -------------------------------------------------------------------------
ibi = diff(respstamp);
indx = find(ibi < 1);
respstamp(indx + 1) = [];

% compute data values, interpolate and write
% -------------------------------------------------------------------------
for iType = 1:(numel(datatypes) - 1)
    if datatype(iType)
        clear newdata
        % compute new data values
        switch iType
            case 1
                respdata = diff(respstamp);
                msg = sprintf('Respiration converted to respiration period and added to data on %s', date);
                newdata.header.chantype = 'rp';
                newdata.header.units = 's';
            case 2
                for k = 1:(numel(respstamp) - 1)
                    win = ceil(respstamp(k) * data{1}.header.sr):ceil(respstamp(k + 1) * data{1}.header.sr);
                    respdata(k) = range(resp(win));
                end;
                msg = sprintf('Respiration converted to respiration amplitude and added to data on %s', date);
                newdata.header.chantype = 'ra';
                newdata.header.units = 'unknown';
            case 3
                ibi = diff(respstamp);
                for k = 1:(numel(respstamp) - 1)
                    win = ceil(respstamp(k) * data{1}.header.sr):ceil(respstamp(k + 1) * data{1}.header.sr);
                    respdata(k) = sum(abs(diff(resp(win))))/ibi(k);
                end;
                msg = sprintf('Respiration converted to RLL and added to data on %s', date);
                newdata.header.chantype = 'RLL';
                newdata.header.units = 'unknown';
            case 4
                msg = sprintf('Respiration converted to respiration time stamps and added to data on %s', date);
                newdata.header.chantype = 'rs';
                newdata.header.units = 'events';
        end;
        % interpolate
        switch iType
            case {1, 2, 3}
                newt = (1/sr):(1/sr):infos.duration;
                writedata = interp1(respstamp(2:end), respdata, newt, 'linear' ,'extrap'); % assign rp to following zero crossing
                newdata.header.sr = sr;
            case {4}
                writedata = respstamp;
                newdata.header.sr = 1;
        end;
        % write
        newdata.data = writedata(:);
        nsts = scr_add_channel(fn, newdata, msg);
        if nsts == -1, return; end;
    end;
end;

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
