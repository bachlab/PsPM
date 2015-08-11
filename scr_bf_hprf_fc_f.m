function [fx, p] = scr_bf_hprf_fc_f(td, p)
% SCR_bf_hprf_fc_f: canonical skin conductance response function 
% (exponentially modified gaussian, EMG)
% FORMAT: [bf p] = SCR_bf_hprf_fc_f(td, p)
% with  td = time resolution in s
%       p(1):
%       p(2):
%       p(3):
%       p(4):
% 
% REFERENCE
%
%__________________________________________________________________________
% PsPM 3.0
% (C) 2009-2015 Dominik R Bach (Wellcome Trust Centre for Neuroimaging)

% $Id$   
% $Rev$

% initialise
% -------------------------------------------------------------------------
global settings;
if isempty(settings), scr_init; end;
% -------------------------------------------------------------------------

if nargin < 1
   errmsg='No sampling interval stated'; warning(errmsg); return;
elseif nargin < 2
    p=[82.8 2.56e5 0.00226 -574];
end;

x0 = p(4);
b = p(3);
a = p(2);
A = p(1);
gamma_a = gamma(a);

x = (td:td:90)';

fx = ((A/((b.^a).*gamma_a)).*((x-x0).^(a-1))).*exp((-x-x0)/b);

%fx = ft(1:numel(x));
%fx = ft/max(fx);
