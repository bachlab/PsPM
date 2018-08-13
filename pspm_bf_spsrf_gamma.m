function [bs, t] = pspm_bf_spsrf_gamma( td, cs_m, cs_p,soa)
% pspm_bf_spsrf_box basis 
% 
%   FORMAT: [bf p] = pspm_bf_spsrf_gamma(td, cs_m, cs_p,soa)
%           with  td = time resolution in s
%          
%________________________________________________________________________
% PsPM 4.0

% initialize
global settings
if isempty(settings), pspm_init; end;

% check input arguments
if nargin < 4
    warning('ID:invalid_input', 'Not enough input arguments for the basisfunktion'); return;
end;
% default value
stop = 10;
ydata = squeeze(nanmean(cs_p - cs_m,1));

% specify time course
t = linspace(0,numel(ydata)*td,numel(ydata)); 

ft = @(p) sum((ydata - p(1)*gampdf(t-p(2),p(3),p(4))).^2); % calculate RSS
[p, fval] = fminsearch(ft,[-0.007,0,4,0.5]);

% get coefficients from fminsearch
mycoeffs = p;
x = (0:td:(stop-td)); % check time duration of response function

bs = mycoeffs(1)*gampdf(x-(mycoeffs(2)-3.0)- soa,mycoeffs(3),mycoeffs(4));
end

