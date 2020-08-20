function newdatafile = pspm_pp(varargin)
% pspm_pp contains various preprocessing utilities for reducing noise in the
% data. 
%
% INPUT:
%   pspm_pp('median', datafile, n, channelnumber, options)
%   pspm_pp('butter', datafile, freq, channelnumber, options)
%   pspm_pp('simple_qa', datafile, qa, channelnumber, options)
%
% Currently implemented: 
%   'median':                           medianfilter for SCR
%       n:                              number of timepoints for median filter
%   'butter':                           1st order butterworth low pass filter for SCR
%       freq:                           cut off frequency (min 20 Hz)
%   'simple_qa':                        Simple quality assessment for SCR
%       qa:                             A struct with quality assessment settings
%           min:                        Minimum value in microsiemens
%           max:                        Maximum value in microsiemens
%           slope:                      Maximum slope in microsiemens per second
%           missing_epochs_filename:    If provided will create a .mat file with the missing epochs,
%                                       e.g. abc will create abc.mat
%           deflection_threshold:       Define an threshold in original data units for a slope to pass to be considerd in the filter.
%                                       This is useful, for example, with oscillatory wave data
%                                       The slope may be steep due to a jump between voltages but we
%                                       likely do not want to consider this to be filtered.
%                                       A value of 0.1 would filter oscillatory behaviour with threshold less than 0.1v but not greater
%                                       Default: 0 - ie will take no effect on filter
%__________________________________________________________________________
%
% References: For 'simple_qa' method, refer to:
%
% I. R. Kleckner et al., "Simple, Transparent, and Flexible Automated Quality
% Assessment Procedures for Ambulatory Electrodermal Activity Data," in IEEE
% Transactions on Biomedical Engineering, vol. 65, no. 7, pp. 1460-1467,
% July 2018.
%__________________________________________________________________________
% PsPM 3.0
% (C) 2009-2015 Dominik R Bach (Wellcome Trust Centre for Neuroimaging)

% $Id$   
% $Rev$

% initialise
% -------------------------------------------------------------------------
global settings;
if isempty(settings), pspm_init; end
newdatafile = [];

% check input arguments
% -------------------------------------------------------------------------
if nargin < 1
    warning('ID:invalid_input', 'No input arguments. Don''t know what to do.');
elseif nargin < 2
    warning('ID:invalid_input', 'No datafile.'); return;
end
method = varargin{1};
supported_methods = {'median', 'butter', 'simple_qa'};
if ~any(strcmp(method, supported_methods))
    methods_str = sprintf('%s ', supported_methods{:});
    warning('ID:invalid_input', sprintf('Preprocessing method must be one of %s', methods_str)); return;
end
if nargin < 3
    if strcmp(method, 'median') || strcmp(method, 'butter')
        warning('ID:invalid_input', 'Missing filter specs.'); return;
    end
end

fn = varargin{2};

if nargin >=5 && isstruct(varargin{5}) && isfield(varargin{5}, 'overwrite')
    options = varargin{5};
else
    options.overwrite = 0;
end

% load data
% -------------------------------------------------------------------------
[sts, infos, data] = pspm_load_data(fn, 0);
if sts ~= 1,
    warning('ID:invalid_input', 'call of pspm_load_data failed');
    return;
end

% determine channel number
% -------------------------------------------------------------------------
if nargin >= 4 && ~isempty(varargin{4}) && ...
        (~isequal(size(varargin{4}), [1,1]) || varargin{4} ~= 0)
    channum = varargin{4};
else
    for k = 1:numel(data)
        if strcmp(data{k}.header.chantype, 'scr')
            channum(k) = 1;
        end
    end
    channum = find(channum == 1);
end

% do the job
% -------------------------------------------------------------------------
switch method
    case 'median'
        n = varargin{3};
        % user output
        fprintf('Preprocess: median filtering datafile %s ...', fn);
        for k = 1:numel(channum)
            curr_chan = channum(k);
            data{curr_chan}.data = medfilt1(data{curr_chan}.data, n);
        end
        infos.pp = sprintf('median filter over %1.0f timepoints', n);
    case 'butter'
        freq = varargin{3};
        if freq < 20, warning('ID:invalid_freq', 'Cut off frequency must be at least 20 Hz'); return; end;
        % user output
        fprintf('Preprocess: butterworth filtering datafile %s ...', fn);
        for k = 1:numel(channum)
            curr_chan = channum(k);
            filt.sr = data{curr_chan}.header.sr;
            filt.lpfreq = freq;
            filt.lporder = 1;
            filt.hpfreq = 'none';
            filt.hporder = 0;
            filt.down = 'none';
            filt.direction = 'bi';
            [sts, data{curr_chan}.data, data{curr_chan}.header.sr] = pspm_prepdata(data{curr_chan}.data, filt);
            if sts == -1
                warning('ID:invalid_input', 'call of pspm_prepdata failed');
                return;
            end
        end
        infos.pp = sprintf('butterworth 1st order low pass filter at cutoff frequency %2.2f Hz', freq);
    case 'simple_qa'
        if nargin < 3
            qa = struct();
        else
            qa = varargin{3};
        end
        for k = 1:numel(channum)
            curr_chan = channum(k);
            [sts, data{curr_chan}.data] = pspm_simple_qa(data{curr_chan}.data, data{curr_chan}.header.sr, qa);
            if sts == -1
                warning('ID:invalid_input', 'call of pspm_simple_qa failed in round %s',k);
                return;
            end
        end
        infos.pp = sprintf('simple scr quality assessment');
    otherwise
        warning('ID:invalid_input', 'Unknown filter option ...');
        return;
end

[pth, fn, ext] = fileparts(fn);
newdatafile = fullfile(pth, ['m', fn, ext]);
infos.ppdate = date;
infos.ppfile = newdatafile;
clear savedata
savedata.data = data; savedata.infos = infos; 
savedata.options = options;
sts = pspm_load_data(newdatafile, savedata);
fprintf(' done\n');

return;

