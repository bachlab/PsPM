function [gx,dgdx,dgdPhi] = g_aSCR(Xt,Phi,ut,inG)
% ● Description
%   TBA.
% ● Version
%   PsPM 3.0
% ● Written By
%   (C) 2008-2015 Dominik R Bach (Wellcome Trust Centre for Neuroimaging)

% initialise
% -------------------------------------------------------------------------
global settings;
if isempty(settings), pspm_init; end;

gx = Xt(1) + Xt(4) + Xt(7);

dgdx = zeros(size(Xt,1),1);
dgdx([1;4;7]) = 1;
dgdPhi = [];

if any(isnan(gx)|isinf(gx)), keyboard; end;
if any(isnan(dgdx)|isinf(dgdx)), keyboard; end;


