function [bs, x] = scr_bf_hprf_fc(varargin)
% SCR_bf_hprf_fc  
% Description: 
%
% FORMAT: [INFBS] = SCR_BF_HPRF_FC(TD, D) 
%     OR: [INFBS] = SCR_BF_HPRF_FC([TD, D]) 
% with td = time resolution in s and d:number of derivatives (default 0)
%
% REFERENCE
%
%________________________________________________________________________
% PsPM 3.0
% (C) 2015 Tobias Moser (University of Zurich)

% $Id$   
% $Rev$

% initialise
global settings
if isempty(settings), scr_init; end;

% check input arguments
if nargin==0
    errmsg='No sampling interval stated'; warning(errmsg); return;
end;

td = varargin{1}(1);
if numel(varargin{1}) == 1 && nargin == 1
    d = 0;
elseif numel(varargin{1}) == 2
    d = varargin{1}(2);
else
    d = varargin{2}(1);
end;
    
if (d<0)||(d>1), d=0; end;

% get parameters and basis function
[bs(:, 1), x, p] = scr_bf_hprf_fc_f(td);
if d>0
    bs(:, 2) = [0; diff(bs(:,1))]; 
    bs(:, 2) = bs(:,2)/sum(abs(bs(:,2)));
end;

% orthogonalise
bs = spm_orth(bs);