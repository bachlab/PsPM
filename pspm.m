function pspm(varargin)
% ● Description
%   pspm.m handles the main GUI for PsPM
% ● Last Updated in
%   PsPM 6.1
% ● History
%   Written in 13-09-2022 by Teddy Chao (UCL)

if verLessThan('matlab','9.4')
    pspm_guide
else
    pspm_appdesigner
end
return
