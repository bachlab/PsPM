function [fx, x, p] = scr_bf_hprf_fc_f(td, soa, p)
% SCR_bf_hprf_fc_f
% Description: 
%
% FORMAT: [bf p] = SCR_bf_hprf_fc_f(td, soa, p)
% with  td = time resolution in s
%       p(1): a
%       p(2): b
%       p(3): x0
%       p(4): A
% 
% REFERENCE
%
%__________________________________________________________________________
% PsPM 3.0
% (C) 2015 Tobias Moser (University of Zurich)

% $Id$   
% $Rev$

% initialise
% -------------------------------------------------------------------------
global settings;
if isempty(settings), scr_init; end;
% -------------------------------------------------------------------------

if nargin < 1
   errmsg='No sampling interval stated'; warning('ID:invalid_input',errmsg); return;
end;

if nargin < 2
    soa = 3.5;
end;

if nargin < 3
    % former parameters [256389.754969900,0.00225906399760227,-574.596030378357,82.7785576729272]
    p=[43.2180170215633,0.195621916215104,-6.9671,81.0383536117737];
end;

x0 = p(3);
b = p(2);
a = p(1);
A = p(4);

shift = soa + x0;
d = 10;

start = 0;
stop = d + soa;


if td > (stop-start)
    warning('ID:invalid_input', 'Time resolution is larger than duration of the function.'); return;
elseif td == 0
    warning('ID:invalid_input', 'Time resolution must be larger than 0.'); return;
elseif soa < 2
    warning(['The SOA is smaller than 2 but the response function has only been ', ...
        'tested with SOA 3.5, 4 and 6. With SOA < 2 you use it at your own risk. ', ...
        'For further information see Castegnetti et al. (2016).']);
end;

x = (start:td:stop-td)';

% try not to use stats toolbox, but stats toolbox has very good
% approximations
%
fx = A * gampdf(x - shift, a, b);

%fx = A * exp(log(x-shift).*(a-1) - gl - (x-shift)./b - log(b)*a);



