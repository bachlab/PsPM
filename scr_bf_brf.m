function [bs, x] = scr_bf_brf(varargin)
% SCR_brf constructs a blink response function
%
% FORMAT: [BS, X] = SCR_BF_BRF(TD, type) 
%     OR: [BS, X] = SCR_BF_BRF([TD, type]) 
% with td = time resolution in s 
% type: 1 - one Gaussian, 2 - one Gaussian with time derivative, 3 - two
% Gaussians
%
%________________________________________________________________________
% PsPM 3.0
% (C) 2008-2015 Saurabh Khemka & Dominik R Bach (UZH)

% $Id: scr_bf_brf.m 702 2015-01-22 15:06:14Z tmoser $   
% $Rev: 702 $

% initialise
global settings
if isempty(settings), scr_init; end;

% check input arguments
if nargin==0
    errmsg='No sampling interval stated'; warning('ID:invalid_input', errmsg); return;
end;

td = varargin{1}(1);
if numel(varargin{1}) == 1 && nargin == 1
    d = 1;
elseif numel(varargin{1}) == 2
    d = varargin{1}(2);
else
    d = varargin{2}(1);
end;
    
if td > 1
    warning('ID:invalid_input', 'Time resolution is larger than duration of the function.'); return;
elseif td == 0
    warning('ID:invalid_input', 'Time resolution must be larger than 0.'); return;    
end;

if (d<1)||(d>3), d=1; end;

x = (0:td:1-td)';

switch d
    case 1
        mu = 137.1 * 1e-3;
        sigma = 31.34 * 1e-3;
        bs = exp(-((x-mu)/sigma).^2);
    case 2
        mu = 137.1 * 1e-3;
        sigma = 31.34 * 1e-3;
        bs = exp(-((x-mu)/sigma).^2);
        bs(:, 2) = [0;diff(bs(:, 1))];
    case 3
        mu = [134.8, 180.4] * 1e-3;
        sigma = [26.15, 73.5] * 1e-3;
        a = 0.03071/0.1649;
        bs = exp(-((x-mu(1))/sigma(1)).^2) + a .* exp(-((x-mu(2))/sigma(2)).^2);
end;


% orthogonalize
if size(bs, 2) > 1
    bs=spm_orth(bs);
end;

% normalise
bs = bs./repmat((max(bs) - min(bs)), size(bs, 1), 1);

