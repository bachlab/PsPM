function [bs, t] = pspm_bf_spsrf_gamma( td,soa,p)
% pspm_bf_spsrf_box basis 
% 
%   FORMAT: [bf p] = pspm_bf_spsrf_gamma(td, soa,p)
%           with  td = time resolution in s
%                 p(1) = A
%                 p(2) = x0
%                 p(3) = a
%                 p(4) = b
%          
%________________________________________________________________________
% PsPM 4.0

% initialize
global settings
if isempty(settings), pspm_init; end;


%check input arguments
if nargin < 1
   errmsg='No sampling interval stated'; warning('ID:invalid_input',errmsg); return;
end;

if nargin < 2
    soa = 3.5;
end;

if nargin < 3
    p=[-0.007,0,4,0.5];
end;


A  = p(1);
x0 = p(2);
a  = p(3);
b  = p(4);

% default value
d     = 10;
start = 0;
stop  = d + soa;

if td > (stop-start)
    warning('ID:invalid_input', 'Time resolution is larger than duration of the function.'); return;
elseif td == 0
    warning('ID:invalid_input', 'Time resolution must be larger than 0.'); return;
elseif soa < 2
    soa = 2;
    stop = d + soa;
    warning('Changing SOA to 2s to avoid implausible values (<2s).');
elseif soa > 8
    warning(['SOA longer than 8s is not recommended. ', ...
        'Use at own risk.']);
end;

shift = soa + x0;

t = (start:td:stop-td)';
bs = A * gampdf(t - shift, a, b);
end

