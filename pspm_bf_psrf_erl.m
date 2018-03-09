function [bs, x] = pspm_bf_psrf_erl(varargin)
% pspm_bf_psrf_erl
% Description: 
% Erlang response function to pupil size changes
%
% FORMAT: [bs, x] = PSPM_BF_PSRF_ERL(TD, n, tmax)
%         [bs, x] = PSPM_BF_PSRF_ERL([TD, n, tmax])
% 
% ARGUMENTS:
%   td:         Time resolution
%   n:          number of layers / boxes
%   tmax:       t of the maximum amplitude in seconds
%
% REFERENCE
% Hoeks, B., & Levelt, W.J.M. (1993). 
% Pupillary Dilation as a Measure of Attention - a Quantitative System-Analysis. 
% Behavior Research Methods Instruments & Computers, 25, 16-26.
%________________________________________________________________________
% PsPM 3.1
% (C) 2018 Tobias Moser (University of Zurich)

% $Id: pspm_bf_psrf_fc.m 403 2017-01-06 09:33:44Z tmoser $   
% $Rev: 403 $


% initialise
global settings
if isempty(settings), pspm_init; end

% check input arguments
if nargin==0
    errmsg='No sampling interval stated'; warning('ID:invalid_input', errmsg); 
    return;
end

% default values
duration = 20;
n = 10.1;
tmax = 0.93;

% set parameters
td = varargin{1}(1);
if nargin > 1 
    if nargin > 2
        tmax = varargin{3};
    end
    n = varargin{2};
elseif numel(varargin{1}) > 1
    narg = numel(varargin{1});
    
    if narg > 2
        tmax = varargin{1}(3);
    end
    n = varargin{1}(2);
end

if td > duration
    warning('ID:invalid_input', 'Time resolution is larger than duration of the function.'); return;
elseif td == 0
    warning('ID:invalid_input', 'Time resolution must be larger than 0.'); return;
end

x = (0:td:duration-td)';
bs = zeros(numel(x), 1);
bs(:,1) = x.^n.*exp(-n.*x/tmax);

% orthogonalise
bs(:,1) = spm_orth(bs(:,1));

% normalise
bs = bs./repmat((max(bs) - min(bs)), size(bs, 1), 1);
