function pspm(varargin)
% œ Description
%   pspm.m handles the main GUI for PsPM
% œ Last Updated in
%   PsPM 6.1
% œ History
%   Written in 13-09-2022 by Teddy Chao (UCL)

if verLessThan('matlab','9.4')
    pspm_guide
else
    pspm_appdesigner
end
return
