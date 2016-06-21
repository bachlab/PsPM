function [bs, x] = scr_bf_rarf_e(varargin)
% SCR_BF_RARF_E
% Description: 
%
% FORMAT: [bs, x] = SCR_BF_RARF_E(td)
%       [bs, x] = SCR_BF_RARF_E(td)
%
% ARGUMENTS:
%           td:         The time the response function should have.   
%
% REFERENCE
% 
%________________________________________________________________________
% PsPM 3.1
% (C) 2016 Tobias Moser (University of Zurich)

% initialise
global settings
if isempty(settings), scr_init; end;

% check input arguments
if nargin==0
    errmsg='No sampling interval stated'; warning('ID:invalid_input', errmsg); return;
end;

td = varargin{1}(1);
% other variables

% duration
duration = 30;

if td > duration
    warning('ID:invalid_input', 'Time resolution is larger than duration of the function.'); return;
elseif td == 0
    warning('ID:invalid_input', 'Time resolution must be larger than 0.'); return;
end;


x = (0:td:duration-td)';

% ... do bf stuff

% orthogonalise
bs = spm_orth(bs);