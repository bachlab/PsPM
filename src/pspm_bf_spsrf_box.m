function [bs, x] = pspm_bf_spsrf_box( td, soa )
% pspm_bf_spsrf_box basis function dependent on SOA 

% FORMAT: [bf p] = pspm_bf_spsrf_box(td, soa)
%         with  td: time resolution in s
%
%________________________________________________________________________
% PsPM 4.0

% initialize
global settings
if isempty(settings), pspm_init; end;

% check input arguments
if nargin < 1
   errmsg='No sampling interval stated'; warning('ID:invalid_input',errmsg); return;
end;

if nargin < 2
    soa = 3.5;
end;


%create boder of interval
stop = soa;
start = soa-2;
start_idx = floor(start/td);
if start_idx ==0
    start_idx = start_idx+1;
end 
stop_idx = floor(stop/td); 

if td > (stop-start)
    warning('ID:invalid_input', 'Time resolution is larger than duration of the function.'); return;
elseif td == 0
    warning('ID:invalid_input', 'Time resolution must be larger than 0.'); return;
elseif soa < 2
    soa = 2;
    stop = soa;
    start = soa-2;
    warning('Changing SOA to 2s to avoid implausible values (<2s).');
elseif soa > 8
    warning(['SOA longer than 8s is not recommended. ', ...
        'Use at own risk.']);
end;

x = (0:td:stop-td)';
bs = zeros(stop_idx,1);
bs(start_idx:stop_idx) = 1;

end

