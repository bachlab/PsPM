function [bf, x ,p] = pspm_bf_hprf(td,p)
% ● Description
%   pspm_bf_hprf is the heart period response function (scaled gamma functions).
% ● Format
%   [bf, x, p] = pspm_bf_hprf(td, p)
% ● Arguments
%   td: time resolution in s
%    p: '3' vs '4' basis function solution
% ● References
% ● History
%   Introduced in PsPM 3.0
%   Written in 2008-2015 by Dominik R Bach (Wellcome Trust Centre for Neuroimaging)
%   Maintained in 2022 by Teddy Chao (UCL)

%% initialise
global settings;
if isempty(settings), pspm_init; end

if nargin < 1
  errmsg = 'No sampling interval stated'; warning('ID:invalid_input',errmsg); return;
elseif nargin < 2
  p = 3;
end
if td > 29
  warning('ID:invalid_input', 'Time resolution is larger than duration of the function.'); return;
elseif td == 0
  warning('ID:invalid_input', 'Time resolution must be larger than 0.'); return;
end
if p == 4
  idx = 1:4;
else
		idx = [1 3:4];
end
x = (0:td:29-td);
s(1,:) = [3.1 13.4 6 5.8];
s(2,:) = [.27 .73 .96 3.8];
s(3,:) = [.0075 -2.4 8.7 4.9];
s = s(:,idx);
for k = 1:length(idx)
  bf(:,k) = gampdf(x - s(3,k), s(1,k), s(2,k));
end
% orthogonalise
bf = spm_orth(bf);
% normalise
bf = bf./repmat((max(bf) - min(bf)), size(bf, 1), 1);
x = x';
return
