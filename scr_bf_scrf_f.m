function [ft, p, t] = scr_bf_scrf_f(td, p)
% SCR_bf_crf: canonical skin conductance response function 
% (exponentially modified gaussian, EMG)
% FORMAT: [bf p] = SCR_bf_scrf_f(td, p)
% with  td = time resolution in s
%       p(1): time to peak
%       p(2): variance of rise defining gaussian
%       P(3:4): decay constants
% 
% REFERENCE
% Bach DR, Flandin G, Friston KJ, Dolan RJ (2010). Modelling event-related skin 
% conductance responses. International Journal of Psychophysiology, 75, 349-356.
%__________________________________________________________________________
% PsPM 3.0
% (C) 2009-2015 Dominik R Bach (Wellcome Trust Centre for Neuroimaging)

% $Id: scr_bf_scrf_f.m 702 2015-01-22 15:06:14Z tmoser $   
% $Rev: 702 $

% initialise
% -------------------------------------------------------------------------
global settings;
if isempty(settings), scr_init; end;
% -------------------------------------------------------------------------

if nargin < 1
   errmsg='No sampling interval stated'; warning('ID:invalid_input', errmsg); return;
elseif nargin < 2
    p=[3.0745  0.7013 0.3176 0.0708];
end;

if td > 90
    warning('ID:invalid_input', 'Time resolution is larger than duration of the function.'); return;
elseif td == 0
    warning('ID:invalid_input', 'Time resolution must be larger than 0.'); return;
end;

t0 = p(1);
sigma = p(2);
lambda1 = p(3);
lambda2 = p(4);

t = (0:td:90-td)';

gt = exp(-((t - t0).^2)./(2.*sigma.^2));
ht = exp(-t*lambda1) + exp(-t*lambda2);

ft = conv(gt, ht);
ft = ft(1:numel(t));
ft = ft/max(ft);

