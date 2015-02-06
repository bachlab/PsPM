function [bf,p] = scr_bf_hprf(td,p)
% SCR_bf_hprf: heart period response function
% (scaled gamma functions)
% FORMAT: [bf p] = SCR_bf_hprf(td, p)
% with  td = time resolution in s
%       p = '3' vs '4' basis function solution 
% REFERENCE
%
%__________________________________________________________________________
% PsPM 3.0
% (C) 2008-2015 Dominik R Bach (Wellcome Trust Centre for Neuroimaging)

% $Id: scr_bf_hprf.m 701 2015-01-22 14:36:13Z tmoser $
% $Rev: 701 $

% initialise
% -------------------------------------------------------------------------
global settings;
if isempty(settings), scr_init; end;
% -------------------------------------------------------------------------

if nargin < 1
   errmsg='No sampling interval stated'; warning(errmsg); return;
elseif nargin < 2
    p=3;
end;

if p==4
    idx=1:4;
else idx=[1 3:4];
end

x = (0:td:29);

s(1,:)=[3.1 13.4 6 5.8];         
s(2,:)=[.27 .73 .96 3.8]; 
s(3,:)=[.0075 -2.4 8.7 4.9];

s=s(:,idx);

for k=1:length(idx)
    bf(k,:) =gampdf(x - s(3,k), s(1,k), s(2,k));
end