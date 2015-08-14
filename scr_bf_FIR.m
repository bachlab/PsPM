function [FIR, x] = scr_bf_FIR(varargin)

% SCR_BF_FIR provides a pre-defined finite impulse response (FIR) model for
% skin conductance responses with n (default 30) post-stimulus timebins of 1 second
% each
%
% FORMAT:
    % FIR=SCR_BF_FIR(TD, N) OR FIR=SCR_BF_FIR([TD, N]) OR 
    % FIR=SCR_BF_FIR([TD, N, D]) with 
%   TD: sampling interval in seconds 
%   N: number of timepoints (default: 30)
%   D: duration of bin in seconds (default: 1 s)
% 
%_________________________________________________________________________
% PsPM 3.0
% (C) 2008-2015 Dominik R Bach (Wellcome Trust Centre for Neuroimaging)

% $Id: scr_bf_FIR.m 702 2015-01-22 15:06:14Z tmoser $   
% $Rev: 702 $

% check input arguments
if nargin==0
    errmsg='No sampling interval stated'; warning(errmsg); return;
end;

td = varargin{1}(1);
if numel(varargin{1}) == 1 && nargin == 1
    n = 30;
elseif numel(varargin{1}) >= 2
    n = varargin{1}(2);
else
    n = varargin{2}(1);
end;

if nargin == 1 && numel(varargin{1}) < 3
    d = 1;
else
    d = varargin{1}(3);
end;
    

% initialise FIR
FIR=[zeros(1, n); zeros(round((d*n)/td), n);];

% generate timestamps
x = (0:td:n)';

% set FIR columns
starts=1;
for reg=1:n
    stops=(d*reg)/td;
    FIR(starts:stops, reg)=1;
    starts=stops+1;
end;

return;


