function pspm(varargin)
% â—? Description
%   pspm.m handles the main GUI for PsPM
% â—? Last Updated in
%   PsPM 6.1
% â—? History
%   Written in 13-09-2022 by Teddy Chao (UCL)

if verLessThan('matlab','9.4')
    pspm_guide
else
    pspm_appdesigner
end
return
