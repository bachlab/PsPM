function [sts, output] = pspm_emg_pp(fn, options)
% pspm_emg_pp contains various preprocessing utilities for reducing noise in 
% the emg data
% 
%   FORMAT:
%       fn:                 [string] Path to the PsPM file which contains 
%                           the EMG data
%       options.
%           mains_freq:     [integer] Frequency of mains noise to remove 
%                           with notch filter (default: 50Hz).
%
%           channel:        [(cell of) numeric/string] Channels to be preprocessed.
%                           Can be a channel id or a channel name. Either a
%                           single value or a one dimensional cell array 
%                           with multiple values.
%                           Default is 'emg'.
%
%           output_file:    [string] File where the preprocessed data should be
%                           stored. Default is input file.
%
%           channel_action: ['add'/'replace'] Defines whether data should be added ('add') or
%                           last existing channel should be replaced ('replace').
%                           Default is 'replace'.
%
%           overwrite:      [logical] Defines whether existing files should
%                           be overwritten or not. Default is false.
%__________________________________________________________________________
% PsPM 3.1
% (C) 2009-2016 Tobias Moser (University of Zurich)

% $Id$   
% $Rev$

% initialise
% -------------------------------------------------------------------------
global settings;
if isempty(settings), pspm_init; end;
output = struct();

% set default values
% -------------------------------------------------------------------------
if nargin < 2
    options = struct();
end;

if ~isfield(options, 'mains_freq')
    options.mains_freq = 50;
end;

if ~isfield(options, 'channel') 
    options.channel = 'emg';
end;

if ~isfield(options, 'output_file')
    options.output_file = fn;
end;

if ~isfield(options, 'channel_action')
    options.channel_action = 'replace';
end;

if ~isfield(options, 'overwrite')
    options.overwrite = 0;
end;

if ~isfield(options, 'dont_ask_overwrite')
    options.overwrite = 0;
end;

% check values
% -------------------------------------------------------------------------
if ~isnumeric(options.mains_freq)
    warning('ID:invalid_input', 'Option mains_freq must be numeric.');
    return;
elseif ~ischar(options.output_file) 
    warning('ID:invalid_input', 'Option output_file must be a string.');
    return;
elseif ~ismember(options.channel_action, {'add', 'replace'})
    warning('ID:invalid_input', 'Option channel_action must be either ''add'' or ''repalce''');
    return;
elseif ~islogical(options.overwrite) && ~isnumeric(options.overwrite)
    warning('ID:invalid_input', 'Option overwrite must be logical or numeric');
    return;
elseif (~isnumeric(options.channel) && ~ischar(options.channel))  ...
    || (iscell(options.channel) && any(cellfun(@(x) ~isnumeric(x) && ~ischar(x))))
    warning('ID:invalid_input', '');
end;

% load data
% -------------------------------------------------------------------------
[sts, infos, data] = pspm_load_data(fn, 0);
if sts ~= 1, return, end;

% determine channel numbers
% -------------------------------------------------------------------------
work_chans = options.channels;

if ~iscell(work_chans)
    work_chans = {work_chans};
end;

str_chans = find(cellfun(@(x) ischar(x), work_chans));
chan_names = cellfun(@(x) x.header.chantype, 'UniformOutput', 0);

for i = 1:numel(str_chans)
    work_chans{i} = find(strcmpi(work_chans{i}, chan_names), 1, 'first');
end;
% do the job
% -------------------------------------------------------------------------
ndata = cell(numel(work_chans), 1);
for k = 1:numel(work_chans)
    ndata{k} = data{work_chans{k}};
    % (1) 4th order Butterworth band-pass filter with cutoff frequency of 28 Hz and 250 Hz
    filt.sr =ndata{k}.header.sr;
    filt.lpfreq = 250;
    filt.lporder = 4;
    filt.hpfreq = 28;
    filt.hporder = 4;
    filt.down = 'none';
    filt.direction = 'uni';
    
    [sts, ndata{k}.data, ndata{k}.header.sr] = pspm_prepdata(ndata{k}.data, filt);
    if sts == -1, return; end;
    
    % (2) remove mains noise with notch filter
    % design from 
    % http://dsp.stackexchange.com/questions/1088/filtering-50hz-using-a-
    % notch-filter-in-matlab
    nfr = filt.sr/2;                         % Nyquist frequency
    freqRatio = options.mains_freq/nfr;      % ratio of notch freq. to Nyquist freq.
    nWidth = 0.1;                            % width of the notch filter
    % Compute zeros
    nZeros = [exp( sqrt(-1)*pi*freqRatio ), exp( -sqrt(-1)*pi*freqRatio )];
    % Compute poles
    nPoles = (1-nWidth) * nZeros;    
    b = poly( nZeros ); % Get moving average filter coefficients
    a = poly( nPoles ); % Get autoregressive filter coefficients
    
    % filter signal x
    ndata{k}.data = filter(b,a,ndata{k}.data);

    % (3)  rectified and smoothed 4th order Butterworth low-pass filter with 
    % a time constant of 3 ms corresponding to a cutoff frequency of 53.05 Hz
    filt.sr = ndata{k}.header.sr;
    filt.lpfreq = 53.05;
    filt.lporder = 4;
    filt.hpfreq = 'none';
    filt.hporder = 0;
    filt.down = 'none';
    filt.direction = 'uni';
    [sts, ndata{k}.data, ndata{k}.header.sr] = pspm_prepdata(ndata{k}.data, filt);
    if sts == -1, return; end;
end;

% save data
% -------------------------------------------------------------------------

out_data.data = data;
out_data.infos = infos;

infos.ppdat = date;
infos.ppfile = options.output_file;

for k = 1:numel(ndata)
    if strcmpi(options.channel_action, 'replace')
        out_data.data{work_chans{k}} = ndata{k};
    elseif strcmpi(options.channel_action, 'add')
        out_data.data{end+1} = ndata{k};
    end;
end;


if exist(options.output_file, 'file')
    write_ok = false;
    if options.overwrite
        write_ok = true;
    elseif ~options.dont_ask_overwrite
        button = questdlg(sprintf('File (%s) already exists. Overwrite?', out_file), ...
            'Overwrite existing file?', 'Yes', 'No', 'No');
        write_ok = strcmpi(button, 'Yes');
    end;
else
    write_ok = true;
end;
    
if write_ok
    [sts] = pspm_load_data(options.output_file, out_data);
    if sts == -1, return; end;
end;

end